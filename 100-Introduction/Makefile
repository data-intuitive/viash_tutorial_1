FILE=README
SED=gsed

$(FILE).md: $(FILE).Rmd
	# Use viash component from viash_docs
	knit $(FILE).Rmd --variant markdown
	# Strip local paths
	$(SED) -i 's|/\([/a-zA-Z0-9]*\)/work|<...>/work|g' $(FILE).md

$(FILE).html: $(FILE).md
	pandoc $(FILE).md -o $(FILE).html -t html5 -s --self-contained --toc --highlight-style espresso
