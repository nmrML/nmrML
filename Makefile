# Grab the current version
VERSION := $(shell sed '/^$$/d' VERSION)
MAJOR   := $(shell echo $(VERSION) | cut -f1 -d'.' )
MINOR   := $(shell echo $(VERSION) | cut -f2 -d'.' )
BUILD   := $(shell echo $(VERSION) | cut -f3 -d'.' )

.PHONY: docs docs_clean docs_rebuild tidy undo_tag show_tags \
	show_tags bump_build bump_minor bump_major prepare_release \
	release_major release_minor release_build

# Build the docs if they don't exist
docs: docs/schema.html

# Delete all the generated docs
docs_clean:
	rm docs/schema.html

# Delete and rebuild the docs
docs_rebuild: docs_clean docs

# Build the html file explaining the schema from the xsd file
docs/schema.html: schemas/nmr-ml.xsd tidy
	xsltproc --stringparam title "NMR-ML v$(shell cat VERSION)" \
         lib/xs3p.xsl schemas/nmr-ml.xsd > docs/schema.html

# Tidy up the files to prepare for pushingn changes
# Strip white space from the VERSION
# Sort the AUTHORS file and remove blank lines
tidy:
	sed -i ".tmp" -e '/^$$/d' VERSION && rm VERSION.tmp
	sed '/^$$/d' AUTHORS  | sort -o AUTHORS
	
# Tag the current version
tag: tidy
	git tag -a v$$(cat VERSION) 

# Delete the tag if you accidently made it too soon
undo_tag:
	git tag -d v$$(cat VERSION)

show_tags:
	git tag -l -n1

bump_build:
	echo $(MAJOR).$(MINOR).$(shell expr $(BUILD) + 1 ) > VERSION

bump_minor:
	echo $(MAJOR).$(shell expr $(MINOR) + 1 ).0 > VERSION

bump_major:
	echo $(shell expr $(MAJOR) + 1 ).0.0 > VERSION

prepare_release: tidy docs_rebuild
	git add AUTHORS VERSION docs
	git commit -m "Release $$(cat VERSION)"

release_build: bump_build prepare_release

release_minor: bump_minor prepare_release

release_major: bump_major prepare_release

show_version:
	@echo "version:   $(VERSION)"
	@echo "major:     $(MAJOR)"	 
	@echo "minor:     $(MINOR)"	 
	@echo "build:     $(BUILD)"	 
	@echo "revision:  "`git rev-parse --short HEAD`
