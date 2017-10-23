#!/bin/bash

x=$1
tp=$2
sp=10


if [ -s genes/$x/FNA2AA-upp-masked-c12.fasta.mask${sp}sites.mask${tp}taxa.tre ]; then
 echo $x FNA2AA-c12 is done;
else
 ./mask-for-gt.sh $x $sp $tp FNA2AA-upp-masked-c12.fasta
 /work/01721/smirarab/1kp/capstone/secondset/fasttree -nt -gtr -gamma genes/$x/FNA2AA-upp-masked-c12.fasta.mask${sp}sites.mask${tp}taxa.fasta > genes/$x/FNA2AA-upp-masked-c12.fasta.mask${sp}sites.mask${tp}taxa.tre
fi

if [ -s genes/$x/FAA-upp-masked.fasta.mask${sp}sites.mask${tp}taxa.tre ]; then
 echo $x FAA is done;
else
 ./mask-for-gt.sh $x $sp $tp FAA-upp-masked.fasta
 /work/01721/smirarab/1kp/capstone/secondset/fasttree  -gamma genes/$x/FAA-upp-masked.fasta.mask${sp}sites.mask${tp}taxa.fasta > genes/$x/FAA-upp-masked.fasta.mask${sp}sites.mask${tp}taxa.tre
fi
