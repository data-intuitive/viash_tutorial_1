FILE=README
SED=gsed

$(FILE).md: $(FILE).Rmd
	# Use viash component from viash_docs
	knit $(FILE).Rmd
	# Strip local paths
	$(SED) -i 's,\x1B\[[0-9;]*m,,g' $(FILE).md
	$(SED) -i 's|/\([/a-zA-Z0-9]*\)/work|<...>/work|g' $(FILE).md

$(FILE).html: $(FILE).md
	pandoc $(FILE).md -o $(FILE).html -t html5 -s --self-contained --toc --highlight-style espresso

casts: $(FILE).Rmd
	mkdir -p casts/
	# Extract code blocks and create casts for them
	awk -f ../scripts/create_casts.awk $(FILE).Rmd
	# Strip local paths
	$(SED) -i 's|/\([/a-zA-Z0-9]*\)/work| <...>/work|g' casts/*.cast
	# base64 encode
	../scripts/encode.sh
	# generate gifs
	../scripts/togif.sh
