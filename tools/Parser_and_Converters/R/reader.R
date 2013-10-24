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
nmrMLOnto <- getOntology("../../../ontologies/nmrMLv1.2.owl")

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

## but here is the "Contact Type":
str(d@.Data[[1]]@.Data[[1]], max.level=2)


## Parse XML sample files
tree <- xmlTreeParse("../../../examples/nmrML/biosample-concentrations.xml")
root <- xmlRoot(tree)

tree <- xmlTreeParse("../../../examples/nmrML/instance1modifiedToBiosample-concentrations.xml")
root <- xmlRoot(tree)

tree <- xmlTreeParse("../../../examples/nmrML/instance1.xml")
root <- xmlRoot(tree)

tree <- xmlTreeParse("../../../examples/wishart_data/simple_spectra1/HMDB00005.nmrML")
root <- xmlRoot(tree)


verify.nmrML <- function(filename,
                         xsdfilename=system.file(unitTests/nmrML.xsd, package = "nmRio")) {
    xsd = xmlTreeParse(xsdfilename, isSchema =TRUE, useInternal = TRUE)
    doc = xmlInternalTreeParse(filename)
    xmlSchemaValidate(xsd, doc)    
}

verify.nmrML("../../../examples/nmrML/instance1.xml",
             "../../../xml-schemata/nmrML.xsd")


## base64decode("Q+YlUkP16FxEbvVxRHj+mg==", "double", endian="big", size=32/8)

## Works:
dvector <- base64decode("54ywP6MBAEBmSQZAowEAQEloc0CjAQBA", "double", size=4)
compl <- complex(real=dvector[c(TRUE,FALSE)], imaginary=dvector[c(FALSE,TRUE)])
compl




## Doesn't work
base64decode("54ywP6MBAEBmSQZAowEAQEloc0CjAQBA", "complex", size=8)

## What I get:
base64encode(c(1.37930,2.00010,2.09823,2.00010,3.80324,2.00010))

base64decode(base64encode(c(complex(1.37930,2.00010), complex(2.09823, 2.00010), c(3.80324, 2.00010))), "complex")



base64strings <- sapply (xmlElementsByTagName(root, "binary", recursive = TRUE), xmlValue)

require(caTools)
intensities = base64decode(base64strings[2], "double", size=8)



d <- memDecompress(base64decode(base64strings[2], "raw"), type="gzip")






ppm <- seq(from=14.77180,
           to= 14.77180 - (7200.07200072 / 599.4094446),
           length=65536)

ppm <- seq(offset or delay =14.77180,
           to= offset or delay =14.77180, - (sweepWidth  value="7200.07200072" / irradiationFrequency  value="599.4094446")
           length=numberOfDataPoints="57804")

intensities <- memDecompress(base64decode(stringfromnmrml, "raw"), type="gzip")

require(caTools)


readNMRML <- function (filename) {
delayTime <- 1.0
ppmOffset <- delayTime / 599.4094446,
irradiationFrequency <- 500
sweepWidth <- "7200.07200072"
numberOfDataPoints <- "57804"
    
ppm <- seq(from=14.77180, to= -5.239921, length=65536)
intensities <- memDecompress(base64decode(stringfromnmrml, "raw"), type="gzip")
        
    cbind(ppm, assayname=intensities)
}





BrukerDataDir <- "../../../examples/MTBLS1_DiagramUseCase/MTBLS1/ADG19007u_436"



    tree <- xmlTreeParse(filename)
    root <- xmlRoot(tree)

    ## Extract base64encoded data 
    cvParams <- sapply (xmlElementsByTagName(root, "userParam",
                                         recursive = TRUE), xmlValue)
