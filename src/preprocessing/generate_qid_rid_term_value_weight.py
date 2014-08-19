# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('DID_TOK')
parser.add_argument('DID_FEATURE')

args = parser.parse_args()
DID_TOK = args.DID_TOK
DID_FEATURE = args.DID_FEATURE

# Load 'did term' and 'qid rid feature did weight' into dataframe and merge
df1 = pd.read_table(DID_TOK, header=None, names=['inDocument', 'did', 'term'])
df2 = pd.read_table(DID_FEATURE, header=False, 
        names=['qid', 'rid', 'feature', 'did', 'weight'])
df3 = pd.merge(df2, df1, on='did')

# Sort by ascending 'rid', 'did' and 'term'
df3 = df3.sort(columns=['rid','did','term'])

# Change feature column to 'term'
df3['feature'] = 'term'

# Write 'qid rid feature term weight' to file
df3[['qid', 'rid', 'feature', 'term', 'weight']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
