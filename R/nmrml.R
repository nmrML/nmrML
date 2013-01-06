library(XML)
library(ontoCAT)

msiNMR <- getOntology("../xsd+obo/msi-nmr.obo")
unit <- getOntology("http://unit-ontology.googlecode.com/svn/trunk/unit.obo")

tree <-  xmlTreeParse("../examples/biosample-concentrations.xml")
root <-  xmlRoot(tree)

