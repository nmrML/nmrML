#' verify.nmrML
#'
#' This function will just call the libXML validation
#' of a given file against the XML schema definition (XSD)
#'
#' This is the Details section
#'
#' @param filename character Filename of the nmrML to check
#' @param xsdfilename character Filename of the XSD for nmrML to check
#' @return An XML validation object  with the status slot and error messages if there were any
#' @author Steffen Neumann
#' @examples
#' #verify.nmrML(system.file("examples/HMDB00005.nmrML", package = "nmRIO"))
#' @export

verify.nmrML <- function(filename,
                         xsdfilename=system.file("unitTests/nmrML.xsd", package = "nmRIO")) {
    xsd = xmlTreeParse(xsdfilename, isSchema =TRUE, useInternalNodes = TRUE)
    doc = xmlInternalTreeParse(filename)
    xmlSchemaValidate(xsd, doc)    
}

