#!/bin/bash

med=3

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

$DIR/remove-long-branch.sh FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa rapid $med
$DIR/remove-long-branch.sh FAA-upp-masked.fasta.mask10site rapid $med

paste <( cat filter-lb-$med-raxmlboot.FAA-upp-masked.fasta.mask10sites.mask33taxa.rapid |tr  '\n' ';'|tr ':' '\n'|sed -e "s/;;.*$/;/g"|sed -e "s/[^;]*;//"|sed -e "s/ [^;]*;/|/g"|sed -e "s/|$//"|tail -n+2 )  <( cat filter-lb-$med-raxmlboot.FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa.rapid |tr  '\n' ';'|tr ':' '\n'|sed -e "s/;;.*$/;/g"|sed -e "s/[^;]*;//"|sed -e "s/ [^;]*;/|/g"|sed -e "s/|$//"|tail -n+2 ) <( ls genes/*/*input*FAA ) | sed -e "s/\t/|/"  |sed -e "s/\t/,/g" |xargs -n1 echo remove_taxon_from_fasta.sh|sed -e 's/ / "/g' -e 's/,/" /g'| sed -e 's/"|/"/g' -e 's/|"/"/g' | grep -v '""'| awk '{print $0, "> ",$3".filterbln-'$med'"}' |tee rem-both-faa-$med.sh
bash rem-both-faa-$med.sh
for x in `ls genes`; do ln -s $x.input.FAA genes/$x/$x.input.FAA.filterbln-$med; done

paste <( cat filter-lb-$med-raxmlboot.FAA-upp-masked.fasta.mask10sites.mask33taxa.rapid |tr  '\n' ';'|tr ':' '\n'|sed -e "s/;;.*$/;/g"|sed -e "s/[^;]*;//"|sed -e "s/ [^;]*;/|/g"|sed -e "s/|$//"|tail -n+2 )  <( cat filter-lb-$med-raxmlboot.FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa.rapid |tr  '\n' ';'|tr ':' '\n'|sed -e "s/;;.*$/;/g"|sed -e "s/[^;]*;//"|sed -e "s/ [^;]*;/|/g"|sed -e "s/|$//"|tail -n+2 ) <( ls genes/*/*input*FNA ) | sed -e "s/\t/|/"  |sed -e "s/\t/,/g" |xargs -n1 echo remove_taxon_from_fasta.sh|sed -e 's/ / "/g' -e 's/,/" /g'| sed -e 's/"|/"/g' -e 's/|"/"/g' | grep -v '""'| awk '{print $0, "> ",$3".filterbln-'$med'"}' |tee rem-both-fna-$med.sh
bash rem-both-fna-$med.sh
for x in `ls genes`; do ln -s $x.input.FNA genes/$x/$x.input.FNA.filterbln-$med; done


mv genes genes-before-lb-filtering; mkdir genes; 

for x in `ls genes-before-lb-filtering`; do mkdir genes/$x; cp -H genes-before-lb-filtering/$x/$x.input.FNA.filterbln-$med genes/$x/$x.input.FNA; cp -H genes-before-lb-filtering/$x/$x.input.FAA.filterbln-$med genes/$x/$x.input.FAA; done
