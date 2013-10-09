\name{readNMRMLProcessed}
\alias{readNMRMLProcessed}
\title{readNMRMLProcessed}
\usage{
  readNMRMLProcessed(filename)
}
\arguments{
  \item{filename}{character Filename of the nmrML to check}
}
\value{
  A vector with the numeric values of the processed data
}
\description{
  Extract binary processed data from nmrML
}
\details{
  This is the Details section
}
\examples{
length(readNMRMLProcessed(system.file("examples/HMDB00005.nmrML", package = "nmRIO")))
}
\author{
  Steffen Neumann
}

