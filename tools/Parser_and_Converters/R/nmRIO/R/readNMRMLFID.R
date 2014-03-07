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

    ## Currently reads only the FIRST fidData from file:
    fidData <- xmlElementsByTagName(root, "fidData", recursive = TRUE)[["acquisition.acquisition1D.fidData"]]
    
    ## Extract base64encoded data 
    b64s <- gsub("\n", "", xmlValue(fidData))

    ## byteFormat="Integer32" Used by Daniel Jacobs, should change into cvParam as complex64int
    ## byteFormat="complex128" Used by Michael should change into cvParam as complex64 as 128 is misleading

    byteFormat <- xmlAttrs(fidData)["byteFormat"]
    what <- switch(byteFormat,
                   Complex128 = "double", # that's because complex128 is misleading
                   Complex64 = "double",
                   Integer32 = "integer",
                   Complex32int = "integer",
                   Complex64int = "currentlynotsupported")
    
    compression <- ifelse(xmlAttrs(fidData)["compressed"]=="true", "gzip", "none")
    
    ## Decode. TODO: Check cvParam about the encoding
    dfid <- binaryArrayDecode(b64s,
                      what=what, compression=compression)
    
    fid <- fidvector2complex(dfid)

    ## Return the fid
    fid
}

#' binaryArrayDecode
#'
#' Extract binary (optionally compressed) data from base64 encoded strings
#'
#' This is the Details section
#'
#' @param b64string character the base64 encoded (optionally zipped) 
#' @param what character Either an object whose mode will give the mode of the vector
#'        to be read, or a character vector of length one describing
#'        the mode: one of '"numeric"', '"double"', '"integer"',
#'        '"int"', '"logical"', '"complex"', '"character"', '"raw"'.
#' @param sizeof the data type. 
#' @param compression c("gzip", "bzip2", "xz", "none") 
#'        character string, the type of compression.  May be
#'        abbreviated to a single letter, defaults to "none"
#'  
#' @return A vector with the type "what" 
#' @author Steffen Neumann
#' @examples
#' nmRIO:::binaryArrayDecode("eJxjYACBD/YMEOAAoTigtACUFoHSElBaBkorOAAAeOcDcA==", compression="gzip")

binaryArrayDecode <- function (b64string, what="double", sizeof=4, compression=c("gzip", "bzip2", "xz", "none") ) {
    if (missing(compression)) {
        compression <- "none"
    }
    ## Decode. TODO: Check cvParam about the encoding
    raws <- memDecompress(base64decode(b64string, "raw"), type=compression)
    result <- readBin(raws, n=length(raws)+1, what=what, size=sizeof, endian = "little")
    result
}

#' binaryArrayEncode
#'
#' Create a base64 encoded string from vector of complex or real data (optionally compressed)
#'
#' This is the Details section
#'
#' @param data vector of type numeric or complex to write out.
#' @param byteFormat which byte-level representation to use
#' @param compression c("gzip", "bzip2", "xz", "none") 
#'        character string, the type of compression.  May be
#'        abbreviated to a single letter, defaults to "none"#'  
#' @return base64 encoded character string (optionally zipped) 
#' @author Steffen Neumann
#' @examples
#' fid <- c(complex(1.37930,2.00010), complex(2.09823, 2.00010), c(3.80324, 2.00010))
#' b64string <- nmRIO:::binaryArrayEncode(fid, byteFormat="complex64", compression="gzip")

binaryArrayEncode <- function (data, byteFormat=c("complex64", "complex128"), compression=c("gzip", "bzip2", "xz", "none") ) {
  
  numericVector <- as.numeric(data)
  
  if(byteFormat=="complex128") {
    sizeof=8
  } else if(byteFormat=="complex64") {
    sizeof=4
  }
    
  raws <- writeBin(numericVector, con=raw(), size=sizeof, endian = "little", useBytes = FALSE)      
  compressed <- memCompress(raws, type = compression)  
  b64string <- base64encode(compressed, endian="little")    
  b64string
}  

if (FALSE) {
fid <- c(complex(1.37930,2.00010), complex(2.09823, 2.00010), c(3.80324, 2.00010))

b <- binaryArrayEncode(fid, byteFormat="complex128", compression="none")
b
b <- binaryArrayEncode(fid, byteFormat="complex64", compression="none")
b
b <- binaryArrayEncode(fid, byteFormat="complex64", compression="gzip")
b
}

