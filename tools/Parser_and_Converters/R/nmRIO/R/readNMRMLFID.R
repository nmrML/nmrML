#' readNMRMLFID
#'
#' Extract binary FID data from nmrML
#'
#' This is the Details section
#'
#' @param filename character Filename of the nmrML to check
#' @return A vector with the complex values of the FID data
#' @author Steffen Neumann
#' @examples
#' length(readNMRMLFID(system.file("examples/HMDB00005.nmrML", package = "nmRIO")))
#' @export

readNMRMLFID <- function (filename) {
    tree <- xmlTreeParse(filename)
    root <- xmlRoot(tree)

    ## Extract base64encoded data 
    b64s <- gsub("\n", "", sapply (xmlElementsByTagName(root, "binary", recursive = TRUE),
                                   xmlValue))

    ## Decode. TODO: Check cvParam about the encoding
    rfid <- memDecompress(base64decode(b64s["acquisition.acquisition1D.fid.binary"], "raw"), type="gzip")
    dfid <- readBin(rfid, n=length(rfid)/4+1, what="double", size=4)
    fid <- complex(real=dfid[c(TRUE,FALSE)], imaginary=dfid[c(FALSE,TRUE)])

    ## Return the fid
    fid
}
