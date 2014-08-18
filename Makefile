# location of external sources; usually the only lines that need to be changed
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt
QNAME := $(EXTDIR)/kbp.cfacts/queryName_qid_name.cfacts
SCORE := $(EXTDIR)/proppr-output/kbp_train.trained.solutions.txt

# project directories (top-level) 
DATDIR := data
OUTDIR := output
RESDIR := results
SRCDIR := src

# src subdirectories
BASDIR := $(SRCDIR)/baseline
SSLDIR := $(SRCDIR)/semi_supervised
USLDIR := $(SRCDIR)/unsupervised
PREDIR := $(SRCDIR)/preprocessing

# raw input
QID_EID := $(DATDIR)/qid_eid.txt
QID_STR := $(DATDIR)/queryName_qid_name.txt
QID_DID := $(DATDIR)/qid_did.txt

# ------------------------------------------------------------------------------

all: RAW

# ------------------------------------------------------------------------------

# obtain raw input from external sources
RAW : $(QID_EID) $(QID_STR) $(QID_DID)

$(QID_EID): | $(DATDIR)
	cp $(PROPPR) $(QID_EID)

$(QID_STR): | $(DATDIR)
	cp $(QNAME) $(QID_STR)

# TODO NB ORDER HAS BEEN CHANGED FROM (DID, QID) TO (QID, DID)
$(QID_DID): | $(DATDIR)
	./$(PREDIR)/parse_did.py < $(SCORE) > $(QID_DID)

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

# remove data, output, and results
clean:
	rm -rf $(DATDIR) $(OUTDIR) $(RESDIR)

.PHONY: clean
