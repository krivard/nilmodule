# coding: utf-8

import argparse
from itertools import count
import pandas as pd
import sys

# Parse path to input files
parser = argparse.ArgumentParser()
parser.add_argument('TACPR')

args = parser.parse_args()
TACPR = args.TACPR

# Load PR/TAC data into dataframe
#df1 = pd.read_table(TACPR, header=None, names=['did', 'wp14', 'type', 'score', 
df1 = pd.read_table(TACPR, header=None, names=['did', 'wp14', 'type', 'score', 
    'begin', 'end', 'mention', 'tacid', 'tacname' , 'tactype', 'gentype'])

# Select NILs where gentype is either PERSON, PLACE or ORGANIZATION
#df2 = df1[df1['tacid'].isnull()]
# TODO IS THIS CORRECT? ###
df2 = df1[df1['tacid'].isnull() &  df1['gentype'].notnull()]
df2 = df2[df2['gentype'] != 'OTHER']

# Assign nilID
c = count(start=1)
assign = lambda x: 'nil' + str(c.next()).zfill(4)
df2['tacid'] = df2.groupby('wp14')['tacid'].transform(assign)

# Convert 'name' and 'mention' to lowercase and replace ' ' with '_'
df1['tacname'] = df1.tacname.str.lower()
df1['tacname'] = df1.tacname.str.replace(' ', '_')
df2['mention'] = df2.mention.str.lower()
df2['mention'] = df2.mention.str.replace(' ', '_')

# Merge NILs back into PR/TAC dataframe
df3 = df2.combine_first(df1)
# TODO IS THIS CORRECT? ###
df3 = df3[df3['tacid'].notnull()]

# Write data to stdout
df3.to_csv(sys.stdout, header=False, index=False, sep='\t')
