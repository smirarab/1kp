#/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#for x in `ls genes`; do $DIR/mask-for-gt.sh $x 10 10 FNA2AA-upp-masked-c12.fasta|tee -a genes/$x/mask-gt.log; done
for x in `ls genes`; do $DIR/mask-for-gt.sh $x 10 33 FNA2AA-upp-masked-c12.fasta|tee -a genes/$x/mask-gt.log; done
#for x in `ls genes`; do $DIR/mask-for-gt.sh $x 10 10 FAA-upp-masked.fasta|tee -a genes/$x/mask-gt.log; done
for x in `ls genes`; do $DIR/mask-for-gt.sh $x 10 33 FAA-upp-masked.fasta|tee -a genes/$x/mask-gt.log;  done
