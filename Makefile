# location of external sources; usually the only lines that need to be changed
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt
QNAME := $(EXTDIR)/kbp.cfacts/queryName_qid_name.cfacts
SCORE := $(EXTDIR)/proppr-output/kbp_train.trained.solutions.txt
TOKEN := $(EXTDIR)/kbp.cfacts/inDocument_did_tok.cfacts

# project directories (top-level) 
DATDIR := data
EXPDIR := resources/ExploreEM_package_v2
OUTDIR := output
RESDIR := results
RSCDIR := resources
SRCDIR := src

# src subdirectories
BASDIR := $(SRCDIR)/baseline
SSLDIR := $(SRCDIR)/semi_supervised
USLDIR := $(SRCDIR)/unsupervised
PREDIR := $(SRCDIR)/preprocessing

# raw input
QID_EID := $(DATDIR)/qid_eid.txt
QID_NAME := $(DATDIR)/queryName_qid_name.txt
QID_DID := $(DATDIR)/qid_did.txt
QID_DID_STRING_EID := $(DATDIR)/qid_did_string_eid.txt
DID_TOK := $(DATDIR)/inDocument_did_tok.txt

# output
BASELINE0 := $(OUTDIR)/baseline0.txt
BASELINE1 := $(OUTDIR)/baseline1.txt
BASELINE2 := $(OUTDIR)/baseline2.txt
BASELINE3 := $(OUTDIR)/baseline3.txt

# ------------------------------------------------------------------------------

all: BASELINE

# ------------------------------------------------------------------------------

# obtain raw input from external sources
#RAW : $(QID_EID) $(QID_NAME) $(QID_DID)
RAW : $(QID_DID_STRING_EID) $(DID_TOK)

$(QID_EID): | $(DATDIR)
	cp $(PROPPR) $(QID_EID)

$(QID_NAME): | $(DATDIR)
	cp $(QNAME) $(QID_NAME)

# TODO NB ORDER HAS BEEN CHANGED FROM (DID, QID) TO (QID, DID)
$(QID_DID): venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/parse_did.py < $(SCORE) > $(QID_DID)

$(QID_DID_STRING_EID): $(QID_EID) $(QID_NAME) $(QID_DID) venv | $(DATDIR)
	. venv/bin/activate; python $(PREDIR)/generate_qid_did_string_eid.py \
		$(QID_EID) $(QID_NAME) $(QID_DID) > $(QID_DID_STRING_EID)

$(DID_TOK): | $(DATDIR)
	cp $(TOKEN) $(DID_TOK)

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
BASELINE: $(BASELINE0) $(BASELINE1) $(BASELINE2) $(BASELINE3) 

$(BASELINE0): $(QID_DID_STRING_EID) venv | $(OUTDIR)
	. venv/bin/activate; python $(BASDIR)/baseline0.py \
		$(QID_DID_STRING_EID) > $(BASELINE0)

$(BASELINE1): $(QID_DID_STRING_EID) venv | $(OUTDIR)
	. venv/bin/activate; python $(BASDIR)/baseline1.py \
		$(QID_DID_STRING_EID) > $(BASELINE1)

$(BASELINE2): $(QID_DID_STRING_EID) $(DID_TOK) venv | $(OUTDIR)
	. venv/bin/activate; python $(BASDIR)/baseline2.py \
		$(QID_DID_STRING_EID) $(DID_TOK)  > $(BASELINE2)

$(BASELINE3): $(QID_DID_STRING_EID) $(DID_TOK) venv | $(OUTDIR)
	. venv/bin/activate; python $(BASDIR)/baseline3.py \
		$(QID_DID_STRING_EID) $(DID_TOK) $(EXPDIR)  > $(BASELINE3)

# ------------------------------------------------------------------------------

# create virtualenv
venv: venv/bin/activate

venv/bin/activate: $(RSCDIR)/requirements.txt
	test -d venv || virtualenv venv
	. venv/bin/activate; pip install -Ur $(RSCDIR)/requirements.txt
	touch venv/bin/activate

# ------------------------------------------------------------------------------

# remove data, output, and results
clean:
	rm -rf $(DATDIR) $(OUTDIR) $(RESDIR)

.PHONY: clean
