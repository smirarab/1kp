#!/bin/bash

for x in $*; do 
  simplifyfasta.sh $x|sed -e "/^>/! s/[?N-]//g"|awk '/>/ {x=$0} /^[^>]/ {print "'$x'",x,length($0)}';
done
