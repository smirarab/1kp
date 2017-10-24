#!/usr/bin/env python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import os
import copy
import os.path

hdir=os.path.dirname(os.path.realpath(__file__))

ROOTS = [
        ["Red Algae","Chromista (Algae)"],
        ["Glaucophyta (Algae)"],
        ["prasinophytes/Prasinococcales"],["prasinophytes"],["Volca_v2.0","Chlre_v5.5"],["Klefl_v1.0"]
        ]

def root (rootgroup, tree):
    root = None
    bigest = 0
    oldroot = tree.seed_node
    for n in tree.postorder_node_iter():
        if n.is_leaf():
            n.r = c.get(n.taxon.label) in rootgroup or n.taxon.label in rootgroup
            n.s = 1
        else:
            n.r = all((a.r for a in n.child_nodes()))
            n.s = sum((a.s for a in n.child_nodes()))
        if n.r and bigest < n.s:
            bigest = n.s
            root = n
    if root is None:
        return None
    #print "new root is: ", root.as_newick_string()
    newlen = root.edge.length/2 if root.edge.length else None
    tree.reroot_at_edge(root.edge,length1=newlen,length2=newlen)
    '''This is to fix internal node labels when treated as support values'''
    while oldroot.parent_node != tree.seed_node and oldroot.parent_node != None:
        oldroot.label = oldroot.parent_node.label
        oldroot = oldroot.parent_node
        if len(oldroot.sister_nodes()) > 0:
            oldroot.label = oldroot.sister_nodes()[0].label
    return root

if __name__ == '__main__':

    if len(sys.argv) < 2: 
        print("USAGE: treefile [output]")
        sys.exit(1)
    treeName = sys.argv[1]
    if len(sys.argv ) == 3:
        resultsFile=sys.argv[2]
    else:
        resultsFile="%s.%s" % (treeName, "rerooted")
    
    c={}
    for x in open(os.path.join(hdir,"annotate.txt")):
        c[x.split('\t')[0]] = x.split('\t')[2][0:-1]

    trees = dendropy.TreeList.get_from_path(treeName, 'newick', preserve_underscores=True)
    for i,tree in enumerate(trees):
        roots = ROOTS
        while roots and root(roots[0],tree) is None:
            roots = roots[1:]
        if not roots:
            print("Tree %d: none of the root groups %s exist. Leaving unrooted." %(i," or ".join((" and ".join(a) for a in ROOTS))))
    print("writing results to " + resultsFile)        
    trees.write(file=open(resultsFile,'w'),schema='newick',suppress_rooting=True,suppress_leaf_node_labels=False)
