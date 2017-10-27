########
#
#  Pipeline that creates the partitioned FNA2AA supermatrix, assumes that
#  input directory has the following structure:
#  <input_directory>/<gene_name>/<alignment_filename_prefix>.fasta, and the script
#  is run from the supermatrix script directory
#
#  Run using: perl create_supermatrix.pl <input_directory> <alignment_filename_prefix>
#
#  Will perform the following steps:
#
#  1. Create a directory named <alignment_filename_prefix> in the <gene_name> folder
#  2. Split the <alignment_filename_prefix>.fasta into codon.1.fasta and codon.2.fasta
#  3. Run RAxML on each codon.<X>.fasta file (assumes that RAxML binary is available on path)
#  4. Read the RAxML_info file and put it into a file in <input_directory>/<alignment_filename_prefix>.rates.csv
#  5. Run the helper script pca_cluster.r to cluster codon positions into partitions
#  6. Create an alignment and a partition file named <alignment_filename_prefix>.fasta and 
#     <alignment_filename_prefix>.partition in the <input_directory> folder
#  
########

use File::Spec::Functions qw(rel2abs);
use File::Basename;
use strict;
use File::Path;
use Data::Dumper;

my $input_directory=$ARGV[0];
my $alignment_file_name_prefix=$ARGV[1];
run_pipeline();

