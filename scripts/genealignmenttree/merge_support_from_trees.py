#! /usr/bin/env python

import dendropy
import os
import sys
import re


if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 4:
    sys.stderr.write("usage: %s [threshold] [<tree-file-path>] [<out-file-path>]\n" % sys.argv[0])
    sys.exit(1)
 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
if not os.path.exists(src_fpath):
    sys.stderr.write('Not found: "%s"' % src_fpath)
src = open(src_fpath, "r")        
 
dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[3]))
dest = open(dest_fpath, "w")

print("Will write to file %s" % os.path.abspath(dest_fpath))


trees = dendropy.TreeList()
for tree_file in [src_fpath]:
    trees.read_from_path(tree_file,'newick' ) #, taxon_set = trees.taxon_set, encode_splits=True)
for tree in trees:
    tree.encode_splits()
    above = False
    for n in tree.internal_nodes():
        if n.label and float(n.label) > 1:
            above = True
            break
    if not above:
        continue
    for n in tree.internal_nodes():
        if n.label:
           n.label = float(n.label)/100.0

#con_tree = trees.consensus(min_freq=threshold)
con_tree = dendropy.Tree(trees[0])
print(con_tree.as_string('newick'))
for edge in con_tree.postorder_edge_iter():
    taxa = [n.taxon for n in edge.head_node.leaf_nodes()]
    if len(taxa) == 1:
        continue
    labels=[]
    for tre in trees:
        mrca = tre.find_node( lambda n: n.edge.split_bitmask == edge.split_bitmask)
        labels.append(str(int(round(float(mrca.label)*100))) if mrca.label is not None else "NA")
    fl = "*" if all(x=="100" for x in labels) else (None if all(x=="NA" for x in labels) else ",".join(labels))
    print(labels,fl)
    edge.head_node.label = fl
con = con_tree.as_string('newick',suppress_internal_node_labels=False)
#,edge_label_compose_func=lambda e: "[&SP='%s']%s" %(e.label,e.length) if e.label is not None else str(e.length))
dest.write(con)

dest.close()
print(con)
