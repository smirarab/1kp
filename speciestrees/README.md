* The file [SupFigs1-3-FigTree.tre](SupFigs1-3-FigTree.tre) is a (FigTree compatible) nexus file including the main ASTRAL tree (Figure S1), the main concatenation tree (Figure S2) and the main Plastid tree (Figure S3). Note the tree is not rooted and has to be rooted manually. 

* The [groups](groups) folder includes pdf figures (and newick trees) for individual groups within the larger group

* In addition, we provide all the alternative species trees tested in the onekp paper and shown in Figure S10. 
    * The directory [trees](trees) includes the newick species trees, as detailed below. 
    * The directory [output](output) includes the results of running DiscoVista with parameters for the DiscoVista are given in the [parameters](parameters) folder.

Directory name   |   Tree name
-----------------|-------------------
| **Full AA**|
| [astral_trees_33_percent-FAA](trees/astral_trees_33_percent-FAA) | ASTRAL-33%-FAA |
| [astral.20.503-FAA](trees/astral.20.503-FAA) | ASTRAL-20%-FAA |
| [astral.10.503-FAA](trees/astral.10.503-FAA) | ASTRAL-10%-FAA |
| [astral.05.503-FAA](trees/astral.05.503-FAA) | ASTRAL-05%-FAA |
| [astral-trees-unbinned-mlbs-raxmlboot.FAA-upp-masked.fasta.mask10sites.mask33taxa.mainlocalpp.tree-FAA](trees/astral-trees-unbinned-mlbs-raxmlboot.FAA-upp-masked.fasta.mask10sites.mask33taxa.mainlocalpp.tree-FAA) | ASTRAL-full-FAA |
| [astral-trees-supergenes-mlbs-raxmlboot.FAA-supergene.mainlocalpp.tree-FAA](trees/astral-trees-supergenes-mlbs-raxmlboot.FAA-supergene.mainlocalpp.tree-FAA) | ASTRAL-binning-FAA |
| [upp_masked.fasta.mask10sites.mask33taxa_FAA_alltaxa-FAA](trees/upp_masked.fasta.mask10sites.mask33taxa_FAA_alltaxa-FAA) | CAML-FAA |
| **Full-DNA**|
| [astral-trees-unbinned-mlbs-raxmlboot.FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa.mainlocalpp.tree-FAA](trees/astral-trees-unbinned-mlbs-raxmlboot.FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa.mainlocalpp.tree-FAA) | ASTRAL-full-C12 |
| [astral-trees-supergenes-mlbs-raxmlboot.FNA2AA-supergene.mainlocalpp.tree-FAA](trees/astral-trees-supergenes-mlbs-raxmlboot.FNA2AA-supergene.mainlocalpp.tree-FAA) | ASTRAL-binning-C12 |
| [upp_masked_c12.fasta.mask10sites.mask33taxa_FNA2AA_alltaxa-FAA](trees/upp_masked_c12.fasta.mask10sites.mask33taxa_FNA2AA_alltaxa-FAA) | CAML-C12 |
| [plastid_renamed_withsupport.noUAUU.rerooted-FAA](trees/plastid_renamed_withsupport.noUAUU.rerooted-FAA) | Plastid |
| **Filtered-rogue** |
| [astral-trees-remove-rogoue-mlbs-raxmlboot.FAA-upp-masked.fasta.mask10sites.mask33taxa.fasttreelocalpp.tree-FAA](trees/astral-trees-remove-rogoue-mlbs-raxmlboot.FAA-upp-masked.fasta.mask10sites.mask33taxa.fasttreelocalpp.tree-FAA) | ASTRAL-remove-rogue-FAA |
| [upp_masked.fasta.mask10sites.mask33taxa_FAA_filtered_remove_rogoue-FAA](trees/upp_masked.fasta.mask10sites.mask33taxa_FAA_filtered_remove_rogoue-FAA) | CAML-remove-rogue-FAA |
| [astral-trees-remove-rogoue-mlbs-raxmlboot.FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa.fasttreelocalpp.tree-FAA](trees/astral-trees-remove-rogoue-mlbs-raxmlboot.FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa.fasttreelocalpp.tree-FAA) | ASTRAL-remove-rogue-C12 |
| [upp_masked_c12.fasta.mask10sites.mask33taxa_FNA2AA_filtered_remove_rogoue-FAA](trees/upp_masked_c12.fasta.mask10sites.mask33taxa_FNA2AA_filtered_remove_rogoue-FAA) | CAML-remove-rogue-C12 |
| **Eudicots-only** |
| [astral.trees.eudicots.mlbs.raxmlboot.FAA.upp.masked.fasta-mask10sites.mask33taxa.mainlocalpp.tree-FAA](trees/astral.trees.eudicots.mlbs.raxmlboot.FAA.upp.masked.fasta.mask10sites.mask33taxa.mainlocalpp.tree-FAA) | ASTRAL-Eudicots-only-FAA |
| [upp_masked.fasta.mask10sites.mask33taxa_FAA_eudicot-FAA](trees/upp_masked.fasta.mask10sites.mask33taxa_FAA_eudicot-FAA) | CAML-Eudicots-only-FAA |
| [astral-trees-eudicots-mlbs-raxmlboot.FNA2AA-upp-masked-c12.fasta-mask10sites.mask33taxa.mainlocalpp.tree-FAA](trees/astral-trees-eudicots-mlbs-raxmlboot.FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa.mainlocalpp.tree-FAA) | ASTRAL-Eudicots-only-C12 |
| [upp_masked_c12.fasta.mask10sites.mask33taxa_FNA2AA_eudicot-FAA](trees/upp_masked_c12.fasta.mask10sites.mask33taxa_FNA2AA_eudicot-FAA) | CAML-Eudicots-only-C12 |
