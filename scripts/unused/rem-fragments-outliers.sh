#!/bin/bash

set -x

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

x=$1
t=6

torem=`sed -e "s/-//g" $x |awk '/^>/{print $1} /^$/ {print 0} /^[^>]/{print length($1)}'|tr '\n' ' '|sed -e "s/>/\n/g"|sed -e "s/ *$//g"|tail -n+2 >len.s; echo 'd=read.csv("len.s",header=F,sep=" "); write(as.vector(d[d$V2<median(d$V2)-'$t'*mad(d$V2),1]),file="toremv");median(d$V2);mad(d$V2);median(d$V2)-'$t'*mad(d$V2);'| R --no-save 1>/dev/null; cat toremv|tr '\n' '|'`nothing

echo removing `wc -l toremv` taxa

#echo $torem

tmp=`mktemp`
remove_empty_sequences_from_fasta.sh $x > $tmp

if [ "$torem" == "|nothing" ]; then
  mv $tmp ${x/%.fasta/-mask6mad.fasta}
else
  remove_taxon_from_fasta.sh $torem $tmp > ${x/%.fasta/-mask6mad.fasta}
  rm $tmp
fi
