test.openPyConverter <- function() {
    file <- system.file('examples/HMDB00005.nmrML', package = "nmRIO")
    fid <- readNMRMLFID(file)
    checkEqualsNumeric(as.double(fid)[1:2], c(11451, -130998))
  }

test.openDJconverter <- function() {
    file <- system.file('examples/MMBBI_10M12-CE01-1a.nmrML', package = "nmRIO")
    fid <- readNMRMLFID(file)
    checkEqualsNumeric(as.double(fid)[1:2], c(1,-11))
  }

test.openLuisFFconverter <- function() {
    file <- system.file('examples//bmse000325.nmrML', package = "nmRIO")
    fid <- readNMRMLFID(file)
    checkEqualsNumeric(as.double(fid)[27:28], c(100663296, -117440513))
  }

