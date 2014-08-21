# location of external sources
# NB these should be the only lines that need to be changed
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt
QNAME := $(EXTDIR)/kbp.cfacts/queryName_qid_name.cfacts
SCORE := $(EXTDIR)/proppr-output/kbp_train.trained.solutions.txt
TOKEN := $(EXTDIR)/kbp.cfacts/inDocument_did_tok.cfacts
TACPR := /remote/curtis/bbd/KBP_2014/alignKBs/e54_v11.docid_wp14_enType_score_begin_end_mention.TAC_id_name_type.txt

# project directories (top-level) 
DATDIR := data
RSCDIR := resources
EXPDIR := $(RSCDIR)/ExploreEM_package_v2
IPTDIR := $(EXPDIR)/data
OUTDIR := output
RESDIR := results
SRCDIR := src

# src subdirectories
PREDIR := $(SRCDIR)/preprocessing
BASDIR := $(SRCDIR)/baseline
EEMDIR := $(SRCDIR)/exploratory
SSLDIR := $(SRCDIR)/semi_supervised
USLDIR := $(SRCDIR)/unsupervised

# raw input
QID_DID := $(DATDIR)/qid_did.txt
QID_DID_STRING_EID := $(DATDIR)/qid_did_string_eid.txt
QID_EID := $(DATDIR)/qid_eid.txt
QID_NAME := $(DATDIR)/queryName_qid_name.txt
DID_TOK := $(DATDIR)/inDocument_did_tok.txt
QID_EID_SCORE := $(DATDIR)/qid_eid_score.txt
QID_RID := $(DATDIR)/qid_rid.txt
DID_FEATURE := $(DATDIR)/qid_rid_did_value_weight.txt
EID_FEATURE := $(DATDIR)/qid_rid_eid_value_weight.txt
STRING_FEATURE := $(DATDIR)/qid_rid_string_value_weight.txt
TOKEN_FEATURE := $(DATDIR)/qid_rid_token_value_weight.txt
RID_FID_WEIGHT := $(DATDIR)/rid_fid_weight.txt

TACPR_RAW := $(DATDIR)/did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.txt

# exploreEM input
DATA_X := $(IPTDIR)/data.X.txt
DATA_Y := $(IPTDIR)/data.Y.txt

# exploreEM input
ASSGN := $(IPTDIR)/KM*explore*.assgn.txt

# TODO refactor ". venv/bin/activate python" into PYTHON
PYTHON := . venv/bin/activate; python

# matlab
M_FLAGS := -nodesktop -nosplash -r
EM_MAIN := "try, All_BIC_ExplEM_Main; catch, end, exit"

# output
BASELINE0 := $(OUTDIR)/baseline0.txt
BASELINE1 := $(OUTDIR)/baseline1.txt
BASELINE2 := $(OUTDIR)/baseline2.txt
BASELINE3 := $(OUTDIR)/baseline3.txt
UNSUPERVISED0 := $(OUTDIR)/unsupervised0.txt
UNSUPERVISED1 := $(OUTDIR)/unsupervised1.txt
SEMI_SUPERVISED0 := $(OUTDIR)/semi_supervised0.txt
SEMI_SUPERVISED1 := $(OUTDIR)/semi_supervised1.txt

# ------------------------------------------------------------------------------

all: baseline

# ------------------------------------------------------------------------------

# obtain raw input from external sources
.PHONY: raw
raw : $(QID_DID_STRING_EID) $(RID_FID_WEIGHT) $(TACPR_RAW)

$(QID_EID): | $(DATDIR)
	cp $(PROPPR) $(QID_EID)

# TODO PROBLEM: PROPPR REMOVES NAMES WITH SPECIAL CHARACTERS; POLICY?
# (SHOULD NOT MATTER FOR EXPLORATORY VERSION -> STRING IS JUST ONE FEATURE)
$(QID_NAME): | $(DATDIR)
	cp $(QNAME) $(QID_NAME)

# TODO NB ORDER HAS BEEN CHANGED FROM (DID, QID) TO (QID, DID)
$(QID_DID): $(SCORE) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/parse_did.py < $(SCORE) > $(QID_DID)

$(QID_DID_STRING_EID): $(QID_EID) $(QID_NAME) $(QID_DID) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/generate_qid_did_string_eid.py \
		$(QID_EID) $(QID_NAME) $(QID_DID) > $(QID_DID_STRING_EID)

$(DID_TOK): | $(DATDIR)
	cp $(TOKEN) $(DID_TOK)

# TODO RAW FOR USL AND SSL
$(QID_RID): venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/generate_qid_rid.py \
		$(QID_EID) > $(QID_RID)

$(QID_EID_SCORE): $(SCORE) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/parse_score.py < $(SCORE) \
		> $(QID_EID_SCORE)

