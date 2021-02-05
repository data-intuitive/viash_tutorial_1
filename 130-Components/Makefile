FILE=README
SED=gsed

all: $(FILE).pdf $(FILE).html

$(FILE).md: $(FILE).Rmd
	# Use viash component from viash_docs
	knit $(FILE).Rmd --variant markdown --preserve_yaml false
	# Strip local paths
	$(SED) -i 's|/\([/a-zA-Z0-9]*\)/work|<...>/work|g' $(FILE).md
	$(SED) -i -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g" $(FILE).md
	@echo "$(shell date) ========> md done"

$(FILE).pdf: $(FILE).md
	pandoc $(FILE).md -o $(FILE).pdf -d ../stylesheets/tutorial.yaml
	@echo "$(shell date) ========> pdf done"

$(FILE).html: $(FILE).md
	pandoc $(FILE).md -o $(FILE).html -t html5 -s --self-contained --toc --variable toc-title="Table of Contents" --highlight-style espresso --include-in-header ../stylesheets/style.html
	@echo "$(shell date) ========> html done"

