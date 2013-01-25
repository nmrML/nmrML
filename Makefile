VERSION := `cat VERSION`

docs: docs/schema.html

docs/schema.html: schemas/nmr-ml.xsd
	xsltproc --stringparam title "NMR-ML v$(VERSION)" \
         lib/xs3p.xsl schemas/nmr-ml.xsd > docs/schema.html

rebuild: clean docs

clean:
	rm docs/schema.html




