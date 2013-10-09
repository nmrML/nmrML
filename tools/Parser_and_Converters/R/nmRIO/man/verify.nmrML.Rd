\name{verify.nmrML}
\alias{verify.nmrML}
\title{verify.nmrML}
\usage{
  verify.nmrML(filename,
    xsdfilename = system.file("unitTests/nmrML.xsd", package = "nmRIO"))
}
\arguments{
  \item{filename}{character Filename of the nmrML to check}

  \item{xsdfilename}{character Filename of the XSD for
  nmrML to check}
}
\value{
  An XML validation object with the status slot and error
  messages if there were any
}
\description{
  This function will just call the libXML validation of a
  given file against the XML schema definition (XSD)
}
\details{
  This is the Details section
}
\examples{
#verify.nmrML(system.file("examples/HMDB00005.nmrML", package = "nmRIO"))
}
\author{
  Steffen Neumann
}

