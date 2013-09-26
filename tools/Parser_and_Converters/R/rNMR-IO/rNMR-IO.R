################################################################################
##                                                                            ##
##                  Spectral (binary) file reading utilities                  ##
##                                                                            ##
################################################################################

## Internal function ucsfHead
## Reads a sparky format file and returns a header and other file info 
## file.name - File to be read, NULL will open a file selection window
## print.info - prints a summary of the data if TRUE
## returns a header for a sparky format file
ucsfHead <- function (file.name = NULL, print.info = TRUE){
	
	## Get the path to the file
	if(is.null(file.name))
		file.name <- myOpen(title = "Select a spectrum", multiple = FALSE)
	if(file.name == '')
		return(invisible())
	
	## Open connection to binary file and check the file format
	con <- myFile(file.name, "rb")
	fileType <- readLines(con, n=1)
	if (fileType == "RSD_NMR"){
		close(con)
		return(rsdHead(file.name, print.info))
	}
	if(fileType != "UCSF NMR"){
		close(con)
		stop(paste('rNMR only accepts UCSF (sparky) format data.',
						'Use cf() to convert spectra to the correct format.',
						'If you want to load an R workspace, use wl().', sep='\n'), 
				call.=FALSE)
	}
	
	## Make sure data is modern sparky format and is 1D, 2D, or 3D
	seek(con, where=10, origin = "start")
	nDim <- readBin(con, size=1, what='integer') 
	if(nDim != 1 && nDim != 2 && nDim != 3){
		close(con)
		stop('rNMR only supports 1D, 2D, and 3D sparky format data', call.=FALSE)
	}
	if(readBin(con, size = 1, what = 'integer') != 1){
		close(con)
		stop('rNMR does not support complex data', call.=FALSE)
	}
	seek(con, where = 13, origin = "start")
	if(readBin(con, size=1, what='integer') != 2 ){ 
		close(con)
		stop('rNMR only supports the current version of sparky formatting', 
				call.=FALSE)
	}
	
	## Get file information
	fileInfo <- file.info(file.name)
	fsize <- fileInfo$size
	mtime <- fileInfo$mtime
	
	## Set points for the start of each header
	headStart <- 180
	
	## Set endian format -- sort of a bonehead way of doing it...
	endFormat <- 'big'
	seek(con, where=(headStart + 20), origin = "start")
	w2Frq <- readBin(con, size=4, what='double', endian=endFormat) 
	
	## Switch endian format if the frequency is wierd
	if( is.na(w2Frq) || w2Frq < 1 || w2Frq > 1500 )
		endFormat <- 'little'
	
	## Read noise estimate if present
	seek(con, where=14, origin="start")
	noiseText <- readBin(con, size=8, what='character')
	noiseEst <- NULL
	if (noiseText == 'noiseEst')
		noiseEst <- readBin(con, size=4, what='double', endian=endFormat)
	
	## Read first header
	if( nDim == 1 ){
		axis <- 'w2'
	}else
		axis <- 'w1'
	
	## Set nucleus name (1H, 13C, 15N, 31P, ...)
	seek(con, where=headStart, origin = "start")
	nuc <- readBin(con, size=6, what='character')
	
	## number of data points in this axis
	seek(con, where=(headStart + 8), origin = "start")
	msize <- readBin(con, size=4, what='integer', endian=endFormat)
	
	## tile size along this axis
	seek(con, where=(headStart + 16), origin = "start")
	bsize <- readBin(con, size=4, what='integer', endian=endFormat)
	
	##spectrometer frequency (MHz)
	seek(con, where=(headStart + 20), origin = "start")
	sFrq <- readBin(con, size=4, what='double', endian=endFormat)
	
	## spectral width (Hz)
	seek(con, where=(headStart + 24), origin = "start")
	swHz <- readBin(con, size=4, what='double', endian=endFormat)
	
	## center of data (ppm)
	seek(con, where= (headStart + 28), origin = "start")
	cFrqPPM <- readBin(con, size=4, what='double', endian=endFormat)
	
	## up and downfield shifts for this axis
	seek(con, where=(headStart + 32), origin = "start")
	upShift <- readBin(con, size=4, what='double', endian=endFormat)
	downShift <- readBin(con, size=4, what='double', endian=endFormat)
	
	## Start of NMR data for 1D
	binLoc <- headStart + 128
	
	##Read the second header
	if( nDim > 1){
		
		headStart <- headStart + 128
		
		## Start of NMR data for 2D
		binLoc <- headStart + 128 
		
		axis <- c(axis, 'w2')
		
		## Set nucleus name (1H, 13C, 15N, 31P, ...)
		seek(con, where=headStart, origin = "start")
		nuc <- c(nuc, readBin(con, size=6, what='character'))
		
		## number of data points in this axis
		seek(con, where=(headStart + 8), origin = "start")
		msize <- c(msize, readBin(con, size=4, what='integer', endian=endFormat))
		
		## tile size along this axis
		seek(con, where=(headStart + 16), origin = "start")
		bsize <- c(bsize, readBin(con, size=4, what='integer', endian=endFormat))
		
		#spectrometer frequency (MHz)
		seek(con, where=(headStart + 20), origin = "start")
		sFrq <- c(sFrq, readBin(con, size=4, what='double', endian=endFormat))
		
		## spectral width (Hz)
		seek(con, where=(headStart + 24), origin = "start")
		swHz <- c(swHz, readBin(con, size=4, what='double', endian=endFormat))
		
		## center of data (ppm)
		seek(con, where=(headStart + 28), origin = "start")
		cFrqPPM <- c(cFrqPPM, readBin(con, size=4, what='double', endian=endFormat))
		
		## up and downfield shifts for this axis
		seek(con, where=(headStart + 32), origin = "start")
		upShift <- c(upShift, readBin(con, size=4, what='double', 
						endian=endFormat))
		downShift <- c(downShift, readBin(con, size=4, what='double', 
						endian=endFormat))
	}
	
	##Read the third header
	if( nDim == 3 ){
		
		headStart <- headStart + 128
		
		## Start of NMR data for 2D
		binLoc <- headStart + 128 
		
		axis <- c('w1', 'w2', 'w3')
		
		## Set nucleus name (1H, 13C, 15N, 31P, ...)
		seek(con, where=headStart, origin = "start")
		nuc <- c(nuc[2], readBin(con, size=6, what='character'), nuc[1])
		
		## number of data points in this axis
		seek(con, where=(headStart + 8), origin = "start")
		msize <- c(msize[2], readBin(con, size=4, what='integer', endian=endFormat), 
				msize[1])
		
		## tile size along this axis
		seek(con, where=(headStart + 16), origin = "start")
		bsize <- c(bsize[2], readBin(con, size=4, what='integer', endian=endFormat),
				bsize[1])
		
		#spectrometer frequency (MHz)
		seek(con, where=(headStart + 20), origin = "start")
		sFrq <- c(sFrq[2], readBin(con, size=4, what='double', endian=endFormat),
				sFrq[1])
		
		## spectral width (Hz)
		seek(con, where=(headStart + 24), origin = "start")
		swHz <- c(swHz[2], readBin(con, size=4, what='double', endian=endFormat),
				swHz[1])
		
		## center of data (ppm)
		seek(con, where=(headStart + 28), origin = "start")
		cFrqPPM <- c(cFrqPPM[2], readBin(con, size=4, what='double', 
						endian=endFormat), cFrqPPM[1])
		
		## up and downfield shifts for this axis
		seek(con, where=(headStart + 32), origin = "start")
		upShift <- c(upShift[2], readBin(con, size=4, what='double', 
						endian=endFormat), upShift[1])
		downShift <- c(downShift[2], readBin(con, size=4, what='double', 
						endian=endFormat), downShift[1])
	}
	
	## Find the range, interquartile range, and median of spectrum for noise est
	## For 2D/3D data, this is based on the first tile
	seek(con, where = binLoc, origin = "start")
	if(nDim > 1){          
		file.range <- fivenum(readBin(con, size=4, what='double',
						endian = endFormat, n=(bsize[1] * bsize[2])))                                                
	}else
		file.range <- fivenum(readBin(con, size=4, what='double',
						endian = endFormat, n= msize[1])) 
	
	## Close binary connection
	closeAllConnections()
	
	## Translate sweep width to ppm
	swPPM <- swHz / sFrq
	
	## Calculate the up and downfield shifts
	if (all(downShift == 0) && all(upShift == 0)){
		upPPM <- cFrqPPM - (swPPM / 2)
		downPPM <- cFrqPPM + (swPPM / 2)
	}else{
		
		## Use the up and downfield shifts from the header if present
		## This is used for files that have been converted from ASCII
		upPPM <- round(upShift, 5)
		downPPM <- round(downShift, 5)
	}
	
	## Calculate noise estimate, if not present in main header
	if (is.null(noiseEst))
		noiseEst <- (diff(file.range[c(2, 4)]) / 2) / .674 ## 1 sd
	
	## Make a new header with extracted data
	head <- list(
			file.name = file.name,
			file.size = fsize,
			date.modified = mtime,
			axis = axis,
			nucleus = nuc,
			matrix_size = msize,
			block_size = bsize,
			upfield_ppm = upPPM,
			downfield_ppm = downPPM,
			spectrum_width_Hz = swHz,
			transmitter_MHz = sFrq,
			center_ppm = cFrqPPM,
			binary_location = binLoc,
			endian = endFormat,
			number_dimensions = nDim,
			noise_est = noiseEst,
			min_intensity = file.range[1],
			max_intensity = file.range[5],
			zero_offset = file.range[3],
			user_title = basename(file.name)
	)
	if (nDim == 3)
		head$z_value <- upPPM[3]
	
	## Print useful file info if print.info = TRUE
	if(print.info)
		print(data.frame(head[5:12]))
	
	## Modify upfield PPM for rNMR format 
	## NOTE: Fourier transform shifts the observed center
	##       frequency to the right in the frequency domain.
	##       This small defect can cause problems when the number of points 
	##       collected is very small. The code below corrects the problem
	##       for most datasets. However, if a different Fourier algorithm is used
	##       then the correction may be applied in the wrong direction.
	##       A more robust method for determining this correction would be 
	##       an obvious method for improving the accuracy of peak picking.
	if (all(downShift == 0) && all(upShift == 0)){
		cor <- ((head$downfield_ppm - head$upfield_ppm) / (msize - 1))	* 
				-(msize %% 2 - 1)
		head$upfield_ppm <- head$upfield_ppm + cor
	}
	return( list( file.par = head ) )
}


