#!/bin/bash

if [ "--help" = "$1" ]
then
    echo -e "Available options:"
    echo -e "  --extdir /path/to/kbp.dataset.x.x/"
    exit 0
fi

if [ -n "$1" ]
then
    rm -f Makefile.in
fi

echo -e "# external data (NB these lines will have to be changed)" >> Makefile.in

while [ -n "$2" ];
do
    NAME=$1
    VALUE=$2
    if [ "--extdir" = "$NAME" ]
    then
	echo -e "EXTDIR := $VALUE" >> Makefile.in
    fi
    shift
    shift
done

if [ -n "$1" ]
then
    echo -e "Unrecognized option: $1"
fi


cat >> Makefile.in <<EOF
#### DEFAULTS:
ifeq (,\$(strip \$(EXTDIR))
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.4
endif
PROPPR_TRAIN := \$(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt
PROPPR_TEST := \$(EXTDIR)/proppr-output/kbp_test.trained.t_0.028.results.txt
QNAME := \$(EXTDIR)/kbp.cfacts/queryName_qid_name.cfacts
SCORE_TRAIN := \$(EXTDIR)/proppr-output/kbp_train.trained.solutions.txt
SCORE_TEST := \$(EXTDIR)/proppr-output/kbp_test.trained.solutions.txt
TOKEN := \$(EXTDIR)/kbp.cfacts/inDocument_did_tok.cfacts
QSENT := \$(EXTDIR)/kbp.cfacts/querySentence_qid_sid.cfacts
INSENT := \$(EXTDIR)/kbp.cfacts/inSentence_sid_tok.cfacts
TACPR := /remote/curtis/bbd/KBP_2014/alignKBs/e54_v11.docid_wp14_enType_score_begin_end_mention.TAC_id_name_type.genericType.txt

# formatting parameters
FORMATTING_FLAGS := --padding=4

# baseline clustering parameters
GLOBAL_BASELINE_CLUSTERING_FLAGS := --threshold=0.5
LOCAL_BASELINE_CLUSTERING_FLAGS := --threshold=0.7

EOF
