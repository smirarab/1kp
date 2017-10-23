#!/usr/bin/env perl

# concatenate a set of alignments into a single concatenated alignment
# and output a charset partition list
# based on names of input set of alignments
#
# essentially reverses effect of PAUP charset breakup of an alignment
#
# NOTE - to get interesting results, taxa lists of input alignments should
# be overlapping!

# pick up global settings
#use FindBin qw($Bin);
use lib "$ENV{WS_HOME}/global/src/perl";
use setenv;
use framework;
# also make environment changes
setenv::setenv();

use Getopt::Std;
use Cwd;

# for sanity's sake
use strict;

# for hi res timing - from Li-San
#use Time::HiRes qw(gettimeofday);

# for temp files
use File::Temp qw/ tempfile tempdir /;

use constant PARTITIONS_LIST_ENTRY_PREFIX => "DNA, ";

# WARNING - using N can cause raw sequence estimator as well 
# as alignment SP-FN score calculator to fail!
# since N's aren't properly dropped for both of these, and N-run's
# depend on length of alignment from which taxon is missing

#use constant MISSING_TAXON_LETTER => "-";
use constant MISSING_TAXON_LETTER => "?";

sub outputConcatenatedAlignment {
    my $alignmentRefsMap = shift;
    my $combinedTaxaSetRef = shift;
    my $alignmentLengthsRef = shift;
    my $alignmentRefsKeys = shift;
    my $outputFilename = shift;

    open (OUT, ">$outputFilename");
    my $taxa;
    foreach $taxa (@$combinedTaxaSetRef) {
	my $sequence = "";
	my $alignmentRefsKey;
	foreach $alignmentRefsKey (@$alignmentRefsKeys) {
	    my $alignmentRef = $$alignmentRefsMap{$alignmentRefsKey};
	    if (defined($$alignmentRef{$taxa})) {
		$ sequence .= $$alignmentRef{$taxa};
	    }
	    else {
		# unsequenced taxa for this marker
		$sequence .= MISSING_TAXON_LETTER x $$alignmentLengthsRef{$alignmentRefsKey};
	    }
	}
	framework::filePrintPair($taxa, $sequence, *OUT);
    }
    close (OUT);
}

sub verifyAlignmentRowsSameLength {
    my $alignmentRef = shift;

    my @rows = values(%$alignmentRef);
    for (my $i = 0; $i < (scalar @rows) - 1; $i++) {
	if (length($rows[$i]) != length($rows[$i+1])) {
	    print "ERROR: " . length($rows[$i]) . " " . length($rows[$i+1]) . "\n";
#	    print "ERROR: " . $rows[$i] . "\n" . $rows[$i+1] . "\n";
	    return 0;
	}
    }

    return 1;
}

sub getCombinedTaxaSet {
    my $alignmentRefsMap = shift;

    my %taxaMap = ();

    my $alignmentRef;
    foreach $alignmentRef (values %$alignmentRefsMap) {
	my $taxa;
	foreach $taxa (keys %$alignmentRef) {
	    $taxaMap{$taxa} = 1;
	}
    }

    my @taxaSet = keys(%taxaMap);
    
    # also alphabetize it
    @taxaSet = sort {$a cmp $b} @taxaSet;

    return (\@taxaSet);
}

sub getAlignmentLengths {
    my $alignmentRefsMap = shift;

    my @keys = keys(%$alignmentRefsMap);
    my $key;

    my %lengths = ();

    foreach $key (@keys) {
	my $alignmentRef = $$alignmentRefsMap{$key};
	my @sequences = values(%$alignmentRef);
	$lengths{$key} = length($sequences[0]);

	# testing
#	print "length: |" . $lengths{$key} . "\n";
    }

    return (\%lengths);
}

sub getPartitionPrefix {
    my $alignmentFilename = shift;

    my @fields = split(/\./, $alignmentFilename);
    return (shift(@fields));
}

