# coding: utf-8

import argparse
import glob
from itertools import count
import numpy as np
import pandas as pd
import pymatlab
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_DID_STRING_EID')
parser.add_argument('DID_TOK')
parser.add_argument('EXPLORE_EM')
parser.add_argument('--existing', help='pre-existing nill ids', 
        action='store_true')
parser.add_argument('--padding', help='amount of padding in nid', 
        type=int, default=4)

args = parser.parse_args()
QID_DID_STRING_EID = args.QID_DID_STRING_EID
DID_TOK = args.DID_TOK
EXPLORE_EM = args.EXPLORE_EM
EXISTING = args.existing
padding = args.padding

# Load 'qid did string eid' into dataframe
df1 = pd.read_table(QID_DID_STRING_EID, header=None, 
        names=['qid', 'did', 'string', 'eid'])

# Sort by ascending qid
df1.sort('qid', inplace=True)

# Select queries where 'eid' is NIL
df2 = df1[df1['eid'] == 'nil']

df3 = pd.read_table(DID_TOK, header=None, 
        names=['inDocument', 'did', 'tok'])

# Create docs
terms = df3.groupby('did')['tok'].apply(pd.Series.unique)

# Create vocabulary
# TODO if performance is a problem: only use nil vocab
vocab = pd.Series(data=df3.tok.unique(), name='tok')

# Create fid array (TODO USE OTHER FEATURES AS WELL)
features = pd.Series(np.arange(1, vocab.size+1))

# Create df with 'string [did]'
df4 = df2.groupby('string')['did'].apply(pd.Series.unique)

# Set starting value for nid counter
if EXISTING:
    nils = df1.eid.str.extract('nil(\d+)')
    start_value = int(nils.convert_objects(convert_numeric=True).max() + 1)
else:
    start_value = 1

# Create dict with (string, did) as key and nid as value
nid = {}
c = count(start=start_value)
session = pymatlab.session_factory()
session.run("cd('" + EXPLORE_EM + "')")
for row in df4.iteritems():
    string, docs = row
    if len(docs) == 1:
        nid[(string, docs[0])] = c.next()
    else:
        # Generate data.X.txt input
        dataX = pd.DataFrame()
        for row, sid in enumerate(docs):
            fid = features[vocab.isin(terms[sid])]
            rid = np.empty(len(fid))
            rid.fill(row+1)
            weight = np.empty(len(fid))
            weight.fill(1)
            dataX = dataX.append(pd.DataFrame([rid, fid, weight]).T)

        # Write input to file
        dataX.to_csv(EXPLORE_EM + '/data/data.X.txt', 
                header=False, index=False, sep='\t')

        # Generate data.Y.txt and seeds.Y.txt
        dataY = np.ones((2, 2))
        dataY[1][0] = 2
        dataY = pd.DataFrame(dataY)
        #seedsY = np.ones((2, 3))
        #dataY.to_csv('input/s5/ExploreEM_package_v2/data/data.Y.txt', 
        dataY.to_csv(EXPLORE_EM + '/data/data.Y.txt', 
                header=False, index=False, sep='\t')

        # Perform exploratory clustering
        session.run('All_BIC_ExplEM_Main')

        # TODO USE ALL FEATURES, NOT JUST TERMS!
        #OUTPUT = glob.glob('input/s5/ExploreEM_package_v2/data/*assgn.txt')[0]
        OUTPUT = glob.glob(EXPLORE_EM + '/data/*assgn.txt')[0]
        assignment = pd.read_table(OUTPUT, header=None)
        cluster = np.array([c.next() for i in range(assignment.shape[1])])
        ids = np.dot(assignment, cluster)

        for i, did in enumerate(docs):
            nid[(string, did)] = ids[i]

assignID = lambda x: 'nil' + str(nid[tuple(x)]).zfill(3)
df2['eid'] = df2[['string', 'did']].apply(assignID, axis=1)

df5 = df2.combine_first(df1)
df5[['qid', 'eid']].to_csv(sys.stdout, header=False, index=False, sep='\t')
