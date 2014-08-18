# location of external data
EXTDIR := /remote/curtis/krivard/2014/kbp.dataset.2014-0.3/
PROPPR := $(EXTDIR)/proppr-output/kbp_train.trained.t_0.028.results.txt

# project directories
DATDIR := data
OUTDIR := output
RESDIR := results
SRCDIR := src

# raw input
QID_EID := $(DATDIR)/qid_eid.txt

# targets
$(QID_EID): | $(DATDIR)
	cp $(PROPPR) $(QID_EID)

$(DATDIR):
	mkdir $(DATDIR)

clean:
	rm -rf $(DATDIR) $(OUTDIR) $(RESDIR)

.PHONY: clean
