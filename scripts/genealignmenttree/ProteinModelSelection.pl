#!/usr/bin/env perl

#print $ARGV[0]." ".$ARGV[1]." ".$#ARGV."\n";
use File::Basename;
use Scalar::Util qw(looks_like_number);

my $dir = dirname(__FILE__);

$raxmlHPC = $dir."/raxmlHPC";

if($#ARGV < 0 || $#ARGV > 1)
  {
    print "ERROR: usage: \"perl RAxML_AA_Test.pl alignmentFileName [modelFileName] \"\n";
    exit;
  }

$alignmentName = $ARGV[0];

$UNLIKELY = -1.0E300;

sub getLH
  {
    my $fileID = $_[0];  
    open(CPF, $fileID);
    my @lines = <CPF>;	
    close(CPF);	
    my $numIT = @lines;   	
    my $lastLH = pop(@lines);  
    my $k = index($lastLH, '-');   
    my $LH = substr($lastLH, $k);     
    return $LH;
  }

sub getTIME
  {
    my $fileID = $_[0];  
    open(CPF, $fileID);
    my @lines = <CPF>;	
    close(CPF);	
    my $numIT = @lines;   	
    my $lastLH = pop(@lines);  
    my $k = index($lastLH, '-');   
    my $TIME = substr($lastLH, 0, $k-1);     
    return $TIME;
  }


#@AA_Models = ("DAYHOFF", "DCMUT", "JTT", "MTREV", "WAG", "RTREV", "CPREV", "VT", "BLOSUM62", "MTMAM", 
#	      "DAYHOFFF", "DCMUTF", "JTTF", "MTREVF", "WAGF", "RTREVF", "CPREVF", "VTF", "BLOSUM62F", "MTMAMF");

#@AA_Models = ("LG", "MTART",  "PMB", "JTTDCMUT",  "DAYHOFF", "DCMUT", "JTT", "MTREV", "WAG", "RTREV", "CPREV", "VT", "BLOSUM62", "MTMAM", 
#	      "LGF", "MTARTF",  "PMBF", "JTTDCMUTF","DAYHOFFF", "DCMUTF", "JTTF", "MTREVF", "WAGF", "RTREVF", "CPREVF", "VTF", "BLOSUM62F", "MTMAMF");

@AA_Models = ("LG",  "JTTDCMUT",  "DAYHOFF",  "JTT",  "WAG",  "CPREV", "VT", "BLOSUM62",  
	      "LGF", "JTTDCMUTF","DAYHOFFF",  "JTTF",  "WAGF", "CPREVF", "VTF", "BLOSUM62F");

my $seed = int(rand(1000));

if($#ARGV == 1)
  {
    print "Splitting up multi-gene alignment\n";
    $partition =  $ARGV[1];
    $cmd = $raxmlHPC." -f s -m PROTCATJTT -p ".$seed." -s ".$alignmentName." -q ".$partition." -n SPLIT_".$alignmentName." \> SPLIT_".$alignmentName."_out";
    system($cmd);
    $count = 0;
    while(open(CPF, $alignmentName.".GENE.".$count))
      {
	close CPF;
	print "PARTITION: ".$count."\n";
	#print "perl ProteinModelSelection.pl ".$alignmentName.".GENE.".$count;
	system("perl ProteinModelSelection.pl ".$alignmentName.".GENE.".$count);
	$count = $count + 1;
      }
  }
else
  {
    #print "Determining AA model data\n";
    #print "Computing randomized stepwise addition starting tree number :".$i."\n";
    $cmd = $raxmlHPC." -y -p ".$seed." -m PROTCATJTT -s ".$alignmentName." -n ST_".$alignmentName." \> ST_".$alignmentName."_out";
    system($cmd);
    
    $numberOfModels = @AA_Models;
    
    for($i = 0; $i < $numberOfModels; $i++)
      {
	$aa = "PROTGAMMA".$AA_Models[$i];
	$cmd = $raxmlHPC." -p ".$seed." -f e -m ".$aa." -s ".$alignmentName." -t RAxML_parsimonyTree.ST_".$alignmentName." -n ".$AA_Models[$i]."_".$alignmentName."_EVAL \> ".$AA_Models[$i]."_".$alignmentName."_EVAL.out\n";  
	#print($cmd);
	system($cmd);
      }
    
   
    for($i = 0; $i < $numberOfModels; $i++)
      {
	$logFileName = "RAxML_log.".$AA_Models[$i]."_".$alignmentName."_EVAL";
	#print $logFileName."\n";
	$lh[$i] = getLH($logFileName);
      }
    
    $bestLH = $UNLIKELY;
    $bestI = -1;
    
    for($i = 0; $i < $numberOfModels; $i++)
      {
	#print "Model: ".$AA_Models[$i]." LH: ". $lh[$i]." best: ".$bestI."\n";
        if (looks_like_number($lh[$i]))
	 { 
          if ( $lh[$i] > $bestLH )
	   {
	     $bestLH = $lh[$i];
	     $bestI = $i;
	   }
         } else 
         {
           exit 1;
         }
      }
    
    if ( $bestI != -1 ) {
	print "Best Model : ".$AA_Models[$bestI]."\n";
	$bestModel = $AA_Models[$bestI];
    } else 
    {
        exit 1;
    }
 
  }
    
