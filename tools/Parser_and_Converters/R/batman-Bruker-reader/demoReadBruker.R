source('./readBrukerZipped.R')
source('./readBruker.R')
# Read in multiple raw binary Bruker NMR spectra (1D) from a specified directory, 
# all the 1r files in that directory will be read in, the title files will also be read in, 
# and assigned as the column name to the corresponding specctrum column.
# The returned matrix has columns as the following format:
#         [ppm, spectrum1, spectrum2, ...]. 
# Interpolation may be performed if spectra have different ppm scales.
# BrukerDataDir: directory for bruker data files.
# BrukerDataZipDir: directory for zipped bruker data files.


# sa<-readBruker(BrukerDataDir)  
# or if zipped Bruker files, to read in example dataset in MTBLS1

BrukerDataZipDir <- "../../../../examples/MTBLS1_DiagramUseCase/MTBLS1"
sa <- readBrukerZipped(BrukerDataZipDir)

