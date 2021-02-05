SUBDIRS := $(wildcard 1?0*/.)
FILE=README

all: $(SUBDIRS) $(FILE).md

$(SUBDIRS):
	$(MAKE) -C $@
	
$(FILE).md: $(FILE).Rmd $(SUBDIRS)
	# Use viash component from viash_docs
	knit $(FILE).Rmd --format=github_document

.PHONY: all $(SUBDIRS)
