# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_DID_STRING_EID')
parser.add_argument('QID_EID')

args = parser.parse_args()
QID_DID_STRING_EID = args.QID_DID_STRING_EID
QID_EID = args.QID_EID

import pandas as pd

# Load 'qid did string eid' and 'qid eid' into dataframe
df1 = pd.read_table(QID_DID_STRING_EID, header=None, 
        names=['qid', 'did', 'string', 'eid'])
df2 = pd.read_table(QID_EID, header=None, names=['qid', 'eid'])

# Use 'qid' as index
df3 = df1.set_index('qid')
df4 = df2.set_index('qid')

# Merge 'qid did string eid' into 'qid eid'
df5 = df4.combine_first(df3)

# Convert 'qid' back into a regular column
df5.reset_index(inplace=True)

# Write 'qid eid' to stdout
df5.to_csv(sys.stdout, header=False, index=False, sep='\t')

#TODO REINDEX NILS! O/W CONFLICTS WITH NEW NILS!
