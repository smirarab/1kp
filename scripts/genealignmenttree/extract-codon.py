#! /usr/bin/env python

import os
import sys
import re
import subprocess as sub
from mirphyl.setup import WS_HOME

if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 3:
    sys.stderr.write("usage: %s [<alignment-file-path>] [<out-file-path>] [codon]\n"%sys.argv[0])
    sys.exit(1)
 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
if not os.path.exists(src_fpath):
    sys.stderr.write('Not found: "%s"' % src_fpath)
#src = open(src_fpath,"r")        
 
dest_fpath = os.path.expanduser(os.path.expandvars(sys.argv[2]))
dest = open(dest_fpath, "w")

c = int(sys.argv[3]) - 1

p = sub.Popen(['%s/global/src/shell/simplifyfasta.sh'%WS_HOME,src_fpath],stdout=sub.PIPE,stderr=sub.PIPE)
output, errors = p.communicate()
if errors is not None and errors != "":
    print errors
    sys.exit(1)

print "writing to file %s" %os.path.abspath(dest_fpath)

for t in output.split("\n"):    
    if not t.startswith(">"):
        t = t[c::3]
        t = t +"\n" 
    dest.write("%s\n"%t)

dest.close()
