#!/bin/bash
set -x

H=/work/01721/smirarab/1kp/single_copy
T=$1
A=$2
C=$3
CODON=$4
label=$5
S=raxml
in=$A.$T.removed.realigned$CODON
rep=200
boot="-b $RANDOM"
s="-p $RANDOM"
dirn=raxmlboot.$T.$label


if [ "$A" == "FAA" ]; then
  model=PROTCAT`sed -e "s/.* //g" $H/$A/bestModel.$T`
else
  model=GTRCAT
fi

cd $H/$A
$HOME/workspace/global/src/shell/convert_to_phylip.sh $in $in.phylip
test "`head -n 1 $in.phylip`" == "0 0" && exit 1

mkdir $dirn
cd $dirn

#Figure out if main ML has already finished
donebs=`grep "Overall execution time" RAxML_info.best`
#Infer ML if not done yet
if [ "$donebs" == "" ]; then
 rm RAxML*best.back
 rename "best" "best.back" *best
 # Estimate the RAxML best tree
 if [ $C -gt 1 ]; then
  $HOME/bin/raxmlHPC-PTHREADS-SSE3-git-Sept25 -m $model -T $C -n best -s ../$in.phylip $s -N 10
 else
  $HOME/bin/raxmlHPC-SSE3-git-Sept25 -m $model -n best -s ../$in.phylip $s -N 10
 fi
fi

#Figure out if bootstrapping has already finished
donebs=`grep "Overall Time" RAxML_info.ml`
#Bootstrap if not done yet
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
  rm RAxML_info.ml
  if [ $crep -gt 0 ]; then
   if [ $C -gt 1 ]; then
      $HOME/bin/raxmlHPC-PTHREADS-SSE3-git-Sept25 -m $model -n ml -s ../$in.phylip -N $crep $boot -T $C  $s &>$H/logs/ml_std.errout.$in
   else
      $HOME/bin/raxmlHPC-SSE3-git-Sept25 -m $model -n ml -s ../$in.phylip -N $crep $boot $s &>$H/logs/ml_std.errout.$in
   fi
  fi
fi

if [ ! -s RAxML_bootstrap.all ] || [ `cat RAxML_bootstrap.all|wc -l` -ne $rep ]; then
 cat  RAxML_bootstrap.ml* > RAxML_bootstrap.all
fi

 
if [ ! `wc -l RAxML_bootstrap.all|sed -e "s/ .*//g"` -eq $rep ]; then
 echo `pwd`>>$H/../notfinishedproperly
 exit 1
else
 #Finalize 
 rename "final" "final.back" *final
 $HOME/bin/raxmlHPC-SSE3-git-Sept25 -f b -m $model -n final -z RAxML_bootstrap.all -t RAxML_bestTree.best

#/share/home/01721/smirarab/bin/mapsequences.py raxml/RAxML_bipartitions.ml namemap ml.mapped -rev &>logs/map
 if [ -s RAxML_bipartitions.final ]; then
   mv logs.tar.bz logs.tar.bz.back.$RANDOM
   tar cvfj logs.tar.bz --remove-files RAxML_log.* RAxML_parsimonyTree.best.RUN.* RAxML_*back* RAxML_bootstrap.ml RAxML_result.best.RUN.* RAxML_bootstrap.ml*
   cd ..
   echo "Done">.done.$S.$T.$label
 fi
fi

