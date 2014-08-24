# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('SID_TOK')
parser.add_argument('SID_FEATURE')

args = parser.parse_args()
SID_TOK = args.SID_TOK
SID_FEATURE = args.SID_FEATURE

# Load 'sid token' and 'qid rid feature sid weight' into dataframe and merge
df1 = pd.read_table(SID_TOK, header=None, names=['inSentence', 'sid', 'token'])
df2 = pd.read_table(SID_FEATURE, header=False, 
        names=['qid', 'rid', 'feature', 'sid', 'weight'])
df3 = pd.merge(df2, df1, on='sid')

# Sort by ascending 'rid', 'sid' and 'token'
df3 = df3.sort(columns=['rid','sid','token'])

# Change feature column to 'token'
df3['feature'] = 'local'

# Write 'qid rid feature token weight' to file
df3[['qid', 'rid', 'feature', 'token', 'weight']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
