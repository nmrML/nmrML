nmrML0.1.0.html: schemas/nmrML0.1.0.xsd
	xsltproc --stringparam title "My New XML Schema" \
         lib/xs3p.xsl schemas/nmrML0.1.0.xsd > docs/nmrML0.1.0.html


