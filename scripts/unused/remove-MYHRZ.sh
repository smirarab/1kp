#!/bin/bash

# MXEZ, YTYU, HJVM, RXRQ, and ZRAV
mv genes genes-with-MYHRZ
mkdir genes
for x in `ls genes-with-MYHRZ`; do mkdir genes/$x; done
for x in `ls genes-with-MYHRZ`; do remove_taxon_from_fasta.sh "MXEZ|YTYU|HJVM|RXRQ|ZRAV" genes-with-MYHRZ/$x/$x.input.FAA > genes/$x/$x.input.FAA; done
for x in `ls genes-with-MYHRZ`; do remove_taxon_from_fasta.sh "MXEZ|YTYU|HJVM|RXRQ|ZRAV" genes-with-MYHRZ/$x/$x.input.FNA > genes/$x/$x.input.FNA; done
