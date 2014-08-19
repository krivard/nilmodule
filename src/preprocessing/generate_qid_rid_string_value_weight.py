# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_NAME')
parser.add_argument('QID_RID')

args = parser.parse_args()
QID_NAME = args.QID_NAME
QID_RID = args.QID_RID

# Load 'qid string' and 'qid rid' into dataframe and merge
df1 = pd.read_table(QID_NAME, header=False, names=['queryName', 'qid', 'string'])
df2 = pd.read_table(QID_RID, header=False, names=['qid', 'rid'])
df3 = pd.merge(df2, df1, on='qid')

# Create 'feature' and 'weight' column
df3['feature'] = 'string'
df3['weight'] = 1

# Write 'qid rid feature string weight' to file
df3[['qid', 'rid', 'feature', 'string', 'weight']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
