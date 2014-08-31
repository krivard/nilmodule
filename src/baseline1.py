# coding: utf-8

import argparse
from itertools import count
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_DID_STRING_EID')
args = parser.parse_args()
QID_DID_STRING_EID = args.QID_DID_STRING_EID

# Load 'qid did string eid' into dataframe
df1 = pd.read_table(QID_DID_STRING_EID, header=None, 
        names=['qid', 'did', 'string', 'eid'])

# Sort by ascending qid
df1.sort('qid', inplace=True)

# Select queries where 'eid' is NIL
df2 = df1[df1['eid'] == 'nil']

# Assign nil-ID
c = count(start=1)
assign = lambda x: 'nil' + str(c.next()).zfill(3)
df2['eid'] = df2.groupby(['string', 'did'])['eid'].transform(assign)

# Merge nil-IDs back into original dataframe
df3 = df2.combine_first(df1)

# Write 'qid eid' to stdout
df3[['qid', 'eid']].to_csv(sys.stdout, header=False, index=False, sep='\t')
