#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Find median sequence length for the genomes (i.e., sequences with a _ in their name)
seq=`grep "_" $1|wc -l|sed -e "s:$: / 2:g"|bc`
median=`$DIR/simplifyfasta.sh $1| grep -A1 "_" |grep -v ">"|grep -v "\-\-"|awk '{print length($0)}'|sort -n|head -n $seq|tail -n1`

echo $median
