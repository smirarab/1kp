#!/bin/bash

# MXEZ, YTYU, HJVM, RXRQ, and ZRAV
mv genes genes-with-lowocc
mkdir genes

for x in `ls genes-with-lowocc`; do mkdir genes/$x; done
for x in `ls genes-with-lowocc`; do remove_taxon_from_fasta.sh "LMVB|XONJ|TWFZ|CGGO|DNQA|HTDC|MJMQ|TRPJ|XDVM" genes-with-lowocc/$x/$x.input.FAA > genes/$x/$x.input.FAA; done
for x in `ls genes-with-lowocc`; do remove_taxon_from_fasta.sh "LMVB|XONJ|TWFZ|CGGO|DNQA|HTDC|MJMQ|TRPJ|XDVM" genes-with-lowocc/$x/$x.input.FNA > genes/$x/$x.input.FNA; done
