#!/bin/bash

module load jdk64 

C=$2
M=$3
T=$4
H=/work/01721/smirarab/1kp/capstone/secondset

INPUT=$1.input.$T

CD=$H/genes/$1

cd $CD
mkdir logs

#if [ "$4" == "-res" ]; then 
#	rm -r tmp/$T.$1.removed.realigned checkpoint.$T.$1 sateout_$T.$1 logs/alg_std*.$T.$1
#fi

tmp=`mktemp -d`
$HOME/bin/runpasta.sh -d protein --aligned -i $CD/$INPUT --max-mem-mb $M --num-cpus $C --temporaries=$tmp -o pasta-$T -j pasta_$T.$1 1>$CD/logs/std.out.pasta.$T.$1 2>$CD/logs/std.err.pasta.$T.$1

if [ -s pasta_$T.$1.fasta ]; then
 echo "Done">.done.$T.pasta
fi 
