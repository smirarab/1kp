for x in group-*.tre; do  
	cat $x|nw_order -cn -|nw_rename - map|sed -e "s/)1/)/g"| draw-trees.sh - $x.pdf $( echo 400 + 10 \* `nw_stats -fl $x |cut -f3`|bc ); 
done
