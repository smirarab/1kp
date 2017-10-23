#!/lusr/bin/python
'''
Created on Jun 3, 2011

@author: smirarab
'''
import dendropy
import sys
import random
from dendropy import Node

def resolve_polytomies(tree, update_splits=False, rng=None):
    """
    Arbitrarily resolve polytomies using 0-length splits.

    If `rng` is an object with a sample() method then the polytomy will be
        resolved by sequentially adding (generating all tree topologies
        equiprobably
        rng.sample() should behave like random.sample()
    If `rng` is not passed in, then polytomy is broken deterministically by
        repeatedly joining pairs of children.
    """
    polytomies = []
    for node in tree.postorder_node_iter():
        if len(node.child_nodes()) > 2:
            polytomies.append(node)
    for node in polytomies:
        children = node.child_nodes()
        nc = len(children)
        if nc > 2:
            while len(children) > 2:
                nn1 = Node()
                nn1.edge.length = 0
                if rng:
                    sample = random.sample(children,2)
                else:
                    sample = [children[0], children[1]]
                c1 = sample[0]
                c2 = sample[1]
                node.remove_child(c1)
                node.remove_child(c2)
                nn1.add_child(c1)
                nn1.add_child(c2)
                node.add_child(nn1)
                children = node.child_nodes()
    if update_splits:
        tree.update_splits()
if __name__ == '__main__':

    treeName = sys.argv[1]
    
    resultsFile="%s.resolved" % treeName
    
    trees = dendropy.TreeList.get_from_path(treeName, 'newick')
    for tree in trees:            
        print ".",  
        resolve_polytomies(tree,rng=random) 
    print 
    trees.write(open(resultsFile,'w'),'newick',suppress_rooting=True)
