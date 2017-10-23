#!/bin/bash

algfn=$4
f=genes/$1/$algfn
percent=$2
taxapercent=$3
out=$f.mask${percent}sites.mask${taxapercent}taxa.fasta

test $# == 4 || { echo  USAGE: gene site_percent taxa_percent file_name; exit 1;  }

m=`echo $( grep ">" $f|wc -l ) \* $percent / 100 |bc`
run_seqtools.py -infile $f -masksites $m -outfile $f.mask${percent}sites.fasta
echo From `simplifyfasta.sh $f|wc -L` sites in $f to `wc -L $f.mask${percent}sites.fasta` sites

m2=`echo $( cat $f.mask${percent}sites.fasta|wc -L ) \* $taxapercent / 100 |bc`
run_seqtools.py -infile $f.mask${percent}sites.fasta -filterfragments $m2 -outfile $out

echo went from `grep ">" $f|wc -l` to `grep ">" $out|wc -l` sequences
