# This is a simple example of a complete R script 
# allowing to read fid / 1r data along with the metadata
# from a nmrML file with both fid and real spectra 
# 
# AUTHORS: Daniel Jacob
#
# To install the requirements for running the R parser run 
# the following commands in R
# 
# 	install.packages(c('XML', 'base64enc'), repos='http://cran.rstudio.com')
# 
# To run the example, launch R from the root nmrML directory (or in R, use the setwd() command )
# then run 
# 
# 	source("tools/Parser_and_Converters/R/RnmrML/read_nmrML.R")
# 
library(XML)
library(base64enc)

what <- "double"
endian <- "little"
sizeof <- 8
compression.type <- "gzip"

filename <- "examples/reference_spectra_examples/MMBBI/MMBBI_10M12-CE01-1a.nmrML"

doc = xmlInternalTreeParse(filename)

#xsdfilename <- "xml-schemata/nmrML.xsd"
#xsd = xmlTreeParse(xsdfilename, isSchema =TRUE, useInternalNodes = TRUE)
#check <- xmlSchemaValidate(xsd, doc)
 
tree <- xmlTreeParse(filename)
root <- xmlRoot(tree)

### ---  Acquisition Parameters -----
acquisition <- xmlElementsByTagName(root, "acquisition", recursive = TRUE)[[1]]
SFO1 <- as.double(xmlAttrs(xmlElementsByTagName(acquisition, "irradiationFrequency", recursive = TRUE)[[1]])["value"])
SWH <-  as.double(xmlAttrs(xmlElementsByTagName(acquisition, "sweepWidth", recursive = TRUE)[[1]])["value"])
SW <- SWH/SFO1
TD  <-  as.integer(xmlAttrs(xmlElementsByTagName(acquisition, "DirectDimensionParameterSet", recursive = TRUE)[[1]])["numberOfDataPoints"])
TEMP <- as.double(xmlAttrs(xmlElementsByTagName(acquisition, "sampleAcquisitionTemperature", recursive = TRUE)[[1]])["value"])
RELAXDELAY <- as.double(xmlAttrs(xmlElementsByTagName(acquisition, "relaxationDelay", recursive = TRUE)[[1]])["value"])
SPINNINGRATE <- as.double(xmlAttrs(xmlElementsByTagName(acquisition, "spinningRate", recursive = TRUE)[[1]])["value"])
PULSEWIDTH <- as.double(xmlAttrs(xmlElementsByTagName(acquisition, "pulseWidth", recursive = TRUE)[[1]])["value"])
PULSEPROG <- xmlAttrs(xmlElementsByTagName( xmlElementsByTagName(acquisition, "pulseSequence", recursive = TRUE)[[1]], "userParam", recursive=TRUE )[[1]])["value"]
NUC_LABEL <- xmlAttrs(xmlElementsByTagName(acquisition, "acquisitionNucleus", recursive = TRUE)[[1]])["name"]
GRPDLY <- 0
if ( length(xmlElementsByTagName(root, "groupDelay", recursive = TRUE)) ) {
    GRPDLY <- as.double(xmlAttrs(xmlElementsByTagName(root, "groupDelay", recursive = TRUE)[[1]])["value"])
}
ACC <- "none"
if ( length(xmlAttrs(xmlElementsByTagName(acquisition, "acquisition1D", recursive = TRUE)[[1]])["id"]) ) {
    ACC <- xmlAttrs(xmlElementsByTagName(acquisition, "acquisition1D", recursive = TRUE)[[1]])["id"]
}

if (length(grep("hydrogen",NUC_LABEL))>0) NUC <- '1H'
if (length(grep("carbon",NUC_LABEL))>0) NUC <- '13C'

acqparams <- data.frame( Name=ACC,
                         irradiationFrequency=SFO1, 
                         sweepWidth=SW,
                         acquisitionNucleus=NUC,
                         AcqDimension=TD, 
                         Temperature=TEMP,
                         relaxationDelay=RELAXDELAY,
                         spinningRate=SPINNINGRATE,
                         pulseWidth=PULSEWIDTH,
                         pulseSequence=PULSEPROG,
                         stringsAsFactors = FALSE)