## Internal function rsdHead
## Reads an RSD file and returns header information 
## fileName - File to be read, NULL will open a file selection window
## print.info - prints a summary of the data if TRUE
## returns a header for a sparky format file
rsdHead <- function (file.name, print.info=TRUE){
	
	## Get the path to the file
	if (missing(file.name))
		file.name <- myOpen(title='Select a spectrum', multiple=FALSE, 
				filetypes=list(rsd="RSD File"))
	if (!nzchar(file.name))
		return(invisible())
	
	## Open connection to binary file and check the file format
	con <- myFile(file.name, 'rb')
	fileType <- readBin(con, size=10, what='character')
	if (fileType != 'RSD_NMR'){
		close(con)
		stop('Specified file is not in RSD format.', call.=FALSE)
	}
	
	## Read top-level header
	seek(con, where=20)
	nDim <- readBin(con, size=4, what='integer', endian='big')
	nblocks <- readBin(con, size=4, what='integer', endian='big')
	noiseEst <- readBin(con, size=4, what='double', endian='big')
	
	## Read header information for original spectrum
	origNp <- origDown <- origUp <- sw <- sf <- nuc <- NULL
	for (i in 1:nDim){
		seek(con, where=(100 + (i - 1) * 50 + 4))
		origNp <- c(origNp, readBin(con, size=4, what='integer', endian='big'))
		origDown <- c(origDown, readBin(con, size=4, what='double', endian='big'))
		origUp <- c(origUp, readBin(con, size=4, what='double', endian='big'))
		sw <- c(sw, readBin(con, size=4, what='double', endian='big'))
		sf <- c(sf, readBin(con, size=4, what='double', endian='big'))
		nuc <- c(nuc, readBin(con, size=10, what='character'))
	}
	
	## Read block headers
	np <- downShifts <- upShifts <- as.list(1:nDim)
	seek(con, where=(100 + nDim * 50))
	for (i in 1:nDim){
		for (j in 1:nblocks){
			seek(con, where=4, origin='current')
			np[[i]][j] <- readBin(con, size=4, what='integer', endian='big')
			downShifts[[i]][j] <- readBin(con, size=4, what='double',	endian='big')
			upShifts[[i]][j] <- readBin(con, size=4, what='double', endian='big')
			if (!(j == nblocks && i == nDim))
				seek(con, where=14, origin='current')
		}
	}
	
	## Get file information
	binLoc <- 100 + nDim * 50 + nDim * nblocks * 30
	fileInfo <- file.info(file.name)
	fsize <- fileInfo$size
	mtime <- fileInfo$mtime
	
	## Format values
	if (nDim == 1){
		axis <- 'w2'
		totalPoints <- sum(np[[1]])
	}else{
		axis <- c('w1', 'w2')
		totalPoints <- sum(np[[1]] * np[[2]])
	}
	names(np) <- names(downShifts) <- names(upShifts) <- axis
	
	## Find the range, interquartile range, and median of spectrum for noise est
	seek(con, where=binLoc, origin='start')
	file.range <- fivenum(readBin(con, size=4, what='double',	endian='big', 
					n=totalPoints)) 
	close(con)
	
	## Make a new header with extracted data
	head <- list(file.name=file.name,
			file.size=fsize,
			date.modified=mtime,
			user_title=basename(file.name),
			axis=axis,
			nucleus=nuc,
			matrix_size=origNp,
			upfield_ppm=origUp,
			downfield_ppm=origDown,
			block_size=np,
			block_upfield_ppms=upShifts,
			block_downfield_ppms=downShifts,
			spectrum_width_Hz=sw,
			transmitter_MHz=sf,
			binary_location=binLoc,
			endian='big',
			number_dimensions=nDim,
			noise_est=noiseEst,
			min_intensity=file.range[1],
			max_intensity=file.range[5],
			zero_offset=file.range[3]
	)
	
	## Print useful file info if print.info = TRUE
	if (print.info)
		print(data.frame(head[5:9]))
	
	return(list(file.par=head))
}


