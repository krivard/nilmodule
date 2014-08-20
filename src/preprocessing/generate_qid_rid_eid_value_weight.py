# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('DID_TOK')
parser.add_argument('DID_FEATURE')

# TODO ################################

args = parser.parse_args()
DID_TOK = args.DID_TOK
DID_FEATURE = args.DID_FEATURE


# Load 'did eid score' and 'qid rid' into dataframe and merge
df1 = pd.read_table('input/s5/qid_eid_score.txt', header=None, names=['qid', 'eid', 'score'])
df2 = pd.read_table('input/s5/qid_rid.txt', header=None, names=['qid', 'rid'])
df3 = pd.merge(df1, df2, on='qid')

# Sort by ascending 'rid' and 'score'
df4 = df3.sort(columns=['rid', 'score'])

# Create 'feature' column
df4['feature'] = 'eid'

# Write 'qid rid feature eid score' to file
df4[['qid', 'rid', 'feature', 'eid', 'score']].to_csv('output/s5/qid_rid_eid_value_weight.txt', header=False, index=False,  sep='\t')
