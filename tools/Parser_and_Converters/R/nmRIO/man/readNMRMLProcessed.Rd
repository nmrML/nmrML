\name{readNMRMLProcessed}
\alias{readNMRMLProcessed}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
readNMRMLProcessed(filename)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{filename}{
%%     ~~Describe \code{filename} here~~
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
function (filename) 
{
    tree <- xmlTreeParse(filename)
    root <- xmlRoot(tree)
    b64s <- sapply(xmlElementsByTagName(root, "binary", recursive = TRUE), 
        xmlValue)
    intensities <- base64decode(b64s[2], "double", size = 8)
    irradiationFrequency <- as.double(xmlAttrs(xmlElementsByTagName(root, 
        "irradiationFrequency", recursive = TRUE)[[1]])["value"])
    sweepWidth <- as.double(xmlAttrs(xmlElementsByTagName(root, 
        "sweepWidth", recursive = TRUE)[[1]])["value"])
    numberOfDataPoints <- as.integer(xmlAttrs(xmlElementsByTagName(root, 
        "DirectDimensionParameterSet", recursive = TRUE)[[1]])["numberOfDataPoints"])
    ppm <- seq(from = 14.7718, to = -5.239921, length = numberOfDataPoints)
    datamatrix <- cbind(ppm, intensities)
    names(datamatrix) <- c("ppm", basename(filename))
    datamatrix
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
