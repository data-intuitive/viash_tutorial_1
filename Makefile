SUBDIRS := $(wildcard 030*/.)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
