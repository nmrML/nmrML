\name{verify.nmrML}
\alias{verify.nmrML}
\title{
This function will verify an nmrML file against the schema
}
\description{
  This function will just call the libXML validation
  of a given file against the XML schema definition (XSD)
}
\usage{
verify.nmrML(filename, xsdfilename = system.file(unitTests/nmrML.xsd, package = "nmRio"))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{filename}{
%%     ~~Describe \code{filename} here~~
}
  \item{xsdfilename}{
%%     ~~Describe \code{xsdfilename} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (filename, xsdfilename = system.file(unitTests/nmrML.xsd, 
    package = "nmRio")) 
{
    xsd = xmlTreeParse(xsdfilename, isSchema = TRUE, useInternal = TRUE)
    doc = xmlInternalTreeParse(filename)
    xmlSchemaValidate(xsd, doc)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