## Internal function ucsf1D
## Reads sparky format 1D spectra and returns data within specified range
## file.name - File to be read, NULL will open a file selection window
## w2Range   - Numeric list of length 2, chemical shift range to be read
## file.par  - The header returned from ucsfHead can be passed to ucsf1D,
##             this speeds up graphics by eliminating noise estimates
## returns   - List object with file header, w2 shifts, and data
ucsf1D <- function(file.name = NULL, w2Range = NULL, file.par = NULL){
	
	## Get the path to the file and ucsf header
	if(is.null(file.name))
		file.name <- myOpen(title = "Select a spectrum", multiple = FALSE)
	if(file.name == '')
		return(invisible())
	if( is.null(file.par) ){
		if (file.name %in% names(fileFolder))
			file.par <- fileFolder[[file.name]]$file.par
		file.par <- ucsfHead(file.name = file.name, print.info = FALSE)[[1]]
	}
	
	## Redirect to rsd1D for RSD format spectra
	if (!is.null(file.par$block_upfield_ppms)){
		outFolder <- rsd1D(file.name, w2Range, file.par)
		return(outFolder)
	}
	
	## Setup outgoing list 
	outFolder <- list( file.par = file.par, w2 = seq(file.par$upfield_ppm[1], 
					file.par$downfield_ppm[1], length.out = file.par$matrix_size[1]), 
			data = NULL )
	
	## Make sure valid w2 ranges were submitted
	out <- list( w2 = NULL )
	if( is.null(w2Range) || length(w2Range) != 2 || !is.numeric(w2Range) ){
		w2Range <- c(file.par$upfield_ppm[1], file.par$downfield_ppm[1])
		out$w2 <- c(1,length(outFolder$w2))
	}else{
		w2Range <- sort(w2Range)	
		t1 <- findInterval(w2Range, outFolder$w2, all.inside = TRUE)	
		t2 <- t1 + 1
		for(i in 1:2)
			out$w2[i] <- switch( which.min(c(
									abs(w2Range[i] - outFolder$w2[t1[i]]),
									abs(w2Range[i] - outFolder$w2[t2[i]]))), t1[i], t2[i])
	}
	
	## Read data from memory if entry exists in fileFolder
	if (file.name %in% names(fileFolder) && 
			!is.null(fileFolder[[file.name]]$data))
		outFolder$data <- fileFolder[[file.name]]$data
	else{
		
		## Read binary data
		endFormat <- outFolder$file.par$endian 
		con <- myFile(file.name, "rb")
		seek(con, where=outFolder$file.par$binary_location, origin = "start")
		outFolder$data <- readBin(con, size=4, what='double',
				endian = endFormat, n=outFolder$file.par$matrix_size[1])
		closeAllConnections()
	}
	
	## Trim data to fit w2 ranges
	outFolder$w2 <- outFolder$w2[out$w2[1]:out$w2[2]]
	
	## Invert selections to match binary
	out$w2 <- sort(outFolder$file.par$matrix_size[1] - out$w2) + 1	
	outFolder$data <- outFolder$data[out$w2[1]:out$w2[2]]
	
	return(outFolder)
}


