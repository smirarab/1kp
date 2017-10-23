a=updated_annotations.txt; 
t=astral-33-new.tre.rerooted

cut -f6 $a|sort -u| while IFS= read x; do  
   echo $x =======================;  
   nw_prune  $t  `awk -F'\t' '{if ($6!="'"$x"'") printf $1" "}' $a` |tee group-`echo $x| sed -e 's/[^A-Za-z0-9._-]/_/g' `.tre; 
done

nw_prune  $t  `awk -F'\t' '{if ($16=="'"Out"'" || $16=="'"Vascs"'") printf $1" "}' $a` |tee group-bryophytes.tre;
