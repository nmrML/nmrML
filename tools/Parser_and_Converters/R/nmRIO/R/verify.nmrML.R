verify.nmrML <-
function(filename,
                         xsdfilename=system.file(unitTests/nmrML.xsd, package = "nmRio")) {
    xsd = xmlTreeParse(xsdfilename, isSchema =TRUE, useInternal = TRUE)
    doc = xmlInternalTreeParse(filename)
    xmlSchemaValidate(xsd, doc)    
}
