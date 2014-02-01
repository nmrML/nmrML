# Copyright (c) 2013-2014. European Bioinformatics Institute (EMBL-EBI)
#                       Luis F. de Figueiredo (Luis.deFigueiredo@ebi.ac.uk)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

###################################
# This is a simple example file to demonstrate the use
#   of nmRIO to read NMR data and do a simple 1D nmr spectra processing
# 
# AUTHORS: Luis F. de Figueiredo
#
# 
# To run the example, launch R from the root NMR-ML directory then
# run 
# 
# 	source("tools/R/examples/src/basic-1D_NMR-spectra_processing.R")
# 
#


library("nmRIO");
library("nmRPro")
setwd("~/Dev/cosmos/nmrML/tools/Parser_and_Converters/R/")
HMDB00005<-new("NmrData")
HMDB00005@fid<-readNMRMLFID("nmRIO/inst/examples/HMDB00005.nmrML")
HMDB00005@Acqu@nbOfPoints=19478
HMDB00005@Acqu@spectralWidth=12.9911091032519;#ppm (SW)
HMDB00005@Acqu@transmitterFreq=499.842349248;# MHz (SF1)

########

#plot the FID
plot.spectrum(HMDB00005)

#transform to the frequency domain spetrum
plot.spectrum(fourierTransform(HMDB00005,isBruker=FALSE))

#check where the reference points is located
plot.spectrum(fourierTransform(HMDB00005,isBruker=FALSE),xlim=range(1.31,1.33))
HMDB00005@Proc@referencePoint=1.3197
#confirm the position
plot.spectrum(fourierTransform(HMDB00005,isBruker=FALSE),xlim=range(-0.1,0.1))
abline(v=0,col="blue")
#do zero order phase correction
plot.spectrum(phaseCorr(fourierTransform(HMDB00005,isBruker=FALSE),zeroOrder=105),xlim=range(-0.1,0.1),ylim=range(-1e5,2e6))
#do first order phase correction
plot.spectrum(phaseCorr(fourierTransform(HMDB00005,isBruker=FALSE),zeroOrder=105,pivot=0,firstOrder=17),xlim=range(-0.1,5.2),ylim=range(-1e5,2e6))
#have a look lower zoom
plot.spectrum(phaseCorr(fourierTransform(HMDB00005,isBruker=FALSE),zeroOrder=105,pivot=0,firstOrder=17),xlim=range(-0.1,3.2),ylim=range(-1e5,5e7))
#do baseline correction
plot.spectrum(baselineCorr(phaseCorr(fourierTransform(HMDB00005,isBruker=FALSE),zeroOrder=105,pivot=0,firstOrder=17),method="TOPHAT"),xlim=range(-0.1,5.2),ylim=range(-1e5,5e7))

###### metabolomics experiment

FAM013_AHTM<-new("NmrData")
FAM013_AHTM@fid<-readNMRMLFID("~/Dev/cosmos/nmrML/examples/IPB_HopExample/nmrMLs.v2/FAM013_AHTM.PROTON_04.nmrML")
FAM013_AHTM@Acqu@nbOfPoints=length(FAM013_AHTM@fid)
sw_h=12019.2307692 #Hz
FAM013_AHTM@Acqu@transmitterFreq=599.8311617;# MHz 
FAM013_AHTM@Acqu@spectralWidth=sw_h/FAM013_AHTM@Acqu@transmitterFreq;#ppm 

#plot the fid
plot.spectrum(FAM013_AHTM)

#transform to the frequency domain spetrum
plot.spectrum(fourierTransform(FAM013_AHTM,isBruker=FALSE))

#check where the reference points is located
plot.spectrum(fourierTransform(FAM013_AHTM,isBruker=FALSE),xlim=range(2.06,2.072))
abline(v=2.0675,col="blue")
# define the zero
FAM013_AHTM@Proc@referencePoint=2.0675
#do zero order phase correction
plot.spectrum(phaseCorr(fourierTransform(FAM013_AHTM,isBruker=FALSE),zeroOrder=75),xlim=range(-0.1,0.1),ylim=range(-1e4,2e6))
#have a look at lower zoom
plot.spectrum(phaseCorr(fourierTransform(FAM013_AHTM,isBruker=FALSE),zeroOrder=75),xlim=range(-0.1,8.3),ylim=range(-1e4,4e6))

plot.spectrum(phaseCorr(fourierTransform(FAM013_AHTM,isBruker=FALSE),zeroOrder=75),xlim=range(-0.1,8.3),ylim=range(-1e4,4e7))
