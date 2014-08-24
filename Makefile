################################################################################
#                 MAKEFILE NILCLUSTERING MODULE TAC/KBP 2014                   #
################################################################################

# external data (NB these should be the only lines that need to be changed)
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt
QNAME := $(EXTDIR)/kbp.cfacts/queryName_qid_name.cfacts
SCORE := $(EXTDIR)/proppr-output/kbp_train.trained.solutions.txt
TOKEN := $(EXTDIR)/kbp.cfacts/inDocument_did_tok.cfacts
QSENT := /remote/curtis/krivard/2014/kbp.dataset.2014-0.4/kbp.cfacts/querySentence_qid_sid.cfacts
INSENT := /remote/curtis/krivard/2014/kbp.dataset.2014-0.4/kbp.cfacts/inSentence_sid_tok.cfacts
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

# ------------------------------------------------------------------------------

# baseline and exploreEM input
qid_did := $(datdir)/qid_did.txt
qid_eid := $(datdir)/qid_eid.txt
qid_name := $(datdir)/queryName_qid_name.txt
qid_sid := $(datdir)/querySentence_qid_sid.txt
did_tok := $(datdir)/inDocument_did_tok.txt
sid_tok := $(datdir)/inSentence_sid_tok.txt
qid_did_string_eid := $(datdir)/qid_did_string_eid.txt
qid_sid_string_eid := $(datdir)/qid_sid_string_eid.txt

# additional exploreEM input
qid_rid := $(datdir)/qid_rid.txt
qid_eid_score := $(datdir)/qid_eid_score.txt
did_feature := $(datdir)/qid_rid_did_value_weight.txt
eid_feature := $(datdir)/qid_rid_eid_value_weight.txt
string_feature := $(datdir)/qid_rid_string_value_weight.txt
token_feature := $(datdir)/qid_rid_token_value_weight.txt
sid_feature := $(datdir)/qid_rid_sid_value_weight.txt
local_feature := $(datdir)/qid_rid_local_value_weight.txt
rid_fid_weight := $(datdir)/rid_fid_weight.txt
rid_fid_weight_local := $(datdir)/rid_fid_weight_local.txt

# additional exploreEM input (PageReactor)
qid_tacid := $(datdir)/qid_tacid.txt
tacpr_raw := $(datdir)/did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.txt
rid_lid_score := $(datdir)/rid_lid_score.txt

# ------------------------------------------------------------------------------

