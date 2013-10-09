readNMRMLFID <-
function (filename) {
    tree <- xmlTreeParse(filename)
    root <- xmlRoot(tree)

    ## Extract base64encoded data 
    b64s <- gsub("\n", "", sapply (xmlElementsByTagName(root, "binary",
                                         recursive = TRUE), xmlValue))
    rfid <- memDecompress(base64decode(b64s["acquisition.acquisition1D.fid.binary"], "raw"), type="gzip")
    dfid <- readBin(rfid, n=length(rfid)/4+1, what="double", size=4)
    fid <- complex(real=dfid[c(TRUE,FALSE)], imaginary=dfid[c(FALSE,TRUE)])
    
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
