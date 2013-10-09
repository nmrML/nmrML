test.open <- function() {
    file <- system.file('examples/HMDB00005.nmrML', package = "nmRIO")
    dummy <- readNMRMLFID(file)
  }
