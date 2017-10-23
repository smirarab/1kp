import sys
import itertools

gencode = {
    'ATA':'I', 'ATC':'I', 'ATT':'I', 'ATG':'M',
    'ACA':'T', 'ACC':'T', 'ACG':'T', 'ACT':'T',
    'AAC':'N', 'AAT':'N', 'AAA':'K', 'AAG':'K',
    'AGC':'S', 'AGT':'S', 'AGA':'R', 'AGG':'R',
    'CTA':'L', 'CTC':'L', 'CTG':'L', 'CTT':'L',
    'CCA':'P', 'CCC':'P', 'CCG':'P', 'CCT':'P',
    'CAC':'H', 'CAT':'H', 'CAA':'Q', 'CAG':'Q',
    'CGA':'R', 'CGC':'R', 'CGG':'R', 'CGT':'R',
    'GTA':'V', 'GTC':'V', 'GTG':'V', 'GTT':'V',
    'GCA':'A', 'GCC':'A', 'GCG':'A', 'GCT':'A',
    'GAC':'D', 'GAT':'D', 'GAA':'E', 'GAG':'E',
    'GGA':'G', 'GGC':'G', 'GGG':'G', 'GGT':'G',
    'TCA':'S', 'TCC':'S', 'TCG':'S', 'TCT':'S',
    'TTC':'F', 'TTT':'F', 'TTA':'L', 'TTG':'L',
    'TAC':'Y', 'TAT':'Y', 'TAA':'_', 'TAG':'_',
    'TGC':'C', 'TGT':'C', 'TGA':'_', 'TGG':'W'#,
#    'CCA':'Z', 'CCC':'Z', 'CCG':'Z', 'CCT':'Z',
#    'GCA':'Z', 'GCC':'Z', 'GCG':'Z', 'GCT':'Z'
    }

dnacode = {'A':['A'],'C':['C'],'G':['G'],'T':['T'],
           'S':['G','C'],'R':['G','A'],'Y':['T','C'],'W':['A','T'],'M':['A','C'],'K':['G','T'],
           'B':['G','C','T'],'H':['A','C','T'],'D':['G','A','T'],'V':['G','C','A'],
           'N':['A','C','G','T']}

def read_fasta(src):
    """generator that returns (name, sequence) tuples from either a FASTA
    formatted file or file object.
    """
    file_obj = None
    ret = dict()
    if isinstance(src, str):
        try:
            file_obj = open(src, "rU")
        except IOError:
            print("The file `%s` does not exist, exiting gracefully" % src)
    elif isinstance(src, file):
            file_obj = src
    else:
        raise TypeError('FASTA reader cannot recognize the source of %s' % src)
    name = None
    seq_list = list()
    for line_number, i in enumerate(file_obj):
        if i.startswith('>'):
            if name:
                ret[name] = ''.join(seq_list)
                seq_list = list()
            name = i[1:].strip()
        else:
            seq = ''.join(i.strip().upper().split())
            seq_list.append(seq)
    if name:
        ret[name] = ''.join(seq_list)
    if isinstance(src, str):
        file_obj.close()
    return ret


def write_fasta(alignment, dest):
    """Writes the `alignment` in FASTA format to either a file object or file"""
    file_obj = None
    if isinstance(dest, str):
        file_obj = open(dest, "w")
    else:
        file_obj = dest
    for name, seq in alignment.items():
        file_obj.write('>%s\n%s\n' % (name, seq) )
    if isinstance(dest, str):
        file_obj.close()

def is_compatible(cd,aa):
    if aa == 'Z':
        return is_compatible(cd,'E') or is_compatible(cd,'Q')
    elif aa == 'B':
        return is_compatible(cd,'N') or is_compatible(cd,'D')
    else:
        return aa == 'X' or aa in set( gencode[''.join(a)] 
            for a in itertools.product(
               [ ''.join(a) for a in itertools.product(dnacode[cd[0]] , dnacode[cd[1]]) ], 
                  dnacode[cd[2]]) )

def is_ambiguous(cd):
    return len(set(gencode[''.join(a)] 
        for a in itertools.product(
           [ ''.join(a) for a in itertools.product(dnacode[cd[0]] , dnacode[cd[1]]) ], 
             dnacode[cd[2]]))) > 1

def backtranslate(faa,fna):
    newfna = dict()
    for k,s in fna.iteritems():
        aa = faa[k]
        cd = []
        i = 0
        for r in aa:
            cds = s[i:i+3]
            if r == '-':
                #if is_ambiguous(cds):
                #    cd.append(cds)
                #    i += 3
                #    print >> sys.stderr, "Found ambiguous %s at %d of %s. Matched it with a -" %(cds, i, k)
                #else:
                #    print >> sys.stderr, "Add a dash after %d of %s." %(i, k)
                cd.append('---')
            else:
                if is_compatible(cds,r):
                    cd.append(cds)
                    i += 3
                else:
                    raise ValueError('%s at position %d of %s does not translate to %s' %(cds, i, k, r))
        newfna[k] = ''.join(cd)
    return newfna


faa = read_fasta(sys.argv[1])
fna = read_fasta(sys.argv[2])
fo = sys.stdout

newfna = backtranslate(faa,fna)
write_fasta(newfna, fo)