sub outputPartitionsList {
    my $alignmentLengthsRef = shift;
    my $alignmentRefsKeys = shift;
    my $outputPartitionsFilename = shift;

    my $startind = 1;

    open (OUT, ">$outputPartitionsFilename");
    my $alignmentRefsKey;
    foreach $alignmentRefsKey (@$alignmentRefsKeys) {
	my $length = $$alignmentLengthsRef{$alignmentRefsKey};
	my $endind = $startind + $length - 1;
	print OUT PARTITIONS_LIST_ENTRY_PREFIX . getPartitionPrefix($alignmentRefsKey) . " = " . $startind . "-" . $endind . "\n";
	$startind += $length;
    }
    close (OUT);
}

sub process {
    my $inputAlignmentsString = shift;
    my $outputAlignmentFilename = shift;
    my $outputPartitionsFilename = shift;

    ## split(/,/, $inputAlignmentsString);
    my @inputAlignmentFilenames = ();
    my $fh;
    open ($fh, $inputAlignmentsString);
    while (<$fh>) {
	my $line = $_;
	chomp ($line);
	$line = framework::trim($line);
	push (@inputAlignmentFilenames, $line);
    }
    close ($fh);

    # alphabetize it
    #@inputAlignmentFilenames = sort {$a cmp $b} @inputAlignmentFilenames;

    # need to map from original input filename to alignment proper
    my %inputAlignmentRefsMap = ();
    my $inputAlignmentFilename;
    foreach $inputAlignmentFilename (@inputAlignmentFilenames) {
	# whew - this forces upper case
	my $inputAlignmentRef = framework::readAlignment($inputAlignmentFilename, 0);
	# paranoid
	# verify that all rows in alignment are the same
	if (!verifyAlignmentRowsSameLength($inputAlignmentRef)) {
	    die "ERROR: not all rows are the same length for alignment $inputAlignmentFilename!\n";
	}
	$inputAlignmentRefsMap{$inputAlignmentFilename} = $inputAlignmentRef;
    }

    my $combinedTaxaSetRef = getCombinedTaxaSet(\%inputAlignmentRefsMap);
    my $alignmentLengthsRef = getAlignmentLengths(\%inputAlignmentRefsMap);

    # now just stitch it together
    # in order specified in @inputAlignmentFilenames
    outputConcatenatedAlignment(\%inputAlignmentRefsMap, $combinedTaxaSetRef, $alignmentLengthsRef, \@inputAlignmentFilenames, $outputAlignmentFilename);
    
    # finally output the partitions list
    outputPartitionsList($alignmentLengthsRef, \@inputAlignmentFilenames, $outputPartitionsFilename);
}


sub printUsage {
    print STDERR
	"Usage: perl concatenate_alignments.pl \n" .
	"       -i <text file with list of input alignments> REQUIRED \n" .
	"       -o <output concatenated alignment> REQUIRED \n" .
	"       -p <partition list, suitable for enabling RAxML partitioned analysis> REQUIRED \n"
;
    exit 1;
}

# output all stats to STATS file directly
sub main {
    # for now, just pass in 
    # raw sequences file (with path)
    getopt("iop");

    if (($Getopt::Std::opt_i eq "") ||
	($Getopt::Std::opt_o eq "") ||
	($Getopt::Std::opt_p eq "")) {	
	printUsage;
    }

    my $currdir = getcwd;

    $Getopt::Std::opt_i =~ s/CURRDIR\_MARKER/$currdir/g;
    $Getopt::Std::opt_o =~ s/CURRDIR\_MARKER/$currdir/g;
    $Getopt::Std::opt_p =~ s/CURRDIR\_MARKER/$currdir/g;

    print "Processing $Getopt::Std::opt_i...";

    # use $workdir instead of $Getopt::Std::opt_w
    process($Getopt::Std::opt_i,
	    $Getopt::Std::opt_o,
	    $Getopt::Std::opt_p
	    );

    print "done.\n";
}

main;

