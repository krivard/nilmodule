# coding: utf-8

import argparse
from itertools import count
import pandas as pd
from scipy import cluster, spatial
import sys

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument('QID_SID_STRING_EID')
parser.add_argument('SID_TOK')
parser.add_argument('--pairwise', help='pairwise distance metric', 
        default='jaccard')
parser.add_argument('--cluster', help='cluster distance metric', 
        default='euclidean')
parser.add_argument('--method', help='clustering method', default='single')
parser.add_argument('--threshold', help='clustering threshold', default='0.5')
args = parser.parse_args()
QID_SID_STRING_EID = args.QID_SID_STRING_EID
SID_TOK = args.SID_TOK
metric_pairwise = args.pairwise
metric_cluster= args.cluster
method = args.method
threshold = float(args.threshold)

# Load 'qid sid string eid' into dataframe
df1 = pd.read_table(QID_SID_STRING_EID, header=None, 
        names=['qid', 'sid', 'string', 'eid'])

# Select queries where 'eid' is NIL
df2 = df1[df1['eid'] == 'nil']

df3 = pd.read_table(SID_TOK, header=None, 
        names=['inSentence', 'sid', 'tok'])

# Create docs
terms = df3.groupby('sid')['tok'].apply(pd.Series.unique)

# Create vocabulary
# TODO if performance is a problem: use nil vocab only 
vocab = pd.Series(data=df3.tok.unique(), name='tok')

# Create df with 'string [sid]'
df4 = df2.groupby('string')['sid'].apply(pd.Series.unique)

# Create dict with (string, sid) as key and nid as value
nid = {}
c = count(start=1)
for row in df4.iteritems():
    string, docs = row
    if len(docs) == 1:
        nid[(string, docs[0])] = c.next()
    else:
        # Create boolean feature array
        X = [ vocab.isin(terms[sid]) for sid in docs ]
        # Compute pairwise distance matrix
        Y = spatial.distance.pdist(X, metric_pairwise)
        # Perform hierarchical/agglomerative clustering
        Z = cluster.hierarchy.linkage(Y, method, metric_cluster)
        # Form flat clusters from the hierarchical clusters
        fcluster = cluster.hierarchy.fcluster(Z, threshold)
        # Assign nid to each cluster
        cid = [ c.next() for nb in range(max(fcluster)) ]
        ids = [ cid[i-1] for i in fcluster ]
        for i, sid in enumerate(docs):
            nid[(string, sid)] = ids[i]

assignID = lambda x: 'nil' + str(nid[tuple(x)]).zfill(3)
df2['eid'] = df2[['string', 'sid']].apply(assignID, axis=1)

df5 = df2.combine_first(df1)

# Write 'qid eid' to stdout
df5[['qid', 'eid']].to_csv(sys.stdout, header=False, index=False, sep='\t')