$(STRING_FEATURE): $(QID_NAME) $(QID_RID) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/generate_qid_rid_string_value_weight.py \
		$(QID_NAME) $(QID_RID) > $(STRING_FEATURE)

$(DID_FEATURE): $(QID_DID) $(QID_RID) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/generate_qid_rid_did_value_weight.py \
		$(QID_DID) $(QID_RID) > $(DID_FEATURE)

$(TOKEN_FEATURE): $(DID_TOK) $(DID_FEATURE) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/generate_qid_rid_term_value_weight.py \
		$(DID_TOK) $(DID_FEATURE) > $(TOKEN_FEATURE)

$(EID_FEATURE): $(QID_EID_SCORE) $(QID_RID) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/generate_qid_rid_eid_value_weight.py \
		$(QID_EID_SCORE) $(QID_RID) > $(EID_FEATURE)

$(RID_FID_WEIGHT): $(STRING_FEATURE) $(DID_FEATURE) $(TOKEN_FEATURE) \
		$(EID_FEATURE) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/generate_rid_fid_weight.py \
		$(STRING_FEATURE) $(DID_FEATURE) $(TOKEN_FEATURE) $(EID_FEATURE) \
		> $(RID_FID_WEIGHT)

# TODO PR INPUT
$(TACPR_RAW): venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.py \
		$(TACPR) > $(TACPR_RAW)

# ------------------------------------------------------------------------------

# create data directory
$(DATDIR):
	mkdir $(DATDIR)

# create output directory
$(OUTDIR):
	mkdir $(OUTDIR)

# create results directory
$(RESDIR):
	mkdir $(RESDIR)

# ------------------------------------------------------------------------------

# baseline clustering
.PHONY: baseline
baseline: $(BASELINE0) $(BASELINE1) $(BASELINE2) $(BASELINE3) 

# string only
$(BASELINE0): $(QID_DID_STRING_EID) venv | $(OUTDIR)
	. venv/bin/activate; python $(BASDIR)/baseline0.py \
		$(QID_DID_STRING_EID) > $(BASELINE0)

# string and did
$(BASELINE1): $(QID_DID_STRING_EID) venv | $(OUTDIR)
	. venv/bin/activate; python $(BASDIR)/baseline1.py \
		$(QID_DID_STRING_EID) > $(BASELINE1)

# string and document distance (agglomerative)
$(BASELINE2): $(QID_DID_STRING_EID) $(DID_TOK) venv | $(OUTDIR)
	. venv/bin/activate; python $(BASDIR)/baseline2.py \
		$(QID_DID_STRING_EID) $(DID_TOK)  > $(BASELINE2)

# string and document distance (exploratory)
$(BASELINE3): $(QID_DID_STRING_EID) $(DID_TOK) venv | $(OUTDIR)
	rm -rf $(IPTDIR)/*
	. venv/bin/activate; python $(BASDIR)/baseline3.py \
		$(QID_DID_STRING_EID) $(DID_TOK) $(EXPDIR)  > $(BASELINE3)

# exploratory clustering
.PHONY: explore
explore: $(UNSUPERVISED0) $(SEMI_SUPERVISED0)

# unsupervised without local context
$(UNSUPERVISED0): $(RID_FID_WEIGHT) $(QID_RID) $(QID_EID) venv | $(OUTDIR)
	rm -rf $(IPTDIR)/*
	cp $(RID_FID_WEIGHT) $(DATA_X)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	echo "1\t1" > $(DATA_Y)
	cd $(EXPDIR); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(EEMDIR)/exploratory.py $(ASSGN) $(QID_RID) $(QID_EID) \
		> $(UNSUPERVISED0)

# unsupervised with local context
# TODO

# semi-supervised without local context
$(SEMI_SUPERVISED0): $(RID_FID_WEIGHT) $(QID_RID) $(QID_EID) venv | $(OUTDIR)
	rm -rf $(IPTDIR)/*
	cp $(RID_FID_WEIGHT) $(DATA_X)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	# TODO GENERATE SEEDS FROM PR OUTPUT
	cd $(EXPDIR); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(EEMDIR)/exploratory.py $(ASSGN) $(QID_RID) $(QID_EID) \
		> $(SEMI_SUPERVISED0)

# semi-supervised with local context
# TODO

# ------------------------------------------------------------------------------

# create virtualenv
venv: venv/bin/activate

# activate virtualenv
venv/bin/activate: $(RSCDIR)/requirements.txt
	test -d venv || virtualenv venv
	. venv/bin/activate; pip install -Ur $(RSCDIR)/requirements.txt
	touch venv/bin/activate

# ------------------------------------------------------------------------------

# remove data, output, and results
.PHONY: clean
clean:
	rm -rf $(DATDIR) $(OUTDIR) $(RESDIR)

.PHONY: cleandist
cleandist: clean
	rm -rf venv build
