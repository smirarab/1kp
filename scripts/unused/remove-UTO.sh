#!/bin/bash
 
mv genes genes-with-UTO
mkdir genes
for x in `ls genes-with-UTO`; do mkdir genes/$x; done
for x in `ls genes-with-UTO`; do remove_taxon_from_fasta.sh "OTAN|UNBZ|TZJQ" genes-with-UTO/$x/$x.input.FAA > genes/$x/$x.input.FAA; done
for x in `ls genes-with-UTO`; do remove_taxon_from_fasta.sh "OTAN|UNBZ|TZJQ" genes-with-UTO/$x/$x.input.FNA > genes/$x/$x.input.FNA; done
