# coding: utf-8

import argparse
from itertools import count
import pandas as pd
from scipy import cluster, spatial
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_DID_STRING_EID')
parser.add_argument('DID_TOK')

args = parser.parse_args()
QID_DID_STRING_EID = args.QID_DID_STRING_EID
DID_TOK = args.DID_TOK

# TODO use config file
metric_pairwise = 'jaccard'
metric_cluster= 'euclidean'
method = 'single'
threshold = 0.5

# Load 'qid did string eid' into dataframe
df1 = pd.read_table(QID_DID_STRING_EID, header=None, 
        names=['qid', 'did', 'string', 'eid'])

# Select queries where 'eid' is NIL
df2 = df1[df1['eid'] == 'nil']

df3 = pd.read_table(DID_TOK, header=None, names=['inDocument', 'did', 'tok'])

# Create docs
terms = df3.groupby('did')['tok'].apply(pd.Series.unique)

# Create vocabulary
# TODO if performance is a problem: only use nil vocab
vocab = pd.Series(data=df3.tok.unique(), name='tok')

# Create df with 'string [did]'
df4 = df2.groupby('string')['did'].apply(pd.Series.unique)

# Create dict with (string, did) as key and nid as value
nid = {}
c = count(start=1)
for row in df4.iteritems():
    string, docs = row
    if len(docs) == 1:
        nid[(string, docs[0])] = c.next()
    else:
        # Create boolean feature array
        X = [ vocab.isin(terms[did]) for did in docs ]
        # Compute pairwise distance matrix
        Y = spatial.distance.pdist(X, metric_pairwise)
        # Perform hierarchical/agglomerative clustering
        Z = cluster.hierarchy.linkage(Y, method, metric_cluster)
        # Form flat clusters from the hierarchical clusters
        fcluster = cluster.hierarchy.fcluster(Z, threshold)
        # Assign nid to each cluster
        cid = [ c.next() for nb in range(max(fcluster)) ]
        ids = [ cid[i-1] for i in fcluster ]
        for i, did in enumerate(docs):
            nid[(string, did)] = ids[i]

assignID = lambda x: 'nil' + str(nid[tuple(x)]).zfill(3)
df2['eid'] = df2[['string', 'did']].apply(assignID, axis=1)

df5 = df2.combine_first(df1)

# Write 'qid eid' to stdout
df5[['qid', 'eid']].to_csv(sys.stdout, header=False, index=False, sep='\t')
