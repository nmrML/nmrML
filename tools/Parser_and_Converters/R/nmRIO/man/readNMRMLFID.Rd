\name{readNMRMLFID}
\alias{readNMRMLFID}
\title{readNMRMLFID}
\usage{
  readNMRMLFID(filename)
}
\arguments{
  \item{filename}{character Filename of the nmrML to check}
}
\value{
  A vector with the complex values of the FID data
}
\description{
  Extract binary FID data from nmrML
}
\details{
  This is the Details section
}
\examples{
length(readNMRMLFID(system.file("examples/HMDB00005.nmrML", package = "nmRIO")))
}
\author{
  Steffen Neumann
}