## Internal function ucsf2D
## Reads sparky format spectra and returns all of the sparky tiles covered
##    by the chemical shift range provided.
## file.name - name of spectrum to be read, NULL opens a file slection window
## w1Range = Min and Max chemical shifts to be read in the indirect dimension,
##           NULL will return all values.
## w2Range = Min and Max chemical shifts to be read in the direct dimension
##           NULL will return all values.
## file.par - file header (from ucsfHead()), NULL will read the header first
## notes: providing a file.par from memory is used to speed up graphics
## returns the designated region of a spectrum and associated parameters
ucsf2D <- function ( file.name = NULL, w1Range=NULL, w2Range=NULL,
		file.par=NULL){
	
	## Get the path to the file and ucsf header
	if(is.null(file.name))
		file.name <- myOpen(title = "Select a spectrum", multiple = FALSE)
	if(file.name == '')
		return(invisible())
	if( is.null(file.par) ){
		if (file.name %in% names(fileFolder))
			file.par <- fileFolder[[file.name]]$file.par
		file.par <- ucsfHead(file.name = file.name, print.info = FALSE)[[1]]
	}
	
	## Redirect to ucsf1D if 1D file is opened
	if( file.par$number_dimensions == 1 )
		return(ucsf1D( file.name=file.name, w2Range=w2Range, file.par=file.par ))
	
	## Redirect to rsd2D if RSD file is opened
	if( !is.null(file.par$block_upfield_ppms) )
		return(rsd2D( file.name=file.name, w1Range=w1Range, w2Range=w2Range, 
						file.par=file.par ))
	
	## Redirect to ucsf3D if 3D file is opened
	if( file.par$number_dimensions == 3 )
		return(ucsf3D( file.name=file.name, w1Range=w1Range, w2Range=w2Range, 
						file.par=file.par ))
	
	## Setup outgoing list 
	outFolder <- list( file.par = file.par, 
			w1 = seq(file.par$upfield_ppm[1], file.par$downfield_ppm[1], 
					length.out = file.par$matrix_size[1]),
			w2 = seq(file.par$upfield_ppm[2], file.par$downfield_ppm[2], 
					length.out = file.par$matrix_size[2]), data = NULL )
	
	## Make sure valid w2 ranges were submitted
	out <- list( w1 = NULL, w2 = NULL )
	if( is.null(w1Range) || length(w1Range) != 2 || !is.numeric(w1Range) )
		w1Range <- c(file.par$upfield_ppm[1], file.par$downfield_ppm[1])
	if( is.null(w2Range) || length(w2Range) != 2 || !is.numeric(w2Range) )
		w2Range <- c(file.par$upfield_ppm[2], file.par$downfield_ppm[2])
	
	## Find best w1/w2 matches	
	w1Range <- sort(w1Range); w2Range <- sort(w2Range)
	t1 <- findInterval(w1Range, outFolder$w1, all.inside = TRUE)
	d1 <- findInterval(w2Range, outFolder$w2, all.inside = TRUE)
	t2 <- t1 + 1; d2 <- d1 + 1
	for(i in 1:2){
		out$w1[i] <- switch( which.min(c(
								abs(w1Range[i] - outFolder$w1[t1[i]]),
								abs(w1Range[i] - outFolder$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch( which.min(c(
								abs(w2Range[i] - outFolder$w2[d1[i]]),
								abs(w2Range[i] - outFolder$w2[d2[i]]))), d1[i], d2[i])
	}
	
	## Trim w1/w2 Ranges
	outFolder$w1 <- outFolder$w1[ (out$w1[1] : out$w1[2] )]
	outFolder$w2 <- outFolder$w2[ (out$w2[1] : out$w2[2] )]
	
	## Invert w1/w2 selection to match binary data format
	out$w1 <- sort(file.par$matrix_size[1] - out$w1) + 1
	out$w2 <- sort(file.par$matrix_size[2] - out$w2) + 1
	
	## Read and trim data from memory if entry exists in fileFolder
	if (file.name %in% names(fileFolder) && 
			!is.null(fileFolder[[file.name]]$data)){
		outFolder$data <- fileFolder[[file.name]]$data[out$w2[1]:out$w2[2], 
				out$w1[1]:out$w1[2]]
		return(outFolder)
	}
	
	## Find sparky tiles that will be plotted
	w1Tiles <- (ceiling(out$w1[1] / file.par$block_size[1]):
				ceiling(out$w1[2] / file.par$block_size[1]))
	w2Tiles <- (ceiling(out$w2[1] / file.par$block_size[2]):
				ceiling(out$w2[2] / file.par$block_size[2]))
	tiles <- NULL
	for ( i in 1:length(w1Tiles))
		tiles <- c(tiles, ((w1Tiles[i]-1) * (ceiling(file.par$matrix_size[2] / 
												file.par$block_size[2])) + (w2Tiles-1)))
	
	## Reset the match index to the active tiles
	out$w1 <- out$w1 - (w1Tiles[1] -1 ) * file.par$block_size[1]
	out$w2 <- out$w2 - (w2Tiles[1] -1 ) * file.par$block_size[2]
	gc(FALSE)
	
	## Open connection to binary file
	w2TileNum <- ceiling(file.par$matrix_size[2] / file.par$block_size[2] )
	endFormat <- file.par$endian
	outFolder$data <- matrix( rep( NA, file.par$block_size[1] * length(w1Tiles) * 
							file.par$block_size[2] * length(w2Tiles)), 
			ncol = file.par$block_size[1] * length(w1Tiles))
	con <- myFile(file.name, "rb")
	seek(con, where = file.par$binary_location, origin = "start")
	
	##Read binary data for each tile
	j <- -1
	w1Count <- w2Count <- 1
	for(i in tiles){
		w1R <- (1:file.par$block_size[1]) + file.par$block_size[1] * (w1Count -1)
		w2R <- (1:file.par$block_size[2]) + file.par$block_size[2] * (w2Count -1)
		w2Count <- w2Count + 1
		if(w2Count > length(w2Tiles)){
			w2Count <- 1
			w1Count <- w1Count + 1
		}
		
		## read binary
		seek(con, where = (file.par$block_size[1] *
							file.par$block_size[2] * 4 * (i - j - 1)), origin = "current")
		outFolder$data[w2R, w1R] <- readBin(con, size=4, what='double',
				endian = endFormat, 
				n=(file.par$block_size[1] * file.par$block_size[2]))
		j <- i
	}
	
	## Close binary conection
	closeAllConnections()
	
	## Trim data to fit w1/w2 ranges
	outFolder$data <- outFolder$data[out$w2[1]:out$w2[2], out$w1[1]:out$w1[2]]
	gc(FALSE)
	
	return(outFolder)
}


## Internal function ucsf3D
## Reads sparky format spectra and returns all of the sparky tiles covered
##    by the chemical shift range provided.
## file.name - name of spectrum to be read, NULL opens a file slection window
## w1Range - Min and Max chemical shifts to be read in the indirect dimension,
##           NULL will return all values.
## w2Range - Min and Max chemical shifts to be read in the direct dimension
##           NULL will return all values.
## w3Range - chemical shift in the z dimension, must be a single value
## file.par - file header (from ucsfHead()), NULL will read the header first
## notes: providing a file.par from memory is used to speed up graphics
## returns the designated region of a spectrum and associated parameters
ucsf3D <- function(file.name=NULL, w1Range=NULL, w2Range=NULL, w3Range=NULL, 
		file.par=NULL){
	
	## Get the path to the file and ucsf header
	if (is.null(file.name))
		file.name <- myOpen(title="Select a spectrum", multiple=FALSE)
	if (file.name == '')
		return(invisible())
	if( is.null(file.par) ){
		if (file.name %in% names(fileFolder))
			file.par <- fileFolder[[file.name]]$file.par
		file.par <- ucsfHead(file.name = file.name, print.info = FALSE)[[1]]
	}
	
	## Define some local variables
	bs <- file.par$block_size
	ms <- file.par$matrix_size
	uf <- file.par$upfield_ppm
	df <- file.par$downfield_ppm
	endFormat <- file.par$endian
	binLoc <- file.par$binary_location
	
	## Setup outgoing list 
	outFolder <- list(file.par=file.par, w1=seq(uf[1], df[1], length.out=ms[1]),
			w2=seq(uf[2], df[2], length.out=ms[2]), w3=seq(uf[3], df[3], 
					length.out=ms[3]), data=NULL)
	
	## Make sure valid w2 ranges were submitted
	if (is.null(w1Range) || length(w1Range) != 2 || !is.numeric(w1Range))
		w1Range <- c(file.par$upfield_ppm[1], file.par$downfield_ppm[1])
	if (is.null(w2Range) || length(w2Range) != 2 || !is.numeric(w2Range))
		w2Range <- c(file.par$upfield_ppm[2], file.par$downfield_ppm[2])
	if (is.null(w3Range) || length(w3Range) != 1 || !is.numeric(w3Range))
		w3Range <- rep(file.par$z_value, 2)
	
	## Find best w1/w2 matches	
	w1Range <- sort(w1Range); w2Range <- sort(w2Range)
	t1 <- findInterval(w1Range, outFolder$w1, all.inside=TRUE)
	d1 <- findInterval(w2Range, outFolder$w2, all.inside=TRUE)
	z1 <- findInterval(w3Range, outFolder$w3, all.inside=TRUE)
	t2 <- t1 + 1; d2 <- d1 + 1; z2 <- z1 + 1
	out <- NULL
	for(i in 1:2){
		out$w1[i] <- switch(which.min(c(abs(w1Range[i] - outFolder$w1[t1[i]]),
								abs(w1Range[i] - outFolder$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch(which.min(c(abs(w2Range[i] - outFolder$w2[d1[i]]),
								abs(w2Range[i] - outFolder$w2[d2[i]]))), d1[i], d2[i])
		out$w3[i] <- switch(which.min(c(abs(w3Range[i] - outFolder$w3[z1[i]]),
								abs(w3Range[i] - outFolder$w3[z2[i]]))), z1[i], z2[i])
	}
	
	## Trim w1/w2 Ranges
	outFolder$w1 <- outFolder$w1[(out$w1[1]:out$w1[2])]
	outFolder$w2 <- outFolder$w2[(out$w2[1]:out$w2[2])]
	outFolder$w3 <- outFolder$w3[(out$w3[1]:out$w3[2])]
	
	## Invert w1/w2 selection to match binary data format
	out$w1 <- sort(ms[1] - out$w1) + 1
	out$w2 <- sort(ms[2] - out$w2) + 1
	
	## Read and trim data from memory if entry exists in fileFolder
	if (file.name %in% names(fileFolder) && 
			!is.null(fileFolder[[file.name]]$data)){
		outFolder$data <- fileFolder[[file.name]]$data[out$w2[1]:out$w2[2], 
				out$w1[1]:out$w1[2]]
		return(outFolder)
	}
	
	## Find sparky tiles that will be plotted
	w1Tiles <- (ceiling(out$w1[1] / bs[1]):ceiling(out$w1[2] / bs[1]))
	w2Tiles <- (ceiling(out$w2[1] / bs[2]):ceiling(out$w2[2] / bs[2]))
	w3Tiles <- (ceiling(out$w3[1] / bs[3]):ceiling(out$w3[2] / bs[3]))
	tiles <- NULL
	numTiles <- ceiling(ms / bs)
	for (i in w1Tiles)
		tiles <- c(tiles, (i - 1) * numTiles[2] + (w2Tiles - 1))
	tiles <- tiles + (w3Tiles - 1) * numTiles[1] * numTiles[2]
	
	
	## Reset the match index to the active tiles
	out$w1 <- out$w1 - (w1Tiles[1] - 1) * bs[1]
	out$w2 <- out$w2 - (w2Tiles[1] - 1) * bs[2]
	out$w3 <- out$w3 - (w3Tiles[1] - 1) * bs[3]
	
	## Open connection to binary file
	w2TileNum <- ceiling(ms[2] / bs[2] )
	outFolder$data <- matrix(NA, nrow=bs[2] * length(w2Tiles), 
			ncol=bs[1] * length(w1Tiles))
	con <- myFile(file.par$file.name, "rb")
	
	##Read binary data for each tile
	w1Count <- w2Count <- 1
	tileSize <- bs[1] * bs[2] * bs[3] * 4
	for (i in tiles){
		
		## Define current w1/w2 range
		w1R <- (1:bs[1]) + bs[1] * (w1Count - 1)
		w2R <- (1:bs[2]) + bs[2] * (w2Count - 1)
		w2Count <- w2Count + 1
		if (w2Count > length(w2Tiles)){
			w2Count <- 1
			w1Count <- w1Count + 1
		}
		
		## Define data location for current tile
		tileLoc <- tileSize * i + binLoc
		if (bs[3] > 1)
			zPos <- (out$w3[1] - 1) * bs[3]
		else
			zPos <- 0
		dataLoc <- tileLoc + bs[1] * bs[2] * 4 * zPos
		
		## read binary
		seek(con, dataLoc, origin='start')
		outFolder$data[w2R, w1R] <- readBin(con, size=4, what='double', 
				endian=endFormat,	n=bs[1] * bs[2])
	}
	close(con)
	
	## Trim data to fit shift ranges
	outFolder$data <- outFolder$data[out$w2[1]:out$w2[2], out$w1[1]:out$w1[2]]
	
	return(outFolder)
} 


## Internal function rsd1D
## Reads RSD format 1D spectra and returns data within specified range
## file.name - name of spectrum to be read, NULL opens a file slection window
## w2Range - Numeric list of length 2, chemical shift range to be read
## file.par - file header (from rsdHead()), NULL will read the header first
## notes: providing a file.par from memory is used to speed up graphics
## returns the designated region of a spectrum and associated parameters
rsd1D <- function(file.name=NULL, w2Range=NULL, file.par=NULL){
	
	## Get the path to the file and RSD header
	if (is.null(file.name))
		file.name <- myOpen(title='Select a spectrum', multiple=FALSE)
	if (!length(file.name) || !nzchar(file.name))
		return(invisible())
	if( is.null(file.par) )
		file.par <- rsdHead(file.name=file.name, print.info=FALSE)[[1]]
	
	## Setup outgoing list 
	outFolder <- list(file.par=file.par, w2=seq(file.par$upfield_ppm[1], 
					file.par$downfield_ppm[1], length.out=file.par$matrix_size[1]), 
			data=NULL)
	
	## Make sure a valid w2 range was submitted
	if (is.null(w2Range) || length(w2Range) != 2 || !is.numeric(w2Range))
		w2Range <- c(file.par$upfield_ppm[1], file.par$downfield_ppm[1])
	
	## Find best w2 matches
	w2Range <- sort(w2Range)	
	t1 <- findInterval(w2Range, outFolder$w2, all.inside=TRUE)	
	t2 <- t1 + 1
	out <- list(w2=NULL)
	for (i in 1:2)
		out$w2[i] <- switch(which.min(c(abs(w2Range[i] - outFolder$w2[t1[i]]),
								abs(w2Range[i] - outFolder$w2[t2[i]]))), t1[i], t2[i])
	winW2 <- outFolder$w2[(out$w2[1]:out$w2[2])]
	
	## Find tiles that will be plotted
	tiles <- NULL
	for (tNum in seq_along(file.par$block_size$w2)){
		
		## Get the chemical shifts for the current tile
		blockW2 <- seq(file.par$block_upfield_ppms$w2[tNum], 
				file.par$block_downfield_ppms$w2[tNum], 
				length.out=file.par$block_size$w2[tNum])
		
		## Check the window for the presence of any shift in the current block
		if (any(round(blockW2, 3) %in% round(winW2, 3)))
			tiles <- c(tiles, tNum)
	}
	
	## Define data locations for each block
	blockLoc <- file.par$binary_location
	for (i in seq_along(file.par$block_size$w2))
		blockLoc <- c(blockLoc, blockLoc[i] + 4 * file.par$block_size$w2[i])
	
	## Read binary data for each tile
	outFolder$data <- rep(0, length(outFolder$w2))
	con <- myFile(file.name, 'rb')
	for (i in tiles){
		
		## Find best w2 matches for current tile
		w2Range <- c(file.par$block_upfield_ppms$w2[i], 
				file.par$block_downfield_ppms$w2[i])
		t1 <- findInterval(w2Range, outFolder$w2, all.inside=TRUE)
		t2 <- t1 + 1
		tile <- NULL
		for (j in 1:2)
			tile$w2[j] <- switch(which.min(c(abs(w2Range[j] - outFolder$w2[t1[j]]),
									abs(w2Range[j] - outFolder$w2[t2[j]]))), t1[j], t2[j])
		
		## Read data for current tile
		seek(con, blockLoc[i], origin='start')
		outFolder$data[tile$w2[1]:tile$w2[2]] <- rev(readBin(con, size=4, 
						what='double', endian='big',	n=file.par$block_size$w2[i]))
	}
	close(con)
	
	## Trim data to fit w2 ranges
	outFolder$w2 <- winW2
	outFolder$data <- rev(outFolder$data[out$w2[1]:out$w2[2]])
	
	return(outFolder)  
}


## Internal function rsd2D
## Reads 2D RSD format spectra and returns all of the tiles covered by the 
##	chemical shift range provided.
## file.name - name of spectrum to be read, NULL opens a file slection window
## w1Range - Min and max chemical shifts to be read in the indirect dimension,
##           NULL will return all values.
## w2Range - Min and max chemical shifts to be read in the direct dimension
##           NULL will return all values.
## file.par - file header (from rsdHead()), NULL will read the header first
## notes: providing a file.par from memory is used to speed up graphics
## returns the designated region of a spectrum and associated parameters
rsd2D <- function(file.name=NULL, w1Range=NULL, w2Range=NULL,
		file.par=NULL){
	
	## Get the path to the file and RSD header
	if (is.null(file.name))
		file.name <- myOpen(title='Select a spectrum', multiple=FALSE, 
				filetypes=list(rsd="RSD File"))
	if (!length(file.name) || !nzchar(file.name))
		return(invisible())
	if (is.null(file.par))
		file.par <- rsdHead(file.name=file.name, print.info=FALSE)[[1]]
	
	## Setup outgoing list 
	outFolder <- list(file.par=file.par, w1=seq(file.par$upfield_ppm[1], 
					file.par$downfield_ppm[1], length.out=file.par$matrix_size[1]),
			w2=seq(file.par$upfield_ppm[2], file.par$downfield_ppm[2], 
					length.out=file.par$matrix_size[2]), data=NULL) 
	
	## Make sure valid w2 ranges were submitted
	if (is.null(w1Range) || length(w1Range) != 2 || !is.numeric(w1Range))
		w1Range <- c(file.par$upfield_ppm[1], file.par$downfield_ppm[1])
	if (is.null(w2Range) || length(w2Range) != 2 || !is.numeric(w2Range))
		w2Range <- c(file.par$upfield_ppm[2], file.par$downfield_ppm[2])
	
	## Find best w1/w2 matches	
	w1Range <- sort(w1Range)
	w2Range <- sort(w2Range)
	t1 <- findInterval(w1Range, outFolder$w1, all.inside=TRUE)
	d1 <- findInterval(w2Range, outFolder$w2, all.inside=TRUE)
	t2 <- t1 + 1
	d2 <- d1 + 1
	out <- list(w1=NULL, w2=NULL)
	for (i in 1:2){
		out$w1[i] <- switch(which.min(c(abs(w1Range[i] - outFolder$w1[t1[i]]),
								abs(w1Range[i] - outFolder$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch(which.min(c(abs(w2Range[i] - outFolder$w2[d1[i]]),
								abs(w2Range[i] - outFolder$w2[d2[i]]))), d1[i], d2[i])
	}
	winW1 <- outFolder$w1[(out$w1[1]:out$w1[2])]
	winW2 <- outFolder$w2[(out$w2[1]:out$w2[2])]
	
	## Find tiles that will be plotted
	tiles <- NULL
	upShifts <- file.par$block_upfield_ppms
	downShifts <- file.par$block_downfield_ppms
	blockSizes <- file.par$block_size
	for (tNum in seq_along(file.par$block_size$w1)){
		
		## Get the chemical shifts for the current tile
		blockW1 <- seq(upShifts$w1[tNum], downShifts$w1[tNum], 
				length.out=blockSizes$w1[tNum])
		blockW2 <- seq(upShifts$w2[tNum], downShifts$w2[tNum],
				length.out=blockSizes$w2[tNum])
		
		## Check the window for the presence of any shift in the current block
		if (any(round(blockW1, 3) %in% round(winW1, 3)) && 
				any(round(blockW2, 3) %in% round(winW2, 3)))
			tiles <- c(tiles, tNum)
	}
	
	## Define data locations for each block
	blockLoc <- file.par$binary_location
	for (i in seq_along(file.par$block_size$w1))
		blockLoc <- c(blockLoc, blockLoc[i] + 4 * file.par$block_size$w1[i] * 
						file.par$block_size$w2[i])
	
	## Read binary data for each tile
	outData <- matrix(0, nrow=length(outFolder$w2), ncol=length(outFolder$w1))
	con <- myFile(file.name, "rb")
	for (i in tiles){
		
		## Find best w1/w2 matches for current tile
		w1Range <- c(upShifts$w1[i], downShifts$w1[i])
		w2Range <- c(upShifts$w2[i], downShifts$w2[i])
		t1 <- findInterval(w1Range, outFolder$w1, all.inside=TRUE)
		d1 <- findInterval(w2Range, outFolder$w2, all.inside=TRUE)
		t2 <- t1 + 1
		d2 <- d1 + 1
		tile <- NULL
		for (j in 1:2){
			tile$w1[j] <- switch(which.min(c(abs(w1Range[j] - outFolder$w1[t1[j]]),
									abs(w1Range[j] - outFolder$w1[t2[j]]))), t1[j], t2[j])
			tile$w2[j] <- switch(which.min(c(abs(w2Range[j] - outFolder$w2[d1[j]]),
									abs(w2Range[j] - outFolder$w2[d2[j]]))), d1[j], d2[j])
		}
		
		## Read data for current tile and place in matrix
		seek(con, blockLoc[i], origin='start')
		outData[tile$w2[1]:tile$w2[2], tile$w1[1]:tile$w1[2]] <- 
				matrix(rev(readBin(con, size=4, what='double', endian='big', 
										n=file.par$block_size$w1[i] * file.par$block_size$w2[i])), 
						ncol=file.par$block_size$w1[i])
	}
	close(con)
	
	## Trim data to fit w1/w2 ranges
	outFolder$w1 <- winW1
	outFolder$w2 <- winW2
	outData <- outData[out$w2[1]:out$w2[2], out$w1[1]:out$w1[2]]
	outFolder$data <- matrix(rev(outData), ncol=length(outFolder$w1))
	
	return(outFolder)
}


## Internal function ucsfTile
## Reads a single sparky tile from a binary connection and returns a data folder
## file.par - rNMR file header for file to be read (output from ucsfHead)
## con      - A seekable connection, if missing, a connection will be opened
##            to the path provided by file.par$file.name 
## tile     - The sparky tile to be read as a zero indexed integer
## w1       - If tile is missing, then w1 and w2 chemical shifts can be given
##            and the entire tile that corresponds to the shifts is returned
## w2       - Numeric value of w2 chemical shift in ppm
## returns  - A data folder with the file header, data, and chemical shifts
##            for the entire tile.
## Note:    - This function is used for plotting 2D data and 2D peak picking
##            and is used to avoid loading large chunks of data into memory.
ucsfTile <- function(file.par, con, tile, w1, w2){
	
	## Check incoming arguments
	if( missing(tile) && missing(w1) && missing(w2) )
		stop('A tile or w1Range and w2Range must be provided')
	if( missing(file.par) )
		stop('A file.par must be provided')
	if( file.par$number_dimensions != 2 )
		stop('ucsfTile only supports 2D sparky data')
	if( missing(con) || !isSeekable(con) ){
		con <- myFile(file.par$file.name, "rb")
		closeCon <- TRUE
	}else
		closeCon <- FALSE
	
	## Setup outgoing list 
	outFolder <- list( file.par = file.par, w1 = NULL, w2 = NULL, data = NULL )
	tTiles <- ceiling(file.par$matrix_size / file.par$block_size )
	
	if( missing(tile)){
		
		## Make sure valid w2 ranges were submitted
		if( any( !is.numeric(c(w1, w2)) ) || length(c(w1, w2)) != 2 )
			stop('w1 and w2 must be numeric values of length 1, use ucsf2D')
		
		## Find w1/w2 tiles and sparky tiles
		mShift <- matchShift(outFolder, w1 = w1, w2 = w2, 
				return.inc = TRUE, return.seq = FALSE, invert = TRUE)		
		w1Tiles <- (mShift$w1 - 1)  %/% file.par$block_size[1]
		w2Tiles <- (mShift$w2 - 1)  %/% file.par$block_size[2]
		tile <- w1Tiles * tTiles[2] + w2Tiles[1]
		
	}else{
		## Stop if more than one tile is provided
		if(length(tile) > 1 )
			stop('ucsfTile can only read 1 tile at a time, use ucsf2D')
		w1Tiles <- floor( tile %/% tTiles[2] )
		w2Tiles <- floor( tile %% tTiles[2] ) 	
	}
	
	## Set the outgoing chemical shift range
	w1Range <- (1:file.par$block_size[1]) + (w1Tiles * file.par$block_size[1])
	w1Range <- w1Range[w1Range <= file.par$matrix_size[1]]
	w2Range <- (1:file.par$block_size[2]) + (w2Tiles * file.par$block_size[2])
	w2Range <- w2Range[w2Range <= file.par$matrix_size[2]]
	outFolder$w1 <- rev(seq(file.par$downfield_ppm[1], file.par$upfield_ppm[1],
					length.out = file.par$matrix_size[1])[w1Range])	
	outFolder$w2 <- rev(seq(file.par$downfield_ppm[2],file.par$upfield_ppm[2],
					length.out = file.par$matrix_size[2])[w2Range])
	
	## Find the binary location an read the data
	seek(con, file.par$block_size[1] * file.par$block_size[2] * 4 * tile + 
					file.par$binary_location, origin = 'start')
	outFolder$data <- matrix(readBin(con, size=4, what='double', 
					endian = file.par$endian, 
					n=(file.par$block_size[1] * file.par$block_size[2])), 
			ncol = file.par$block_size[1])
	outFolder$data <- outFolder$data[(1:length(w2Range)), (1:length(w1Range))]
	
	if(closeCon)
		closeAllConnections()	
	
	return(outFolder)
}
