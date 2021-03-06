################################################################################
#                 MAKEFILE NILCLUSTERING MODULE TAC/KBP 2014                   #
################################################################################
include Makefile.in

# ==============================================================================

# project directories
datdir := data
rscdir := resources
expdir := $(rscdir)/ExploreEM_package_v2
iptdir := $(expdir)/data
outdir := output
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
qid_did_string_eid_agglomerative := $(datdir)/qid_did_string_eid_agglomerative.txt
qid_did_string_eid_exploratory := $(datdir)/qid_did_string_eid_exploratory.txt

# additional exploreEM input
qid_rid := $(datdir)/qid_rid.txt
qid_eid_score := $(datdir)/qid_eid_score.txt
did_feature := $(datdir)/qid_rid_did_value_weight.txt
eid_feature := $(datdir)/qid_rid_eid_value_weight.txt
string_feature := $(datdir)/qid_rid_string_value_weight.txt
token_feature := $(datdir)/qid_rid_token_value_weight.txt
sid_feature := $(datdir)/qid_rid_sid_value_weight.txt
local_feature := $(datdir)/qid_rid_local_value_weight.txt
rid_fid_weight_global := $(datdir)/rid_fid_weight_global.txt
rid_fid_weight_local := $(datdir)/rid_fid_weight_local.txt
rid_fid_weight := $(datdir)/rid_fid_weight.txt

# additional exploreEM input (PageReactor)
qid_tacid := $(datdir)/qid_tacid.txt
tacpr_raw := $(datdir)/did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.txt
rid_lid_score := $(datdir)/rid_lid_score.txt

# ------------------------------------------------------------------------------

