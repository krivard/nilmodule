# location of external sources
# NB these should be the only lines that need to be changed
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt
QNAME := $(EXTDIR)/kbp.cfacts/queryName_qid_name.cfacts
SCORE := $(EXTDIR)/proppr-output/kbp_train.trained.solutions.txt
TOKEN := $(EXTDIR)/kbp.cfacts/inDocument_did_tok.cfacts
TACPR := /remote/curtis/bbd/KBP_2014/alignKBs/e54_v11.docid_wp14_enType_score_begin_end_mention.TAC_id_name_type.txt

# ==============================================================================

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
# TODO DELETE
#SSLDIR := $(SRCDIR)/semi_supervised
#USLDIR := $(SRCDIR)/unsupervised

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
QID_TACID := $(DATDIR)/qid_tacid.txt
RID_LID_SCORE := $(DATDIR)/rid_lid_score.txt

# ------------------------------------------------------------------------------

# exploreEM
DATA_X := $(IPTDIR)/data.X.txt
DATA_Y := $(IPTDIR)/data.Y.txt
SEEDS_Y := $(IPTDIR)/seeds.Y.txt
ASSGN := $(IPTDIR)/KM*explore*.assgn.txt

# ------------------------------------------------------------------------------

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

# python
PYTHON := . venv/bin/activate; python

# matlab
M_FLAGS := -nodesktop -nosplash -r
EM_MAIN := "try, All_BIC_ExplEM_Main; catch, end, exit"

# ==============================================================================

all: baseline

# ------------------------------------------------------------------------------

# obtain raw input from external sources
.PHONY: raw
raw : $(QID_DID_STRING_EID) $(RID_FID_WEIGHT) $(RID_LID_SCORE)

$(QID_EID): | $(DATDIR)
	cp $(PROPPR) $@

# TODO PROBLEM: PROPPR REMOVES NAMES WITH SPECIAL CHARACTERS; POLICY?
# (SHOULD NOT MATTER FOR EXPLORATORY VERSION -> STRING IS JUST ONE FEATURE)
$(QID_NAME): | $(DATDIR)
	cp $(QNAME) $@

# TODO NB ORDER HAS BEEN CHANGED FROM (DID, QID) TO (QID, DID)
$(QID_DID): $(SCORE) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/parse_did.py < $(SCORE) > $@

$(QID_DID_STRING_EID): $(QID_EID) $(QID_NAME) $(QID_DID) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_qid_did_string_eid.py \
		$(QID_EID) $(QID_NAME) $(QID_DID) > $@

$(DID_TOK): | $(DATDIR)
	cp $(TOKEN) $@

# TODO RAW FOR USL AND SSL
$(QID_RID): venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_qid_rid.py $(QID_EID) > $@

$(QID_EID_SCORE): $(SCORE) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/parse_score.py < $(SCORE) > $@

$(STRING_FEATURE): $(QID_NAME) $(QID_RID) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_qid_rid_string_value_weight.py \
		$(QID_NAME) $(QID_RID) > $@

$(DID_FEATURE): $(QID_DID) $(QID_RID) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_qid_rid_did_value_weight.py \
		$(QID_DID) $(QID_RID) > $@

$(TOKEN_FEATURE): $(DID_TOK) $(DID_FEATURE) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_qid_rid_term_value_weight.py \
		$(DID_TOK) $(DID_FEATURE) > $@

$(EID_FEATURE): $(QID_EID_SCORE) $(QID_RID) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_qid_rid_eid_value_weight.py \
		$(QID_EID_SCORE) $(QID_RID) > $@

$(RID_FID_WEIGHT): $(STRING_FEATURE) $(DID_FEATURE) $(TOKEN_FEATURE) \
		$(EID_FEATURE) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_rid_fid_weight.py \
		$(STRING_FEATURE) $(DID_FEATURE) $(TOKEN_FEATURE) $(EID_FEATURE) > $@

# TODO PR INPUT
$(TACPR_RAW): venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.py \
		$(TACPR) > $@

$(QID_TACID): $(TACPR_RAW) $(QID_NAME) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_qid_tacid.py $(TACPR_RAW) $(QID_NAME) > $@

#$(QID_LID): $(QID_TACID) $(QID_RID) venv | $(DATDIR)
#	$(PYTHON) $(PREDIR)/generate_rid_lid_score.py $(QID_TACID) $(QID_RID) \
#		> $(QID_LID)

$(RID_LID_SCORE): $(QID_TACID) $(QID_RID) venv | $(DATDIR)
	$(PYTHON) $(PREDIR)/generate_rid_lid_score.py $(QID_TACID) $(QID_RID) > $@

# ------------------------------------------------------------------------------

# create data directory
$(DATDIR):
	mkdir $@

# create output directory
$(OUTDIR):
	mkdir $@

# create results directory
$(RESDIR):
	mkdir $@

# ------------------------------------------------------------------------------

# baseline clustering
.PHONY: baseline
baseline: $(BASELINE0) $(BASELINE1) $(BASELINE2) $(BASELINE3) 

# string only
$(BASELINE0): $(QID_DID_STRING_EID) venv | $(OUTDIR)
	$(PYTHON) $(BASDIR)/baseline0.py $(QID_DID_STRING_EID) > $@

# string and did
$(BASELINE1): $(QID_DID_STRING_EID) venv | $(OUTDIR)
	$(PYTHON) $(BASDIR)/baseline1.py $(QID_DID_STRING_EID) > $@

# string and document distance (agglomerative)
$(BASELINE2): $(QID_DID_STRING_EID) $(DID_TOK) venv | $(OUTDIR)
	$(PYTHON) $(BASDIR)/baseline2.py $(QID_DID_STRING_EID) $(DID_TOK)  > $@

# string and document distance (exploratory)
$(BASELINE3): $(QID_DID_STRING_EID) $(DID_TOK) venv | $(OUTDIR)
	rm -rf $(IPTDIR)/*
	$(PYTHON) $(BASDIR)/baseline3.py \
		$(QID_DID_STRING_EID) $(DID_TOK) $(EXPDIR)  > $@

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
	$(PYTHON) $(EEMDIR)/exploratory.py $(ASSGN) $(QID_RID) $(QID_EID) > $@

# unsupervised with local context
# TODO

# semi-supervised without local context
$(SEMI_SUPERVISED0): $(RID_FID_WEIGHT) $(RID_LID_SCORE) $(QID_RID) \
		$(QID_EID) venv | $(OUTDIR)
	rm -rf $(IPTDIR)/*
	cp $(RID_FID_WEIGHT) $(DATA_X)
	cp $(RID_LID_SCORE) $(SEEDS_Y)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	cp $(RID_LID_SCORE) $(DATA_Y)
	# TODO GENERATE SEEDS FROM PR OUTPUT
	cd $(EXPDIR); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(EEMDIR)/exploratory.py $(ASSGN) $(QID_RID) $(QID_EID) > $@

# semi-supervised with local context
# TODO

# ------------------------------------------------------------------------------

# create virtualenv
venv: venv/bin/activate

# activate virtualenv
venv/bin/activate: $(RSCDIR)/requirements.txt
	test -d venv || virtualenv venv
	. $@; pip install -Ur $(RSCDIR)/requirements.txt
	touch $@

# ------------------------------------------------------------------------------

# remove data, output, and results
.PHONY: clean
clean:
	rm -rf $(DATDIR) $(OUTDIR) $(RESDIR)

.PHONY: cleandist
cleandist: clean
	rm -rf venv build
