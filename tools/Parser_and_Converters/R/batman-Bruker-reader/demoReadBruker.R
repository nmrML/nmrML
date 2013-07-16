
source('~/readBrukerZipped.R')
source('~/readBruker.R')
# Read in multiple raw binary Bruker NMR spectra (1D) from a specified folder, 
# and return a matrix with columns:
#         [ppm, spectrum1, spectrum2, ...]. 
# Interpolation may be performed if spectra have different ppm scales.
sa<-readBruker(BrukerDataDir)  
# or if zipped Bruker files, example files from: http://www.ebi.ac.uk/metabolights/MTBLS1
sa<-readBrukerZipped(BrukerDataZipDir)

