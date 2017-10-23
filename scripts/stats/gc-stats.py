#! /usr/bin/env python
 
import os
import sys
import re
import subprocess as sub

name_pt = re.compile("(?<=[>])(.+)")
 
if ("--help" in sys.argv) or ("-?" in sys.argv) or len(sys.argv) < 1:
    sys.stderr.write("usage: %s <alignment-file-path> [<results-file-path>]\n"%sys.argv[0])
    sys.exit(1)
 
src_fpath = os.path.expanduser(os.path.expandvars(sys.argv[1]))
if not os.path.exists(src_fpath):
    sys.stderr.write('Not found: "%s"' % src_fpath)

p = sub.Popen(['simplifyfasta.sh',src_fpath],stdout=sub.PIPE,stderr=sub.PIPE)
simpl, errors = p.communicate()
if errors is not None and errors != "":
    print errors
    sys.exit(1)

dest_fpath=None
if len(sys.argv) > 2:
    dest_fpath=os.path.expanduser(os.path.expandvars(sys.argv[2]))
    dest = open(dest_fpath, "w")
else:
    dest = sys.stdout

def counts(l):
    x=l.lower()
    return (x.count('a'),x.count('c'),x.count('g'),x.count('t'))

print >>dest, "%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" %("SEQUENCE","TAXON","A_C","C_C","G_C","T_C","A_R","C_R","G_R","T_R","c1_A_C","c1_C_C","c1_G_C","c1_T_C","c1_A_R","c1_C_R","c1_G_R","c1_T_R","c2_A_C","c2_C_C","c2_G_C","c2_T_C","c2_A_R","c2_C_R","c2_G_R","c2_T_R","c3_A_C","c3_C_C","c3_G_C","c3_T_C","c3_A_R","c3_C_R","c3_G_R","c3_T_R")
#print mapping
try:
    seq=""
    for l in simpl.split("\n"):    
        if l.startswith(">"):
            seq=l[1:]
            seq2=seq.split("_")[0]
        else:
            if not l:
                continue
            a= [0, 0, 0, 0]
            c= [0, 0, 0, 0]
            g= [0, 0, 0, 0]
            t= [0, 0, 0, 0]
            (a[0],c[0],g[0],t[0]) = counts(l)
            
            s=a[0]+c[0]+g[0]+t[0]+0.0
            sc=s/3
            
            (a[1],c[1],g[1],t[1]) = counts(l[0::3])
            (a[2],c[2],g[2],t[2]) = counts(l[1::3])
            (a[3],c[3],g[3],t[3]) = counts(l[2::3])
            
            try:
                print >>dest, "%s %s %d %d %d %d %f %f %f %f %d %d %d %d %f %f %f %f %d %d %d %d %f %f %f %f %d %d %d %d %f %f %f %f" %(
                          seq,seq2,
                                  a[0],c[0],g[0],t[0],a[0]/s,c[0]/s,g[0]/s,t[0]/s,
                                                         a[1],c[1],g[1],t[1],a[1]/sc,c[1]/sc,g[1]/sc,t[1]/sc,
                                                                                  a[2],c[2],g[2],t[2],a[2]/sc,c[2]/sc,g[2]/sc,t[2]/sc,
                                                                                                        a[3],c[3],g[3],t[3],a[3]/sc,c[3]/sc,g[3]/sc,t[3]/sc)
            except ZeroDivisionError as e:
                print >>sys.stderr, "%s %s ERROR" %(seq,seq2)
                print >>sys.stderr, "L:%s*\n%d %s" %(l, s, a)

except RuntimeError as e:
    dest.close()
    if dest_fpath is not None:
        os.remove(dest_fpath)
    raise e
        
dest.close()
