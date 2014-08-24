# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_EID')
parser.add_argument('QID_NAME')
parser.add_argument('QID_SID')

args = parser.parse_args()
QID_EID = args.QID_EID
QID_NAME = args.QID_NAME
QID_SID = args.QID_SID

# Load 'qid eid', 'queryname qid string', 'qid sid' into dataframes
df1 = pd.read_table(QID_EID, header=None, names=['qid', 'eid'])
df2 = pd.read_table(QID_NAME, header=None, names=['queryName', 'qid', 'string'])
#df2.drop('queryName', axis=1, inplace=True)
df3 = pd.read_table(QID_SID, header=None, 
        names=['querySentence_qid_sid', 'qid', 'sid'])

# Convert 'qid' to lowercase
df3['qid'] = df3.qid.str.lower()

# Merge data into one dataframe
df4 = pd.merge(df1, df2, on='qid')
df4 = pd.merge(df4, df3, on='qid')

# Sort by ascending 'qid'
df5 = df4.sort('qid')

# Write 'qid sid string eid' to stdout
df5[['qid', 'sid', 'string', 'eid']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
