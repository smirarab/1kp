########
#
#  Pipeline that creates the partitioned FAA supermatrix, assumes that
#  input directory has the following structure:
#  <input_directory>/<gene_name>/<alignment_filename_prefix>.fasta, 
#  <input_directory>/<gene_name>/<model_filename> containing "Best Model : <PROTEIN_MODEL>" 
#  and the script
#  is run from the supermatrix script directory
#
#  Run using: perl create_supermatrix_faa.pl <input_directory> <alignment_filename_prefix> <model_filename>
#
#  Will perform the following steps:
#
#  1. Read the <model_filename> file
#  2. Create partitions based upon the best model
#  3. Create an alignment and a partition file named <alignment_filename_prefix>.fasta and 
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
my $model_filename=$ARGV[2];

run_pipeline();

sub run_pipeline {
  my @dirs = <$input_directory/*>;
  if (not -e "$input_directory/$alignment_file_name_prefix.fasta") {    
    my %species = ();
    my %partitions = ();        
    for my $dir (@dirs) {
      if (not -e "$dir/$model_filename" or not -e "$dir/$alignment_file_name_prefix.fasta") {
        next;
      }  
      $dir =~ m/.*\/(.*)/;
      my $gene = $1;
      my $model = trim(`awk '{print \$4}' $dir/$model_filename`);
            
      my %aln = %{read_fasta_file("$dir/$alignment_file_name_prefix.fasta")};
      $partitions{$model}->{"$gene"} =  \%aln;
      for my $s (keys %{$partitions{$model}->{"$gene"}}) {
        $species{$s} = "";
      }
    }
    #Join partitions together into single alignment
    my $curr = 0;
    open(PART, ">$input_directory/$alignment_file_name_prefix.partition");
    my $part = 0;
    for my $model (sort keys %partitions) {
      my $len = 0;
      for my $gene (keys %{$partitions{$model}}) {
        my @names = keys %{$partitions{$model}->{$gene}};
        $len+=length($partitions{$model}->{$gene}->{$names[0]});
        my $blanks = '-' x length($partitions{$model}->{$gene}->{$names[0]});
        for my $s (keys %species) {
          if (defined $partitions{$model}->{$gene}->{$s}) {
            $species{$s}.=$partitions{$model}->{$gene}->{$s};
          } else {
            $species{$s}.=$blanks;
          }
        }      
      }
      my $end = $curr+$len;      
      $curr+=1;
      print PART "$model, combined_$part=$curr-$end\n";
      $part++;
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
