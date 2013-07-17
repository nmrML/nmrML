Currently, rNMR only reads processed data. This is no problem for Bruker/nmrPipe/Sparky, but has some challenges when dealing with Varian data. The bleeding-edge rNMR code is on sourceforge at the following link:
http://sourceforge.net/p/rnmr/code/338/tree/development/rNMR/R/rNMR.r
 
Here are the commands rNMR uses in converting and reading files:

Sparky format (this is rNMR's main format, other file types are converted to Sparky)
 ucsfHead
 ucsf1D
 ucsf2D
 ucsf3D
 ucsfTile

rNMR sparse matrix format (this is a new file type that I am using to transfer big datasets over the net)
 rsdHead
 rsd1D
 rsd2D

Bruker format (Requires processed Burker spectra)
 parseAcqus
 parseProcs
 bruker1D
 bruker2D

NMRPipe (Requires processed pipe format spectra)
 pipe2rnmr

Varian (Requires processed Varian data, this function requires data to be saved in specific way)
 parseProcpar
 varian1D
 varian2D

Ascii (basic block/vector format)
 ascii2rnmr

Wrapper and user functions (calls and creates the guis for converting files)
 conFiles
 cf
 ca

Cheers,

Ian

