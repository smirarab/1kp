- [annotate.txt](annotate.txt): annotations of species names used by some of the scripts.

## Building and filtering alignments.

- [mask-for-gt.sh](mask-for-gt.sh): masks gappy sites and fragmentary sequences from a given gene alignment. Assumes [PASTA](https://github.com/smirarab/pasta) is installed.
- [mask-gt.sh](mask-gt.sh): executes `mask-for-gt.sh` on all gene alignments.
.
- [find-long-branches-2.py](find-long-branches-2.py): used to find and remove long branches from rooted gene trees.
- [remove-long-branch.sh](remove-long-branch.sh): root gene tree, remove long branches, remove sequences from the alignment, preparing us for another round of alignments.
- [remove-both.sh](remove-both.sh): a helper script used to remove long branches from all input gene trees and the alignments.
.
- [runupp.sh](runupp.sh): 
  - Decides on the parameters of UPP (e.g., fragmentation length), 
  - Runs UPP
  - Cleans ups files afterwards
  -  Calls `backtranslate.py` to backtranslate to CDS and creates a version with only 1st and 2nd positions using `create_1stAnd2ndcodon_alignment.sh`
  - Calls `mask-insertion.sh` to  remove  insertion sites.
- [medseqlen.sh](medseqlen.sh): used by `runupp.sh` to find median sequence length.
- [run-upp-wrapper.sh](run-upp-wrapper.sh): a smaller wrapper scripts to run UPP (assuming [UPP](https://github.com/smirarab/sepp) is installed). 
- [runpasta.sh](runpasta.sh): runs PASTA on individual genes. Assumes [PASTA](https://github.com/smirarab/pasta) is installed.
- [backtranslate.py](backtranslate.py): backtranslates AA alignments to DNA given cds unaligned sequences.
- [mask-insertion.sh](mask-insertion.sh): masks insertion sites from UPP alignments. Assumes [trimal](trimal.cgenomics.org/) is installed.

- [create_1stAnd2ndcodon_alignment.sh](create_1stAnd2ndcodon_alignment.sh): removes 3rd position. Note that this script will put all the 1st codons first and then all the 2nd condon positions.
- [extract-codon.py](extract-codon.py): used by create_1stAnd2ndcodon_alignment.sh.

## Gene tree estimation.

- [ProteinModelSelection.pl](ProteinModelSelection.pl): Script used to select the AA model for each gene.
- [runraxml-rapidboot.sh](runraxml-rapidboot.sh): runs RAxML with bootstrapping (and a bit of checkpointing).
- [runfasttree.sh](runfasttree.sh): Runs fasttree on individual genes .
- [arb_resolve_polytomies.py](arb_resolve_polytomies.py): arbitrary resolves a polytomy.

## Concatenation.
- [concatenate_alignments.pl](concatenate_alignments.pl): concatenates gene alignments.
- [convert_to_phylip.sh](convert_to_phylip.sh): converts from fasta to phylip.

## Misc helper scripts.
- [merge_support_from_trees.py](merge_support_from_trees.py): a helper script to combine support values from multiple trees into a comma separated list.
- [root.py](root.py): roots gene trees. Used by `remove-long-branch.sh`.
- [simplifyfasta.sh](simplifyfasta.sh): simplifies a fasta file (used by other scripts).
