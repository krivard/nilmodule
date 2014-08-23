# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_DID')
parser.add_argument('QID_RID')

args = parser.parse_args()
QID_DID = args.QID_DID
QID_RID = args.QID_RID

# Load 'did qid' and 'qid rid' into dataframe and merge
df1 = pd.read_table(QID_DID, header=None, names=['qid', 'did'])
df2 = pd.read_table(QID_RID, header=None, names=['qid', 'rid'])
df3 = pd.merge(df2, df1, on='qid')

# Create 'feature' and 'weight' column
df3['feature'] = 'did'
df3['weight'] = 1

# Write 'qid rid feature did weight' to file
df3[['qid', 'rid', 'feature', 'did', 'weight']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
