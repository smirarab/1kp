The scripts to build the bargraphs that summarize quartet scores, local posterior probability, and tests of polytomy for specific parts of the species trees are provided here. These are shown in Figure 3 of the paper. 

To create the results, you should run:

~~~bash
./pos-for-hyp-4-11-2.sh  ../../speciestrees/trees/astral_trees_33_percent-faa/estimated_species_tree.tree ../../genetrees/best.33.faa.tre astral-faa-33

./quart-for-hyp-4-11-2.sh ../../speciestrees/trees/astral_trees_33_percent-faa/estimated_species_tree.tree ../../genetrees/best.33.faa.tre astral-faa-33

./poly-for-hyp-4-11-02.sh ../../speciestrees/trees/astral_trees_33_percent-faa/estimated_species_tree.tree ../../genetrees/best.33.faa.tre astral-faa-33
~~~

Running these commands generates the following files:

* [astral-faa-33-poly.tre](astral-faa-33-poly.tre): The results of the polymy test using the method described by Sayyari and Mirarab, 2019.
* [astral-faa-33-pos.tre](astral-faa-33-pos.tre): The local posterior probabilities for the three alternatives, per branch 
* [astral-faa-33-quart.tre](astral-faa-33-quart.tre): The three quartet frequencies for the three alternatives, per branch



-- Sayyari, Erfan, and Siavash Mirarab. 2018. “Testing for Polytomies in Phylogenetic Species Trees Using Quartet Frequencies.” Genes 9 (3): 132. https://doi.org/10.3390/genes9030132.
