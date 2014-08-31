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
parser.add_argument('SID_FEATURE')
parser.add_argument('LOCAL_FEATURE')
parser.add_argument('EID_FEATURE')

args = parser.parse_args()
STRING_FEATURE = args.STRING_FEATURE
DID_FEATURE = args.DID_FEATURE
TOKEN_FEATURE = args.TOKEN_FEATURE
SID_FEATURE = args.SID_FEATURE
LOCAL_FEATURE = args.LOCAL_FEATURE
EID_FEATURE = args.EID_FEATURE

# Concat feature data
df1 = pd.read_table(STRING_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df2 = pd.read_table(DID_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df3 = pd.read_table(TOKEN_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df4 = pd.read_table(SID_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df5 = pd.read_table(LOCAL_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df6 = pd.read_table(EID_FEATURE, header=None, 
        names=['qid', 'rid', 'feature', 'value', 'weight'])
df7 = pd.concat([df1, df2, df3, df4, df5, df6])

# Create fid
c = count(start=1)
fid = df7.groupby(['feature', 'value']).apply(lambda x: c.next())
df7['feature_value'] = zip(df7.feature, df7.value)
df7['fid'] = df7.feature_value.map(lambda x: fid[x])
df7 = df7.drop('feature_value', 1)

# Sort by ascending 'rid' and 'fid'
df7 = df7.sort(columns=['rid', 'fid'])

# Write 'qid rid feature value weight fid' to file
#df7.to_csv(sys.stdout, header=False, index=False, sep='\t')

# Write 'rid fid weight' to file
df7[['rid', 'fid', 'weight']].to_csv(sys.stdout, 
        header=False, index=False, sep='\t')
