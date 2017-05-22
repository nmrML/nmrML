\name{binaryArrayDecode}
\alias{binaryArrayDecode}
\title{binaryArrayDecode}
\usage{
  binaryArrayDecode(b64string, what = "double", sizeof = 4,
    compression = c("gzip", "bzip2", "xz", "none"))
}
\arguments{
  \item{b64string}{character the base64 encoded (optionally
  zipped)}

  \item{what}{character Either an object whose mode will
  give the mode of the vector to be read, or a character
  vector of length one describing the mode: one of
  '"numeric"', '"double"', '"integer"', '"int"',
  '"logical"', '"complex"', '"character"', '"raw"'.}

  \item{sizeof}{the data type.}

  \item{compression}{c("gzip", "bzip2", "xz", "none")
  character string, the type of compression.  May be
  abbreviated to a single letter, defaults to "none"}
}
\value{
  A vector with the type "what"
}
\description{
  Extract binary (optionally compressed) data from base64
  encoded strings
}
\details{
  This is the Details section
}
\examples{
nmRIO:::binaryArrayDecode("eJxjYACBD/YMEOAAoTigtACUFoHSElBaBkorOAAAeOcDcA==", compression="gzip")
}
\author{
  Steffen Neumann
}

