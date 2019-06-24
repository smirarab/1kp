Some extra files and figures:

- bestModel : the AA model chosen for each gene
- filter-lb-aaand filter-lb-fna2aa : the name of sequences filtered by long branch filtering
- FNA2AA-upp-masked-c12.fasta.mask10sites.mask33taxa.rates.csv : GTR+Alpha parameters for the 1st and 2nd codon positions for the
 	FNA2AA-masked10sites-mask33taxa alignments
- pTpP_GC_box.pdf and names.csv : the GC content of species for all codon positions and the name of species used in pTpP_GC_box.pdf
   - Drawn using [plot.gc.R](../scripts/stats/plot.gc.R) and data  built using [gc-stats.py](../scripts/stats/gc-stats.py)
- taxon-occupancy.png : taxon occupancy
   - Drawn using [taxonOccupancyMap.R](../scripts/stats/taxonOccupancyMap.R) and data built using [occupancy.sh](../scripts/stats/occupancy.sh)


- [annotations.csv](annotations.csv) : Mapping between 4-letter codes, species names, and a classification of species used to color figures in the paper
    * Note: before the data release, for improved consistency with current literature, the following changes are made 
        - NPND: Changed
        - Change all "BasalAngiosperms" to  "ANAGrade"
        - Change all "BasalEudicots" to  "Eudicots"
