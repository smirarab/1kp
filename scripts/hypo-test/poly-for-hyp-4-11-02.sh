#!/bin/bash

name=$3-pos

python spit-hypo-trees.py $1  updated_annotations.txt contract

cp $1-hypo.tre $name-hypo.tre

java -jar ~/workspace/ASTRAL/astral.4.10.12.jar -i $2 -q $name-hypo.tre -t 4 |tee $name-uncollapsed.tre

python spit-hypo-trees.py $name-uncollapsed.tre updated_annotations.txt collapse

mv $name-uncollapsed.tre-collapsed.tre $name-collapsed.tre

python ~/workspace/global/src/mirphyl/utils/reroot.py $name-collapsed.tre Out,Chromista

mv $name-collapsed.tre.rooted $name.tre
