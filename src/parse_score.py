#!/usr/bin/env python

import fileinput
#import pandas as pd
#import sys

scores = {}
qid = None
for line in fileinput.input():
    if line.startswith('#'):
        qid = line.strip().split('\t')[1].split(',')[1]
        #scores[qid] = []
    else:
        # TODO use threshold for scores?
        i, score, eid_raw = line.strip().split('\t')
        eid = eid_raw.lstrip('-1=c[').rstrip(']')
        # TODO change formatting for score to %d and set precision?
        row = '%s\t%s\t%s' % (qid, eid, score)
        print(row)
        #scores[qid].append((eid, score))

#table = []
#for qid in scores:
#    for (eid, score) in scores[qid]:
#        table.append([qid, eid, score])
#        
#df = pd.DataFrame(data=table, columns=['qid', 'eid', 'score'])
#df.to_csv(sys.stdout, header=False, index=False, sep='\t')
