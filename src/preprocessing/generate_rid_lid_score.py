# coding: utf-8

import argparse
from itertools import count
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_TACID')
parser.add_argument('QID_RID')

args = parser.parse_args()
QID_TACID = args.QID_TACID
QID_RID = args.QID_RID

# Load 'qid tacid' and 'qid rid' into dataframes
df1 = pd.read_table(QID_TACID, header=None, names=['qid', 'tacid'])
df2 = pd.read_table(QID_RID, header=None, names=['qid', 'rid'])

# Merge dataframes and restrict to NILs
df3 = pd.merge(df2, df1, on='qid')
df4 = df3[df3['tacid'].str.startswith('nil')]
df4.reset_index(inplace=True)

# Assign 'lid'
c = count(start=1)
df4['lid'] = df4.groupby('tacid')['tacid'].transform(lambda x: c.next())

# Assign 'score'
df4['score'] = 1

# Write 'rid lid score' to stdout
df4[['rid', 'lid', 'score']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
