# coding: utf-8

import argparse
import numpy as np
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('ASSGN')
parser.add_argument('QID_RID')
parser.add_argument('QID_EID')

args = parser.parse_args()
ASSGN = args.ASSGN
QID_RID = args.QID_RID
QID_EID = args.QID_EID

# Load ExploreEM cluster assignments
assignments = np.loadtxt(open(ASSGN))

# Generate array with nilID
nbcluster = assignments.shape[1]
cluster_list = [ i for i in range(nbcluster) ]
cluster = np.array(cluster_list)
nils = np.dot(assignments, cluster)

# Load 'qid rid' and 'qid eid' into dataframes
# TODO do dataframes need to be sorted?
df1 = pd.read_table(QID_RID, header=None, names=['qid', 'rid'])
df1['cid'] = nils
df2 = pd.read_table(QID_EID, header=None, names=['qid', 'eid'])

df3 = pd.merge(df2, df1, on='qid')
df3['eid'] = df3.cid.map(lambda x: 'nil' + str(int(x)).zfill(3))

df2 = df2.set_index('qid')
df3 = df3[['qid', 'eid']].set_index('qid')

#df4 = df4.sort('qid')
df4 = df3.combine_first(df2)

# Write 'qid eid' to stdout
df4.to_csv(sys.stdout, header=False, index=True, sep='\t')
