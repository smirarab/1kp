#!/bin/bash

set -x

module load python

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
H=$WORK/1kp/capstone/secondset

test $# == 9 || exit 1

ALGNAME=$1
DT=$2
CPUS=$3
ID=$4
label=$5
bestN=$6
rep=$7
st=$8 # Start tree, use fasttree for FastTree or anything else for default
rapid=$9 # use rapid for rapid bootstrapping or anything else for default
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
 rm RAxML*best.back
 rename "best" "best.back" *best
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
if [ "`cat RAxML_bootstrap.all|wc -l`" -ne "$rep" ]; then

  crep=$rep
  # if bootstrapping is partially done, resume from where it was left
  if [ -s RAxML_bootstrap.all ]; then
    l=`cat RAxML_bootstrap.all|wc -l|sed -e "s/ .*//g"`
    crep=`expr $rep - $l`
    test -s RAxML_info.BS.upto.$l || mv RAxML_info.BS RAxML_info.BS.upto.$l
    test -s bootstrap-files.tar.gz || gzip bootstrap-files.tar
    test -s bootstrap-files.tar.upto.$l.gz || { mv bootstrap-files.tar.gz bootstrap-files.tar.upto.$l.gz; }
  fi
  rm RAxML_info.BS
  
  rm fast*.BS* RAxML*.ml.BS* 

  $DIR/raxmlHPC -f j -s ../$in.phylip -n BS -m GTRCAT $boot -N $crep
  mv ../$in.phylip.BS* .
  tar cfj bootstrap-reps.tbz --remove-files $in.phylip.BS*
 
  for bs in `seq 0 $(( crep - 1 ))`; do 

   tar xfj bootstrap-reps.tbz $in.phylip.BS$bs

   $DIR/fasttree $ftmodel $in.phylip.BS$bs > fasttree.tre.BS$bs 2> ft.log.BS$bs;  
   test $? == 0 || { cat ft.log.BS$bs; exit 1; }
   python $DIR/arb_resolve_polytomies.py fasttree.tre.BS$bs
   st=fasttree.tre.BS$bs.resolved

   if [ $CPUS -gt 1 ]; then
      $DIR/raxmlHPC-PTHREADS -F -t $st -m $model -n ml.BS$bs -s $in.phylip.BS$bs -N 1  -T $CPUS  $s &> ../logs/ml_std.errout.$in
   else
      $DIR/raxmlHPC          -F -t $st -m $model -n ml.BS$bs -s $in.phylip.BS$bs -N 1            $s &> ../logs/ml_std.errout.$in
   fi
   test $? == 0 || { echo in running RAxML on bootstrap trees; exit 1; }
   cat RAxML_result.ml.BS$bs >> RAxML_bootstrap.all
   rm $in.phylip.BS$bs*
   tar rvf bootstrap-files.tar --remove-files *BS$bs *BS$bs.*
  done
  gzip bootstrap-files.tar
  rm bootstrap-reps.tbz

fi

 
if [ ! `wc -l RAxML_bootstrap.all|sed -e "s/ .*//g"` -eq $rep ]; then
 echo `pwd`>>$H/notfinishedproperly
 exit 1
else
 #Finalize 
 rename "final" "final.back" *final
 $DIR/raxmlHPC -f b -m $model -n final -z RAxML_bootstrap.all -t RAxML_bestTree.best

 if [ -s RAxML_bipartitions.final ]; then
   mv logs.tar.bz logs.tar.bz.back.$RANDOM
   tar cvfj logs.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.* RAxML_*back* RAxML_bootstrap.ml RAxML_result.best.* RAxML_bootstrap.ml* RAxML_info.final ft.log.* RAxML_info.BS* bootstrap-files.tar*.gz
   cd ..
   echo "Done">.done.$dirn
 fi
fi

