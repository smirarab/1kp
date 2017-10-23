#!/bin/bash
 
mv genes genes-with-TFDQ
mkdir genes
for x in `ls genes-with-TFDQ`; do mkdir genes/$x; done
for x in `ls genes-with-TFDQ`; do remove_taxon_from_fasta.sh TFDQ genes-with-TFDQ/$x/$x.input.FAA > genes/$x/$x.input.FAA; done
for x in `ls genes-with-TFDQ`; do remove_taxon_from_fasta.sh TFDQ genes-with-TFDQ/$x/$x.input.FNA > genes/$x/$x.input.FNA; done
