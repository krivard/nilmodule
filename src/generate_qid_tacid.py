# coding: utf-8

import argparse
from itertools import count
import numpy as np
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('TACPR_RAW')
parser.add_argument('QID_NAME')

args = parser.parse_args()
TACPR_RAW = args.TACPR_RAW
QID_NAME = args.QID_NAME

df1 = pd.read_table(QID_NAME, header=None, names=['queryName', 'qid', 'name'])
df2 = pd.read_table(TACPR_RAW, header=None, names=['did', 'wp14', 'type', 
        'score', 'begin', 'end', 'mention', 'tacid', 'tacname', 'tactype', 'gentype'])

df1['name'] = df1.name.str.lower()
df1['name'] = df1.name.str.replace(' ', '_')

df2['mention'] = df2.mention.str.lower()
df2['mention'] = df2.mention.str.replace(' ', '_')

df1.sort('name', inplace=True)
df2.sort('mention', inplace=True)

df2.reset_index(drop=True, inplace=True)
df1.reset_index(drop=True, inplace=True)

df1['appearance'] = df1.groupby('name')['name'].transform(lambda x: 
        np.arange(len(x)))
df2['appearance'] = df2.groupby('mention')['mention'].transform(lambda x: 
        np.arange(len(x)))

df3 = pd.merge(df1, df2, left_on=['name', 'appearance'], 
        right_on=['mention', 'appearance'])

#df3.to_csv('output/s2/complete.txt', header=False, index=False, sep='\t')
df3[['qid','tacid']].to_csv(sys.stdout, header=False, index=False, sep='\t')
