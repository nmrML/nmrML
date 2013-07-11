# This is a simple example file to demonstrate loading
# ontologies and parsing an NMR-ML file
# 
# AUTHORS: Steffen Neumann 
#
# To install the requirements for running the R parser run 
# the following commands in R
# 
# 	install.packages("XML")
# 	source("http://bioconductor.org/biocLite.R")
#   biocLite("ontoCAT")
# 
# To run the example, launch R from the root NMR-ML directory then
# run 
# 
# 	source("tools/R/reader.R")
# 
library(XML)

## Load ontologies in OBO format,
## Likely to be deprecated in favour of OWL
library(ontoCAT)
msiNMR <- getOntology("../../../ontologies/msi-nmr.obo")
unit   <- getOntology("http://unit-ontology.googlecode.com/svn/trunk/unit.obo")



##
## Ontology in OWL
##
## nmrML is currently not clean enough for ontoCAT:
nmrMLOnto <- getOntology("../../../ontologies/nmrMLv.9.owl")

#btl2Onto <- getOntology("http://purl.org/biotop/btl2.owl")
btl2Onto <- getOntology("https://biotop.googlecode.com/svn/trunk/btl2.owl")

##
## XSD Schema
##
library(XMLSchema)
d = readSchema("../../../xml-schemata/nmrML.xsd")
## I am not yet sure how to use the powerful XMLSchema package,
## but here is the "Contact Type":
str(d@.Data[[1]]@.Data[[6]], max.level=2)

# Parse an XML sample file
tree <- xmlTreeParse("../../../examples/nmrML/biosample-concentrations.xml")
root <- xmlRoot(tree)


