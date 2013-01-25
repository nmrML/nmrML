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
library(ontoCAT)

# Load ontologies
msiNMR <- getOntology("ontologies/msi-nmr.obo")
unit   <- getOntology("http://unit-ontology.googlecode.com/svn/trunk/unit.obo")

# Parse an XML sample file
tree <- xmlTreeParse("examples/biosample-concentrations.xml")
root <- xmlRoot(tree)

