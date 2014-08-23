# location of external sources
# NB these should be the only lines that need to be changed
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt
QNAME := $(EXTDIR)/kbp.cfacts/queryName_qid_name.cfacts
SCORE := $(EXTDIR)/proppr-output/kbp_train.trained.solutions.txt
TOKEN := $(EXTDIR)/kbp.cfacts/inDocument_did_tok.cfacts
TACPR := /remote/curtis/bbd/KBP_2014/alignKBs/e54_v11.docid_wp14_enType_score_begin_end_mention.TAC_id_name_type.txt
GOLD := /remote/curtis/krivard/2014/e54_v11.tac_2014_kbp_english_EDL_training_KB_links.tab

# ==============================================================================

# project directories
datdir := data
rscdir := resources
expdir := $(rscdir)/ExploreEM_package_v2
iptdir := $(expdir)/data
outdir := output
resdir := results
srcdir := src

# src subdirectories
# TODO move all scripts into src and remove subdirs? 
# If yes, then use vpath instead of srcdir prefix
predir := $(srcdir)/preprocessing
basdir := $(srcdir)/baseline
eemdir := $(srcdir)/exploratory

# ------------------------------------------------------------------------------
# set vpath
#vpath %.txt $(datdir)
#vpath %.py $(srcdir)/*

# ------------------------------------------------------------------------------

# raw input
# TODO remove datdir prefix and use vpath instead
qid_did := $(datdir)/qid_did.txt
qid_did_string_eid := $(datdir)/qid_did_string_eid.txt
qid_eid := $(datdir)/qid_eid.txt
qid_name := $(datdir)/queryName_qid_name.txt
did_tok := $(datdir)/inDocument_did_tok.txt
qid_eid_score := $(datdir)/qid_eid_score.txt
qid_rid := $(datdir)/qid_rid.txt
did_feature := $(datdir)/qid_rid_did_value_weight.txt
eid_feature := $(datdir)/qid_rid_eid_value_weight.txt
string_feature := $(datdir)/qid_rid_string_value_weight.txt
token_feature := $(datdir)/qid_rid_token_value_weight.txt
rid_fid_weight := $(datdir)/rid_fid_weight.txt
tacpr_raw := $(datdir)/did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.txt
qid_tacid := $(datdir)/qid_tacid.txt
rid_lid_score := $(datdir)/rid_lid_score.txt

# ------------------------------------------------------------------------------

# exploreEM
data_X := $(iptdir)/data.X.txt
data_Y := $(iptdir)/data.Y.txt
seeds_Y := $(iptdir)/seeds.Y.txt
assgn := $(iptdir)/KM*explore*.assgn.txt

# ------------------------------------------------------------------------------

# output
baseline0 := $(outdir)/baseline0.txt
baseline1 := $(outdir)/baseline1.txt
baseline2 := $(outdir)/baseline2.txt
baseline3 := $(outdir)/baseline3.txt
unsupervised0 := $(outdir)/unsupervised0.txt
unsupervised1 := $(outdir)/unsupervised1.txt
semi_supervised0 := $(outdir)/semi_supervised0.txt
semi_supervised1 := $(outdir)/semi_supervised1.txt

# ------------------------------------------------------------------------------

# results
gold_qid_eid := $(datdir)/gold_qid_eid.txt
results := $(resdir)/results.txt

# ------------------------------------------------------------------------------

# python
PYTHON := . venv/bin/activate; python

# matlab
M_FLAGS := -nodesktop -nosplash -r
EM_MAIN := "try, All_BIC_ExplEM_Main; catch, end, exit"

# scorer
SCORER := $(rscdir)/el_scorer.py

# ==============================================================================

all: baseline

# ------------------------------------------------------------------------------

.PHONY: raw
raw : $(qid_did_string_eid) $(rid_fid_weight) $(rid_lid_score)

# prepare common input for baseline and exploreEM
$(qid_eid): $(PROPPR) | $(datdir)
	cp $(PROPPR) $@

$(qid_name): $(QNAME) | $(datdir)
	cp $(QNAME) $@

$(qid_did): $(SCORE) venv | $(datdir)
	$(PYTHON) $(predir)/parse_did.py < $(SCORE) > $@

$(qid_did_string_eid): $(qid_eid) $(qid_name) $(qid_did) venv | $(datdir)
	$(PYTHON) $(predir)/generate_qid_did_string_eid.py \
		$(qid_eid) $(qid_name) $(qid_did) > $@

$(did_tok): $(TOKEN) | $(datdir)
	cp $(TOKEN) $@

# prepare additional input for exploreEM
$(qid_rid): venv | $(datdir)
	$(PYTHON) $(predir)/generate_qid_rid.py $(qid_eid) > $@

$(qid_eid_score): $(SCORE) venv | $(datdir)
	$(PYTHON) $(predir)/parse_score.py < $(SCORE) > $@

