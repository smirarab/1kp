########
#
#  Pipeline that creates the supermatrix trees, assumes that
#  input directory has the following structure:
#  <input_directory>/initial.fasta and <input_directory>/initial.partition, and the script
#  is run from the supermatrix script directory
#
#  Run using: perl create_supermatrix_trees.pl <input_directory> <model_type> <threads> <cores>, 
#      where input_directory is where the initial.fasta and initial.partition file is
#            model_type is DNA or PROT, and 
#            threads is the number of threads to use
#            cores is the number of cores for the MPI run
#
#  Assumes that this code is running on a cluster with MPI support.
#
#  Will perform the following steps:
#
#  1. Create bootstrap alignments
#  2. Convert bootstrap alignments from phylip to fasta format
#  3. Build starting trees from initial alignment and bootstrap alignments, using either
#     Fasttree or MP trees
#  4. Convert alignments into ExaML binary format
#  5. Run ExaML on the input alignment using the starting tree
#  
#  
########

use File::Spec::Functions qw(rel2abs);
use File::Basename;
use strict;
use File::Path;
use Data::Dumper;

my $input_directory=$ARGV[0];
my $model_type=$ARGV[1];
my $threads=$ARGV[2];
my $cores=$ARGV[3];
run_pipeline();

sub run_pipeline {
  my $raxml_model = "PROTCATJTT";
  my $fasttree_model = "";
  if ($model_type eq "DNA") {
    $raxml_model = "GTRGAMMA";
    $fasttree_model = "-gtr -nt";
  } 
  #Create initial bootstrap alignments if they don't exist
  if (not -e "$input_directory/initial.fasta.BS99") {
    `raxmlHPC-PTHREADS-SSE3 -T $threads -s $input_directory/initial.fasta -p 1111 -m $raxml_model -n alignment -f j -b 1111 -N 100 -q $input_directory/initial.partition`;
  }

  #Convert bootstrap alignments from PHYLIP to FASTA format, if it doesn't exist
  if (not -e "$input_directory/initial.fasta.BS99.fixed") {
    foreach my $idx (0..99) {
      phylip_to_fasta("$input_directory/initial.fasta.BS$idx", "$input_directory/initial.fasta.BS$idx.fixed");
    }
  }
  
  #Create phylip file from fasta alignment
  if (not -e "$input_directory/initial.phylip") {
    my %alignment = %{read_fasta_file("$input_directory/initial.fasta")};
    my @names = sort keys %alignment;
    my $len = length($alignment{$names[0]});
    my $taxa = scalar @names;
    open(OUTPUT, ">$input_directory/initial.phylip");
    print OUTPUT "$taxa $len\n";
    foreach my $key (@names) {
      print OUTPUT "$key $alignment{$key}\n";
    }
    close(OUTPUT);
  }
  
  #Create ExaML binary alignment for supermatrix and its bootstrap replicates
  if (not -e "$input_directory/initial.binary") {
    `parse-examl -s $input_directory/initial.phylip -q $input_directory/initial.partition -m $model_type -n initial`;
  }
  if (not -e "$input_directory/BS99.binary") {
    foreach my $idx (0..99) {
      if (not -e "$input_directory/BS$idx.binary") {
        `parse-examl -s $input_directory/initial.fasta.BS$idx -q $input_directory/initial.partition.reduced -m $model_type -n BS$idx`;
      }
    }
  }
  
  #Create 10 MP trees and 1 ML FastTree tree for the initial alignment
  if (not -e "$input_directory/initial.fasttree") {
    `fasttree -out $input_directory/initial.fasttree -log $input_directory/initial.fasttree.log logfile $fasttree_model $input_directory/initial.fasta`;    
  }
  foreach my $idx (0..9) {    
    if (not -e "$input_directory/RAxML_parsimonyTree.PAR$idx") {
      my $seed = 1111*$idx+1;
      `raxmlHPC-PTHREADS-SSE3 -y -p $seed -m $raxml_model -s $input_directory/initial.fasta -q $input_directory/initial.partition -n PAR$idx`;
    }      
  }
      
  #Create FastTree tree and MP tree for each bootstrap replicate
  foreach my $idx (0..99) {
    if (not -e "$input_directory/initial.fasttree.BS$idx") {
      `fasttree -out $input_directory/initial.fasttree.BS$idx -log $input_directory/initial.fasttree.BS$idx.log logfile $fasttree_model $input_directory/initial.fasta.BS$idx.fixed`;    
    }
    if (not -e "$input_directory/RAxML_parsimonyTree.PAR.BS$idx") {
      `raxmlHPC-PTHREADS-SSE3 -y -p 1111 -m $raxml_model -s $input_directory/initial.fasta.BS$idx -q $input_directory/initial.partition.reduced -n PAR.BS$idx`;    
    }
  }
  
  #Run ExaML on each starting tree for the initial supertree
  if (not -e "$input_directory/ExaML_result.ML.FASTTREE") {
    `ibrun -o 0 -n $cores examl-OMP -t $input_directory/initial.fasttree -m GAMMA -s $input_directory/initial.binary -n ML.FASTTREE`;    
  }  
  foreach my $idx (0..9) {    
    if (not -e "$input_directory/RAxML_parsimonyTree.PAR$idx") {
      `ibrun -o 0 -n $cores examl-OMP -t $input_directory/RAxML_parsimonyTree.PAR$idx -m GAMMA -s $input_directory/initial.binary -n ML.$idx`;    
    }
  }    
  
  #Run ExaML on each starting tree for bootstrap supermatrices  
  foreach my $idx (0..99) {
    if (not -e "$input_directory/ExaML_result.FASTTREE.BS$idx") {
      `ibrun -o 0 -n $cores examl-OMP -t $input_directory/initial.fasttree.BS$idx -m GAMMA -s $input_directory/BS$idx.binary -n FASTTREE.BS$idx`;    
    }  
    if (not -e "$input_directory/ExaML_result.MP.BS$idx") {
      `ibrun -o 0 -n $cores examl-OMP -t $input_directory/RAxML_parsimonyTree.PAR$idx -m GAMMA -s $input_directory/BS$idx.binary -n MP.BS$idx`;
    }    
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

sub phylip_to_fasta {
  my $phylip_file = $_[0];
  my $fasta_file = $_[1];  

  open(INPUT, "<$phylip_file");
  open(OUTPUT,">$fasta_file");
  my $line = <INPUT>;
  while (defined ($line = <INPUT>)) {
    my @results = split(/\s+/, $line);
    print OUTPUT ">$results[0]\n$results[1]\n";      
  }  
  close(INPUT);
  close(OUTPUT);
}