# exploreEM input and main script
data_X := $(iptdir)/data.X.txt
data_Y := $(iptdir)/data.Y.txt
seeds_Y := $(iptdir)/seeds.Y.txt
assgn_suffix := $(iptdir)/*assgn.txt

# ------------------------------------------------------------------------------

# output files
baseline0 := $(outdir)/baseline0.txt
baseline1 := $(outdir)/baseline1.txt
baseline2 := $(outdir)/baseline2.txt
baseline3 := $(outdir)/baseline3.txt
baseline4 := $(outdir)/baseline4.txt
baseline5 := $(outdir)/baseline5.txt
baseline6 := $(outdir)/baseline6.txt
baseline7 := $(outdir)/baseline7.txt
unsupervised0 := $(outdir)/unsupervised0.txt
unsupervised1 := $(outdir)/unsupervised1.txt
unsupervised2 := $(outdir)/unsupervised2.txt
semi_supervised0 := $(outdir)/semi_supervised0.txt
semi_supervised1 := $(outdir)/semi_supervised1.txt
semi_supervised2 := $(outdir)/semi_supervised2.txt
pagereactor0 := $(outdir)/pagereactor0.txt

# ------------------------------------------------------------------------------

# python
PYTHON := . venv/bin/activate; python

# matlab
M_FLAGS := -nodesktop -nosplash -r
EM_MAIN := "try, All_BIC_ExplEM_Main; catch, end, exit"

# ==============================================================================

# perform baseline, exploratory and pagereactor clustering
.DELETE_ON_ERROR:
all: baseline explore pagereactor

# ==============================================================================

# generate all input
.PHONY: raw
raw : $(qid_did_string_eid) $(qid_sid_string_eid) $(rid_fid_weight_global) \
	$(rid_fid_weight_local) $(rid_fid_weight) $(rid_lid_score) 

# ------------------------------------------------------------------------------

# generate common input for baseline and exploreEM
$(qid_eid): $(PROPPR_TRAIN) $(PROPPR_TEST) | $(datdir)
	#cp $(PROPPR) $@
	cat $(PROPPR_TRAIN) $(PROPPR_TEST) | sort > $@

$(qid_name): $(QNAME) | $(datdir)
	cp $(QNAME) $@

$(qid_sid): $(QSENT) | $(datdir)
	cp $(QSENT) $@

$(qid_did): $(SCORE_TRAIN) $(SCORE_TEST) venv | $(datdir)
	$(PYTHON) $(srcdir)/parse_did.py $(SCORE_TRAIN) $(SCORE_TEST) > $@

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

$(qid_eid_score): $(SCORE_TRAIN) $(SCORE_TEST) venv | $(datdir)
	$(PYTHON) $(srcdir)/parse_score.py $(SCORE_TRAIN) $(SCORE_TEST) > $@

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

$(rid_fid_weight_global): $(string_feature) $(did_feature) $(token_feature) \
		$(eid_feature) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_rid_fid_weight_global.py \
		$(string_feature) $(did_feature) $(token_feature) $(eid_feature) > $@

$(rid_fid_weight_local): $(string_feature) $(sid_feature) $(local_feature) \
		$(eid_feature) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_rid_fid_weight_local.py \
		$(string_feature) $(sid_feature) $(local_feature) $(eid_feature) > $@

$(rid_fid_weight): $(string_feature) $(did_feature) $(token_feature) \
	$(sid_feature) $(local_feature) $(eid_feature) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_rid_fid_weight.py \
		$(string_feature) $(did_feature) $(token_feature) \
		$(sid_feature) $(local_feature) $(eid_feature) > $@

# ------------------------------------------------------------------------------

# generate additional input for exploreEM (PageReactor)
$(tacpr_raw): venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_did_wp14_type_score_begin_end_mention_tacid_tacname_tactype.py \
		$(TACPR) > $@

$(qid_tacid): $(tacpr_raw) $(qid_name) venv | $(datdir)
	awk 'BEGIN{FS=OFS="\t"}{print sprintf("CMUPR_%04d",NR),$$8}' $(tacpr_raw) > $@
#	$(PYTHON) $(srcdir)/generate_qid_tacid.py $(tacpr_raw) $(qid_name) > $@

$(rid_lid_score): $(qid_tacid) $(qid_rid) venv | $(datdir)
	$(PYTHON) $(srcdir)/generate_rid_lid_score.py $(qid_tacid) $(qid_rid) > $@

# ==============================================================================

# baseline clustering
.PHONY: baseline
baseline: $(baseline0) $(baseline1) $(baseline2) $(baseline3) \
	$(baseline4) $(baseline5) $(baseline6) $(baseline7)
	#$(baseline4) $(baseline6)

# string only
$(baseline0): $(qid_did_string_eid) venv | $(outdir)
	$(PYTHON) $(srcdir)/baseline0.py $(FORMATTING_FLAGS) \
		$(qid_did_string_eid) > $@

# string and did
$(baseline1): $(qid_did_string_eid) venv | $(outdir)
	$(PYTHON) $(srcdir)/baseline1.py $(FORMATTING_FLAGS) \
	   	$(qid_did_string_eid) > $@

# string and document distance (agglomerative)
$(baseline2): $(qid_did_string_eid) $(did_tok) venv | $(outdir)
	$(PYTHON) $(srcdir)/baseline2.py $(FORMATTING_FLAGS) \
		$(GLOBAL_BASELINE_CLUSTERING_FLAGS) \
		$(qid_did_string_eid) $(did_tok) > $@

# string and document distance (exploratory)
$(baseline3): $(qid_did_string_eid) $(did_tok) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	$(PYTHON) $(srcdir)/baseline3.py $(FORMATTING_FLAGS) \
		$(qid_did_string_eid) $(did_tok) $(expdir) > $@

# string and sentence distance (agglomerative)
$(baseline4): $(qid_sid_string_eid) $(sid_tok) venv | $(outdir)
	$(PYTHON) $(srcdir)/baseline4.py $(FORMATTING_FLAGS) \
		$(LOCAL_BASELINE_CLUSTERING_FLAGS) \
		$(qid_sid_string_eid) $(sid_tok) > $@

# string and sentence distance (exploratory)
$(baseline5): $(qid_sid_string_eid) $(sid_tok) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	$(PYTHON) $(srcdir)/baseline5.py $(FORMATTING_FLAGS) \
		$(qid_sid_string_eid) $(sid_tok) $(expdir) > $@

# string and sentence distance (agglomerative) where available;
# string and document distance for remaining queries
$(baseline6): $(qid_did_string_eid) $(did_tok) $(baseline4) venv | $(outdir)
	# step 1: merge local context data into original data
	$(PYTHON) $(srcdir)/generate_qid_did_string_eid_local.py \
		$(qid_did_string_eid) $(baseline4) > $(qid_did_string_eid_agglomerative)
	# step 2: perform document distance clustering on remaining nils
	$(PYTHON) $(srcdir)/baseline2.py --existing $(FORMATTING_FLAGS) \
		$(qid_did_string_eid_agglomerative) $(did_tok) > $@
	# TODO CHECK RESULT

# string and sentence distance (exploratory) where available;
# string and document distance for remaining queries
$(baseline7): $(qid_did_string_eid) $(did_tok) $(baseline5) venv | $(outdir) \
	$(iptdir)
	# step 1: merge local context data into original data
	$(PYTHON) $(srcdir)/generate_qid_did_string_eid_local.py \
		$(qid_did_string_eid) $(baseline5) > $(qid_did_string_eid_exploratory)
	# step 2: perform document distance clustering on remaining nils
	rm -rf $(iptdir)/*
	$(PYTHON) $(srcdir)/baseline3.py --existing $(FORMATTING_FLAGS) \
		$(qid_did_string_eid_exploratory) $(did_tok) $(expdir) > $@
	# TODO CHECK RESULT

# ------------------------------------------------------------------------------

# exploratory clustering
.PHONY: explore
explore: $(unsupervised0) $(unsupervised1) $(unsupervised2) \
	$(semi_supervised0) $(semi_supervised1) $(semi_supervised2)

# TODO REFACTOR INTO ONE TARGET EACH ###

# unsupervised with global context only
$(unsupervised0): $(rid_fid_weight_global) $(qid_rid) $(qid_eid) venv | \
		$(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight_global) $(data_X)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE DATAPOINT
	echo "1\t1" > $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py $(FORMATTING_FLAGS) \
		$(assgn_suffix) $(qid_rid) $(qid_eid) > $@

# unsupervised with local context only
$(unsupervised1): $(rid_fid_weight_local) $(qid_rid) $(qid_eid) venv | \
		$(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight_local) $(data_X)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE DATAPOINT
	echo "1\t1" > $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py $(FORMATTING_FLAGS) \
		$(assgn_suffix) $(qid_rid) $(qid_eid) > $@

# unsupervised with global and local context
$(unsupervised2): $(rid_fid_weight) $(qid_rid) $(qid_eid) venv | \
		$(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight) $(data_X)
	# TODO WORKAROUND: SEED FILE WITH ONLY ONE DATAPOINT
	echo "1\t1" > $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py $(FORMATTING_FLAGS) \
		$(assgn_suffix) $(qid_rid) $(qid_eid) > $@

# semi-supervised with global context only
$(semi_supervised0): $(rid_fid_weight_global) $(rid_lid_score) $(qid_rid) \
		$(qid_eid) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight_global) $(data_X)
	cp $(rid_lid_score) $(seeds_Y)
	cp $(rid_lid_score) $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py $(FORMATTING_FLAGS) \
		$(assgn_suffix) $(qid_rid) $(qid_eid) > $@

# semi-supervised with local context only
$(semi_supervised1): $(rid_fid_weight_local) $(rid_lid_score) $(qid_rid) \
		$(qid_eid) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight_local) $(data_X)
	cp $(rid_lid_score) $(seeds_Y)
	cp $(rid_lid_score) $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py $(FORMATTING_FLAGS) \
		$(assgn_suffix) $(qid_rid) $(qid_eid) > $@

# semi-supervised with global and local context
$(semi_supervised2): $(rid_fid_weight) $(rid_lid_score) $(qid_rid) \
		$(qid_eid) venv | $(outdir) $(iptdir)
	rm -rf $(iptdir)/*
	cp $(rid_fid_weight) $(data_X)
	cp $(rid_lid_score) $(seeds_Y)
	cp $(rid_lid_score) $(data_Y)
	cd $(expdir); matlab $(M_FLAGS) $(EM_MAIN)
	$(PYTHON) $(srcdir)/exploratory.py $(FORMATTING_FLAGS) \
		$(assgn_suffix) $(qid_rid) $(qid_eid) > $@

# ------------------------------------------------------------------------------

# pagereactor clustering
.PHONY: pagereactor
pagereactor: $(pagereactor0)

# pagereactor output grouped by string
#$(pagereactor0): $(qid_tacid) | $(outdir)
#	cp $(qid_tacid) $@

$(pagereactor0):
	cd pagereactor; $(MAKE) $(MFLAGS)
	cp pagereactor/pagereactor0.txt $@

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

# ==============================================================================

# remove data and output
.PHONY: clean
clean:
	rm -rf $(datdir) $(outdir)

# remove virtualenv
.PHONY: cleandist
cleandist: clean
	rm -rf venv build
