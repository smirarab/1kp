#!/bin/bash

for x in `ls genes/`; do 
 echo; echo -n $x" ";
 simplifyfasta.sh genes/$x/FNA2AA-upp-masked.fasta|awk '/^>/{name=$0} /^[^>]/{l=length($0); gsub("-","",$0);s=length($0); if (s/l < .2) printf " "name}'|sed -e "s/>//g";
done |tee filtered-0.2ratio-masked.txt
