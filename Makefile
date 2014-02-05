# Grab the current version
VERSION := $(shell sed '/^$$/d' VERSION)
MAJOR   := $(shell echo $(VERSION) | cut -f1 -d'.' )
MINOR   := $(shell echo $(VERSION) | cut -f2 -d'.' )
BUILD   := $(shell echo $(VERSION) | cut -f3 -d'.' )

## Some paths 

# Here is the checkout of https://github.com/nmrML/nmrML/blob/gh-pages/
GHP=../gh-pages/

# This is where OWL and HTML of CV will get copied
GHP_XSD = ${GHP}/schema/${VERSION}
GHP_CV = ${GHP}/cv/${VERSION}

## OPENMS settings
# This requires an OpenMS Installation
# XMLVALIDATOR=/vol/openms/src/OpenMS/bin/XMLValidator
# SEMANTICVALIDATOR=/vol/openms/src/OpenMS/bin/SemanticValidator

# The fallback if no OpenMS is available:
XMLVALIDATOR=/bin/true
SEMANTICVALIDATOR=/bin/true

OPENMSSHARE := $(shell which FileInfo | sed -e s!bin[/]\\+FileInfo!share/OpenMS!g )



.PHONY: docs docs_clean docs_rebuild tidy undo_tag show_tags \
	show_tags bump_build bump_minor bump_major prepare_release \
	release_major release_minor release_build \
	gh-pages-install

gh-pages-install: gh-pages-xsd-install gh-pages-specdoc-install gh-pages-cv-install gh-pages-mapping-install

gh-pages-xsd-install: #xml-schemata/nmrML.xsd docs/SchemaDocumentation/HTML_Serialisations/nmrML_xsd.html \
	@echo "Copying the schema" 
	cp -avx xml-schemata/nmrML.xsd ${GHP_XSD}

gh-pages-specdoc-install:
	@echo "Copy a fresh set of Word-exported SpecDoc HTML files" 
	rm -rf ${GHP_XSD}/doc/specification/
	mkdir -p ${GHP_XSD}/doc/specification/
	cp      docs/SchemaDocumentation/NMR-ML1.0_specificationDoc.docx ${GHP_XSD}/doc/specification/
	cp      docs/SchemaDocumentation/NMR-ML1.0_specificationDoc.htm ${GHP_XSD}/doc/specification/index.html
	cp -avx docs/SchemaDocumentation/NMR-ML1.0_specificationDoc-Dateien/ ${GHP_XSD}/doc/specification/

gh-pages-cv-install: ontologies/nmrCV.owl ontologies/nmrCV.obo # docs/CVDocumentation/OwlDoc/index.html
	@echo "Copy CV in OBO and OWL" 
	cp -avx ontologies/nmrCV.owl ${GHP_CV}
	cp -avx ontologies/nmrCV.obo ${GHP_CV}
	@echo "Copy a fresh set of oXygen-exported Ontology HTML files" 
	rm -rf ${GHP_CV}/doc/doc/
	mkdir -p ${GHP_CV}/doc/doc/
	cp -avx docs/CVDocumentation/OwlDoc/* ${GHP_CV}/doc/doc/

gh-pages-mapping-install: docs/mapping_and_cv.html
	@echo "Copy mapping file" 
	cp -avx ontologies/nmr-mapping.xml ${GHP_CV}
	rm -rf ${GHP_CV}/doc/mapping/
	mkdir -p ${GHP_CV}/doc/mapping/
	cp -avx docs/mapping_and_cv.html ${GHP_CV}/doc/mapping/


# Once we have the oXygen gerenated HTML in the nmrML master:
#	@echo "Copy a fresh set of oXygen documentation HTML files" 
#	rm -rf ${GHP_XSD}/doc/doc/
#	mkdir -p ${GHP_XSD}/doc/doc/
#	cp -avx docs/SchemaDocumentation/HTML_Serialisations/* ${GHP_XSD}/doc/doc/









# Build the docs if they don't exist
docs: docs/schema.html docs/CVDocumentation/OwlDoc/index.html	

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
docs/mapping_and_cv.html: ontologies/nmrCV.obo xml-schemata/nmrML.xsd tidy tidy
	CVInspector -cv_files ontologies/nmrCV-protege.obo -cv_names NMR \
	-mapping_file ontologies/nmr-mapping.xml \
	-html docs/mapping_and_cv.html

# Build the HTML documentation for the Ontology 
# Until there is a command line tool to do this, 
# this requires manual intervention

# Soon we might be able to use: xml-schemata/schemaDocumentation.bat
# if Oxygen is installed on the computer
docs/SchemaDocumentation/HTML_Serialisations/nmrML_xsd.html: xml-schemata/nmrML.xsd
	echo "You need to manually export the HTML Documentation for xml-schemata/nmrML.xsd into  docs/SchemaDocumentation/HTML_Serialisations/"
	/bin/false

# Build the Ontology as OBO from the OWL version.
# Until https://github.com/nmrML/nmrML/issues/42
# is fixed, this requires manual intervention
ontologies/nmrCV.obo: ontologies/nmrCV.owl
	echo "You need to manually save ontologies/nmrCV.owl as ontologies/nmrCV.obo"
	/bin/false

# We'd love to be able to use https://code.google.com/p/oboformat/
# for the conversion:
# obolib-owl2obo ontologies/nmrCV.owl -o ontologies/nmrCV.obo

# Make sure OpenMS is using the latest versions of Schema, Ontology and the mapping
# Requires the OpenMS fork from https://github.com/sneumann/OpenMS/tree/nmrML
#update-openms: xml-schemata/nmrML.xsd ontologies/nmrCV.obo ontologies/nmr-mapping.xml
#	cp xml-schemata/nmrML.xsd ${OPENMSSHARE}/SCHEMAS/nmrCV.obo
#	cp ontologies/nmrCV.obo ${OPENMSSHARE}/CV/nmrCV.obo
#	cp ontologies/nmr-mapping.xml ${OPENMSSHARE}/MAPPING/nmrCV.obo

# Validate our examples against Schema, Ontology and the mapping
#validate-all: validate-nmrml-schema validate-nmrml-mapping update-openms validate-HMDB00005 validate-bmse000325
validate-all: validate-nmrml-schema validate-nmrml-mapping validate-HMDB00005 validate-bmse000325

validate-nmrml-schema: 
	xmllint --noout --schema xml-schemata/XMLSchema.xsd xml-schemata/nmrML.xsd

validate-nmrml-mapping: 
	xmllint --noout --schema xml-schemata/CvMapping.xsd ontologies/nmr-mapping.xml

validate-HMDB00005: 
	xmllint --noout --schema xml-schemata/nmrML.xsd examples/reference_spectra_example/HMDB00005.nmrML
	XMLValidator -in examples/reference_spectra_example/HMDB00005.nmrML -schema xml-schemata/nmrML.xsd 
	SemanticValidator -in examples/reference_spectra_example/HMDB00005.nmrML -cv ontologies/nmrCV.obo -mapping_file ontologies/nmr-mapping.xml 

#	FileInfo -v -in examples/reference_spectra_example/HMDB00005.nmrML

validate-bmse000325: 
	xmllint --noout --schema xml-schemata/nmrML.xsd examples/reference_spectra_example/bmse000325.nmrML

# Check for broken links and other problems with linkchecker:
# Homepage: http://linkchecker.sourceforge.net/
# and the debian/ubuntu package linkchecker
gh-pages-linkcheck:
	linkchecker http://nmrml.org/

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
