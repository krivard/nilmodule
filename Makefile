# location of external sources; usually the only lines that need to be changed
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3/
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt
QNAME := $(EXTDIR)/kbp.cfacts/queryName_qid_name.cfacts

# project directories (top-level) 
DATDIR := data
OUTDIR := output
RESDIR := results
SRCDIR := src

# src subdirectories
BASDIR := $(SRCDIR)/baseline
SSLDIR := $(SRCDIR)/semi_supervised
USLDIR := $(SRCDIR)/unsupervised

# raw input
QID_EID := $(DATDIR)/qid_eid.txt
QID_STR := $(DATDIR)/queryName_qid_name.txt
#RAW := $(QID_EID) $(QID_STR)

all: RAW

# obtain raw input from external sources
RAW : $(QID_EID) $(QID_STR) 

$(QID_EID): | $(DATDIR)
	cp $(PROPPR) $(QID_EID)

$(QID_STR): | $(DATDIR)
	cp $(QNAME) $(QID_STR)

# create data directory
$(DATDIR):
	mkdir $(DATDIR)

# create output directory
$(OUTDIR):
	mkdir $(OUTDIR)

# create results directory
$(RESDIR):
	mkdir $(RESDIR)

# remove data, output, and results
clean:
	rm -rf $(DATDIR) $(OUTDIR) $(RESDIR)

.PHONY: clean
