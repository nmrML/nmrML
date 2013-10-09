# Grab the current version
VERSION := $(shell sed '/^$$/d' VERSION)
MAJOR   := $(shell echo $(VERSION) | cut -f1 -d'.' )
MINOR   := $(shell echo $(VERSION) | cut -f2 -d'.' )
BUILD   := $(shell echo $(VERSION) | cut -f3 -d'.' )

## Detect where OpenMS lives
OPENMSSHARE := $(shell which FileInfo | sed -e s!bin[/]\\+FileInfo!share/OpenMS!g )

.PHONY: docs docs_clean docs_rebuild tidy undo_tag show_tags \
	show_tags bump_build bump_minor bump_major prepare_release \
	release_major release_minor release_build

# Build the docs if they don't exist
docs: docs/schema.html

# Delete all the generated docs
docs_clean:
	rm -f docs/schema.html

# Delete and rebuild the docs
docs_rebuild: docs_clean docs

# Build the html file explaining the schema from the xsd file
docs/schema.html: xml-schemata/nmrML.xsd tidy
	xsltproc --stringparam title "NMR-ML v$(shell cat VERSION)" \
         lib/xs3p.xsl xml-schemata/nmrML.xsd > docs/schema.html

# Build the html file explaining the schema of the PSI Mapping from the xsd file
docs/CvMapping-schema.html: ./xml-schemata/CvMapping.xsd tidy
	xsltproc --stringparam title "Ontology - Schema mapping for nmrML v$(shell cat VERSION)" \
         lib/xs3p.xsl ./xml-schemata/CvMapping.xsd > docs/CvMapping-schema.html

# Build the html file explaining the mapping between schema and Ontology.
# Requires CVInspector http://www-bs2.informatik.uni-tuebingen.de/services/OpenMS-release/html/UTILS_CVInspector.html
# from http://sourceforge.net/projects/open-ms/files/OpenMS/
docs/mapping_and_cv.html: ontologies/nmrCV.obo schemas/nmr-ml.xsd tidy tidy
	CVInspector -cv_files ontologies/nmrCV-protege.obo -cv_names NMR \
	-mapping_file ontologies/nmr-mapping.xml \
	-html docs/mapping_and_cv.html

# Build the Ontology as OBO from the OWL version.
# Until https://github.com/nmrML/nmrML/issues/42
# is fixed, this requires manual intervention
ontologies/nmrCV.obo: ontologies/nmrCV.owl
	echo "You need to manually save ontologies/nmrCV.owl as ontologies/nmrCV.obo"
	/bin/false

# Make sure OpenMS is using the latest versions of Schema, Ontology and the mapping
update-openms: xml-schemata/nmrML.xsd ontologies/nmrCV.obo ontologies/nmr-mapping.xml
	cp xml-schemata/nmrML.xsd ${OPENMSSHARE}/SCHEMAS/nmrCV.obo
	cp ontologies/nmrCV.obo ${OPENMSSHARE}/CV/nmrCV.obo
	cp ontologies/nmr-mapping.xml ${OPENMSSHARE}/MAPPING/nmrCV.obo

# Validate our examples against Schema, Ontology and the mapping
validate-all: update-openms validate-HMDB00005

validate-HMDB00005: 
	FileInfo -v -in examples/reference_spectra_example/HMDB00005.nmrML

# Tidy up the files to prepare for pushingn changes
# Strip white space from the VERSION
# Sort the AUTHORS file and remove blank lines
tidy:
	sed -i ".tmp" -e '/^$$/d' VERSION && rm -f VERSION.tmp
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
