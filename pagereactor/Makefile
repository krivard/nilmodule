include ../Makefile.in

TAB=$(shell echo "\t")

all: pagereactor0.txt

clean:
	rm -rf pagereactor*

# drop non-KBP queries
pagereactor.candidates: ${TACPR}
	awk 'BEGIN{FS=OFS="\t";k=1;}{if ($NF != "OTHER") { print sprintf("CMUPR_%04d",k),$$0; k++}}' $< > $@

# generate a unique ID for each wp14 page
pagereactor0.eids: pagereactor.candidates
	cut -f 3 $< | \
	sort -t "${TAB}" -k 1b,1 | \
	uniq | \
	awk 'BEGIN{FS=OFS="\t"}{print $$0,sprintf("nil%04d",NR)}' > $@

# match nil TAC ids to their unique id
pagereactor0.txt: pagereactor.candidates pagereactor0.eids
	sort -t "${TAB}" -k 3b,3 $(word 1,$^) | \
	join -t "${TAB}" -1 3 - $(word 2,$^) | \
	awk 'BEGIN{FS=OFS="\t"}{ tacid=$$9; if (tacid == "") { tacid = $$NF; } print $$2,tacid}' | \
	sort -k 1b,1 > $@