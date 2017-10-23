#!/bin/bash
#set -x
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
$WS_GLB_PUTIL=$DIR
$WS_GLB_PERL=$DIR

if [ ! $# == 3 ]; then  
  echo USAGE: $0 alignment_file output_file output_partition_file;
  exit 1;
fi

$WS_GLB_SH/simplifyfasta.sh $1 >$1.simp

python $WS_GLB_PUTIL/extract-codon.py $1.simp codon1st  1
python $WS_GLB_PUTIL/extract-codon.py $1.simp codon2nd  2

tmp=`mktemp "tmp-codon-XXXXXX"`

echo "codon1st
codon2nd" > $tmp

perl $WS_GLB_PERL/concatenate_alignments.pl -i $tmp -o $2 -p $3

rm codon1st codon2nd $tmp $1.simp
