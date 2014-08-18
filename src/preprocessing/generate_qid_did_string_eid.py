# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_EID')
parser.add_argument('QID_NAME')
parser.add_argument('QID_DID')

args = parser.parse_args()
QID_EID = args.QID_EID
QID_NAME = args.QID_NAME
QID_DID = args.QID_DID

# Load 'qid eid', 'queryname qid string', 'qid did' into dataframes
df1 = pd.read_table(QID_EID, header=None, names=['qid', 'eid'])
df2 = pd.read_table(QID_NAME, header=None, names=['queryName', 'qid', 'string'])
#df2.drop('queryName', axis=1, inplace=True)
df3 = pd.read_table(QID_DID, header=None, names=['qid', 'did'])

# Merge data into one dataframe
df4 = pd.merge(df1, df2, on='qid')
df4 = pd.merge(df4, df3, on='qid')

# Sort by ascending 'qid'
df5 = df4.sort('qid')

# Write 'qid did string eid' to stdout
df5[['qid', 'did', 'string', 'eid']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
