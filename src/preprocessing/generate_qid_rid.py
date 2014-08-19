# coding: utf-8

import argparse
from itertools import count
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('QID_EID')

args = parser.parse_args()
QID_EID = args.QID_EID

# Load 'qid eid' into dataframe and sort by 'qid'
df =  pd.read_table(QID_EID, header=None, names=['qid', 'eid'])
df = df.sort(columns='qid')

# Where 'eid' is NIL
df = df[df['eid'] == 'nil']

# Assign 'rid' ranging from 1 to #NIL
df['rid'] = df.index + 1

# Write 'qid rid' to stdout
df[['qid', 'rid']].to_csv(sys.stdout, header=False, index=False, sep='\t')
