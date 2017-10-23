#!/bin/bash

# PGKL or FAJB
mv genes genes-with-PF
mkdir genes
for x in `ls genes-with-PF`; do mkdir genes/$x; done
for x in `ls genes-with-PF`; do remove_taxon_from_fasta.sh "PGKL|FAJB" genes-with-PF/$x/$x.input.FAA > genes/$x/$x.input.FAA; done
for x in `ls genes-with-PF`; do remove_taxon_from_fasta.sh "PGKL|FAJB" genes-with-PF/$x/$x.input.FNA > genes/$x/$x.input.FNA; done
