#!/bin/bash

for x in `ls genes`
do 
remove_taxon_from_fasta.sh "FAJB|NDUV||RXRQ|UCRN|WCZB" new5taxa/$x/$x.input.FAA -rev >> genes/$x/$x.input.FAA
remove_taxon_from_fasta.sh "FAJB|NDUV||RXRQ|UCRN|WCZB" new5taxa/$x/$x.input.FNA -rev >> genes/$x/$x.input.FNA
done
