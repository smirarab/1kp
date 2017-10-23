#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

test $# == 10 || exit 1

ALGNAME=$1
DT=$2
CPUS=$3
ID=$4
label=$5
bestN=$6
rep=$7
st=$8 # Start tree, use fasttree for FastTree or anything else for default
rapid=$9 # use rapid for rapid bootstrapping or anything else for default
H=${10}
OMP_NUM_THREADS=$CPUS

S=raxml
in=$DT-$ALGNAME
if test "$rapid" == "rapid"; then boot="-x $RANDOM"; else boot="-b $RANDOM"; fi
s="-p $RANDOM"
dirn=raxmlboot.$in.$label

cd $H/genes/$ID/
mkdir logs

$DIR/convert_to_phylip.sh $in.fasta $in.phylip
test "`head -n 1 $in.phylip`" == "0 0" && exit 1

if [ "$DT" == "FAA" ]; then
  if [ -s bestModel.$ALGNAME ]; then
    echo bestModel.$ALGNAME exists
  else
    rm -r modelselection
    mkdir modelselection
    cd modelselection
    ln -s ../$in.phylip .
    perl $DIR/ProteinModelSelection.pl $in.phylip > ../bestModel.$ALGNAME
    cd ..
    test -s bestModel.$ALGNAME && ( tar cfj modelselection-logs.tar.bz --remove-files modelselection/ )
  fi
  if [ -s bestModel.$ALGNAME ]; then
     model=PROTGAMMA`sed -e "s/.* //g" bestModel.$ALGNAME`
  else
     echo model selection failed. check the log file
     exit 1
  fi
  ftmodel=""
else
  model=GTRGAMMA
  ftmodel="-gtr -nt"
fi

mkdir $dirn
cd $dirn

#Figure out if main ML has already finished
donebs=`grep "Overall execution time" RAxML_info.best`
#Infer ML if not done yet
if [ "$donebs" == "" ]; then
 rename "back" "back.`date +%s`"  RAxML*best.back
 rename "best" "best.back.`date +%s`" *best
 # Estimate the RAxML best tree
 if [ "$st" == "fasttree" ]; then
   test -s fasttree.tre || { $DIR/fasttree $ftmodel ../$in.phylip > fasttree.tre 2> ft.log; }
   test $? == 0 || { cat ft.log; exit 1; } 
   python $DIR/arb_resolve_polytomies.py fasttree.tre
   startingtree="-t fasttree.tre.resolved"
 else 
   startingtree=""
 fi
 if [ $CPUS -gt 1 ]; then
  $DIR/raxmlHPC-PTHREADS -m $model -T $CPUS -n best -s ../$in.phylip $s -N $bestN $startingtree &> ../logs/best_std.errout.$in
 else
  $DIR/raxmlHPC -m $model -n best -s ../$in.phylip $s -N $bestN $startingtree &> ../logs/best_std.errout.$in
 fi
fi
 

if [ $rep == 0 ]; then
   mv logs-best.tar.bz logs-best.tar.bz.back.$RANDOM
   tar cvfj logs-best.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.* RAxML_*back*  RAxML_result.best.*
   if [ -s RAxML_bestTree.best ]; then
    cd ..
    echo "Done">.done.best.$dirn
    exit 0
   fi
   exit 1
fi

#Figure out if bootstrapping has already finished
#Bootstrap if not done yet
donebs=`grep "Overall Time" RAxML_info.ml`
if [  `cat RAxML_bootstrap.all|wc -l` == $rep ]; then
 donebs="done"
fi

if [ -n "$donebs" ] && [  `cat RAxML_bootstrap.all|wc -l` -ne $rep ];  then
 mv RAxML_bootstrap.all RAxML_bootstrap.ml.`cat RAxML_bootstrap.all|wc -l`
 donebs=""
fi


if [ "$donebs" == "" ]; then
  crep=$rep
  # if bootstrapping is partially done, resume from where it was left
  if [ `ls RAxML_bootstrap.ml*|wc -l` -ne 0 ]; then
    l=`cat RAxML_bootstrap.ml*|wc -l|sed -e "s/ .*//g"`
    crep=`expr $rep - $l`
  fi
  if [ -s RAxML_bootstrap.ml ]; then
    cp RAxML_bootstrap.ml RAxML_bootstrap.ml.$l
  fi
  rename "ml" "back.ml" *ml
  mv RAxML_info.ml RAxML_info.ml.`date +%s`;
  if [ $crep -gt 0 ]; then
   if [ $CPUS -gt 1 ]; then
      $DIR/raxmlHPC-PTHREADS -m $model -n ml -s ../$in.phylip -N $crep $boot -T $CPUS  $s &> ../logs/ml_std.errout.$in
   else
      $DIR/raxmlHPC -m $model -n ml -s ../$in.phylip -N $crep $boot $s &> ../logs/ml_std.errout.$in
   fi
  fi
fi

dc=`cat RAxML_bootstrap.all|wc -l`
if [ ! -s RAxML_bootstrap.all ] || [ $dc -ne $rep ]; then
  cat  RAxML_bootstrap.ml* > tmp;
  test `cat tmp|wc -l` -ge $dc &&  mv tmp RAxML_bootstrap.all;
fi

 
if [ ! `cat RAxML_bootstrap.all|wc -l` -eq $rep ] ; then
 echo `pwd`>>$H/notfinishedproperly
 exit 1
elif [ ! -s RAxML_bipartitions.final ]; then
 #Finalize 
 rename "final" "final.back" *final
 $DIR/raxmlHPC -f b -m $model -n final -z RAxML_bootstrap.all -t RAxML_bestTree.best

 if [ -s RAxML_bipartitions.final ]; then
   mv logs.tar.bz logs.tar.bz.back.$RANDOM
   tar cvfj logs.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.* RAxML_*back* RAxML_bootstrap.ml RAxML_result.best.* RAxML_bootstrap.ml* RAxML_info.final
   cd ..
   echo "Done">.done.$dirn
 fi
fi

