#!/bin/bash

x=$1;

mask=`cat $x/upp/FAA_insertion_columns.txt|tr ',' '\n'|sed -e "s/-/ /g"|awk '{if ($1>-1) print $1*3"-"$2*3+2}'|tr '\n' ','|sed -e "s/,$//g";`;

if [ "$mask" != "" ]; then
 trimal -selectcols { $mask } -in $x/FNA2AA-upp-unmasked.fasta -out $x/FNA2AA-upp-masked.fasta
else
 ln -s FNA2AA-upp-unmasked.fasta $x/FNA2AA-upp-masked.fasta
fi
