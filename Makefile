# location of external data
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3/
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt

# data, output and results directories
DATDIR := data
OUTDIR := output
RESDIR := results

# raw input
QID_EID := $(DATDIR)/qid_eid.txt

# src folder
SRCDIR := src

$(QID_EID): | $(DATDIR)
	cp $(PROPPR) $(QID_EID)

$(DATDIR):
	mkdir $(DATDIR)
