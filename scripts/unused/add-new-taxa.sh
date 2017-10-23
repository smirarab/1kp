#!/bin/bash

for x in `ls genes`
do 
  cat Vcarteri_199_v2.0/Vcarteri_199_v2.0.$x.FILTERED.FAA Cyanidioschyzon.merolae/Cyanidioschyzon.merolae.$x.FILTERED.FAA| sed -e "s/>Vocar.*/>Volca_v2.0/" -e "s/>gnl.*/>Cyame_v1.0/g" -e "s/\*/X/g" >> genes/$x/$x.input.FAA
  cat Vcarteri_199_v2.0/Vcarteri_199_v2.0.$x.FILTERED.FNA Cyanidioschyzon.merolae/Cyanidioschyzon.merolae.$x.FILTERED.FNA| sed -e "s/>Vocar.*/>Volca_v2.0/" -e "s/>gnl.*/>Cyame_v1.0/g" -e "s/\*/N/g" >> genes/$x/$x.input.FNA
done