# Instrument
instrument <- xmlElementsByTagName(root, "instrumentConfiguration", recursive = TRUE)[[1]]
instrument.name <- xmlAttrs(xmlElementsByTagName(instrument,"cvParam")[[1]])["name"]
instrument.probe <- xmlAttrs(xmlElementsByTagName(instrument,"userParam")[[1]])["value"]
instrument <- data.frame ( instrument.name=instrument.name, instrument.probe=instrument.probe, stringsAsFactors = FALSE )
instrument

### ---  FID -----
fidData <- xmlElementsByTagName(acquisition, "fidData", recursive = TRUE)
compression <- ifelse(  xmlAttrs(fidData[[1]])["compressed"]=="true", compression.type, "" )
encodedLength <- as.numeric(xmlAttrs(fidData[[1]])["encodedLength"])
raws <- base64decode(gsub("\n", "", xmlValue(fidData[[1]])))
if (xmlAttrs(fidData[[1]])["compressed"]=="true") raws <- memDecompress(raws, type=compression)
signal <- readBin(raws, n=length(raws), what=what, size=sizeof, endian = endian)
td <- length(signal)
rawR <- signal[seq(from = 1, to = td, by = 2)]
rawI <- signal[seq(from = 2, to = td, by = 2)]
mediar<-mean(as.integer(rawR[c((3*length(rawR)/4):length(rawR))]),na.rm = TRUE)
mediai<--mean(as.integer(rawI[c((3*length(rawR)/4):length(rawR))]),na.rm = TRUE)
rawR<-rawR-mediar
rawI<-rawI-mediai
fid <- complex(real=rawR, imaginary=rawI)


### ---  1R -----
specList <- list()

spectrumList <- xmlElementsByTagName(root, "spectrum1D", recursive = TRUE)
for ( i in 1:length(spectrumList) ) {
   realData <- xmlElementsByTagName(spectrumList[[i]], "spectrumDataArray", recursive = TRUE)[["spectrumDataArray"]]
   compression <- ifelse( xmlAttrs(realData)["compressed"]=="true", compression.type, "" )
   raws <- base64decode(gsub("\n", "", xmlValue(realData)))
   if (xmlAttrs(realData)["compressed"]=="true") {
       raws <- memDecompress(raws, type=compression)
   }
   spec1r <- readBin(raws, n=length(raws), what=what, size=sizeof, endian = endian)
   SI <- length(spec1r)
   dppm <- SW/(SI-1)
   ppm_max <-as.double(xmlAttrs(xmlElementsByTagName(spectrumList[[i]], "xAxis", recursive = TRUE)[[1]])["startValue"])
   ppm_min <-as.double(xmlAttrs(xmlElementsByTagName(spectrumList[[i]], "xAxis", recursive = TRUE)[[1]])["endValue"])
   specList[[i]] <- list( values=spec1r, SI=SI, dppm=dppm, ppm_max=ppm_max, ppm_min=ppm_min )
}


### ---  Plot 1R -----
plot_spec <- function (spec1r, MIN=-1, MAX=10, YMAX=NULL)
{
   ppm <- seq(from=spec1r$ppm_min, to=(spec1r$ppm_max), by=spec1r$dppm)
   vmin <- max(MIN,min(ppm))
   vmax <- min(MAX,max(ppm))
   i1 <- length(which(ppm<=vmin))
   i2 <-which(ppm>=vmax)[1]
   if( is.null(YMAX)) YMAX <- max(rev(spec1r$values)[i1:i2])
   plot( cbind(ppm[i1:i2], rev(spec1r$values)[i1:i2]),
         xlim=rev(range(ppm[i1:i2])), ylim=c(0,YMAX), type="l", xlab="PPM", ylab="Intensities",
         col="blue", main=paste(gsub(".nmrML","",basename(filename)),"/ 1r")) 
   abline(v=0, col="red")
}

plot_spec(specList[[1]], -1, 10, 1e7)