#' fidvector2complex
#'
#' Convert a vector of double into a vector or array of complex numbers with row-major order
#'
#' for 1D fid:
#' [1+1i,2+2i,3+3i]
#' 
#' when we store it we flatten the complex numbers to adjacent floats, giving:
#' [1,1i,2,2i,3,3i]
#' 
#' This case extends to 2D, up to ND, I will give an example with 3D so that all is clear:
#' 
#' For 3D with dimensions X=3,Y=3,Z=3:
#' [
#' [
#' [1+1i,2+2i,3+3i],
#' [4+4i,5+5i,6+6i],
#' [7+7i,8+8i,9+9i]
#' ],[
#' [1+1i,2+2i,3+3i],
#' [4+4i,5+5i,6+6i],
#' [7+7i,8+8i,9+9i]
#' ],[
#' [1+1i,2+2i,3+3i],
#' [4+4i,5+5i,6+6i],
#' [7+7i,8+8i,9+9i]
#' ]
#' ]
#' 
#' When flattened is:
#' [
#' 1,1i,2,2i,3,3i,4,4i,5,5i,6,6i,7,7i,8,8i,9,9i,
#' 1,1i,2,2i,3,3i,4,4i,5,5i,6,6i,7,7i,8,8i,9,9i,
#' 1,1i,2,2i,3,3i,4,4i,5,5i,6,6i,7,7i,8,8i,9,9i
#' ]
#' 
#' If the array is stored in a block of contiguous memory, we can use the following pointer arithmetic to access the data
#' 
#' To access the real part of number at [x][y][z] (multiply Z by 2 since we flatten complex into two floats):
#' [x*Y*Z*2 + y*Z*2 + 2*z ]
#' 
#' To access the imaginary part of number at [x][y][z]:
#' [x*Y*Z*2 + y*Z*2 + (2*z+1)]
#' 
#' so for example to access [1][2][2] ( in bold )
#' 
#' in our case, X=3,Y=3,Z=3
#' 
#' [1*3*3*2 + 2*3*2 + 2*2] = 30
#' [1*3*3*2 + 2*3*2 + 2*2+1] = 31
#' 
#' In a real FID the dimensions are defined as so:
#' Z = number of datapoints in direct dimension
#' Y = number of datapoints in first indirect dimension
#' X = number of datapoints in 2nd indirect dimension
#'
#' @param doubles numeric A vector of doubles decoded from the nmrML file
#' @param dimensions numeric depending on how we'll implement nD NMR data, either the number of dimensions,
#'                           or a vector with n elements and the length of each dimension
#' @return A vector or array with the complex values of the FID data
#' @author Steffen Neumann

fidvector2complex <- function(doubles, dimensions=1) {
    fid <- complex(real=doubles[c(TRUE,FALSE)], imaginary=doubles[c(FALSE,TRUE)])
    if (dimensions == 2) {        
        ## re-shape into matrix
        stop("NYI")
        ## Requires re-checking the input structure and expected output structure
        fid <- as.matrix(fid,
                         nrow=dimensions[1],
                         ncol=dimensions[2],
                         byrow=FALSE)
    } else if (dimensions >3) {
        stop("NYI")
        ## Requires the correct re-shaping of the 1D vector
        ## into 3D or nD.
        ## http://stackoverflow.com/questions/12859215/switching-row-major-to-column-major-dimensions
        fid <- as.array(data=fid, dim=dimensions)
    }
    fid   
}


if (FALSE) {
    ## This section contains test snippets during development
    library(XML)
    library(caTools)
    
    files <- list.files("../../../../../examples/IPB_HopExample/nmrMLs/",
                        full.names=TRUE)

    filename <- files[1]
    filename
    
    fid <- readNMRMLFID(filename)
    str(fid)

    ## Snippet from Luis:
    
    acqu<-data.frame(
        td = 14400, #encodedLength="165170"
        bitorder= "little", # (BYTORDA) 0 -> little; 1 -> big        
        bitsize=4 # (DTYPA) 0 -> 32 bit int -> size 4; 1 -> 64 bit double -> size 8
  )

    to.read = file("../../../../../examples/reference_spectra_example/HMDB00005.fid/fid", "rb");

    fid = readBin(to.read, integer(),
        n=acqu$td, size = acqu$bitsize, endian = acqu$bitorder);
    str(fid)
    
    
    ## from Bruker 
    library(nmRIO)
    filename <- "../../../../../examples/reference_spectra_example/HMDB00005.nmrML"
    filename
    
    fid <- readNMRMLFID(filename)
    str(fid)
    plot(as.double(fid), pch=".")
    
    filename <- "../inst/examples/MMBBI_10M12-CE01-1a.nmrML"
    fid <- readNMRMLFID(filename)
    str(fid)
    plot(as.double(fid), pch=".")
    
}



