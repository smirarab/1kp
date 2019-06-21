The scripts to build the bargraphs that summarize quartet scores, local posterior probability, and tests of polytomy for specific parts of the species trees are provided here.

To create the results, you should run:

~~~bash
./pos-for-hyp-4-11-2.sh  ../../speciestrees/trees/astral_trees_33_percent-faa/estimated_species_tree.tree ../../genetrees/best.33.faa.tre astral-faa-33

./quart-for-hyp-4-11-2.sh ../../speciestrees/trees/astral_trees_33_percent-faa/estimated_species_tree.tree ../../genetrees/best.33.faa.tre astral-faa-33

./poly-for-hyp-4-11-02.sh ../../speciestrees/trees/astral_trees_33_percent-faa/estimated_species_tree.tree ../../genetrees/best.33.faa.tre astral-faa-33
~~~



