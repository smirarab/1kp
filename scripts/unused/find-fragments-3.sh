#!/bin/bash

for x in `ls genes/`; do 
  echo; echo -n $x; 
  simplifyfasta.sh genes/$x/FNA2AA-upp-masked.fasta|sed -e "s/-//g" | awk '/^>/{name=$0} /^[^>]/{s=length($0); if (s<600) printf " "name}'|sed -e "s/>//g"; 
done
