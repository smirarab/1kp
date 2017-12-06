Here, we include the final single-copy alignment files used for gene tree and species tree analyses. 

The following are the alignments after all main filtering steps have been applied. 

1. [alignments-FAA-masked.tar.bz](alignments-FAA-masked.tar.bz) 
2. [alignments-C12-masked.tar.bz](alignments-C12-masked.tar.bz)

These are alignments after the initial filtering steps but before filtering gappy sits and fragmentary sequences

1. [alignments-FAA.tar.bz](alignments-FAA.tar.bz): The FAA alignments, one file per gene. 
2. [alignments-C12.tar.bz](alignments-C12.tar.bz): The FNA2AA alignments, with C3 removed, one file per gene. The `.part` files show the boundary between C1 and C2. Note that C1 positions come before C2 positions. 
3. [alignments-FNA2AA.tar.bz](alignments-FNA2AA.tar.bz): The FNA2AA alignments, with all three codon positions, one file per gene.

And here is the FAA alignment before even filtering of insertion sites in UPP. 

1. [alignments-FAA-unmasked.tar.bz](alignments-FAA-unmasked.tar.bz): The unmasked FAA alignment, one file per gene        


All files are `tar.bz`; thus, you should decompress using `tar xvfj alignments-FAA.tar.bz`
