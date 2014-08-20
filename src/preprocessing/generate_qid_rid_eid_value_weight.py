# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_EID_SCORE')
parser.add_argument('QID_RID')

args = parser.parse_args()
QID_EID_SCORE = args.QID_EID_SCORE
QID_RID = args.QID_RID

# Load 'did eid score' and 'qid rid' into dataframe and merge
df1 = pd.read_table(QID_EID_SCORE, header=None, names=['qid', 'eid', 'score'])
df2 = pd.read_table(QID_RID, header=None, names=['qid', 'rid'])
df3 = pd.merge(df1, df2, on='qid')

# Sort by ascending 'rid' and descending 'score'
df4 = df3.sort(columns=['rid', 'score'], ascending=[True, False])

# Create 'feature' column
df4['feature'] = 'eid'

# Write 'qid rid feature eid score' to file
df4[['qid', 'rid', 'feature', 'eid', 'score']].to_csv(sys.stdout, 
        header=False, index=False,  sep='\t')
