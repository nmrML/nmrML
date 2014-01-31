test.base64roundtrip <- function() {
  fid <- c(complex(1.37930,2.00010), complex(2.09823, 2.00010), c(3.80324, 2.00010))
  
  b64string <- nmRIO:::binaryArrayEncode(fid, byteFormat="complex64", compression="gzip")
  fidresult <- as.complex(nmRIO:::binaryArrayDecode(b64string, compression="gzip"))
  
  checkEqualsNumeric(fidresult, fid, tolerance = .Machine$double.eps^0.1)
  
  b64stringresult <- nmRIO:::binaryArrayEncode(fidresult, byteFormat="complex64", compression="gzip")
  checkEquals(b64string, b64stringresult)
  
}
  
test.fidvector2complex1D <- function() {
    dfid <- c(1.37930,1.00010,2.09823,2.00010,3.80324,3.00010)
    fidresult <- c(complex(real=1.37930, imaginary=1.00010),
                   complex(real=2.09823, imaginary=2.00010),
                   complex(real=3.80324, imaginary=3.00010))

    fid <- nmRIO:::fidvector2complex(dfid)

    checkEqualsNumeric(fidresult, fid)
}

disabled_test.fidvector2complex3D <- function() {
    ## 3D and nD not yet implemented.
    
    dfid <- c(complex(1,1), complex(2,2), complex(3,3), complex(4,4), complex(5,5), complex(6,6), complex(7,7), complex(8,8), complex(9,9),
              complex(1,1), complex(2,2), complex(3,3), complex(4,4), complex(5,5), complex(6,6), complex(7,7), complex(8,8), complex(9,9),
              complex(1,1), complex(2,2), complex(3,3), complex(4,4), complex(5,5), complex(6,6), complex(7,7), complex(8,8), complex(9,9))
        
    ## fidresult <- c(complex(real=1.37930, imaginary=1.00010),
    ##                complex(real=2.09823, imaginary=2.00010),
    ##                complex(real=3.80324, imaginary=3.00010))

    fid <- nmRIO:::fidvector2complex(dfid, dimensions=c(3,3,3))

    checkEqualsNumeric(fid[1,2,2], complex())
}

test.base64todouble <- function() {
    ## b64string <- base64encode(memCompress(writeBin(as.numeric(1:8), con=raw()), type="g"))
    result <- nmRIO:::binaryArrayDecode("eJxjYACBD/YMEOAAoTigtACUFoHSElBaBkorOAAAeOcDcA==", sizeof=8, compression="gzip")
    checkEqualsNumeric(result, 1:8)
}

disabled.test.base64tocomplex128 <- function() {
    b64string <- "MAAAF/H//8no///QF..MAAAF/H//8no///QF"
    
    doubles <- nmRIO:::binaryArrayDecode(b64string,
                                        what="double",
                                        compression="gzip")
    result <- fidvector2complex1D(doubles)    
    checkEqualsNumeric(result, 1:8)
}