# exploreEM input and main script
data_X := $(iptdir)/data.X.txt
data_Y := $(iptdir)/data.Y.txt
seeds_Y := $(iptdir)/seeds.Y.txt
# TODO HOW TO DO GLOBBIGN?
assgn_suffix := $(iptdir)/*assgn.txt
#assgn := $(iptdir)/KM*explore*.assgn.txt

# ------------------------------------------------------------------------------

# output files
baseline0 := $(outdir)/baseline0.txt
baseline1 := $(outdir)/baseline1.txt
baseline2 := $(outdir)/baseline2.txt
baseline3 := $(outdir)/baseline3.txt
baseline4 := $(outdir)/baseline4.txt
baseline5 := $(outdir)/baseline5.txt
unsupervised0 := $(outdir)/unsupervised0.txt
unsupervised1 := $(outdir)/unsupervised1.txt
semi_supervised0 := $(outdir)/semi_supervised0.txt
semi_supervised1 := $(outdir)/semi_supervised1.txt

# ------------------------------------------------------------------------------

# evaluation input and results
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

# perform baseline and exploratory clustering (output will not be evaluated)
all: baseline explore

# ==============================================================================

# generate all input
.PHONY: raw
raw : $(qid_did_string_eid) $(qid_sid_string_eid) $(rid_fid_weight) \
	$(rid_lid_score) $(rid_fid_weight_local)

# ------------------------------------------------------------------------------

# generate common input for baseline and exploreEM
$(qid_eid): $(PROPPR) | $(datdir)
	cp $(PROPPR) $@

$(qid_name): $(QNAME) | $(datdir)
	cp $(QNAME) $@

$(qid_sid): $(QSENT) | $(datdir)
	cp $(QSENT) $@

$(qid_did): $(SCORE) venv | $(datdir)
	$(PYTHON) $(srcdir)/parse_did.py < $(SCORE) > $@

$(qid_did_string_eid): $(qid_eid) $(qid_name) $(qid_did) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_did_string_eid.py \
		$(qid_eid) $(qid_name) $(qid_did) > $@

$(qid_sid_string_eid): $(qid_eid) $(qid_name) $(qid_sid) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_sid_string_eid.py \
		$(qid_eid) $(qid_name) $(qid_sid) > $@

$(did_tok): $(TOKEN) | $(datdir)
	cp $(TOKEN) $@

$(sid_tok): $(INSENT) | $(datdir)
	cp $(INSENT) $@

# ------------------------------------------------------------------------------

# generate additional input for exploreEM
$(qid_rid): venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_rid.py $(qid_eid) > $@

$(qid_eid_score): $(SCORE) venv | $(datdir)
	$(PYTHON) $(srcdir)/parse_score.py < $(SCORE) > $@

$(string_feature): $(qid_name) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_rid_string_value_weight.py \
		$(qid_name) $(qid_rid) > $@

$(did_feature): $(qid_did) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_rid_did_value_weight.py \
		$(qid_did) $(qid_rid) > $@

$(sid_feature): $(qid_sid) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_rid_sid_value_weight.py \
		$(qid_sid) $(qid_rid) > $@

$(token_feature): $(did_tok) $(did_feature) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_rid_term_value_weight.py \
		$(did_tok) $(did_feature) > $@

$(local_feature): $(sid_tok) $(sid_feature) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_rid_local_value_weight.py \
		$(sid_tok) $(sid_feature) > $@

$(eid_feature): $(qid_eid_score) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_rid_eid_value_weight.py \
		$(qid_eid_score) $(qid_rid) > $@

$(rid_fid_weight): $(string_feature) $(did_feature) $(token_feature) \
		$(eid_feature) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_rid_fid_weight.py \
		$(string_feature) $(did_feature) $(token_feature) $(eid_feature) > $@

$(rid_fid_weight_local): $(string_feature) $(sid_feature) $(local_feature) \
		$(eid_feature) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_rid_fid_weight_local.py \
		$(string_feature) $(sid_feature) $(local_feature) $(eid_feature) > $@

# ------------------------------------------------------------------------------

# generate additional input for exploreEM (PageReactor)
$(tacpr_raw): venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.py \
		$(TACPR) > $@

$(qid_tacid): $(tacpr_raw) $(qid_name) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_qid_tacid.py $(tacpr_raw) $(qid_name) > $@

$(rid_lid_score): $(qid_tacid) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_rid_lid_score.py $(qid_tacid) $(qid_rid) > $@

# ------------------------------------------------------------------------------

# prepare input for scorer
$(gold_qid_eid): $(GOLD) $(baseline0) venv | $(datdir)
	# TODO WORKAROUND: TRUNCATE GOLDSTANDARD TO SMALLEST COMMON SUBSET
	$(PYTHON) $(srcdir)/generate_gold_qid_eid.py $(GOLD) $(baseline0) > $@

# ==============================================================================

# baseline clustering
.PHONY: baseline
# TODO add $(baseline4) and $(baseline5)
baseline: $(baseline0) $(baseline1) $(baseline2) $(baseline3)

# string only
$(baseline0): $(qid_did_string_eid) venv | $(outdir)
	$(PYTHON) $(srcdir)/baseline0.py $(qid_did_string_eid) > $@

# string and did
$(baseline1): $(qid_did_string_eid) venv | $(outdir)
	$(PYTHON) $(srcdir)/baseline1.py $(qid_did_string_eid) > $@

# string and document distance (agglomerative)
$(baseline2): $(qid_did_string_eid) $(did_tok) venv | $(outdir)
	$(PYTHON) $(srcdir)/baseline2.py $(qid_did_string_eid) $(did_tok)  > $@

# string and document distance (exploratory)
$(baseline3): $(qid_did_string_eid) $(did_tok) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	$(PYTHON) $(srcdir)/baseline3.py \
		$(qid_did_string_eid) $(did_tok) $(expdir)  > $@

# string and sentence distance (agglomerative)
$(baseline4): $(qid_sid_string_eid) $(sid_tok) venv | $(outdir)
	$(PYTHON) $(srcdir)/baseline4.py $(qid_sid_string_eid) $(sid_tok)  > $@

# string and sentence distance (exploratory)
$(baseline5): $(qid_sid_string_eid) $(sid_tok) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	$(PYTHON) $(srcdir)/baseline5.py \
		$(qid_sid_string_eid) $(sid_tok) $(expdir)  > $@

# ------------------------------------------------------------------------------

# exploratory clustering
.PHONY: explore
explore: $(unsupervised0) $(unsupervised1) $(semi_supervised0) $(semi_supervised1)

# unsupervised without local context
$(unsupervised0): $(rid_fid_weight) $(qid_rid) $(qid_eid) venv | \
		$(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight) $(data_X)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	echo "1\t1" > $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py `echo $(assgn_suffix)` $(qid_rid) $(qid_eid) > $@

# unsupervised with local context only (i.e., no document-level token feature)
$(unsupervised1): $(rid_fid_weight_local) $(qid_rid) $(qid_eid) venv | \
		$(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight_local) $(data_X)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	echo "1\t1" > $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py `echo $(assgn_suffix)` $(qid_rid) $(qid_eid) > $@

# semi-supervised without local context
$(semi_supervised0): $(rid_fid_weight) $(rid_lid_score) $(qid_rid) \
		$(qid_eid) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight) $(data_X)
	cp $(rid_lid_score) $(seeds_Y)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	cp $(rid_lid_score) $(data_Y)
	# TODO GENERATE SEEDS FROM PR OUTPUT
	cd $(EXPDIR); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py `echo $(assgn_suffix)` $(qid_rid) $(qid_eid) > $@

# semi-supervised with local context
$(semi_supervised1): $(rid_fid_weight_local) $(rid_lid_score) $(qid_rid) \
		$(qid_eid) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight_local) $(data_X)
	cp $(rid_lid_score) $(seeds_Y)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE SEED
	cp $(rid_lid_score) $(data_Y)
	# TODO GENERATE SEEDS FROM PR OUTPUT
	cd $(EXPDIR); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py `echo $(assgn_suffix)` $(qid_rid) $(qid_eid) > $@

# ==============================================================================

# evaluate output
evaluate : $(results)

$(results): $(gold_qid_eid) $(outdir) venv | $(resdir)
	$(PYTHON) $(SCORER) $(gold_qid_eid) $(outdir) > $@

# ==============================================================================

# create virtualenv
venv: venv/bin/activate

# activate virtualenv
venv/bin/activate: $(rscdir)/requirements.txt
	test -d venv || virtualenv venv
	. $@; pip install -Ur $(rscdir)/requirements.txt
	touch $@

# ==============================================================================

# create data directory
$(datdir):
	mkdir $@

# create input directory
$(iptdir):
	mkdir $@

# create output directory
$(outdir):
	mkdir $@

# create results directory
$(resdir):
	mkdir $@

# ==============================================================================

# remove data, output, and results
.PHONY: clean
clean:
	rm -rf $(datdir) $(outdir) $(resdir)

# remove virtualenv
.PHONY: cleandist
cleandist: clean
	rm -rf venv build
