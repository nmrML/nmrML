#' readNMRMLProcessed
#'
#' Extract binary processed data from nmrML
#'
#' This is the Details section
#'
#' @param filename character Filename of the nmrML to check
#' @return A vector with the numeric values of the processed data
#' @author Steffen Neumann
#' @examples
#' length(readNMRMLProcessed(system.file("examples/HMDB00005.nmrML", package = "nmRIO")))
#' @export

readNMRMLProcessed <- function (filename) {
    tree <- xmlTreeParse(filename)
    root <- xmlRoot(tree)
    
    ## Extract base64encoded data 
    b64s <- sapply (xmlElementsByTagName(root, "binary",
                                         recursive = TRUE), xmlValue)

    intensities <- base64decode(b64s[2], "double", size=8)
        
    ## Get required parameters from nmrML
    irradiationFrequency <- as.double(xmlAttrs(xmlElementsByTagName(root, "irradiationFrequency", recursive = TRUE)[[1]])["value"])

    sweepWidth <- as.double(xmlAttrs(xmlElementsByTagName(root, "sweepWidth", recursive = TRUE)[[1]])["value"])

    numberOfDataPoints <- as.integer(xmlAttrs(xmlElementsByTagName(root, "DirectDimensionParameterSet", recursive = TRUE)[[1]])["numberOfDataPoints"])

    ## delayTime <- 1.0
    ## ppmOffset <- delayTime / 599.4094446,
    
    ppm <- seq(from=14.77180,
               to= -5.239921,
               length=numberOfDataPoints)
        
    datamatrix <- cbind(ppm, intensities)
    names(datamatrix) <- c("ppm", basename(filename))
    datamatrix
}

if (FALSE) {
    ## This section contains test snippets during development
    library(XML)
    library(caTools)
    
    files <- list.files("../../../../../examples/IPB_HopExample/nmrMLs/",
                        full.names=TRUE)

    filename <- files[1]
    
}
