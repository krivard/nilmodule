# coding: utf-8

import argparse
from itertools import count
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('STRING_FEATURE')
parser.add_argument('DID_FEATURE')
parser.add_argument('TOKEN_FEATURE')
parser.add_argument('EID_FEATURE')

args = parser.parse_args()
STRING_FEATURE = args.STRING_FEATURE
DID_FEATURE = args.DID_FEATURE
TOKEN_FEATURE = args.TOKEN_FEATURE
EID_FEATURE = args.EID_FEATURE

# Concat feature data
df1 = pd.read_table(STRING_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df2 = pd.read_table(DID_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df3 = pd.read_table(TOKEN_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df4 = pd.read_table(EID_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df5 = pd.concat([df1, df2, df3, df4])

# Create fid
c = count(start=1)
fid = df5.groupby(['feature', 'value']).apply(lambda x: c.next())
df5['feature_value'] = zip(df5.feature, df5.value)
df5['fid'] = df5.feature_value.map(lambda x: fid[x])
df5 = df5.drop('feature_value', 1)

# Sort by ascending 'rid' and 'fid'
df5 = df5.sort(columns=['rid', 'fid'])

# Write 'qid rid feature value weight fid' to file
#df5.to_csv(sys.stdout, header=False, index=False, sep='\t')

# Write 'rid fid weight' to file
df5[['rid', 'fid', 'weight']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
