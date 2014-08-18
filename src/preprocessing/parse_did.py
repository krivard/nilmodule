#!/usr/bin/env python
import fileinput

for line in fileinput.input():
    if line.startswith("#"):
        answer = line.strip().split('\t')[1]
        did, qid = answer.lstrip('answerQuery(').rstrip('(').split(',')[0:2]
        out = qid + '\t' + did
        print(out)