$(string_feature): $(qid_name) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(predir)/generate_qid_rid_string_value_weight.py \
		$(qid_name) $(qid_rid) > $@

$(did_feature): $(qid_did) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(predir)/generate_qid_rid_did_value_weight.py \
		$(qid_did) $(qid_rid) > $@

$(token_feature): $(did_tok) $(did_feature) venv | $(datdir)
	$(PYTHON) $(predir)/generate_qid_rid_term_value_weight.py \
		$(did_tok) $(did_feature) > $@

$(eid_feature): $(qid_eid_score) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(predir)/generate_qid_rid_eid_value_weight.py \
		$(qid_eid_score) $(qid_rid) > $@

$(rid_fid_weight): $(string_feature) $(did_feature) $(token_feature) \
		$(eid_feature) venv | $(datdir)
	$(PYTHON) $(predir)/generate_rid_fid_weight.py \
		$(string_feature) $(did_feature) $(token_feature) $(eid_feature) > $@

$(tacpr_raw): venv | $(datdir)
	$(PYTHON) $(predir)/generate_did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.py \
		$(TACPR) > $@

$(qid_tacid): $(tacpr_raw) $(qid_name) venv | $(datdir)
	$(PYTHON) $(predir)/generate_qid_tacid.py $(tacpr_raw) $(qid_name) > $@

$(rid_lid_score): $(qid_tacid) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(predir)/generate_rid_lid_score.py $(qid_tacid) $(qid_rid) > $@

# prepare input for scorer
$(gold_qid_eid): $(GOLD) $(baseline0) venv | $(datdir)
	# TODO use goldstandard and truncate it to smallest common subset
	$(PYTHON) $(predir)/generate_gold_qid_eid.py $(GOLD) $(baseline0) > $@

# ------------------------------------------------------------------------------

# create data directory
$(datdir):
	mkdir $@

# create output directory
$(outdir):
	mkdir $@

# create results directory
$(resdir):
	mkdir $@

# ------------------------------------------------------------------------------

# baseline clustering
.PHONY: baseline
baseline: $(baseline0) $(baseline1) $(baseline2) $(baseline3) 

# string only
$(baseline0): $(qid_did_string_eid) venv | $(outdir)
	$(PYTHON) $(basdir)/baseline0.py $(qid_did_string_eid) > $@

# string and did
$(baseline1): $(qid_did_string_eid) venv | $(outdir)
	$(PYTHON) $(basdir)/baseline1.py $(qid_did_string_eid) > $@

# string and document distance (agglomerative)
$(baseline2): $(qid_did_string_eid) $(did_tok) venv | $(outdir)
	$(PYTHON) $(basdir)/baseline2.py $(qid_did_string_eid) $(did_tok)  > $@

# string and document distance (exploratory)
$(baseline3): $(qid_did_string_eid) $(did_tok) venv | $(outdir)
	rm -rf $(iptdir)/*
	$(PYTHON) $(basdir)/baseline3.py \
		$(qid_did_string_eid) $(did_tok) $(expdir)  > $@

# exploratory clustering
.PHONY: explore
explore: $(unsupervised0) $(semi_supervised0)

# unsupervised without local context
$(unsupervised0): $(rid_fid_weight) $(qid_rid) $(qid_eid) venv | $(outdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight) $(data_X)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	echo "1\t1" > $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(eemdir)/exploratory.py $(assgn) $(qid_rid) $(qid_eid) > $@

# unsupervised with local context
# TODO

# semi-supervised without local context
$(semi_supervised0): $(rid_fid_weight) $(rid_lid_score) $(qid_rid) \
		$(qid_eid) venv | $(outdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight) $(data_X)
	cp $(rid_lid_score) $(seeds_Y)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	cp $(rid_lid_score) $(data_Y)
	# TODO GENERATE SEEDS FROM PR OUTPUT
	cd $(EXPDIR); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(eemdir)/exploratory.py $(assgn) $(qid_rid) $(qid_eid) > $@

# semi-supervised with local context
# TODO

# ------------------------------------------------------------------------------

# create virtualenv
venv: venv/bin/activate

# activate virtualenv
venv/bin/activate: $(rscdir)/requirements.txt
	test -d venv || virtualenv venv
	. $@; pip install -Ur $(rscdir)/requirements.txt
	touch $@

# ------------------------------------------------------------------------------

# results
result : $(results)

$(results): $(gold_qid_eid) venv | $(resdir)
	$(PYTHON) $(SCORER) $(gold_qid_eid) $(outdir) > $@

# ------------------------------------------------------------------------------

# remove data, output, and results
.PHONY: clean
clean:
	rm -rf $(datdir) $(outdir) $(resdir)

# remove virtualenv
.PHONY: cleandist
cleandist: clean
	rm -rf venv build