sub run_pipeline {
  my @dirs = <$input_directory/*>;
  for my $dir (@dirs) {
    next;
    if (not -e "$dir/$alignment_file_name_prefix.fasta") {
      next;
    }
    #1. Create directory
    if (not -e "$dir/$alignment_file_name_prefix") {
      `mkdir $dir/$alignment_file_name_prefix`;      
    }
    chdir("$dir/$alignment_file_name_prefix");
    #2. Split alignment
    if (not -e "codon.1.fasta") {
      split_out_by_codon("$dir/$alignment_file_name_prefix.fasta", "codon");
    }
    #3. Estimate rate parameters
    for my $codon (1,2) {
      if (not -e "RAxML_info.$codon") {
        `raxmlHPC-PTHREADS-SSE3 -T 4 -s codon.$codon.fasta -n codon_$codon -m GTRGAMMA -p 1111`
      }
    }
  }
  
  #4. Read rate parameters and create rate parameter file for clustering
  if (not -e "$input_directory/$alignment_file_name_prefix.rates.csv") {
    open(GTR, ">$input_directory/$alignment_file_name_prefix.rates.csv");
    print GTR "gene,codon,alpha,ac,ag,at,cg,ct,gt\n";    
    for my $dir (@dirs) {
      if (not -e "$dir/$alignment_file_name_prefix.fasta") {
        continue;
      }  
      $dir =~ m/.*\/(.*)/;
      my $gene = $1;
      for my $codon ('1','2') {
        if (-e "$dir/RAxML_info.codon_$codon") {
          my $rates = Phylo::read_raxml_info_rates("$dir/RAxML_info.codon_$codon");
          local $" = ",";
          print GTR "$gene,$codon,@{$rates}\n";
        } 
      }
    }
    close(GTR);
  }
  
  #5. Cluster the results using R
  if (not -e "$input_directory/$alignment_file_name_prefix.partition.csv") {
    `Rscript pca_cluster.r $input_directory/$alignment_file_name_prefix.rates.csv $input_directory/$alignment_file_name_prefix.partition.csv`;    
  }
  
  #6. Create partition and supermatrix from clustering results
  if (not -e "$input_directory/$alignment_file_name_prefix.fasta") {    
    my %species = ();
    my %partitions = ();    
    my %map = ();
    open(INPUT, "$input_directory/$alignment_file_name_prefix.partition.csv");
    my $line = <INPUT>;
    while (my $line = <INPUT>) {
      my @res = split(/,/, trim($line));
      $map{$res[0]}->{$res[1]}=$res[2];
    }
    close(INPUT);    
    
    for my $dir (@dirs) {
      if (not -e "$dir/$alignment_file_name_prefix/codon.1.fasta") {
        next;
      }            
      $dir =~ m/.*\/(.*)/;
      my $gene = $1;
      for my $codon ("1", "2") {
        my %codon_aln = %{read_fasta_file("$dir/$alignment_file_name_prefix/codon.$codon.fasta")};
        for my $s (keys %codon_aln) {
          $species{$s} = "";
        }
        $partitions{$map{$gene}->{$codon}}->{"$gene\_$codon"} =  \%codon_aln;
      }
    }
    #Join partitions together into single alignment
    my $curr = 0;
    open(PART, ">$input_directory/$alignment_file_name_prefix.partition");
    for my $part (sort keys %partitions) {
      my $len = 0;
      for my $codon (keys %{$partitions{$part}}) {
        my @names = keys %{$partitions{$part}->{$codon}};
        $len+=length($partitions{$part}->{$codon}->{$names[0]});
        my $blanks = '-' x length($partitions{$part}->{$codon}->{$names[0]});
        for my $s (keys %species) {
          if (defined $partitions{$part}->{$codon}->{$s}) {
            $species{$s}.=$partitions{$part}->{$codon}->{$s};
          } else {
            $species{$s}.=$blanks;
          }
        }      
      }
      my $end = $curr+$len;      
      $curr+=1;
      print PART "DNA, combined_$part=$curr-$end\n";
      $curr=$end;
    }
    close(PART);
    write_alignment(\%species, "$input_directory/$alignment_file_name_prefix.fasta");
  }
}

sub read_fasta_file {
  my $input_file = $_[0];
  my $verify = $_[1];
  my %name_map = ();
  
  if (not defined $verify) {
    $verify = 1;
  }
  
  if (not -e $input_file) {
    print "$input_file does not exist!\n";
    exit;
  }
  open(FILE, "<$input_file");  
  my $line = "";
  $line = <FILE>;
  my $length = -1;  
  while (defined $line and $line !~ />([^\n\r\f]*)/) {
    $line = <FILE>;
  }
  while (defined $line and $line =~ />([^\n\r\f]*)/) {
    my $sequence = "";
    my $name = $1;
    $line = <FILE>;    
    while (defined $line and not $line =~ />([^\n\r\f]*)/) {
      $line =~ s/\s//g;
      $sequence = $sequence . trim($line);
      $line = <FILE>;
    }
    if ($length == -1 and $verify) {
      $length = length($sequence);
    } else {
      if ($length != length($sequence) and $verify) {
        print "Error in sequence length $name \n";
        return "Error in sequence length $name\n";
      }
    }
    if (length(trim($sequence)) == 0 and $verify) {
      print "Error empty alignment\n";
      return "Error empty alignment\n";
    
    }         
    if (not $sequence =~ /[^-?]/ and $verify) {      
      print "Error all indel characters $name\n";
      return "Error all indel characters $name\n";      
    }
    $name_map{$name} = $sequence;
  }
  close(FILE);
  return \%name_map;
}

sub read_raxml_info_rates {
  my $input_file = $_[0];
  my $line = trim(`grep "alpha\\[0\\]" $input_file | head -n1`."");
  if ($line eq "") {
    return undef;
  }
  $line =~ m/alpha\[0\]: (\d+\.\d+) rates\[0\] ac ag at cg ct gt: (\d+\.\d+) (\d+\.\d+) (\d+\.\d+) (\d+\.\d+) (\d+\.\d+) (\d+\.\d+)/;
  my @rates = ($1, $2, $3, $4, $5, $6, $7);
  return \@rates;
}

sub split_out_by_codon {
  my $input_file = $_[0];
  my $output_prefix = $_[1];
  
  my %sequences = %{read_fasta_file($input_file,0)};
  my @positions = ({},{},{});
  local $" = "";
  foreach my $key (keys %sequences) {
    my @results = split(//,$sequences{$key});
    my @codon_1 = map {$results[$_ * 3]} (0.. (scalar @results / 3)-1);
    my @codon_2 = map {$results[$_ * 3 + 1]} (0.. (scalar @results / 3)-1);
    my @codon_3 = map {$results[$_ * 3 + 2]} (0.. (scalar @results / 3)-1);
    $positions[0]->{$key} = "@codon_1";
    $positions[1]->{$key} = "@codon_2";
    $positions[2]->{$key} = "@codon_3";
  }
  foreach my $idx (1..3) {
    write_alignment($positions[$idx-1], "$output_prefix.$idx.fasta");
  }
}

sub trim {
  my $string = $_[0];
  if (not defined($string)) {
      return undef;
  }
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

sub write_alignment {
  my %aln = %{$_[0]};
  my $output_file = $_[1];
    
  open(OUTPUT, ">$output_file");
  foreach my $key (sort keys %aln) {
    print OUTPUT ">$key\n$aln{$key}\n";
  }
  close(OUTPUT);
}
