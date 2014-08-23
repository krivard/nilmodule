# coding: utf-8

import argparse
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('GOLD')
parser.add_argument('BASELINE0')
#parser.add_argument('QID_NAME')

args = parser.parse_args()
GOLD = args.GOLD
BASELINE0 = args.BASELINE0
#QID_NAME = args.QID_NAME

# Load gold and 'queryName qid name' into dataframes
df1 = pd.read_table(GOLD, skiprows=1,
        names=['qid', 'eid', 'type', 'genre', 'web', 'wiki', 'unknown'])
df2 = pd.read_table(BASELINE0, header=None, names=['qid', 'name'])
#df2 = pd.read_table(QID_NAME, header=None, names=['queryName', 'qid', 'name'])

# Convert gold to all lowercase
df1 = df1.apply(lambda x: x.str.lower())

# Restrict gold to qid found in 'qid name'
df3 = df1[df1.qid.isin(df2.qid)]

# Write 'qid eid' to stdout
df3[['qid', 'eid']].to_csv(sys.stdout, header=False, index=False, sep='\t')
