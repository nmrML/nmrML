################################################################################
################################################################################
##                                                                            ##
##                                                                            ##
##    rNMR version 2.0.0, Tools for viewing and analyzing NMR spectra.        ##
##    Copyright (C) 2009 Ian A. Lewis and Seth C. Schommer under GPL-3        ##
##                                                                            ##
##    This program is free software: you can redistribute it and/or modify    ##
##    it under the terms of the GNU General Public License as published by    ##
##    the Free Software Foundation, either version 3 of the License, or       ##
##    any later version.                                                      ##
##                                                                            ##
##    This program is distributed in the hope that it will be useful,         ##
##    but WITHOUT ANY WARRANTY; without even the implied warranty of          ##
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           ## 
##    GNU General Public License for more details.                            ##
##                                                                            ##
##    A copy of the GNU General Public License can be found at:               ##
##    www.r-project.org/Licenses/GPL-3                                        ##
##                                                                            ##
##                                                                            ##
################################################################################
################################################################################


################################################################################
##                                                                            ##
##     Internal functions for creating, saving and updating rNMR objects      ##
##                                                                            ##
################################################################################

## Assigns objects to the global environment and creates an undo point
myAssign <- function(in.name = NULL, in.object, save.backup = TRUE){
	
	## Make sure the file name is the correct format
	if(!is.character(in.name)) 
		stop( 'myAssign requires a character input', call. = FALSE)
	if( in.name == 'currentSpectrum' )
		in.object <- in.object[1]
	
	## Assign object to global environment
	if(in.name != 'zoom')
		assign(in.name, in.object, inherits=FALSE, envir=.GlobalEnv)
	else  
		assign("fileFolder", in.object, inherits=FALSE, envir=.GlobalEnv)
	
	## Backup copies of the environment for undo/redo 
	if( save.backup && (in.name == "fileFolder" || in.name == "roiTable" ||
				in.name == "currentSpectrum" || in.name == "roiSummary" || 
				in.name == "overlayList" || in.name == "zoom" || 
				in.name == "globalSettings" )){
		
		## Assign NA to non existing files as a structure placeholder
		if(!exists("fileFolder") || is.null(fileFolder))
			fileFolder <- list(NA, NA)
		if(!exists("roiTable") || is.null(roiTable))
			roiTable <- list(NA, NA)
		if(!exists("currentSpectrum") || is.null(currentSpectrum))
			currentSpectrum <- list(NA)
		if(!exists("roiSummary") || is.null(roiSummary))  
			roiSummary <- list(NA, NA)
		if(!exists("overlayList") || is.null(overlayList))
			overlayList <- list(NA, NA)
		if(!exists("globalSettings") || is.null(globalSettings))
			globalSettings <- list(NA, NA)
		
		## Assign the current global state of the environment to the undo list
		if(!exists('oldFolder'))
			oldFolder <- list( undo.index = 0, assign.index = 0, fileFolder = NULL, 
					roiTable = NULL, currentSpectrum = NULL, 
					roiSummary = NULL, overlayList = NULL,
					zoom.history = NULL, zoom.list = NULL)
		if(is.null(oldFolder$undo.index))
			oldFolder$undo.index <- 0
		oldFolder$undo.index <- oldFolder$undo.index + 1  
		if(is.null(oldFolder$assign.index))
			oldFolder$assign.index <- 0
		oldFolder$assign.index <- oldFolder$assign.index + 1  
		oldFolder$fileFolder[[oldFolder$undo.index]] <- fileFolder  
		oldFolder$roiTable[[oldFolder$undo.index]] <- roiTable
		oldFolder$currentSpectrum[[oldFolder$undo.index]] <- currentSpectrum  
		oldFolder$roiSummary[[oldFolder$undo.index]] <-
				roiSummary 
		oldFolder$overlayList[[oldFolder$undo.index]] <- overlayList
		oldFolder$globalSettings[[oldFolder$undo.index]] <- globalSettings
		
		## Keep a seperate zoom list for zoom previous command
		if( in.name == 'currentSpectrum' ){
			oldFolder$zoom.list <- list()
			oldFolder$zoom.list[[1]] <- fileFolder[[currentSpectrum]]$graphics.par$usr
		}
		if((in.name == 'zoom' || is.null(oldFolder$zoom.list)) && 
				(!is.na(fileFolder[1]) && !is.na(currentSpectrum[1])) ){
			oldFolder$zoom.list[[(length(oldFolder$zoom.list) + 1)]] <- 
					fileFolder[[currentSpectrum]]$graphics.par$usr
			oldFolder$zoom.history[[oldFolder$undo.index]] <- TRUE  
		}else
			oldFolder$zoom.history[[oldFolder$undo.index]] <- FALSE      
		
		## Trim oldFolder after undo
		if(oldFolder$undo.index < length(oldFolder$fileFolder)){
			for(i in 1:length(oldFolder)){
				if(names(oldFolder)[i] != 'undo.index' && 
						names(oldFolder)[i] != 'assign.index' &&
						names(oldFolder)[i] != 'zoom.list') 
					oldFolder[[i]] <- oldFolder[[i]][1:oldFolder$undo.index]
			}      
		}
		
		## Limit oldFolder to 10 entries
		if(oldFolder$undo.index > 10){
			for(i in 1:length(oldFolder)){
				if(names(oldFolder)[i] != 'undo.index'&& 
						names(oldFolder)[i] != 'assign.index')
					oldFolder[[i]] <- rev(rev(oldFolder[[i]])[1:10])
			}
			oldFolder$undo.index <- 10  
		}
		
		## Save changes to oldFolder
		assign("oldFolder", oldFolder, inherits=FALSE, envir=.GlobalEnv) 
		
		## Save a backup copy of the workspace
		if (defaultSettings$autoBackup && (oldFolder$assign.index == 1 || 
					!oldFolder$assign.index %% 10)){
			cat('\nPerforming automatic backup . . . ')
			tryCatch(invisible(save(list=ls(envir=.GlobalEnv, all.names=TRUE), 
									file=file.path('~', '.rNMRbackup'), version=NULL, ascii=FALSE, 
									compress=FALSE, envir=.GlobalEnv, eval.promises=FALSE, 
									precheck=FALSE)), error=function(){})
			cat('complete\n')
		}
	}         
}

## Internal function for checking vaulues in defaultSettings
## newDef - object to check
## returns newDef with the correct formatting, all invalid entries will be set
##	to their default values
checkDef <- function(newDef){
	if (missing(newDef))
		newDef <- defaultSettings
	
	##ensure newDef is not missing any values
	defSet <- createObj('defaultSettings', returnObj=TRUE)
	defLength <- length(defSet)
	defNames <- names(defSet)
	newNames <- names(newDef)
	if (length(newDef) < defLength){
		missingNames <- which(is.na(match(defNames, newNames)))
		newDef <- c(newDef, defSet[missingNames])
	}
	
	##reformat values
	for (i in defNames){
		if (length(grep('pch$', i))){
			if (!is.na(suppressWarnings(as.numeric(newDef[[i]]))))
				defMode <- 'numeric'
			else
				defMode <- 'character'
		}
		else if (length(grep('tck$', i)))
			defMode <- 'numeric'
		else
			defMode <- storage.mode(defSet[[i]]) 
		if (defMode != 'function')
			tryCatch(suppressWarnings(storage.mode(newDef[[i]]) <- defMode), 
					error=function(er) newDef[[i]] <- NULL)
		
		##ensure values are the correct length
		if (!i %in% c('libLocs', 'searchLibs') && 
				length(newDef[[i]]) != length(defSet[[i]]))
			newDef[[i]] <- defSet[[i]]
		
		##check for NA values in rNMR specific settings
		rNMRnames <- defNames[66:length(defSet)]
		rNMRnames <- rNMRnames[-match(c('xtck', 'ytck'), rNMRnames)]
		if (i %in% rNMRnames && suppressWarnings(is.na(newDef[[i]])))
			newDef[[i]] <- defSet[[i]]
		
		##check for valid colors
		colorNames <- defNames[grep('color', defNames)]
		if (i %in% colorNames){
			colTest <- try(col2rgb(newDef[[i]]), silent=TRUE)
			if (class(colTest) == 'try-error')
				newDef[[i]] <- defSet[[i]]
		}
	}	
	
	##check for invalid "par" values and reset to default
	dev.new()
	par(defSet[1:65])
	parNames <- defNames[1:65]
	for (i in parNames)
		tryCatch(par(newDef[i]), error=function(er) 
					newDef[i] <<- defSet[i])
	dev.off()
	
	##check for invalid rNMR-specific parameters
	if (!newDef$type %in% c('auto', 'image', 'contour', 'filled', 'l', 'p', 'b'))
		newDef$type <- defSet$type
	if (newDef$position.1D < 0 || newDef$position.1D > 99)
		newDef$position.1D <- defSet$position.1D
	if (newDef$offset < -100 || newDef$offset > 100)
		newDef$offset <- defSet$offset
	if (!newDef$proj.type %in% c('l', 'p', 'b'))
		newDef$proj.type <- defSet$proj.type
	if (newDef$proj.direct != 1 && newDef$proj.direct != 2)
		newDef$proj.direct <- defSet$proj.direct	
	if (!newDef$peak.noiseFilt %in% c(0, 1, 2))
		newDef$peak.noiseFilt <- defSet$peak.noiseFilt
	if (!newDef$peak.labelPos %in% c('top', 'bottom', 'left', 'right', 
			'center'))
		newDef$peak.labelPos <- defSet$roi.labelPos
	if (newDef$clevel <= 0)
		newDef$clevel <- defSet$clevel
	if (newDef$nlevels < 1 || newDef$nlevels > 1000)
		newDef$nlevels <- defSet$nlevels
	if (any(newDef$roi.lwd <= 0))
		newDef$roi.lwd <- defSet$roi.lwd
	if (!newDef$roi.labelPos %in% c('top', 'bottom', 'left', 'right', 'center'))
		newDef$roi.labelPos <- defSet$roi.labelPos
	if (!newDef$roi.noiseFilt %in% c(0, 1, 2))
		newDef$roi.noiseFilt <- defSet$peak.noiseFilt
	
	##check for valid library locations
	newDef$libLocs <- newDef$libLocs[file.exists(newDef$libLocs)]
	if (!length(newDef$libLocs))
		newDef$libLocs <- defSet$libLocs
	newDef$searchLibs <- newDef$searchLibs[file.exists(newDef$searchLibs)]
	if (!length(newDef$searchLibs))
		newDef$searchLibs <- defSet$searchLibs
	
	return(newDef)
}

## Internal function for writing defaultSettings out to file
## configFile - character string; file path to save the default settings to
## defSet - list; the object containing a list of default settings for rNMR
writeDef <- function(configFile, defSet){
	if (missing(configFile))
		configFile <- file.path(path.expand('~'), '.rNMR')
	if (missing(defSet))
		defSet <- defaultSettings
	dput(defSet, file=configFile)
	
	return(configFile)
}

## Internal function for reading in defaultSettings from file
## This function is depracted and is used only for backward-compatibility with
##	the previous defaultSettings format
## configFile - character string; full path to the file where defaultSettings
## 	is saved
## returns values from configFile as a list, in the standard defaultSettings
##	format
oldReadDef <- function(configFile, check=TRUE){
	
	##read from file
	if (missing(configFile))
		configFile <- file.path(path.expand('~'), '.rNMR')
	if (!file.exists(configFile))
		return(NULL)
	defText <- readLines(configFile)
	
	##create list object from file text
	defNames <- defText[grep('#$', defText, fixed=TRUE)]
	defNames <- sapply(strsplit(defNames, '#$', fixed=TRUE), function(x) x[2])
	newDef <- as.list(rep("", length(defNames)))
	names(newDef) <- defNames
	valName <- NULL
	defVal <- NULL
	for (i in seq_along(defText)){
		
		##increment loop if text is a blank line
		if (!nzchar(defText[i]))
			next
		
		##increment loop and store value if text is a parameter name
		if (length(grep('#$', defText[i], fixed=TRUE))){
			valName <- unlist(strsplit(defText[i], '#$', fixed=TRUE))[2]
			next
		}
		
		##get parameter value(s)
		defVal <- c(defVal, defText[i])
		nextVal <- defText[i + 1]
		if (i != length(defText) && nzchar(nextVal))
			next
		
		##insert values into newDef
		if (!is.null(valName)){
			if (valName == 'filter' && defVal[1] != '0'){
				newDef[[valName]] <- function(x){}
				body(newDef[[valName]]) <- parse(text=paste(defVal, collapse='\n'))
			}else
				newDef[[valName]] <- defVal
		}
		defVal <- NULL
	}
	if (check)
		newDef <- checkDef(newDef)
	
	return(newDef)
}

## Internal function for reading in defaultSettings from file
## configFile - character string; full path to the file where defaultSettings
## 	is saved
## returns values from configFile as a list, in the standard defaultSettings
##	format
readDef <- function(configFile, check=TRUE){
	
	##check configFile path and format
	if (missing(configFile))
		configFile <- file.path(path.expand('~'), '.rNMR')
	if (!file.exists(configFile)){
		newDef <- NULL
	}else if (!length(readLines(configFile))){
		newDef <- NULL
	}else{	
		newDef <- tryCatch(dget(configFile), error=function(er)
					oldReadDef(configFile, check))
	}
	
	##check values
	if (check)
		newDef <- checkDef(newDef)
	
	return(newDef)
}

## Internal utility function for creating rNMR objects
## objList - character vector, a list of objects to create
## overwrite - logical, overwrites old data if TRUE
## returnObj - logical, returns a created object if TRUE
createObj <- function(objList, overwrite=FALSE, returnObj=FALSE){
	
	## Turn off locator bell
	options(locatorBell=FALSE)
	
	## Make a list of all rNMR objects if objList is not provided
	if (missing(objList))
		objList <- c('currentSpectrum', 'defaultSettings', 'fileFolder',
				'globalSettings', 'oldFolder', 'overlayList', 'pkgVar', 
				'roiSummary', 'roiTable', 'assignments')
	forceCurrent <- forceDefault <- forceFile <- forceGlobal <- forceOld <-
			forceOverlay <- forcePkg <- forceSum <- forceRoi <- forceAssign <- FALSE
	
	## Create defaultSettings
	defSet <- list(adj=0.5, ann=TRUE, ask=FALSE, bg="black", bty="7", cex=1, 
			cex.axis=.95, cex.lab=1, cex.main=1, cex.sub=1, col="white",
			col.axis="white", col.lab="white", col.main="white", col.sub="white", 
			crt=0, err=0, family="", fg="white", fig=c(0, 1, 0, 1),
			fin=c(10, 6.98958333333333), font=1, font.axis=1, font.lab=1, font.main=2, 
			font.sub=1, lab=c(5, 5, 7), las=0, lend="round", lheight=1, ljoin="round", 
			lmitre=10, lty="solid", lwd=1, mai=c(1.02, 0.82, 0.82, 0.42), 
			mar=c(2.25, 2.25, 1.5, 1), mex=1, mfcol=c(1, 1), mfg=c(1, 1, 1, 1), 
			mfrow=c(1, 1),	mgp=c(3, 1, 0), mkh=0.001, new=FALSE, oma=c(0, 0, 0, 0), 
			omd=c(0, 1, 0, 1), omi=c(0, 0, 0, 0), pch=1, 
			pin=c(8.76, 5.14958333333333), 
			plt=c(0.082, 0.958, 0.145931445603577, 0.882682563338301), ps=12, pty="m", 
			smo=1, srt=0, tck=NA, tcl=-0.5, usr=c(0, 10, 0,	10), xaxp=c(2, 8, 3), 
			xaxs="r", xaxt="s", xlog=FALSE, xpd=FALSE, yaxp=c(20, 80, 6), yaxs="r", 
			yaxt="s", ylog=FALSE,
			pos.color="blue", neg.color="green", conDisp=c(TRUE, TRUE), nlevels=20,
			clevel=6, type="auto", theta=10,	phi=10,	asp=4, position.1D=.1, offset=0, 
			proj.color='yellow', proj.type="l",	proj.mode=FALSE, proj.direct=1, 
			filter=function(x){range(x)[which.max(abs(range(x)))]}, peak.disp=FALSE, 
			peak.color='white', peak.cex=.7, peak.pch='x', peak.labelPos='top', 
			peak.noiseFilt=0, thresh.1D=6, roiMain=TRUE, roi.multi=TRUE, roiMax=TRUE, 
			roi.bcolor=c('red', 'white'), roi.tcolor=c('red', 'white'),	
			roi.lwd=c(2, 1), roi.lty=c('solid', 'dashed'), roi.labelPos='center', 
			roi.cex=c(.95, .95), roi.noiseFilt=2, roi.w1=0, roi.w2=0, roi.pad=15, 
			xtck=NA, ytck=NA, size.main=c(6, 4.25), size.sub=c(6, 1.5),	
			size.multi=c(6, 4.25), mar.sub=c(.1, .1, 1.6, .1), 
			mar.multi=c(0, 0, 0, 0), cex.roi.multi=1, cex.files.multi=1, 
			cex.roi.sub=1, overlay.text=TRUE, autoBackup=TRUE, sdi=TRUE, update=TRUE,
			wd=path.expand('~'),
			libLocs=gsub('\\', '/', system.file('Libraries/1H_13C_HSQC_pH7.4', 
							package='rNMR'), fixed=TRUE),
			searchLibs=gsub('\\', '/', system.file('Libraries/1H_13C_HSQC_pH7.4', 
							package='rNMR'), fixed=TRUE), libUpdate=TRUE)
	
	## Check defaultSettings
	if ('defaultSettings' %in% objList){
		
		## Replace defaultSettings if it is not the correct format
		if (!exists('defaultSettings', envir=.GlobalEnv) || 
				!is.list(defaultSettings) || length(defaultSettings) < length(defSet))
			forceDefault <- TRUE
		
		if (!returnObj){
			
			## Assign defaultSettings 
			if (overwrite || forceDefault){
				assign('defaultSettings', defSet, envir=.GlobalEnv)
			}
			
			## Read defaultSettings from file	
			configFile <- file.path(path.expand('~'), '.rNMR')
			if (length(configFile) && file.exists(configFile)){
				defSet <- readDef(configFile)
				assign('defaultSettings', defSet, envir=.GlobalEnv)
			}
		}
	}
	
	## Create globalSettings
	globalPars <- c('offset', 'position.1D', 'filter', 'proj.direct', 'proj.mode', 
			'proj.type', 'peak.disp', 'peak.noiseFilt', 'thresh.1D', 'peak.pch', 
			'peak.cex', 'peak.labelPos', 'roiMain', 'roiMax', 'roi.bcolor', 
			'roi.tcolor', 'roi.lwd', 'roi.lty', 'roi.cex', 'roi.labelPos', 
			'roi.noiseFilt', 'roi.w1', 'roi.w2', 'roi.pad', 'cex.roi.multi', 
			'cex.files.multi', 'cex.roi.sub', 'size.main', 'size.sub', 'size.multi', 
			'mar', 'mar.sub', 'mar.multi', 'overlay.text')
	defGlobal <- defSet[globalPars]
	
	## Create fileFolder
	defFile <- NULL
	
	## Create oldFolder
	defOld <- list( undo.index = 0, assign.index = 0, fileFolder = NULL, 
			roiTable = NULL, currentSpectrum = NULL,	roiSummary = NULL, 
			overlayList = NULL, zoom.history = NULL, zoom.list = NULL)
	
	## Create currentSpectrum
	if (exists('fileFolder'))
		defCurrent <- names(fileFolder)[length(fileFolder)]
	else	
		defCurrent <- NULL
	
	## Create overlaylist
	defOverlay <- NULL
	
	## Create roiTable
	defRoi <- NULL
	
	## Create roiSummary
	defSummary <- NULL
	
	## Create pkgVar
	defPkg <- list()
	defPkg$prevDir <- defSet$wd
	defPkg$version <- suppressWarnings(paste(packageDescription('rNMR', 
							fields='Version'), ' (',	packageDescription('rNMR', 
							fields='Date'), ')', sep=''))
	
	## Create assignments
	defAssign <- NULL
	
	## Returns the newly created object
	if (returnObj)
		return(switch(objList[1], 'currentSpectrum'=defCurrent, 
						'defaultSettings'=defSet, 
						'fileFolder'=defFile,
						'globalSettings'=defGlobal, 
						'oldFolder'=defOld, 
						'overlayList'=defOverlay, 
						'pkgVar'=defPkg, 
						'roiSummary'=defSummary, 
						'roiTable'=defRoi, 
						'assignments'=defAssign))	
	
	## Check globalSettings
	if ('globalSettings' %in% objList){
		
		## Replace globalSettings if it is not the correct format
		if (!exists('globalSettings', envir=.GlobalEnv) || !is.list(globalSettings) 
				|| length(globalSettings) != length(defGlobal))
			forceGlobal <- TRUE
		
		## Assign globalSettings
		if (overwrite || forceGlobal)
			assign('globalSettings', defGlobal, envir=.GlobalEnv)
	}
	
	## Check fileFolder
	if ('fileFolder' %in% objList){
		
		## Replace fileFolder if it is not the correct format
		if (!exists('fileFolder', envir=.GlobalEnv) || !is.null(fileFolder) && 
				!is.list(fileFolder))
			forceFile <- TRUE
		
		## Assign fileFolder
		if (overwrite || forceFile)
			assign('fileFolder', defFile, envir=.GlobalEnv)
	}
	
	## Check oldFolder
	if ('oldFolder' %in% objList){
		
		## Replace oldFolder if it is not the correct format
		if (!exists('oldFolder', envir=.GlobalEnv) || !is.list(oldFolder))
			forceOld <- TRUE
		
		## Assign oldFolder
		if (overwrite || forceOld)
			assign('oldFolder', defOld, envir=.GlobalEnv)
	}
	
	## Check currentSpectrum
	if ('currentSpectrum' %in% objList){
		
		## Replace currentSpectrum if it is not the correct format
		if (!exists('currentSpectrum', envir=.GlobalEnv) || 
				!is.null(currentSpectrum) && (!nzchar(currentSpectrum) || 
					length(currentSpectrum) != 1 || !is.character(currentSpectrum)))
			forceCurrent <- TRUE
		
		## Assign currentSpectrum
		if (overwrite || forceCurrent)
			assign('currentSpectrum', defCurrent, envir=.GlobalEnv)
	}
	
	## Check overlaylist
	if ('overlayList' %in% objList){
		
		## Replace overlayList if it is not the correct format
		if (!exists('overlayList', envir=.GlobalEnv) || !is.null(overlayList) && 
				!is.character(overlayList))
			forceOverlay <- TRUE
		
		## Assign overlayList
		if (overwrite || forceOverlay)
			assign('overlayList', defOverlay, envir=.GlobalEnv)
	}
	
	## Check roiTable
	if ('roiTable' %in% objList){
		
		## Replace roiTable if it is not the correct format
		if (!exists('roiTable', envir=.GlobalEnv) || !is.null(roiTable) && 
				!is.data.frame(roiTable))
			forceRoi <- TRUE
		
		## Assign roiTable
		if (overwrite || forceRoi)
			assign('roiTable', defRoi, envir=.GlobalEnv)
	}
	
	## Check roiSummary
	if ('roiSummary' %in% objList){
		
		## Replace roiSummary if it is not the correct format
		if (!exists('roiSummary', envir=.GlobalEnv) || !is.null(roiSummary) && 
				!is.list(roiSummary))
			forceSum <- TRUE
		
		## Assign roiSummary
		if (overwrite || forceSum)
			assign('roiSummary', defSummary, envir=.GlobalEnv)
	}
	
	## Check pkgVar
	if ('pkgVar' %in% objList){
		
		## Replace pkgVar if it is not the correct format
		if (exists('pkgVar', envir=.GlobalEnv) && !is.null(pkgVar$prevDir) && 
				!overwrite && pkgVar$prevDir != path.expand('~'))
			defPkg$prevDir <- pkgVar$prevDir
		
		## Assign pkgVar
		assign('pkgVar', defPkg, envir=.GlobalEnv)
	}
	
	## Check assignments
	if ('assignments' %in% objList){
		
		## Replace assignments if it is not the correct format
		if (!exists('assignments', envir=.GlobalEnv) || 
				!is.null(assignments) && !is.data.frame(assignments))
			forceAssign <- TRUE
		
		## Assign roiTable
		if (overwrite || forceAssign)
			assign('assignments', defAssign, envir=.GlobalEnv)
	}
	
	invisible()
}

## Patch for code compatibilty with older rNMR workspaces
## delete - logical, deletes old objects if TRUE
patch <- function(delete=TRUE){
	
	## Do not apply the patch if rNMR version is up to date
	if (exists('pkgVar') && identical(pkgVar, createObj('pkgVar', 
					returnObj=TRUE)$version))
		return(invisible())
	
	## Check for missing values in defaultSettings
	defSet <- createObj('defaultSettings', returnObj=TRUE)
	defaultSettings <- readDef(check=FALSE)
	if (!is.null(defaultSettings)){
		if (length(defaultSettings) == length(defSet)){
			defSet <- checkDef(defaultSettings)
		}else{
			
			## Append missing values
			missingNames <- names(defSet)[!names(defSet) %in% names(defaultSettings)]
			defaultSettings[missingNames] <- defSet[missingNames]
			
			## Write out defaultSettings
			defaultSettings <- checkDef(defaultSettings)
			writeDef(defSet=defaultSettings)
			defSet <- defaultSettings
		}
		myAssign("defaultSettings", defaultSettings, save.backup=FALSE)
	}
	
	## Check fileFolder for correct structure
	if (exists('fileFolder') && !is.null(fileFolder) && length(fileFolder)){
		for (i in seq_along(fileFolder)){
			if (length(fileFolder[[i]]$graphics.par) < length(defSet)){
				missingItems <- defSet[!names(defSet) %in% 
								names(fileFolder[[i]]$graphics.par)]
				fileFolder[[i]]$graphics.par <- c(fileFolder[[i]]$graphics.par, 
						missingItems)
				fileFolder[[i]]$graphics.par$mar <- defSet$mar
				fileFolder[[i]]$graphics.par$cex.main <- defSet$cex.main
				fileFolder[[i]]$graphics.par$cex.axis <- defSet$cex.axis
			}
			if (is.null(fileFolder[[i]]$file.par$file.size) || 
					is.null(fileFolder[[i]]$file.par$date.modified)){
				fileInfo <- tryCatch(file.info(fileFolder[[i]]$file.par$file.name), 
						error=function(er) NULL)
				fileFolder[[i]]$file.par$file.size <- fileInfo$size
				fileFolder[[i]]$file.par$date.modified <- fileInfo$mtime
			}
			if (is.null(fileFolder[[i]]$file.par$user_title)){
				userTitle <- basename(names(fileFolder)[i])
				userTitles <- sapply(fileFolder, function(x) x$file.par$user_title)
				if (userTitle %in% userTitles)
					userTitle <- names(fileFolder)[i]
				fileFolder[[i]]$file.par$user_title <- userTitle
			}
		}
		myAssign("fileFolder", fileFolder, save.backup=FALSE)
	}
	if (exists('file.folder') && !exists('fileFolder')){
		createObj(c('defaultSettings', 'globalSettings'), overwrite=TRUE)		
		
		## Update fileFolder
		fileFolder <- file.folder
		if( is.list(fileFolder) ){
			for( i in 1:length(fileFolder) ){
				usr <- fileFolder[[i]]$graphics.par$usr
				fileFolder[[i]]$graphics.par <- defaultSettings
				fileFolder[[i]]$graphics.par$usr <- 
						c(rev(sort(usr[1:2])), rev(sort(usr[3:4])))
			}
		} 
		myAssign("fileFolder", fileFolder, save.backup = FALSE )
	}
	
	## Rename rNMR objects
	if(exists('roi.table') && (!exists('roiTable') || (exists('roiTable') && 
					is.null(roiTable))))
		myAssign("roiTable", roi.table, save.backup=FALSE)
	if(exists('overlay.list') && (!exists('overlayList') || (exists('overlayList') 
					&& is.null(overlayList))))
		myAssign("overlayList", overlay.list, save.backup=FALSE)
	if(exists('old.folder') && (!exists('oldFolder') || (exists('oldFolder') &&
					is.null(oldFolder$fileFolder))))
		myAssign("oldFolder", createObj('oldFolder', returnObj=TRUE), 
				save.backup=FALSE)
	if(exists('current.roi.summary') && (!exists('roiSummary') || 
				(exists('roiSummary') && is.null(roiSummary))))
		myAssign("roiSummary", current.roi.summary, save.backup=FALSE)
	if(exists('prevDir') && (!exists('pkgVar') || (exists('pkgVar') && 
					is.null(pkgVar$prevDir)))){
		pkgVar <- createObj('pkgVar', returnObj=TRUE)
		pkgVar$prevDir <- prevDir
		myAssign('pkgVar', pkgVar)
	}
	
	## Create any missing rNMR objects
	createObj()
	
	## Update roiTable format
	if( !is.null(roiTable) ){
		if(length(which(names(roiTable) == 'nDim')) == 0){
			roiTable$nDim <- rep(2, nrow(roiTable))
			myAssign("roiTable", roiTable, save.backup = FALSE) 
		}
	}
	
	## Update roiSummary format
	if( !is.null(roiSummary) ){
		if(!is.list(roiSummary))
			myAssign("roiSummary", NULL, save.backup = FALSE)
		else if (!is.null(roiSummary$data) && 'GROUP' %in% names(roiSummary$data)){
			newSum <- NULL
			newSum$data <- roiSummary$data[2:ncol(roiSummary$data)]
			newSum$summary.par$summary.type <- 'maximum'
			newSum$summary.par$norm.data.source <- NA
			if (!is.null(roiSummary$summary.par$normalization.ROIs)){
				if (is.na(roiSummary$summary.par$normalization.ROIs[1]))
					newSum$summary.par$normalization <- 'none'
				else if (roiSummary$summary.par$normalization.ROIs[1] == 
						'Signal to noise')
					newSum$summary.par$normalization <- 'signal/noise'
				else{
					newSum$summary.par$normalization <- 'internal'
					newSum$summary.par$norm.data.source <- 
							roiSummary$summary.par$normalization.ROIs
				}
			}else
				newSum$summary.par$normalization <- 'none'
			myAssign("roiSummary", newSum, save.backup=FALSE)
		}
	} 
	
	## Update version
	if (exists('pkgVar')){
		pkgVar$version <- createObj('pkgVar', returnObj=TRUE)$version
		myAssign('pkgVar', pkgVar, save.backup=FALSE)	
	}
	
	## Remove all of the old objects
	oldObj <- c('about', 'addGui', 'ANOVA', 'appendPeak', 'load', 'pReg',
			'assignGroups', 'autoRef', 'bringFocus', 'changeColor', 'changeRoi', 'co', 
			'buttonDlg', 'createObj', 'ct', 'ct1D', 'ct2D', 'ctd', 'ctu', 'cw', 'da', 
			'dd', 'devGui', 'di', 'dp', 'dr', 'draw2D', 'drawNMR', 'drf', 'ed', 'err', 
			'export', 'fancyPeak2D', 'fc', 'ff', 'fillCon', 'findTiles', 'fo', 'gui', 
			'hideGui', 'import', 'isNoise', 'loc', 'localMax', 'matchShift', 
			'maxShift', 'mmcd', 'more', 'myAssign', 'myDialog', 'myMsg', 'myOpen', 
			'mySave', 'mySelect', 'newRange', 'nf', 'obs2List', 'ol', 'orderROI', 
			'overlays', 'pa', 'paAll', 'pan', 'patch', 'pd', 'pDel', 'pDelAll', 
			'pdisp', 'pe', 'peakDel', 'peakPick', 'peakPick1D', 'peakPick2D', 
			'peakVolume', 'per', 'persp2D', 'ph', 'pj', 'pjv', 'pl', 'plot1D', 
			'plot2D', 'popupGui', 'pp', 'pr', 'proj1D', 'pseudo1D', 'pu', 'pv', 'pw', 
			'pwAll', 'pz', 'ra', 'randomColors', 'rc', 'rcd', 'rci', 'rd', 'rdAll', 
			'rDel', 're', 'recall', 'red', 'refresh', 'regionMax', 'rei', 'reset', 
			'rmd', 'rml', 'rmr', 'rmu', 'rn', 'roi', 'roi.anova', 'roi.pca', 
			'roi.var', 'roi.xy', 'roi.ztdist', 'rotc', 'rotcc', 'rotd', 'rotu', 'rp', 
			'rpAll', 'rs', 'rsAll', 'rsf', 'rSum', 'rv', 'rvm', 'rvs', 'selList', 
			'selMain', 'selMulti', 'selSub', 'setGraphics', 'setWindow', 'shiftToROI',
			'showGui', 'showRoi', 'soon', 'spin', 'sr', 'sr1D', 'sr2D', 'ss', 
			'tclCheck', 'trans2Peak', 'ucsf1D', 'ucsf2D', 'ucsfHead', 'ucsfTile', 
			'ud', 'vp', 'vpd', 'vpu', 'vs', 'wc', 'wl', 'ws', 'xy.plot', 'zc', 'zf', 
			'zi', 'zm', 'zo', 'zp', 'zz', 'anova.plot', 'assign.groups', 'auto.ref', 
			'auto.roi', 'change.roi', 'clickZoom', 'crd', 'cri', 'ct.all', 
			'current.draw.all', 'current.graphics.all', 'default.graphics', 
			'default.settings', 'delete.roi', 'deselect.all', 'draw.roi', 'draw2D', 
			'draw2d', 'drf', 'drff', 'e', 'edit.roi', 'erd', 'eri', 'export.roi', 
			'get.file.name', 'hp', 'import.roi', 'import.summary', 'load.groups', 
			'match.shifts', 'max.shift', 'modify.plot', 'mrd', 'mrl', 'mrr', 'mru', 
			'my.assign', 'my.biplot', 'my.filled', 'neg.only', 'p.clear', 
			'p.clear.all', 'p.edit', 'p.off', 'p.on', 'p.print', 'p.roi', 'p.roi.all',
			'p.save', 'pa.all', 'pc', 'PCA', 'pca.plot', 'peak.pick', 'peak.pick.1D', 
			'peak.pick.2D', 'peak.volume', 'plot.colors', 'plot.gui', 'plot.label', 
			'plot.popup.gui', 'pos.neg', 'pos.only', 'print.data', 'print.graphics', 
			'pw.all', 'pz', 'random.colors', 'renumber.rois', 'replot', 'roi.files', 
			'roi.plot', 'roi.summary', 'save.data', 'select.all', 'select.roi', 
			'set.graphics', 'set.stat.graphics', 'show.roi', 'stat.default.graphics', 
			'stat.print.graphics', 'v.off', 'v.on', 'v1d', 'vabs', 
			'variance.stabilize', 'vd', 'vi', 'view.plot', 'vmax', 'vmin', 'vsi', 
			'z.plot', 'z.test', 'roi.summary', 'roi.table', 'file.folder', 'prevDir',
			'old.folder', 'overlay.list', 'current.roi.summary', 'pdisp.all', 
			'pdisp.off', 'pdisp.off.all', 'plot.roi.summary', 'pm', 'pm.abs', 'pmv', 
			'pmv.abs', 'save.roi.summary', 'ucsfData', 'vsv', 'sdi', 'mdi', 'cf', 
			'tkGuis', 'convList')
	
	if (delete)
		suppressWarnings(rm(list=oldObj, envir=.GlobalEnv))
	updateFiles(halt=FALSE)
}


################################################################################
##                                                                            ##
##     Internal functions for showing, hiding and working with rNMR GUIs      ##
##                                                                            ##
################################################################################

## Internal function for checking that the tcltk package is loaded
tclCheck <- function(){
	
	##load tcltk package
	tryCatch(suppressMessages(library(tcltk)), error=function(er)
				stop("rNMR requires Tcl/Tk version 8.5 or greater", call.=FALSE))
	
	##make sure tcl 8.5 or later is installed
	tclVers <- as.numeric(tcl("info", "tclversion"))
	if (tclVers < 8.5)
		stop("rNMR requires Tcl/Tk version 8.5 or greater", call.=FALSE)
}

## Internal function for creating tcl images from files included with rNMR
## imageName - character string; the name for the tcl image to create
## path - character sting; path to the image file (GIF only) to use, must be 
##	relative to the rNMR package directory
createTclImage <- function(imageName, path=NULL){
	tclImages <- as.character(tcl('image', 'names'))
	if (imageName %in% tclImages)
		return(invisible())
	if (is.null(path))
		path <- paste(imageName, 'gif', sep='.')
	imagePath <- system.file(path, package='rNMR')
	if (!file.exists(imagePath))
		err(paste('Image file:', imagePath, 'does not exist.'))
	tcl('image', 'create', 'photo', imageName, '-file', imagePath)
}

## Internal replacement function for tktoplevel
## Creates a toplevel widget with a given name
## id - character; the pathName for the toplevel, must begin with '.'
## parent - character; parent for the toplevel
## Note:  If a toplevel with the given id already exists the toplevel will be 
##   deiconified (redisplayed)
myToplevel <- function (id, parent, ...){
	
	##check arguments
	tclCheck()
	if (missing(parent))
		parent <- .TkRoot
	if (missing(id))
		id <- paste(parent$ID, evalq(num.subwin <- num.subwin + 1, 
						parent$env), sep = ".")
	else if (length(unlist(strsplit(id, '.', fixed=TRUE))) == 1)
		id <- paste(parent$ID, '.', id, sep='')
	
	##if a toplevel with the same id already exists, display it
	if (as.logical(tcl('winfo', 'exists', id))){
		hideGui(id)
		showGui(id)
		tkfocus(id)
		return(NULL)
	}
	
	##create a new window environment
	win <- .Tk.newwin(id)
	assign(id, win, envir=parent$env)
	assign("parent", parent, envir=win$env)
	
	##create the new toplevel
	win$ID <- id
	tcl("toplevel", id, ...)
	
	##configure the window to be displayed on top of its parent
	if (parent$ID != ""){
		parentTop <- as.logical(tcl('wm', 'attributes', parent, '-topmost'))
		if (parentTop)
			tcl('wm', 'attributes', parent, topmost=FALSE)
		if (as.logical(tkwinfo('viewable', parent)))
			tkwm.transient(win, parent)
		tkwm.withdraw(win)
		tkwm.deiconify(win)
		tkbind(id, "<Destroy>", function(){
					if (parentTop)
						tryCatch(tcl('wm', 'attributes', parent, topmost=TRUE), 
								error=function(er){})
					if (exists(id, envir=parent$env, inherits=FALSE)) 
						rm(list=id, envir=parent$env)
					tkbind(id, "<Destroy>", "")})
	}else{
		tkbind(id, "<Destroy>", function(){
					if (exists(id, envir=parent$env, inherits=FALSE)) 
						rm(list=id, envir=parent$env)
					tkbind(id, "<Destroy>", "")})
	}
	
	return(win)
}

## Internal function for destroying a tk GUI that is currently open 
## guiName - character string: the name for the GUI
closeGui <- function(guiName){
	if (missing(guiName)){
		for (i in ls(envir=.TkRoot$env, all.names=TRUE))
			tryCatch(tkdestroy(i), error=function(er){})
		guiList <- c('per', 'ps', 'co', 'ct', 'os', 'sr', 'pj', 'roi', 'zm', 'pp', 
				'fs', 'ep', 'ca', 'cf', 'aa')
		for (i in guiList)
			tryCatch(tkdestroy(paste('.', i, sep='')), error=function(er){})
	}else{
		for (i in guiName){
			tryCatch(tkdestroy(i), error=function(er){})
			tryCatch(tkdestroy(paste('.', i, sep='')), error=function(er){})
		}
	}
	bringFocus()
}

## Internal function for hiding open tk GUIs
## guiName - character string: the name for the GUI to hide
hideGui <- function(guiName){
	if (missing(guiName)){
		for (i in ls(envir=.TkRoot$env, all.names=TRUE))
			tryCatch(tkwm.iconify(i), error=function(er){})
		guiList <- c('per', 'ps', 'co', 'ct', 'os', 'sr', 'pj', 'roi', 'zm', 'pp', 
				'fs', 'ep', 'ca', 'cf', 'aa')
		for (i in guiList)
			tryCatch(tkwm.iconify(paste('.', i, sep='')), error=function(er){})
	}else{
		for (i in guiName){
			tryCatch(tkwm.iconify(i), error=function(er){})
			tryCatch(tkwm.iconify(paste('.', i, sep='')), error=function(er){})
		}
	}
	bringFocus()
}

## Internal function for hiding open tk GUIs
## guiName - character string: the name for the GUI to show
showGui <- function(guiName){
	if (missing(guiName)){
		for (i in ls(envir=.TkRoot$env, all.names=TRUE))
			tryCatch(tkwm.deiconify(i), error=function(er){})
		guiList <- c('per', 'ps', 'co', 'ct', 'os', 'sr', 'pj', 'roi', 'zm', 'pp', 
				'fs', 'ep', 'ca', 'cf', 'aa')
		for (i in guiList)
			tryCatch(tkwm.deiconify(paste('.', i, sep='')), error=function(er){})
	}else{
		for (i in guiName){
			tryCatch(tkwm.deiconify(i), error=function(er){})
			tryCatch(tkwm.deiconify(paste('.', i, sep='')), error=function(er){})
		}
	}
#	bringFocus()
}

## Internal graphics function gui
## Sets window popup and dropdown windows 
## top - specifies a tk toplevel to send the tk menus to
gui <- function(top=NULL){
	
	if (.Platform$OS.type == 'windows' && .Platform$GUI == 'Rgui' && 
			is.null(top)){
		if ("  rNMR -->  " %in% winMenuNames())
			return(invisible())
		winMenuAdd("  rNMR -->  ")
		winMenuAdd("File")
		winMenuAddItem("File", 'Open/Close files      fs()', "fs()")
		winMenuAddItem("File", 'Convert to rNMR     cf()', "cf()")
		winMenuAddItem("File", '-', "none")
		winMenuAddItem("File", 'Import              import()', "import()")
		winMenuAddItem("File", 'Export                export()', "export()")
		winMenuAddItem("File", '--', "none")
		winMenuAddItem("File", 'Load workspace      wl()', "wl()")
		winMenuAddItem("File", 'Save workspace      ws()', "ws()")
		winMenuAddItem("File", 'Restore backup        rb()', "rb()")
		
		winMenuAdd("Edit")
		winMenuAddItem("Edit", 'Undo                 ud()', "ud()")
		winMenuAddItem("Edit", 'Redo                  rd()', "rd()") 
		winMenuAddItem("Edit", '--', "none")
		winMenuAddItem("Edit", 'Peak list             pe()', "pe()")
		winMenuAddItem("Edit", 'ROI table            re()', "re()")
		winMenuAddItem("Edit", 'ROI summary    se()', "se()")
		winMenuAddItem("Edit", 'Preferences       ep()', "ep()")
		
		
		winMenuAdd("Graphics")
		winMenuAddItem("Graphics", 'Plot colors        co()', "co()")
		winMenuAddItem("Graphics", 'Plot settings      ct()', "ct()")
		winMenuAddItem("Graphics", 'Perspective     per()', "per()")
		
		winMenuAdd("View")
		winMenuAddItem("View", 'Zoom                       zm()', "zm()")
		winMenuAddItem("View", 'Overlays                    ol()', "ol()")
		winMenuAddItem("View", '1D Projections          pj()', "pj()")
		winMenuAddItem("View", 'Redraw spectrum    dd()', "dd()")
		
		winMenuAdd("Tools")
		winMenuAdd("Tools/Assignments")
		winMenuAddItem("Tools/Assignments", 'Auto assign              aa()', "aa()")
		winMenuAddItem("Tools/Assignments", 'Custom libraries       cl()', "cl()")
		winMenuAddItem("Tools", 'ROIs                        roi()', "roi()")
		winMenuAddItem("Tools", 'Peak picking          pp()', "pp()")
		winMenuAddItem("Tools", 'Shift referencing     sr()', "sr()")
		winMenuAddItem("Tools", 'Extract data             ed()', "ed()")
		
		winMenuAdd("Help")
		winMenuAddItem("Help", 'Help topics', "?rNMR")
		winMenuAddItem("Help", 'List functions', "?more")
		winMenuAddItem("Help", 'User manual', "rNMR:::myHelp('user_manual', TRUE)")
		winMenuAddItem("Help", 'Developer\'s guide', 
				"rNMR:::myHelp('developers_guide/developers_guide', TRUE)")
		winMenuAddItem("Help", '--', "none")
		winMenuAddItem("Help", 'Homepage', 
				"browseURL('http://rnmr.nmrfam.wisc.edu')")
		winMenuAddItem("Help", 'Update rNMR', "rNMR:::updater()")
		winMenuAddItem("Help", 'About rNMR', "rNMR:::about()")
		
	}else{
		tclCheck()
		if (is.null(top)){
			if (.Platform$OS.type == 'windows')
				top <- myToplevel('menu', width=255, height=30)
			else
				top <- myToplevel('menu', width=285, height=1)
			if (is.null(top))
				return(invisible())
			tkwm.title(top, 'rNMR Menu')
			tcl('wm', 'attributes', top, topmost=TRUE)
		}
		topMenu <- tkmenu(top)
		tkconfigure(top, menu=topMenu)
		
		fileMenu <- tkmenu(topMenu, tearoff=FALSE)
		tkadd(fileMenu, 'command', label='Open/Close files', accelerator='fs()', 
				command=function() fs())
		tkadd(fileMenu, 'command', label='Convert to rNMR', accelerator='cf()',
				command=function() cf())
		tkadd(fileMenu, 'separator') 
		tkadd(fileMenu, 'command', label='Import', accelerator='import()',	
				command=function() import()) 
		tkadd(fileMenu, 'command', label='Export', accelerator='export()',	
				command=function() export())
		tkadd(fileMenu, 'separator') 
		tkadd(fileMenu, 'command', label='Load workspace', accelerator='wl()',	
				command=function() wl()) 
		tkadd(fileMenu, 'command', label='Save workspace', accelerator='ws()',	
				command=function() ws()) 
		tkadd(fileMenu, 'command', label='Restore backup', accelerator='rb()',	
				command=function() rb()) 
		tkadd(topMenu, 'cascade', label='File', menu=fileMenu)
		
		editMenu <- tkmenu(topMenu, tearoff=FALSE)
		tkadd(editMenu, 'command', label='Undo', accelerator='ud()', 
				command=function() ud())
		tkadd(editMenu, 'command', label='Redo', accelerator='rd()', 
				command=function() rd())
		tkadd(editMenu, 'separator')
		tkadd(editMenu, 'command', label='Peak list', accelerator='pe()', 
				command=function() pe())
		tkadd(editMenu, 'command', label='ROI table', accelerator='re()', 
				command=function() re())
		tkadd(editMenu, 'command', label='ROI summary', accelerator='se()', 
				command=function() se())
		tkadd(editMenu, 'command', label='Preferences', accelerator='ep()', 
				command=function() ep())
		tkadd(topMenu, 'cascade', label='Edit', menu=editMenu)
		
		graphicsMenu <- tkmenu(topMenu, tearoff=FALSE)
		tkadd(graphicsMenu, 'command', label='Plot colors', 
				accelerator='co()', command=function() co())
		tkadd(graphicsMenu, 'command', label='Plot settings', 
				accelerator='ct()',	command=function() ct())	
		tkadd(graphicsMenu, 'command', label='Perspective', accelerator='per()', 
				command=function() per())
		tkadd(topMenu, 'cascade', label='Graphics', menu=graphicsMenu)
		
		viewMenu <- tkmenu(topMenu, tearoff=FALSE)
		tkadd(viewMenu, 'command', label='Zoom', accelerator='zm()', 
				command=function() zm())
		tkadd(viewMenu, 'command', label='Overlays', accelerator='ol()', 
				command=function() ol())
		tkadd(viewMenu, 'command', label='1D Projection', 
				accelerator='pj()', command=function() pj())	
		tkadd(viewMenu, 'command', label='Redraw main spectrum', 
				accelerator='dd()', command=function() dd())
		tkadd(topMenu, 'cascade', label='View', menu=viewMenu)
		
		toolMenu <- tkmenu(topMenu, tearoff=FALSE)
		assignMenu <- tkmenu(toolMenu, tearoff=FALSE)
		tkadd(toolMenu, 'cascade', label='Assignments', menu=assignMenu)
		tkadd(assignMenu, 'command', label='Auto assign', accelerator='aa()', 
				command=function() aa())
		tkadd(assignMenu, 'command', label='Custom libraries', accelerator='cl()', 
				command=function() cl())
		tkadd(toolMenu, 'command', label='ROIs', accelerator='roi()', 
				command=function() roi())
		tkadd(toolMenu, 'command', label='Peak picking', accelerator='pp()', 
				command=function() pp())
		tkadd(toolMenu, 'command', label='Shift referencing', accelerator='sr()', 
				command=function() sr())
		tkadd(toolMenu, 'command', label='Extract data', accelerator='ed()', 
				command=function() ed())
		tkadd(topMenu, 'cascade', label='Tools', menu=toolMenu)
		
		helpMenu <- tkmenu(topMenu, tearoff=FALSE)
		tkadd(helpMenu, 'command', label='Help topics',	
				command=function(...) rNMR:::myHelp('rNMR-package'))
		tkadd(helpMenu, 'command', label='List functions', 
				command=function(...) rNMR:::myHelp('more'))
		tkadd(helpMenu, 'command', label='Update rNMR', 
				command=function() rNMR:::updater())
		tkadd(helpMenu, 'command', label='User manual', 
				command=function(...) rNMR:::myHelp('user_manual', TRUE))
		tkadd(helpMenu, 'command', label='Developer\'s guide', command=function(...) 
					rNMR:::myHelp('developers_guide/developers_guide', TRUE))
		tkadd(helpMenu, 'command', label='Homepage', 
				command=function(...) browseURL('http://rnmr.nmrfam.wisc.edu'))
		tkadd(helpMenu, 'command', label='About rNMR',
				command=function() rNMR:::about())
		tkadd(topMenu, 'cascade', label='Help', menu=helpMenu)
		
		tkfocus(top)
		tkwm.deiconify(top)
		
		invisible()
	}
}

## Internal graphics function devGui
## Sets window popup and dropdown windows
devGui <- function(dev){
	
	if (.Platform$GUI != 'Rgui')
		return(invisible())
	
	devName <- switch(dev, 'main'='$Graph2Main', 'sub'='$Graph3Main', 
			'multi'='$Graph4Main', 'stats'='$Graph5Main')
	if (paste(devName, "rNMR --> ", sep='/') %in% winMenuNames())
		return(invisible())
	
	winMenuAdd(paste(devName, 'rNMR --> ', sep='/'))
	winMenuAdd(paste(devName, 'File', sep='/'))
	winMenuAddItem(paste(devName, 'File', sep='/'), 
			'Open/Close files      fs()', "fs()")
	winMenuAddItem(paste(devName, 'File', sep='/'), 
			'Convert to rNMR     cf()', "cf()")
	winMenuAddItem(paste(devName, 'File', sep='/'), '-', "none")
	winMenuAddItem(paste(devName, 'File', sep='/'), 
			'Import              import()', "import()")
	winMenuAddItem(paste(devName, 'File', sep='/'), 
			'Export              export()', "export()")
	winMenuAddItem(paste(devName, 'File', sep='/'), '--', "none")
	winMenuAddItem(paste(devName, 'File', sep='/'), 
			'Load workspace      wl()', "wl()")
	winMenuAddItem(paste(devName, 'File', sep='/'), 
			'Save workspace     ws()', "ws()")
	winMenuAddItem(paste(devName, 'File', sep='/'), 
			'Restore backup       rb()', "rb()")
	
	winMenuAdd(paste(devName, 'Edit', sep='/'))
	winMenuAddItem(paste(devName, 'Edit', sep='/'), 
			'Undo               ud()', "ud()")
	winMenuAddItem(paste(devName, 'Edit', sep='/'), 
			'Redo                rd()', "rd()")
	winMenuAddItem(paste(devName, 'Edit', sep='/'), '-', "none")
	winMenuAddItem(paste(devName, 'Edit', sep='/'), 
			'Peak list           pe()', "pe()")
	winMenuAddItem(paste(devName, 'Edit', sep='/'), 
			'ROI table         re()', "re()")
	winMenuAddItem(paste(devName, 'Edit', sep='/'), 
			'ROI summary   se()', "se()")
	winMenuAddItem(paste(devName, 'Edit', sep='/'), 
			'Preferences     ep()', "ep()")
	
	winMenuAdd(paste(devName, 'Graphics', sep='/'))
	winMenuAddItem(paste(devName, 'Graphics', sep='/'), 
			'Plot colors        co()', "co()")
	winMenuAddItem(paste(devName, 'Graphics', sep='/'), 
			'Plot settings     ct()', "ct()")
	winMenuAddItem(paste(devName, 'Graphics', sep='/'), 
			'Perspective    per()', "per()")
	
	winMenuAdd(paste(devName, 'View', sep='/'))
	winMenuAddItem(paste(devName, 'View', sep='/'), 
			'Zoom                      zm()', "zm()")
	winMenuAddItem(paste(devName, 'View', sep='/'), 
			'Overlays                  ol()', "ol()")
	winMenuAddItem(paste(devName, 'View', sep='/'), 
			'1D Projections         pj()', "pj()")
	winMenuAddItem(paste(devName, 'View', sep='/'), 
			'Redraw spectrum   dd()', "dd()")
	
	winMenuAdd(paste(devName, 'Tools', sep='/'))
	winMenuAdd(paste(devName, 'Tools/Assignments', sep='/'))
	winMenuAddItem(paste(devName, 'Tools/Assignments', sep='/'), 
			'Auto assign          aa()', "aa()")
	winMenuAddItem(paste(devName, 'Tools/Assignments', sep='/'), 
			'Custom libraries           cl()', "cl()")
	winMenuAddItem(paste(devName, 'Tools', sep='/'), 
			'ROIs                     roi()', "roi()")
	winMenuAddItem(paste(devName, 'Tools', sep='/'), 
			'Peak picking          pp()', "pp()")
	winMenuAddItem(paste(devName, 'Tools', sep='/'), 
			'Shift referencing    sr()', "sr()")
	winMenuAddItem(paste(devName, 'Tools', sep='/'), 
			'Extract data          ed()', "ed()")
	
	winMenuAdd(paste(devName, 'Help', sep='/'))
	winMenuAddItem(paste(devName, 'Help', sep='/'), 'Help topics', "?rNMR")
	winMenuAddItem(paste(devName, 'Help', sep='/'), 'List functions', "?more")
	winMenuAddItem(paste(devName, 'Help', sep='/'), 'User manual', 
			"rNMR:::myHelp('user_manual', TRUE)")
	winMenuAddItem(paste(devName, 'Help', sep='/'), 'Developer\'s guide', 
			"rNMR:::myHelp('developers_guide/developers_guide', TRUE)")
	winMenuAddItem(paste(devName, 'Help', sep='/'), '-', "none")
	winMenuAddItem(paste(devName, 'Help', sep='/'), 'Homepage', 
			"browseURL('http://rnmr.nmrfam.wisc.edu')")
	winMenuAddItem(paste(devName, 'Help', sep='/'), 'Update rNMR', 
			"rNMR:::updater()")
	winMenuAddItem(paste(devName, 'Help', sep='/'), 'About rNMR', 
			'rNMR:::about()')
}

## Internal graphics function popupGui
## Sets window popup and dropdown windows 
popupGui <- function(dev){
	
	if (.Platform$GUI != 'Rgui')
		return(invisible())
	
	##creates context menu for the main plot window
	if (dev == 'main' && !'$Graph2Popup/2D Plot type' %in% winMenuNames()){   	
		winMenuAdd("$Graph2Popup/2D Plot type")
		winMenuAddItem("$Graph2Popup/2D Plot type", 'auto      da()', "da()")
		winMenuAddItem("$Graph2Popup/2D Plot type", 'contour  dr()', "dr()")
		winMenuAddItem("$Graph2Popup/2D Plot type", 'filled      drf()', "drf()")
		winMenuAddItem("$Graph2Popup/2D Plot type", 'image      di()', "di()")
		winMenuAdd("$Graph2Popup/1D Plot type")
		winMenuAddItem("$Graph2Popup/1D Plot type", 'line', 
				"setGraphics(type='auto', refresh.graphics=TRUE)")
		winMenuAddItem("$Graph2Popup/1D Plot type", 'points', 
				"setGraphics(type='p', refresh.graphics=TRUE)")
		winMenuAddItem("$Graph2Popup/1D Plot type", 'both', 
				"setGraphics(type='b', refresh.graphics=TRUE)")
		winMenuAdd("$Graph2Popup/2D Contours")
		winMenuAddItem("$Graph2Popup/2D Contours", 'raise   ctu()', "ctu()")
		winMenuAddItem("$Graph2Popup/2D Contours", 'lower  ctd()', "ctd()")
		winMenuAdd("$Graph2Popup/1D Slices")
		winMenuAddItem("$Graph2Popup/1D Slices", 'direct slice    vs(1)', "vs(1)")
		winMenuAddItem("$Graph2Popup/1D Slices", 'indirect slice  vs(2)', "vs(2)")
		winMenuAddItem("$Graph2Popup/1D Slices", 'projection      pjv()', "pjv()")		
		winMenuAdd("$Graph2Popup/1D position")
		winMenuAddItem("$Graph2Popup/1D position", 'raise   vpu()', "vpu()")
		winMenuAddItem("$Graph2Popup/1D position", 'lower  vpd()', "vpd()")
		winMenuAdd("$Graph2Popup/Zoom")
		winMenuAddItem("$Graph2Popup/Zoom", 'in                zi()', "zi()")
		winMenuAddItem("$Graph2Popup/Zoom", 'out            zo()', "zo()")
		winMenuAddItem("$Graph2Popup/Zoom", '-', "none")
		winMenuAddItem("$Graph2Popup/Zoom", 'center       zc()', "zc()")
		winMenuAddItem("$Graph2Popup/Zoom", 'full             zf()', "zf()")
		winMenuAddItem("$Graph2Popup/Zoom", '--', "none")
		winMenuAddItem("$Graph2Popup/Zoom", 'hand         zz()', "zz()")
		winMenuAddItem("$Graph2Popup/Zoom", 'point         pz()', "pz()")
		winMenuAddItem("$Graph2Popup/Zoom", '---', "none")
		winMenuAddItem("$Graph2Popup/Zoom", 'previous    zp()', "zp()")
		winMenuAddItem("$Graph2Popup/Zoom", 'get shifts  loc()', "loc()")
	}
	
	##creates context menu for the sub plot window
	if (dev == 'sub' && !'$Graph3Popup/Select' %in% winMenuNames()){   	
		winMenuAdd("$Graph3Popup/Select")
		winMenuAddItem("$Graph3Popup/Select", 'from list  rs(1)', "rs(1)")
		winMenuAddItem("$Graph3Popup/Select", 'from window  rs(3)', "rs(3)")
		winMenuAdd("$Graph3Popup/Edit")
		winMenuAddItem("$Graph3Popup/Edit", 'edit table  re()', "re()")
		winMenuAddItem("$Graph3Popup/Edit", 'delete ROI rDel()', "rDel()")
		winMenuAdd("$Graph3Popup/Plot")
		winMenuAddItem("$Graph3Popup/Plot", 'Replot rvs()', "rvs()")
	}
	
	##creates context menu for the multiple file window
	if (dev == 'multi' && !'$Graph4Popup/Select' %in% winMenuNames()){   	
		winMenuAdd("$Graph4Popup/Select")
		winMenuAddItem("$Graph4Popup/Select", 'from list  rs(1)', "rs(1)")
		winMenuAddItem("$Graph4Popup/Select", 'from window  rs(4)', "rs(4)")
		winMenuAddItem("$Graph4Popup/Select", 'files  rsf()', "rsf()")
		winMenuAdd("$Graph4Popup/Edit")
		winMenuAddItem("$Graph4Popup/Edit", 'sort files  fs()', "fs()")
		winMenuAddItem("$Graph4Popup/Edit", 'edit table  re()', "re()")
		winMenuAddItem("$Graph4Popup/Edit", 'delete ROI  rDel()', "rDel()")
		winMenuAdd("$Graph4Popup/Summary")
		winMenuAddItem("$Graph4Popup/Summary", 'rSum()', "rSum()")
		winMenuAdd("$Graph4Popup/Plot")
		winMenuAddItem("$Graph4Popup/Plot", 'Replot rvm()', "rvm()")
	}
}

## Displays the rNMR splash screen
splashScreen <- function(){
	par(mar=defaultSettings$mar, cex.axis=defaultSettings$cex.axis, 
			cex.main=defaultSettings$cex.main, bg='black')
	plot(0, 0, type='n', xlab='', ylab='', col.axis='black')
	text(-.45, .2, 'r', col='#0065ca', cex=6.5, pos=3, offset=.5)
	text(-.44, .2, 'r', col='red', cex=6, pos=3, offset=.6)
	text(-.24, .2, 'N', col='#0065ca', cex=6.5, pos=3, offset=.4)
	text(-.23, .2, 'N', col='#b4d0f3', cex=6, pos=3, offset=.5)
	text(.04, .2, 'M', col='#0065ca', cex=6.5, pos=3, offset=.4)
	text(.05, .2, 'M', col='#b4d0f3', cex=6, pos=3, offset=.5)
	text(.32, .2, 'R', col='#0065ca', cex=6.5, pos=3, offset=.4)
	text(.33, .2, 'R', col='#b4d0f3', cex=6, pos=3, offset=.5)
	text(0, .1, paste('ver', pkgVar$version), col='white')
	text(0, -.15, 'fo() - open files', col='white')
	text(0, -.3, 'wl() - load a workspace', col='white')
	text(0, -.45, 'cf() - convert files to rNMR format', col='white')
}

## Displays rNMR package info
about <- function(){
	
	##creates toplevel
	dlg <- tktoplevel()
	tkwm.title(dlg, 'About rNMR')
	tkwm.resizable(dlg, FALSE, FALSE)
	tkwm.deiconify(dlg)
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	
	##display rNMR package info
	msg <- paste(' rNMR version', pkgVar$version, '\n',
			'Copyright (C) 2009 Ian A. Lewis and Seth C. Schommer\n', 
			'http://rnmr.nmrfam.wisc.edu')
	msgLabel <- ttklabel(dlg, text=msg)
	
	##creates ok button
	okButton <- ttkbutton(dlg, text='OK', width=10, command=function(...)
				tkdestroy(dlg))
	
	##creates release notes button
	onRelease <- function(){
		myHelp('release_notes', TRUE)
		tkdestroy(dlg)
	}
	relButton <- ttkbutton(dlg, text='Release Notes', width=13,
			command=onRelease)
	
	##add widgets to toplevel
	tkgrid(msgLabel, column=1, columnspan=2, row=1, sticky='w', pady=c(12, 0), 
			padx=10)
	tkgrid(okButton, column=1, row=2, padx=c(6, 4), pady=c(6, 10), sticky='e')
	tkgrid(relButton, column=2, row=2, padx=c(4, 6), pady=c(6, 10), sticky='w')
	
	##allow users to press the enter key to make selections
	tkbind(dlg, '<Return>', function(...) tryCatch(tkinvoke(tkfocus()), 
						error=function(er){}))
	tkfocus(okButton)
	
	invisible()
}

## Internal function for displaying HTML help pages
## page - character string; name of the help page to open
## docDir - logical; searches the rNMR 'doc' directory for the HTML help file
## 					 if TRUE, otherwise the default HTML directory for rNMR is used.
myHelp <- function(page, docDir=FALSE){
	
	if (page == 'user_manual')
		page <- paste(page, '.pdf', sep='', collapse='')
	else
		page <- paste(page, '.html', sep='', collapse='')
	if (docDir){
		fileDir <- system.file('doc', package='rNMR')
		msg <- 'Could not find specified help page.'
	}else{
		fileDir <- system.file('html', package='rNMR')
		msg <- paste('Could not find specified help page.\n', 
				'Try entering "?function_name" in the R console.', sep='')
	}
	tryCatch(browseURL(paste('file:///', file.path(fileDir, page), sep='', 
							collapse='')), error=function(er) myMsg(msg, icon='error'))
	
	return(invisible())
}


################################################################################
##                                                                            ##
##                    Chemical shift utilities                                ##
##                                                                            ##
################################################################################

## Internal function matchShift
## Finds the closest match for an input chemical shifts in a spectrum.
##       If shifts are outside of the spectrum's range, the closest shift 
##       from the spectrum will be returned
## inFolder  - Any entry from the fileFolder, default is the current spectrum
## w1        - Numeric argument or vector of w1 chemical shifts to be matched
## w2        - Numeric argument or vector of w2 chemical shifts to be matched
## Note      - If a vector of shifts is provided, then this function returns 
##             the shifts matched from the range of the vector
## w1.pad    - Integer, number of padding points over the w1 range to return
## w2.pad    - Integer, number of padding points over the w2 range to return
## Note      - Padding is used in peak picking, it allows peaks occurring on the 
##             edges of the spectral window to be peak picked
## invert    - Logical argument, will return shifts from the far edge of the 
##             spectrum rather than the closest match. i.e. the shifts as 
##             reflected across the center of the spectrum. 
## return.inc- Logical argument, TRUE returns the file index (point), FALSE
##             (the default) returns the chemical shift
## return.seq- Logical argument, TRUE returns the entire sequence of shifts
##             covered by the range of w1 and w2 provided, FALSE returns 
##             the range of the matched shifts (FALSE is the default)
## overRange - Logical argument, TRUE returns NA if shifts are outside spectra
##             window; FALSE returns closest match to the shifts provided 
## returns the range of chemical shift, or indices , of the closest w1 and w2 
##             shifts found in a spectrum. 
matchShift <- function (inFolder = fileFolder[[wc()]], w1 = NULL, w2 = NULL, 
		w1.pad = 0, w2.pad = 0, invert = FALSE, return.inc = FALSE, 
		return.seq = FALSE, overRange = FALSE ){
	
	if(is.null(w1) && is.null(w2))
		stop('No shifts were entered')
	
	
	## Mantain code format for 1D data
	if(inFolder$file.par$number_dimensions == 1){
		w1 <- NULL
		for( i in c('upfield_ppm', 'downfield_ppm', 'matrix_size'))
			inFolder$file.par[[i]] = c(inFolder$file.par[[i]],
					inFolder$file.par[[i]])
	}
	
	## Find best chemical shift match for w1
	out <- list(w1 = NULL, w2 = NULL)
	if( !is.null(w1) ){
		inFolder$w1 <- seq(inFolder$file.par$upfield_ppm[1],
				inFolder$file.par$downfield_ppm[1],
				length.out = inFolder$file.par$matrix_size[1])
		w1Range <- range(w1)	
		
		## Check for values outside spectral window
		if( overRange && 
				( all(w1Range > max(inFolder$w1)) || all(w1Range < min(inFolder$w1))))
			naOut <- TRUE
		else
			naOut <- FALSE
		
		## Find shifts in data that are the closest match to input data
		t1 <- findInterval(w1Range, inFolder$w1, all.inside = TRUE)	
		t2 <- t1 + 1
		for(i in 1:2)
			out$w1[i] <- switch( which.min(c(
									abs(w1Range[i] - inFolder$w1[t1[i]]),
									abs(w1Range[i] - inFolder$w1[t2[i]]))), t1[i], t2[i])
		
		## Pad outgoing data
		out$w1 <- out$w1 + c(-w1.pad, w1.pad)
		out$w1[out$w1 < 1] <- 1
		out$w1[out$w1 > inFolder$file.par$matrix_size[1]] <- 
				inFolder$file.par$matrix_size[1]
		
		
		## Invert, convert to sequence, and translate to shifts if requested
		if( invert )
			out$w1 <- sort(inFolder$file.par$matrix_size[1] - out$w1) + 1
		if(return.seq)
			out$w1 <- out$w1[1]:out$w1[2]
		if(!return.inc)
			out$w1 <- inFolder$w1[out$w1]
		if(naOut)
			out$w1 <- NA
	}
	
	## Find best chemical shift match for w2
	if( !is.null(w2) ){
		inFolder$w2 <- seq(inFolder$file.par$upfield_ppm[2],
				inFolder$file.par$downfield_ppm[2],
				length.out = inFolder$file.par$matrix_size[2])
		w2Range <- range(w2)
		
		## Check for values outside spectral window
		if( overRange && 
				( all(w2Range > max(inFolder$w2)) || all(w2Range < min(inFolder$w2))))
			naOut <- TRUE
		else
			naOut <- FALSE
		
		## Find shifts in data that are the closest match to input data
		d1 <- findInterval(w2Range, inFolder$w2, all.inside = TRUE)
		d2 <- d1 + 1
		for(i in 1:2)	
			out$w2[i] <- switch( which.min(c(
									abs(w2Range[i] - inFolder$w2[d1[i]]),
									abs(w2Range[i] - inFolder$w2[d2[i]]))), d1[i], d2[i])
		
		## Pad outgoing data
		out$w2 <- out$w2 + c(-w2.pad, w2.pad)
		out$w2[ out$w2 < 1] <- 1
		out$w2[ out$w2 > inFolder$file.par$matrix_size[2]] <- 
				inFolder$file.par$matrix_size[2]
		
		
		## Invert, convert to sequence, and translate to shifts if requested
		if( invert )
			out$w2 <- sort(inFolder$file.par$matrix_size[2] - out$w2) + 1
		if(return.seq)
			out$w2 <- out$w2[1]:out$w2[2]
		if(!return.inc)
			out$w2 <- inFolder$w2[out$w2]
		if(naOut)
			out$w2 <- NA
	}
	
	return(out)       
}

## Internal chemical shift table utility function shiftToROI
## Converts a peak list to an roi table
## shiftList - chemical shift file containing an w1 and a w2 column
##           a column named Code or Assignment will be used for the 
##           ROI names if present.
## w1Delta - Width of the desired ROI in the w1 dimension
## w2Delta - Width of the ROI in the w2 dimension
## returns a table in the same format as the roiTable format
shiftToROI <- function(shiftList = NULL, w1Delta = 1, w2Delta = .05 ){
	
	## Check the input format
	if( is.null(shiftList) )
		stop( 'No chemical shift table was entered' )
	if( length(which(names(shiftList) == 'w2')) == 0 ){
		if( length(which(names(shiftList) == 'Height')) == 0 )
			stop( '1D shift tables must have columns labeled w2 and Height' )
		else
			stop( '1D shift tables must have an w2 column' )
	}
	if( !is.numeric(w1Delta) || !is.numeric(w2Delta) )
		stop( 'w1Delta and w2Delta must be numeric')
	w1Delta <- w1Delta / 2
	w2Delta <- w2Delta / 2
	
	## Generate a 1D roi table
	if( length(shiftList$w1) == 0 ){
		
		outTable <- list( Name = NULL, 
				w2_downfield = shiftList$w2 + w2Delta, 
				w2_upfield = shiftList$w2 - w2Delta, 
				w1_downfield = rep(0, length(shiftList$w2)), 
				w1_upfield = shiftList$Height + 0.1*shiftList$Height, 
				ACTIVE = rep(TRUE, length(shiftList$w2)), 
				nDim = rep(1, length(shiftList$w2)) )		
	}else{
		
		## Generate a 2D roi table
		outTable <- list( Name = NULL, 
				w2_downfield = shiftList$w2 + w2Delta, 
				w2_upfield = shiftList$w2 - w2Delta, 
				w1_downfield = shiftList$w1 + w1Delta, 
				w1_upfield = shiftList$w1 - w1Delta, 
				ACTIVE = rep(TRUE, length(shiftList$w2)), 
				nDim = rep(2, length(shiftList$w2)) )		
		
	}
	
	## Add assignments if possible
	if( !is.null(shiftList$Code) || !is.null(shiftList$Assignment) ){
		if(!is.null(shiftList$Assignment) )
			outTable$Name <- shiftList$Assignment
		else
			outTable$Name <- shiftList$Code	
		
		## Replace NA or "NA" with ROI names ("NA" is returned from rNMR peak lists)
		outTable$Name[ which(outTable$Name == 'NA') ] <- NA
		if( any(is.na(outTable$Name)) )
			outTable$Name[ which( is.na(outTable$Name)) ] <- 
					paste('ROI', 1:length(which(is.na(outTable$Name))), sep='.')	
		
		## Make sure ROI names are unique
		for( i in 1: length(outTable$Name) ){
			tName <- which(outTable$Name == outTable$Name[i])
			if( length (tName) != 1 )
				outTable$Name[tName] <- paste(outTable$Name[i], 
						1:length(tName), sep ='.' )
		}
		
	}else
		outTable$Name <- paste('ROI', 1:length(shiftList$w2), sep='.')
	
	return(data.frame( outTable, stringsAsFactors = FALSE ))      
}

## Internal function autoRef
## fileName  - File to be referenced, defaults to currentSpectrum
## w2Range  - Chemical shift range, in ppm, to be searched,
##            NULL searches the entire spectrum
## w2Shift  - The reference frequency in ppm
## Note: This function is is used to reference well phased spectra containing
##       DSS, TSP, etc. The function finds furthest up field peak above the 
##       1D threshold and defines it as w2Shift (0 by default). 
## Note: Currently autoRef only handles 1D data
## Note: The w2Range option allows some flexibility over which portion of the 
##       spectrum is searched. However, if the referencing is really off, then
##       setting the w2Range argument may lead to some undesirable behavior.
## Note: The chemical shift referencing in rNMR does not alter the original data.
## Returns a referenced spectrum/spectra and refreshes the active plots
autoRef <- function(fileNames = currentSpectrum, w2Range=NULL, 
		w2Shift = 0, all1D = FALSE ){   
	
	oneDs <- which(sapply(fileFolder[fileNames], function(x) 
						x$file.par$number_dimensions) == 1)
	if (length(oneDs) == 0)
		err('No 1D files are open, rNMR can only auto reference 1D files')
	specList <- fileNames[oneDs]
	if (length(oneDs) != length(specList))
		cat('\n', 'The following spectra could not be referenced because they ', 
				'are not one-dimensional:\n  ', 
				paste(getTitles(specList[-oneDs], FALSE), '\n  '), '\n')
	
	## Update chemical shifts of files
	for( i in  specList ){
		
		## Load spectral data from binary 
		in.folder <- ucsf1D( file.name = fileFolder[[i]]$file.par$file.name,
				file.par=fileFolder[[i]]$file.par, w2Range = w2Range)
		in.folder$data <- rev( in.folder$data ) ## This is needed to match binary
		
		## Find Furthest downfield signal above the peak picking threshold
		thresh <- globalSettings$thresh.1D * 
				in.folder$file.par$noise_est + in.folder$file.par$zero_offset
		w2DSS <- min ( in.folder$w2[ in.folder$data >= thresh ] )
		
		## Define the possible chemical shift range for DSS
		w2DSS <- c(w2DSS + 0.1, w2DSS)
		w2DSS <- which(in.folder$w2 >= w2DSS[2] & in.folder$w2 <= w2DSS[1])
		
		## Define DSS as the biggest peak in the upfield sub region
		w2DSS <- in.folder$w2[ w2DSS ][which.max(in.folder$data[ w2DSS ])]
		
		if( length(w2DSS) == 0 ){
			print( paste( 'Auto referencing failed in:',
							basename(in.folder$file.par$file.name)), quote = FALSE )
			next()
		}
		
		## Move reference to specified location
		fileFolder[[i]]$file.par$downfield_ppm[1] <- 
				fileFolder[[i]]$file.par$downfield_ppm[1] - w2DSS + w2Shift
		fileFolder[[i]]$file.par$upfield_ppm[1] <- 
				fileFolder[[i]]$file.par$upfield_ppm[1] - w2DSS + w2Shift
		
		## Update peaklist and graphics
		fileFolder[[i]]$graphics.par$usr[1:2] <- 
				fileFolder[[i]]$graphics.par$usr[1:2] - w2DSS + w2Shift
		if(length(fileFolder[[i]]$peak.list) > 0)
			fileFolder[[i]]$peak.list$w2 <- (
						fileFolder[[i]]$peak.list$w2 - w2DSS + w2Shift)
		
	}
	
	## Assign changes to the file folder and refresh graphics 
	myAssign("fileFolder", fileFolder)
	refresh() 
	lineCol <- fileFolder[[wc()]]$graphics.par$fg
	abline ( v = w2Shift, lty = 2, col=lineCol )
	
}

## Internal peak picking function isNoise
## A simple filter for detecting noise signals in 1D data 
## x    - Numeric argument, a candidate signal
## data - Numeric vector, the field of data being tested
## thresh  - Numeric argument expressing the threshold. Values range from
##        0 (no filtering) to -1 no data returned. The default, .15 seems 
##        like a reasonable compromise between false discovery and sensitivity
## Note: This function is an obvious area for future improvement, the filter
##       currently excludes broad signals.
isNoise <- function( x, data, thresh = -.15 ){
	return( (min((data - x)/ x, na.rm = TRUE )) > thresh  )
} 

## Internal function for combining two peak lists
appendPeak <- function(newList, oldList){
	
	if( is.null(oldList) || length(oldList) == 0)
		return(newList)
	if( is.null(newList) || length(newList) == 0)
		return(oldList)
	
	## Allow lists to differ in structure
	newName <- unique(c(names(newList), names(oldList)))
	
	## Add/update the index column to the new list
	if (is.null(newList$Index))
		newList$Index <- 1:nrow(newList)
	if (is.null(oldList$Index))
		oldList$Index <- 1:nrow(oldList)
	newList$Index <- 1:nrow(newList) + max(oldList$Index)
	
	cList <- data.frame(matrix(rep(NA, length(newName) * 2), nrow=2))
	names(cList) <- newName
	
	noMatch <- which(is.na(match(names(cList), names(oldList))))
	if (length(noMatch)){
		oNames <- names(oldList)
		oldList <- cbind(oldList, matrix(rep(NA, 
								nrow(oldList) * length(noMatch)), ncol=length(noMatch)))
		names(oldList) <- c(oNames, names(cList)[noMatch])
	}
	
	noMatch <- which(is.na(match(names(cList), names(newList))))
	if (length(noMatch)){
		oNames <- names(newList)
		newList <- cbind(newList, matrix(rep(NA, 
								nrow(newList) * length(noMatch)), ncol=length(noMatch)))
		names(newList) <- c(oNames, names(cList)[noMatch])
	}
	
	## Remove duplicate entries
	cList <- rbind(cList[-(1:2),], oldList, newList)
	checkVar <- match(c('w1', 'w2', 'Height'), names(cList))
	checkVar <- which(duplicated(cList[,checkVar]))
	if (length(checkVar))
		cList <- cList[-checkVar, ]
	
	row.names(cList) <- NULL
	cList$Index <- 1:nrow(cList)
	return(cList)
}

## Internal wrapper function for implementing 1D and 2D peak picking
## fileName    - name of the file to be peak picked, NULL will pick the current
## inFile			 - file data as returned by ucsf1D or ucsf2D, used instead of the
##							 fileName argument to peak pick a file without opening it
## w1Range     - w1 chemical shift range c(downfield,upfield) to be used
## w2Range     - w2 chemical shift range c(downfield,upfield) to be used
## append - logical argument, TRUE appends peaks to old list
## internal - logical argument, TRUE returns list without assigning it to
##            fileFolder, FALSE assigns the file to fileFolder
## ... - Additional peak picking parameters passed to trans2peak
## Returns the new peak list 
peakPick <- function( fileName = currentSpectrum, inFile = NULL, 
		w1Range = NULL, w2Range = NULL, append = FALSE, internal = FALSE, ...){
	
	if( length(fileName) > 1 && internal )
		stop('Only one peak list can be returned internally')
	
	if (!is.null(inFile)){
		if(inFile$file.par$number_dimensions == 1)
			nList <- peakPick1D( inFolder = inFile, w2Range = w2Range, ...)
		else if(!is.null(inFile$file.par$block_upfield_ppms))
			nList <- peakPickRsd( inFolder = inFile, w1Range = w1Range, 
					w2Range = w2Range, ...)
		else if(inFile$file.par$number_dimensions == 3)
			nList <- peakPick3D( inFolder = inFile, w1Range = w1Range, 
					w2Range = w2Range, ...)
		else
			nList <- peakPick2D( inFolder = inFile, w1Range = w1Range, 
					w2Range = w2Range, ...)
		row.names(nList) <- NULL
		return(nList)
	}
	
	for(i in fileName){			
		if(fileFolder[[i]]$file.par$number_dimensions == 1)
			nList <- peakPick1D( fileName = i, w2Range = w2Range, ...)
		else if(!is.null(fileFolder[[i]]$file.par$block_upfield_ppms))
			nList <- peakPickRsd( fileName = i, w1Range = w1Range, 
					w2Range = w2Range, ...)
		else if(fileFolder[[i]]$file.par$number_dimensions == 3)	
			nList <- peakPick3D( fileName = i, w1Range = w1Range, 
					w2Range = w2Range, ...)
		else
			nList <- peakPick2D( fileName = i, w1Range = w1Range, 
					w2Range = w2Range, ...)
		row.names(nList) <- NULL
		if( internal )
			break()
		
		## Create peak labels if not provided
		if (!is.null(nList) && (all(is.na(nList$Assignment)) || 
				length(which(nList$Assignment == 'NA')) == length(nList$Assignment)))
			nList$Assignment <- paste('P', nList$Index, sep='')
		
		## Append unique new peaks to old list
		oList <- fileFolder[[i]]$peak.list
		if( append )
			nList <- appendPeak(nList, oList)
		fileFolder[[i]]$peak.list <- nList
		
		if ( !internal ){
			cat(paste(fileFolder[[i]]$file.par$user_title, ':', '\n Total peaks: ', 
							nrow(nList), '\n', sep = ''))
			if( append ){
				if(is.null(oList))
					cat(paste(' New peaks:', nrow(nList), '\n'))
				else
					cat(paste(' New peaks:', nrow(nList) - nrow(oList), '\n'))
			}
			
			flush.console()
		}	
	}
	
	if( !internal )
		myAssign('fileFolder', fileFolder)
	
	return(nList)
}

## Internal peak picking function peakPick1D
## General local maximum (hill climbing method) for 1D peak picking
## fileName    - name of the file to be peak picked, NULL will pick the current
## inFile			 - file data as returned by ucsf1D or ucsf2D, used instead of the
##							 fileName argument to peak pick a file without opening it
## w2Range     - w2 chemical shift range c(downfield,upfield) to be used
## w2Gran      - integer controlling granularity of search space, 
##         			 smaller values are more exhaustive bigger values supress noise
## noiseFilt - Integer argument that can be set to 0, 1 or 2; 
##              0 does not apply a noise filter, 1 applies a mild filter
##              (adjacent points in the direct dimension must be above the 
##              noise threshold), 2 applies a strong filter (all adjacent points
##              must be above the noise threshold
## maxOnly - logical, if TRUE only the maximum peak is returned
## Note: currently the filter excludes broad peaks. 
## Note: the threshold used for peak picking taken from the global parameters
## ... - Additional peak picking parameters
## Returns a new peak list 
peakPick1D <- function( fileName = currentSpectrum, inFile = NULL, 
		w2Range = NULL,	w2Gran = 2, noiseFilt = globalSettings$peak.noiseFilt, 
		maxOnly = FALSE,  ... ){
	
	## Define the current spectrum and w2 range 
	if (is.null(inFile)){
		inFile <- fileFolder[[fileName]]
		inFile <- ucsf1D(file.name = fileName, file.par=inFile$file.par)
	}
	if( inFile$file.par$number_dimensions != 1 )
		stop('You must use peakPick1D to peak pick 1D files')
	if(is.null(w2Range) || length(w2Range) != 2 )
		w2Range <- c(inFile$file.par$upfield_ppm[1],
				inFile$file.par$downfield_ppm[1])
	
	## Find all local maxes
	absData <- abs(inFile$data)
	allPos <- intersect(which(c(NA, absData) <  c(absData, NA)), 
			which(c(NA, absData) >  c(absData, NA))-1)
	
	## Remove local maxes below the threshold
	thresh <- globalSettings$thresh.1D * 
			inFile$file.par$noise_est + inFile$file.par$zero_offset 
	allPos <- allPos[which(absData[allPos] >= thresh )]
	
	## Apply granularity and noise filters
	out <- NULL
	for(i in 1:length(allPos) ){
		subRan <- try(absData[(allPos[i] - w2Gran):(allPos[i] + w2Gran)], 
				silent = TRUE)
		if(class(subRan) == "try-error")
			next()
		x <- subRan[ w2Gran + 1 ]
		if( max( subRan, na.rm = TRUE) == x  ){
			if( noiseFilt == 0  )
				out <- c(out, i)
			else{
				noise <- isNoise( x = x, data = subRan, ...)
				if( !noise )
					out <- c(out, i)
			}
		}
	}
	allPos <- allPos[out]
	
	## Build a peak list
	mShift <- matchShift(inFolder = inFile, w2 = w2Range, return.inc = TRUE, 
			invert = TRUE)$w2
	allPos <- allPos[ allPos <= mShift[2] & allPos >= mShift[1] ]
	if(length(allPos) == 0)
		return(NULL)
	n1 <- length(allPos)
	peak <- data.frame( list( Index = 1:n1, w1 = rep(NA, n1), 
					w2 = rev(inFile$w2)[allPos], Height = inFile$data[allPos],
					Assignment = rep('NA', n1)), stringsAsFactors = FALSE )
	if( maxOnly ){
		peak <- peak[which.max(abs(peak$Height)),]
		peak$Index <- 1
	}
	
	return(peak)
}

## Internal peak picking function peakPick2D
## General local maximum (hill climbing method) for 2D peak picking
## fileName    - name of the file to be peak picked, NULL will pick the current
## inFile			 - file data as returned by ucsf1D or ucsf2D, used instead of the
##							 fileName argument to peak pick a file without opening it
## w1Range     - w1 chemical shift range c(downfield,upfield) to be used
## w2Range     - w2 chemical shift range c(downfield,upfield) to be used
## fancy       - logical argument, FALSE implements a basic peak picker
##               that returns local maxima only, this is fastest; TRUE
##               determines chemical shifts of peaks, groups multiplets,
##               and measures line width and volume
## noiseFilt   - Integer argument that can be set to 0, 1 or 2; 
##               0 does not apply a noise filter, 1 applies a mild filter
##               (adjacent points in the direct dimension must be above the 
##               noise threshold), 2 applies a strong filter (all adjacent points
##               must be above the noise threshold
## maxOnly - logical, if TRUE only the absolute maximum peak is returned
## Note: the threshold used for peak picking taken from the graphics parameters
## ... - Additional peak picking parameters passed to trans2peak
## Returns a new peak list for the w1/w2 ranges provided
peakPick2D <- function(fileName = currentSpectrum, inFile = NULL, 
		w1Range = NULL, w2Range = NULL, fancy = FALSE, 
		noiseFilt = globalSettings$peak.noiseFilt, maxOnly = FALSE, ...){
	
	## Error checking
	if (is.null(inFile))
		inFile <- fileFolder[[fileName]]	
	if(is.null(w1Range))
		w1Range <- c(inFile$file.par$upfield_ppm[1],
				inFile$file.par$downfield_ppm[1])
	if(is.null(w2Range))
		w2Range <- c(inFile$file.par$upfield_ppm[2],
				inFile$file.par$downfield_ppm[2])
	if(is.null(inFile$graphics.par$tiles))
		inFile <- findTiles(in.folder = inFile, internal=TRUE)
	
	## Find best chemical shift match
	bs <- inFile$file.par$block_size
	w1Range <- sort(w1Range); w2Range <- sort(w2Range)
	mShift <- matchShift(inFile, w1 = w1Range, w2 = w2Range, 
			return.inc = TRUE, return.seq = TRUE, invert = TRUE)
	
	## Find the total possible sparky tiles for the range
	w1Tiles <- unique((mShift$w1 - 1)  %/% bs[1])
	w2Tiles <- unique((mShift$w2 - 1)  %/% bs[2])
	tTiles <- ceiling(inFile$file.par$matrix_size / bs )
	tiles <- NULL
	for( i in 1:length(w2Tiles) )
		tiles <- c(tiles, w1Tiles * tTiles[2] + w2Tiles[i])
	tiles <- sort(tiles)
	
	
	## Set up for tile overlap
	w1Slice <- rep(NA, tTiles[1] * bs[1])
	w1Slice <- rbind(w1Slice, w1Slice, w1Slice, w1Slice, w1Slice)
	w2Slice <- rep(NA, tTiles[2] * bs[2] + 5)
	w2Slice <- cbind(w2Slice, w2Slice, w2Slice, w2Slice, w2Slice)
	
	
	## Open connection to binary file
	con <- myFile(inFile$file.par$file.name, "rb")
	binLoc <- inFile$file.par$binary_location
	endForm <- inFile$file.par$endian
	conDisp <- inFile$graphics.par$conDisp
	thresh <- inFile$file.par$noise_est * inFile$graphics.par$clevel
	locMax <- allPos <- NULL
	for(i in 1:length(tiles)){
		
		## Define the current w1/w2 increments
		w1B <- 1:bs[1] + bs[1] * floor( tiles[i] %/% tTiles[2] ) 
		w2B <- 1:bs[2] + bs[2] * floor( tiles[i] %% tTiles[2] )	
		
		##skip tiles with no data above the threshold and set w1/w2 slices to NA
		if( length(which(inFile$graphics.par$tiles == (tiles[i]))) == 0 ){	
			w1Slice[ 1:5, w1B ] <- NA
			w2Slice[ w2B, 1:5 ] <- NA
			next() 			
		}
		
		## Read binary
		seek(con, bs[1] * bs[2] * 4 * tiles[i] + binLoc, origin = 'start')
		tData <- matrix(rev(readBin(con, size=4, what='double', 
								endian = endForm, n=(bs[1] * bs[2]))), ncol = bs[1])
		
		## Make a list of all observable signals for fancy peak picking
		if(fancy){
			tObs <- obs2List(tData, conDisp = conDisp, thresh = thresh, bs = bs)
			tObs$tRow <- tObs$tRow + bs[2] * 
					floor( (tTiles[1] * tTiles[2] - tiles[i] -1) %% tTiles[2])
			tObs$tCol <- tObs$tCol + bs[1] * 
					floor( (tTiles[1] * tTiles[2] - tiles[i] -1) %/% tTiles[2])	
			allPos <- rbind(allPos, tObs)
		}
		
		## Overlap tile, and save upfield slices for next tile
		w1Lap <- w1Slice[1:5, w1B]
		pad <- rev(w2B)[1] + c(1,2,3,4,5)
		w2Lap <- w2Slice[c(w2B, pad), 1:5]
		w1Slice[1:5, w1B] <- tData[1:5,] 
		w2Slice[w2B, 1:5] <- tData[,1:5]
		tData <- cbind(rbind(tData, w1Lap), w2Lap)
		
		## Find local maxes
		if( conDisp[1] && conDisp[2] )
			oThresh <- localMax(abs(tData), thresh=thresh, noiseFilt=noiseFilt ) - 1
		else{
			if( conDisp[1])
				oThresh <- localMax(tData, thresh=thresh, noiseFilt=noiseFilt ) - 1
			else
				oThresh <- localMax(-tData, thresh=thresh, noiseFilt=noiseFilt ) - 1			
		}
		
		peak <-data.frame(list( 
						tRow = (oThresh %% (bs[2] +5)) + 1, 
						tCol = (oThresh %/% (bs[2] +5)) + 1, 
						Height = tData[oThresh + 1]))
		peak <- peak[ peak[,1] > 1 & peak[,1] < bs[2]+2, ]		
		peak <- peak[peak[,2] > 1 & peak[,2] < bs[1] + 2, ]
		if (!length(peak) || nrow(peak) == 0)
			next()
		
		## Translate tile row/column to spectrum row/column
		peak$tRow <- peak$tRow + bs[2] * 
				floor( (tTiles[1] * tTiles[2] - tiles[i] -1) %% tTiles[2])
		peak$tCol <- peak$tCol + bs[1] * 
				floor( (tTiles[1] * tTiles[2] - tiles[i] -1) %/% tTiles[2])
		locMax <- rbind(locMax, peak)
		
	}
	
	## Close binary conection
	closeAllConnections()
	
	## Clean up peak list
	if(is.null(locMax))
		return(NULL)
	locMax <- unique(locMax)
	
	## Match point locations with chemical shifts
	w1 <- seq(inFile$file.par$upfield_ppm[1], 
			inFile$file.par$downfield_ppm[1],
			length.out = inFile$file.par$matrix_size[1])
	if( inFile$file.par$matrix_size[1] %% bs[1] != 0 )
		w1 <- c(rep(NA, bs[1] - inFile$file.par$matrix_size[1] %% bs[1]), w1)
	w2 <- seq(inFile$file.par$upfield_ppm[2], 
			inFile$file.par$downfield_ppm[2],
			length.out = inFile$file.par$matrix_size[2])
	if( inFile$file.par$matrix_size[2] %% bs[2] != 0 )
		w2 <- c(rep(NA, bs[2] - inFile$file.par$matrix_size[2] %% bs[2] ), w2)
	w1Range <- sort(rev(w1)[range(mShift$w1)])
	w2Range <- sort(rev(w2)[range(mShift$w2)])
	
	if(fancy){
		peak <- trans2Peak( allPos = allPos, locMax = locMax, w1 = w1, w2 = w2, 
				w1Range = w1Range, w2Range = w2Range, ...)
	}else{
		
		peak <- data.frame( list(	
						Index = 1:nrow(locMax),
						w1 = w1[locMax$tCol],
						w2 = w2[locMax$tRow],
						Height = locMax$Height,
						Assignment = rep("NA", length(locMax$tCol)) ), 
				stringsAsFactors = FALSE)
		
		## Filter the outgoing list to match the data range
		peak <- peak[peak$w1 <= w1Range[2] & peak$w1 >= w1Range[1] & 
						peak$w2 <= w2Range[2] & peak$w2 >= w2Range[1],]
		if (!length(peak) || nrow(peak) == 0)
			return(NULL)
		if( maxOnly )
			peak <- peak[which.max(abs(peak$Height)),]
		peak <- peak[order(peak$w1, peak$w2),]
		peak$Index <- 1:nrow(peak)
		
	}
	
	## Return the new list
	if (!length(peak) || nrow(peak) == 0)
		return(NULL)
	
	return(peak)
}


## Internal peak picking function peakPick3D
## General local maximum (hill climbing method) for peak picking 2D slices of
## 3D files
## fileName    - name of the file to be peak picked, NULL will pick the current
## inFile			 - file data as returned by ucsf1D or ucsf2D, used instead of the
##							 fileName argument to peak pick a file without opening it
## w1Range     - w1 chemical shift range c(downfield,upfield) to be used
## w2Range     - w2 chemical shift range c(downfield,upfield) to be used
## fancy       - logical argument, FALSE implements a basic peak picker
##               that returns local maxima only, this is fastest; TRUE
##               determines chemical shifts of peaks, groups multiplets,
##               and measures line width and volume
## noiseFilt   - Integer argument that can be set to 0, 1 or 2; 
##               0 does not apply a noise filter, 1 applies a mild filter
##               (adjacent points in the direct dimension must be above the 
##               noise threshold), 2 applies a strong filter (all adjacent points
##               must be above the noise threshold
## maxOnly - logical, if TRUE only the absolute maximum peak is returned
## Note: the threshold used for peak picking taken from the graphics parameters
## ... - Additional peak picking parameters passed to trans2peak
## Returns a new peak list for the w1/w2 ranges provided
peakPick3D <- function(fileName = currentSpectrum, inFile = NULL, 
		w1Range = NULL, w2Range = NULL, fancy = FALSE, 
		noiseFilt = globalSettings$peak.noiseFilt, maxOnly = FALSE, ...){
	
	## Error checking
	if (is.null(inFile))
		inFile <- fileFolder[[fileName]]	
	if (is.null(w1Range))
		w1Range <- c(inFile$file.par$upfield_ppm[1],
				inFile$file.par$downfield_ppm[1])
	if(is.null(w2Range))
		w2Range <- c(inFile$file.par$upfield_ppm[2],
				inFile$file.par$downfield_ppm[2])
	if (is.null(inFile$graphics.par$tiles))
		inFile <- findTiles(in.folder=inFile, internal=TRUE)
	
	## Define some local variables
	filePar <- inFile$file.par
	graphicsPar <- inFile$graphics.par
	bs <- filePar$block_size
	ms <- filePar$matrix_size
	uf <- filePar$upfield_ppm
	df <- filePar$downfield_ppm
	endForm <- filePar$endian
	binLoc <- filePar$binary_location
	conDisp <- graphicsPar$conDisp
	thresh <- inFile$file.par$noise_est * graphicsPar$clevel
	
	## Find best chemical shift match
	shifts <- NULL
	shifts$w1 <- seq(uf[1], df[1], length.out=ms[1])
	shifts$w2 <- seq(uf[2], df[2],	length.out=ms[2])	
	shifts$w3 <- seq(uf[3], df[3],	length.out=ms[3])	
	w1Range <- sort(w1Range); w2Range <- sort(w2Range)
	w3Range <- rep(filePar$z_value, 2)
	t1 <- findInterval(w1Range, shifts$w1, all.inside=TRUE)
	d1 <- findInterval(w2Range, shifts$w2, all.inside=TRUE)
	z1 <- findInterval(w3Range, shifts$w3, all.inside=TRUE)
	t2 <- t1 + 1; d2 <- d1 + 1; z2 <- z1 + 1
	out <- NULL
	for (i in 1:2){
		out$w1[i] <- switch(which.min(c(abs(w1Range[i] - shifts$w1[t1[i]]),
								abs(w1Range[i] - shifts$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch(which.min(c(abs(w2Range[i] - shifts$w2[d1[i]]),
								abs(w2Range[i] - shifts$w2[d2[i]]))), d1[i], d2[i])
		out$w3[i] <- switch(which.min(c(abs(w3Range[i] - shifts$w3[z1[i]]),
								abs(w3Range[i] - shifts$w3[z2[i]]))), z1[i], z2[i])
	}
	
	## Invert w1/w2 selection to match binary data format
	out$w1 <- sort(ms[1] - out$w1) + 1
	out$w2 <- sort(ms[2] - out$w2) + 1
	
	## Find sparky tiles that will be plotted
	w1Tiles <- (ceiling(out$w1[1] / bs[1]):ceiling(out$w1[2] / bs[1]))
	w2Tiles <- (ceiling(out$w2[1] / bs[2]):ceiling(out$w2[2] / bs[2]))
	w3Tiles <- (ceiling(out$w3[1] / bs[3]):ceiling(out$w3[2] / bs[3]))
	numTiles <- ceiling(ms / bs)
	tiles <- NULL
	for (i in w1Tiles)
		tiles <- c(tiles, (i - 1) * numTiles[2] + (w2Tiles - 1))
	tiles <- tiles + (w3Tiles - 1) * numTiles[1] * numTiles[2]
	
	## Set up for tile overlap
	w1Slice <- rep(NA, numTiles[1] * bs[1])
	w1Slice <- rbind(w1Slice, w1Slice, w1Slice, w1Slice, w1Slice)
	w2Slice <- rep(NA, numTiles[2] * bs[2] + 5)
	w2Slice <- cbind(w2Slice, w2Slice, w2Slice, w2Slice, w2Slice)
	
	## Open connection to binary file
	con <- myFile(filePar$file.name, "rb")
	w2TileNum <- ceiling(ms[2] / bs[2])
	tileSize <- bs[1] * bs[2] * bs[3] * 4
	locMax <- allPos <- NULL
	for(i in tiles){
		
		## Define current w1/w2 range
		tile2D <- i - (w3Tiles - 1) * numTiles[1] * numTiles[2]
		w1 <- ceiling((tile2D + 1) / w2TileNum)
		w1B <- (1:bs[1]) + bs[1] * (w1 - 1) 
		w2 <- (tile2D + 1) - (w1 * w2TileNum ) + w2TileNum
		w2B <- (1:bs[2]) + bs[2] * (w2 - 1) 
		
		##skip tiles with no data above the threshold and set w1/w2 slices to NA
		if (!i %in% graphicsPar$tiles){	
			w1Slice[1:5, w1B] <- NA
			w2Slice[w2B, 1:5] <- NA
			next() 			
		}
		
		## Define data location for current tile
		tileLoc <- tileSize * i + binLoc
		if (bs[3] > 1)
			zPos <- (out$w3[1] - 1) * bs[3]
		else
			zPos <- 0
		dataLoc <- tileLoc + bs[1] * bs[2] * 4 * zPos
		
		## Read binary
		seek(con, dataLoc, origin='start')
		tData <- matrix(rev(readBin(con, size=4, what='double', endian=endForm, 
								n=bs[1] * bs[2])), ncol=bs[1])
		
		## Make a list of all observable signals for fancy peak picking
		if (fancy){
			tObs <- obs2List(tData, conDisp=conDisp, thresh=thresh, bs=bs)
			tObs$tRow <- tObs$tRow + bs[2] * 
					floor((numTiles[1] * numTiles[2] - tile2D - 1) %% numTiles[2])
			tObs$tCol <- tObs$tCol + bs[1] * 
					floor((numTiles[1] * numTiles[2] - tile2D - 1) %/% numTiles[2])	
			allPos <- rbind(allPos, tObs)
		}
		
		## Overlap tile, and save upfield slices for next tile
		w1Lap <- w1Slice[1:5, w1B]
		pad <- rev(w2B)[1] + c(1, 2, 3, 4, 5)
		w2Lap <- w2Slice[c(w2B, pad), 1:5]
		w1Slice[1:5, w1B] <- tData[1:5, ] 
		w2Slice[w2B, 1:5] <- tData[, 1:5]
		tData <- cbind(rbind(tData, w1Lap), w2Lap)
		
		## Find local maxima
		if (conDisp[1] && conDisp[2])
			oThresh <- localMax(abs(tData), thresh=thresh, noiseFilt=noiseFilt) - 1
		else{
			if (conDisp[1])
				oThresh <- localMax(tData, thresh=thresh, noiseFilt=noiseFilt) - 1
			else
				oThresh <- localMax(-tData, thresh=thresh, noiseFilt=noiseFilt) - 1			
		}
		
		## Format local maxima
		peak <- data.frame(list(tRow=(oThresh %% (bs[2] + 5)) + 1, 
						tCol=(oThresh %/% (bs[2] + 5)) + 1, 
						Height=tData[oThresh + 1]))
		peak <- peak[peak[, 1] > 1 & peak[, 1] < bs[2] + 2, ]		
		peak <- peak[peak[, 2] > 1 & peak[, 2] < bs[1] + 2, ]
		if (!nrow(peak))
			next()
		
		## Translate tile row/column to spectrum row/column
		peak$tRow <- peak$tRow + bs[2] * 
				floor((numTiles[1] * numTiles[2] - tile2D - 1) %% numTiles[2])
		peak$tCol <- peak$tCol + bs[1] * 
				floor((numTiles[1] * numTiles[2] - tile2D - 1) %/% numTiles[2])
		locMax <- rbind(locMax, peak)
		
	}
	close(con)
	
	## Clean up peak list
	if (is.null(locMax))
		return(NULL)
	locMax <- unique(locMax)
	
	## Match point locations with chemical shifts
	w1 <- seq(uf[1], df[1],	length.out=ms[1])
	if (ms[1] %% bs[1])
		w1 <- c(rep(NA, bs[1] - ms[1] %% bs[1]), w1)
	w2 <- seq(uf[2], df[2], length.out=ms[2])
	if (ms[2] %% bs[2])
		w2 <- c(rep(NA, bs[2] - ms[2] %% bs[2] ), w2)
	w1Range <- sort(rev(w1)[range(out$w1)])
	w2Range <- sort(rev(w2)[range(out$w2)])
	
	if (fancy){
		peak <- trans2Peak(allPos=allPos, locMax=locMax, w1=w1, w2=w2, 
				w1Range=w1Range, w2Range=w2Range, ...)
	}else{
		
		peak <- data.frame(list(Index=1:nrow(locMax), w1=w1[locMax$tCol],
						w2=w2[locMax$tRow], Height=locMax$Height, 
						Assignment=rep("NA", length(locMax$tCol))), stringsAsFactors=FALSE)
		
		## Filter the outgoing list to match the data range
		peak <- peak[peak$w1 <= w1Range[2] & peak$w1 >= w1Range[1] & 
						peak$w2 <= w2Range[2] & peak$w2 >= w2Range[1], ]
		if (!nrow(peak))
			return(NULL)
		if (maxOnly)
			peak <- peak[which.max(abs(peak$Height)), ]
		peak <- peak[order(peak$w1, peak$w2), ]
		peak$Index <- 1:nrow(peak)
	}
	
	## Return the new list
	if (!nrow(peak))
		return(NULL)
	
	return(peak)
}


## Internal peak picking function peakPickRsd
## General local maximum (hill climbing method) for peak picking RSD files
## fileName    - name of the file to be peak picked, NULL will pick the current
## inFile			 - file data as returned by ucsf1D or ucsf2D, used instead of the
##							 fileName argument to peak pick a file without opening it
## w1Range     - w1 chemical shift range c(downfield,upfield) to be used
## w2Range     - w2 chemical shift range c(downfield,upfield) to be used
## fancy       - logical argument, FALSE implements a basic peak picker
##               that returns local maxima only, this is fastest; TRUE
##               determines chemical shifts of peaks, groups multiplets,
##               and measures line width and volume
## noiseFilt   - Integer argument that can be set to 0, 1 or 2; 
##               0 does not apply a noise filter, 1 applies a mild filter
##               (adjacent points in the direct dimension must be above the 
##               noise threshold), 2 applies a strong filter (all adjacent points
##               must be above the noise threshold
## maxOnly - logical, if TRUE only the absolute maximum peak is returned
## Note: the threshold used for peak picking taken from the graphics parameters
## ... - Additional peak picking parameters passed to trans2peak
## Returns a new peak list for the w1/w2 ranges provided
peakPickRsd <- function(fileName=currentSpectrum, inFile=NULL, w1Range=NULL, 
		w2Range=NULL, fancy=FALSE, noiseFilt=globalSettings$peak.noiseFilt, 
		maxOnly=FALSE, ...){
	
	## Error checking
	if (is.null(inFile))
		inFile <- fileFolder[[fileName]]	
	if (is.null(w1Range))
		w1Range <- c(inFile$file.par$upfield_ppm[1],
				inFile$file.par$downfield_ppm[1])
	if (is.null(w2Range))
		w2Range <- c(inFile$file.par$upfield_ppm[2],
				inFile$file.par$downfield_ppm[2])
	if (is.null(inFile$graphics.par$tiles))
		inFile <- findTiles(in.folder=inFile, internal=TRUE)
	
	## Define some local variables
	filePar <- inFile$file.par
	graphicsPar <- inFile$graphics.par
	conDisp <- graphicsPar$conDisp
	thresh <- filePar$noise_est * graphicsPar$clevel
	w1Range <- sort(w1Range)
	w2Range <- sort(w2Range)
	shifts <- matchShift(inFolder=inFile, w1=w1Range, w2=w2Range, return.seq=TRUE)
	winW1 <- shifts$w1
	winW2 <- shifts$w2
	
	## Find tiles that will be plotted
	tiles <- NULL
	upShifts <- filePar$block_upfield_ppms
	downShifts <- filePar$block_downfield_ppms
	blockSizes <- filePar$block_size
	for (tNum in seq_along(filePar$block_size$w1)){
		
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
	blockLoc <- filePar$binary_location
	for (i in seq_along(filePar$block_size$w1))
		blockLoc <- c(blockLoc, blockLoc[i] + 4 * filePar$block_size$w1[i] * 
						filePar$block_size$w2[i])
	
	## Peak pick the spectrum one tile at a time
	con <- myFile(filePar$file.name, "rb")
	peaks <- NULL
	for (tNum in tiles){
		
		## Skip tiles with no data above the noise threshold
		if (!(tNum - 1) %in% graphicsPar$tiles)
			next
		
		## Read data
		bs <- c(filePar$block_size$w1[tNum], filePar$block_size$w2[tNum])
		seek(con, blockLoc[tNum], origin='start')
		tData <- matrix(rev(readBin(con, size=4, what='double', 
								endian=filePar$endian, n=bs[1] * bs[2])), 
				ncol=filePar$block_size$w1[tNum])
		
		## Find local maxima
		if (conDisp[1] && conDisp[2])
			oThresh <- localMax(abs(tData), thresh=thresh, noiseFilt=noiseFilt) - 1
		else{
			if (conDisp[1])
				oThresh <- localMax(tData, thresh=thresh, noiseFilt=noiseFilt) - 1
			else
				oThresh <- localMax(-tData, thresh=thresh, noiseFilt=noiseFilt) - 1			
		}
		
		## Convert maxima indices to row number, column number, and height
		locMax <- data.frame(list(tRow=oThresh %% bs[2] + 1, 
						tCol=oThresh %/% bs[2] + 1, 
						Height=tData[oThresh + 1]))
		if (!nrow(locMax))
			next
		
		## Define chemical shifts for current tile
		w1 <- seq(upShifts$w1[tNum], downShifts$w1[tNum], length.out=bs[1])
		w2 <- seq(upShifts$w2[tNum], downShifts$w2[tNum], length.out=bs[2])
		
		if (fancy){
			
			## Pass a list of all observable signals to the fancy peak picker
			tObs <- obs2List(tData, conDisp=conDisp, thresh=thresh, bs=bs)		
			peak <- trans2Peak(allPos=tObs, locMax=locMax, w1=w1, w2=w2, 
					w1Range=range(w1), w2Range=range(w2), ...)
		}else{
			
			## Format local maxima in to a standard peak list
			peak <- data.frame(list(Index=1:nrow(locMax), 
							w1=w1[locMax$tCol],
							w2=w2[locMax$tRow],
							Height=locMax$Height,
							Assignment=rep("NA", length(locMax$tCol))), 
					stringsAsFactors=FALSE)
		}
		peaks <- rbind(peaks, peak)
	}
	close(con)
	
	## Filter the outgoing list to match the data range
	peaks <- peaks[peaks$w1 <= w1Range[2] & peaks$w1 >= w1Range[1] & 
					peaks$w2 <= w2Range[2] & peaks$w2 >= w2Range[1], ]
	if (!nrow(peaks))
		return(NULL)
	
	## Filter list to include only the peaks with the absolute maximum intensity
	if (!fancy && maxOnly)
		peaks <- peaks[which.max(abs(peaks$Height)), ]
	
	## Format and return the new list
	peaks <- peaks[order(peaks$w1, peaks$w2), ]
	peaks$Index <- 1:nrow(peaks)
	return(peaks)
}


## Internal 2D fancy peak picking helper function
trans2Peak <- function( allPos, locMax, w1, w2, w1Range, w2Range, ...){
	
	## Filter the outgoing list to match the current data range
	locMax <- data.frame( list(	
					tCol = locMax$tCol,
					tRow = locMax$tRow,
					w1 = w1[locMax$tCol],
					w2 = w2[locMax$tRow], 
					Height = locMax$Height))	
	locMax <- locMax[locMax$w1 <= w1Range[2] & locMax$w1 >= w1Range[1] & 
					locMax$w2 <= w2Range[2] & locMax$w2 >= w2Range[1],]
	if(nrow(locMax) == 0)
		return(NULL)
	
	## Group transitions together
	locMax <- fancyPeak2D( allPos = allPos, locMax = locMax, ...)
	locMax$rStart <- w2[locMax$rStart]
	locMax$rEnd <- w2[locMax$rEnd]
	locMax$cStart <- w1[locMax$cStart]
	locMax$cEnd <- w1[locMax$cEnd]
	
	peak <- NULL
	j <- 1
	for( i in unique(locMax$Index) ){
		tSub <- locMax[locMax$Index == i, ]
		tSub$Index <- j
		tSub$Multiplet <- 1:nrow(tSub)
		
		tSub <- rbind(c( mean(tSub$w1),  mean(tSub$w2), 
						tSub$Height[which.max(abs(tSub$Height))], 
						min(tSub$rStart), max(tSub$rEnd),
						min(tSub$cStart), max(tSub$cEnd), j, NA), tSub[,-(1:2)])
		
		peak <- rbind(peak, tSub)
		j <- j + 1
	}		
	
	peak$w1D <- peak$cEnd - peak$cStart
	peak$w2D <- peak$rEnd - peak$rStart
	peak$Assignment <- rep("NA", nrow(peak))		
	peak <- peak[,match(c('Index', 'w1', 'w2', 'Height', 'Assignment', 
							'Multiplet', 'w1D', 'w2D'), names(peak))]
	peak <- peak[order(peak$w1, peak$w2),]
	
	return(peak)
}

## Internal 2D peak finding function 
## allPos  - a data frame with columns labled tRow, tCol, and Height that define
##           the row, column and intensities of observed peaks in a 2D matrix
## w1Gran  - Integer 0 or greater, defines the number of sub threshold points a 
##           peak can cross in either direction of the indirect dimension
## w2Gran  - Integer 0 or greater, defines the number of sub threshold points a 
##           peak can cross in either direction of the direct dimension
## Note:   - Granularities of 0 mean that multiplets must be in the same 
##           row/column and none of the points are separated by points below
##           the noise threshold.
## returns - a data frame with the rows and columns defining each peak 
##           with each transition and chemical shift indicated
fancyPeak2D <- function( allPos, locMax, w1Gran = 1, w2Gran = 3 ){
	
	if( w1Gran < 0 )
		stop('w1Gran must be an integer greater than 0')
	if( w2Gran < 0 )
		stop('w2Gran must be an integer greater than 0')
	
	## Find the w2 row breaks defining each peak 
	allPos <- allPos[order(allPos$tRow, decreasing = FALSE),]
	rowFilt <- NULL	
	for( i in unique(allPos$tCol) ){
		tmp <- allPos[allPos$tCol ==  i, ]
		breaks <-  which((c(tmp$tRow, NA) - c(NA, tmp$tRow + 1) != 0))
		if( length(breaks) == 0 ){
			sBr <- 1
			eBr <- nrow(tmp)
			mRow <- which.max(abs(tmp$Height))
			rowFilt <- rbind(rowFilt, cbind(tmp$tRow[sBr], tmp$tRow[eBr], 
							tmp$tRow[mRow], tmp$tCol[mRow], tmp$tCol[mRow],tmp$tCol[mRow], 
							tmp$Height[mRow]))
			next()
		}
		
		sBr <- sort(c(1, breaks - 1, breaks, nrow(tmp) ))
		eBr <- sBr[ gl( 2, 1, length = length(sBr) ) == 2 ]
		sBr <- sBr[ gl( 2, 1, length = length(sBr) ) == 1 ]
		
		for( j in 1:length(sBr) ){
			subTmp <- tmp[sBr[j]:eBr[j],]
			mRow <- which.max(abs(subTmp$Height))
			rowFilt <- rbind(rowFilt, cbind(tmp$tRow[sBr[j]], tmp$tRow[eBr[j]], 
							subTmp$tRow[mRow], subTmp$tCol[mRow], subTmp$tCol[mRow], 
							subTmp$tCol[mRow], subTmp$Height[mRow]))
		}		
	}
	
	## Find the w1 column breaks defining each peak 
	allPos <- allPos[order(allPos$tCol, decreasing = FALSE),]
	colFilt <- NULL	
	for( i in unique(allPos$tRow) ){
		tmp <- allPos[allPos$tRow ==  i, ]
		breaks <-  which((c(tmp$tCol, NA) - c(NA, tmp$tCol + 1) != 0))
		if( length(breaks) == 0 ){
			sBr <- 1
			eBr <- nrow(tmp)
			mRow <- which.max(abs(tmp$Height))
			colFilt <- rbind(colFilt, cbind(tmp$tRow[mRow], tmp$tRow[mRow], 
							tmp$tRow[mRow], tmp$tCol[sBr], tmp$tCol[eBr], tmp$tCol[mRow], 
							tmp$Height[mRow]))
			next()
		}
		
		sBr <- sort(c(1, breaks - 1, breaks, nrow(tmp) ))
		eBr <- sBr[ gl( 2, 1, length = length(sBr) ) == 2 ]
		sBr <- sBr[ gl( 2, 1, length = length(sBr) ) == 1 ]
		
		for( j in 1:length(sBr) ){
			subTmp <- tmp[sBr[j]:eBr[j],]
			mRow <- which.max(abs(subTmp$Height))
			colFilt <- rbind(colFilt, cbind(subTmp$tRow[mRow], subTmp$tRow[mRow], 
							subTmp$tRow[mRow], tmp$tCol[sBr[j]], tmp$tCol[eBr[j]], 
							subTmp$tCol[mRow], subTmp$Height[mRow]))
		}		
	}
	
	rowFilt <- data.frame(rowFilt)
	colFilt <- data.frame(colFilt)
	names(rowFilt) <- names(colFilt) <- c('rStart', 'rEnd', 'rMax', 'cStart', 
			'cEnd', 'cMax', 'Height')
	
	## Find the peak boundries for each transition
	trans <- data.frame(list( tRow = NA, tCol = NA, Height = NA, rStart = NA, 
					rEnd = NA, cStart = NA, cEnd = NA))[-1,]
	for( i in 1:nrow(locMax) ){
		mSub <- locMax[i, ]
		rowSub <- rowFilt[ rowFilt$cStart == mSub$tCol, ]
		rowSub <- rowSub[ rowSub$rStart <= mSub$tRow &
						rowSub$rEnd >= mSub$tRow, ]					
		colSub <- colFilt[ colFilt$rStart == mSub$tRow, ]
		colSub <- colSub[ colSub$cStart <= mSub$tCol &
						colSub$cEnd >= mSub$tCol, ]
		tSub <- rbind(rowSub, colSub)
		trans <- rbind(trans, cbind(mSub, min(tSub$rStart), max(tSub$rEnd), 
						min(tSub$cStart), max(tSub$cEnd)))
	}
	names(trans) <- c('tRow', 'tCol', 'w1', 'w2', 'Height', 'rStart', 
			'rEnd', 'cStart','cEnd')
	trans$Index <- 1:nrow(trans)
	
	## Group transitions together and generate a master peak summary 
	j <- 1
	for( i in trans$Index ){
		
		tSub <- trans[ trans$Index == i , ]
		if( nrow(tSub) == 0 )
			next()
		
		tmp <- trans[trans$rStart >= (tSub$rStart - w2Gran),]
		tmp <- tmp[tmp$rEnd <= (tSub$rEnd + w2Gran), ]
		tmp <- tmp[tmp$cStart >= (tSub$cStart - w1Gran), ]
		tSub <- tmp[tmp$cEnd <= (tSub$cEnd + w1Gran), ]
		trans[ which(!is.na(match(trans$Index, tSub$Index))), ]$Index <- j	
		
		j <- j + 1
	}
	
	return(trans)
}

## Internal helper function for fancy peak picking
## Converts a data matrix into a list with the rows and columns of 
##          signals that are above the threshold 
## x        - Numeric matrix of data to be searched
## Condisp  - Logical vector of the form c(TRUE, TRUE), allows independent 
##            thresholding of negative and positive values 
## thresh   - Numeric value specifying the absolute limit for observable signals
## bs       - Integer vector of the form c(columns, rows) defining the 
##            dimensions of the matrix
## returns a list of observable signals with the columns tRow, tCol, and Height
obs2List <- function(x, conDisp, thresh, bs = c(ncol(x), nrow(x))){
	
	## Threshold data
	if( conDisp[1] && conDisp[2] )
		x[ which(abs(x) < thresh) ] <- NA
	else{
		if( conDisp[1])
			x[ x < thresh ] <- NA
		else
			x[ (-x) < thresh ] <- NA	
	}
	oThresh <- which(!is.na(x)) - 1
	if( length(oThresh) < 1 )
		return(NULL)
	
	## Convert tile row/columns to overall matrix row/column numbers 
	return(data.frame(list(
							tRow = (oThresh %% bs[2]) + 1, 
							tCol = (oThresh %/% bs[2]) + 1, 
							Height = x[oThresh + 1])))	
}

## Internal 2D peak picking function
## Finds points in a matrix that are larger than all surrounding points
## x  -  A numeric matrix containing the range of data to be peak picked
## thresh    - Numeric value specifying the minimum level to be included
## noiseFilt - Integer argument that can be set to 0, 1 or 2; 
##              0 does not apply a noise filter, 1 applies a mild filter
##              (adjacent points in the direct dimension must be above the 
##              noise threshold), 2 applies a strong filter (all adjacent points
##              must be above the noise threshold
## Returns a vector of points defining the local maxima
localMax <- function(x, thresh, noiseFilt ){
	
	nC <- ncol(x)
	nR <- nrow(x)
	if( noiseFilt == 2 )
		x[x < thresh] <- NA  
	
	## Find row/column local maxes
	if( noiseFilt == 1 ){
		y <- x
		y[ y < thresh ] <- NA
		vMax <- intersect(which(c(NA, y) < c(y, NA)), which(c(NA, y) > c(y, NA))-1)
	}else
		vMax <- intersect(which(c(NA, x) < c(x, NA)), which(c(NA, x) > c(x, NA))-1)
	x <- t(x)
	hMax <- intersect(which(c(NA, x) < c(x, NA)), which(c(NA, x) > c(x, NA))-1)-1
	hMax <- (hMax %% nC * nR) + hMax %/% nC + 1
	
	
	## Find diagonal maxima
	x <- t(x)
	hvMax <- intersect(vMax, hMax)
	if( noiseFilt == 0 )
		hvMax <- hvMax[ x[hvMax] > thresh ]
	dMax <- cbind(hvMax, hvMax - nR + 1, hvMax - nR - 1, hvMax + nR + 1, 
			hvMax + nR - 1)
	dMax[dMax < 1 | dMax > nC*nR ] <- NA
	dMax <- which(max.col(cbind( x[dMax[,1]], x[dMax[,2]], x[dMax[,3]], 
							x[dMax[,4]], x[dMax[,5]])) == 1)
	
	return(hvMax[dMax])
}

## Estimates volumes of 2D peaks using stacked elipsoids
## inFile  - file parameters and data for desired spectrum as returned by ed()
## gran       - Integer indicating granularity of contour fitting 
## c.vol      - Logical argument, TRUE returns stacked elipsoid volumes, 
##               FALSE returns sum of visible data
## note: the default, contour.vol = FALSE, seems to work best
## baselineCorr - local baseline correction for 1D 
## Returns volume for 2D ROIs and area of 1D ROIs
peakVolume <- function(inFile, gran = 200, c.vol = FALSE, 
		baselineCorr = FALSE){
	
	## Volume estimates for 2D data
	if(inFile$file.par$number_dimensions > 1){
		if(!c.vol ){
			volume <- sum(inFile$data[inFile$data >= 
									inFile$file.par$noise_est * inFile$graphics.par$clevel]) 
			if(length(volume) == 0)
				volume <- NA
		}else{
			## Generate contour lines for data
			zlim <- c(inFile$file.par$noise_est *
							inFile$graphics.par$clevel, max(inFile$data))
			c.levels <- seq(zlim[1], zlim[2], length.out=gran )
			c.int <- diff(c.levels[1:2])
			contour.file <- contourLines(z = inFile$data, levels = c.levels )
			
			## Estimate volume as stacked elipsoids
			if(length(contour.file) > 0 && zlim[1] < zlim[2]){
				volume <- NULL 
				for(i in 1:length(contour.file))
					volume <- sum(volume, (4 / 3 * pi * diff(range(contour.file[[i]]$x)) *
										diff(range(contour.file[[i]]$y)) * c.int ))
			}else
				volume <- NA
		}  
		
		## Area estimate for 1D data
	}else{
		
		## Local baseline correction
		if( baselineCorr )
			inFile$data <- inFile$data - fivenum(inFile$data)[2]
		volume <- sum(inFile$data)
		
	}  
	return(volume)
}

################################################################################
##                                                                            ##
##                    Internal graphics functions                             ##
##                                                                            ##
################################################################################

## Internal graphics function bringFocus
## This is a platform independant version of bringToTop
bringFocus <- function(dev = -1){
	if( .Platform$OS.type == 'windows' && sdiCheck(FALSE) )
		bringToTop( dev )
}

## Internal graphics function setWindow
## Makes a new plotting window with the correct title, width/height or sets
## an existing window as the active device
## p.window - The window type, can be 'main', 'sub', 'multi', or 'stats'
## ...      - Additional R graphics parameters, see par()
## returns a new graphics device 
setWindow <- function( p.window = 'main', ...){
	
	## Check to see if window is open
	devNum <- which(c('main', 'sub', 'multi', 'stats') == p.window) + 1
	if(length(which(dev.list() == devNum)) == 0 ){
		odev <- dev.list()
		devTitle <- switch(devNum - 1, "Main Plot Window", "ROI Subplot Window",
				"Multiple File Window")
		devWidth <- switch(devNum - 1, globalSettings$size.main[1], 
				globalSettings$size.sub[1], globalSettings$size.multi[1])
		devHeight <- switch(devNum - 1, globalSettings$size.main[2], 
				globalSettings$size.sub[2], globalSettings$size.multi[2])
		
		## Open new graphics window 
		while(dev.cur()  != devNum){
			if (.Platform$OS == 'windows')
				dev.new(title = devTitle, width = devWidth, height = devHeight)
			else
				X11(title = devTitle, width = devWidth,	height = devHeight)
		}
		for(i in dev.list()){
			if(length(which(c(odev, devNum) == i)) == 0)
				dev.off(i)    
		}
		if (p.window == 'main'){
			par(defaultSettings[1:65])
			par(mar=globalSettings$mar)
		}
		par(...)
		devGui(p.window)
		popupGui(p.window)
	}else{
		dev.set(devNum)
		bringFocus(devNum)
		par(...)
	}
	invisible()
}

## Internal function to cycle through open graphics windows
## note: A device can specified by setting dev (used internally)
cw <- function(dev=NULL){
	if(is.null(dev))
		dev.set(which = dev.next())
	else
		dev.set(which = dev)
	bringFocus(dev.cur())
	
	## Leave the console active
	bringFocus(-1)  
}

## Internal graphics function set.graphics
## General function for changing graphics settings used by lower level functions
## file.name - a list of file names to be modified, default is the current file,
##             names must match names from fileFolder
## all.files - logical argument, if TRUE all files will be updated
## save.backup - logical argument, TRUE will save a copy of the environment
##               for undo/redo, FALSE updates the file folder without saving
##               a backup copy. 
## refresh.graphics - logical argument, refreshes the active plots if TRUE
## par() parameters: bg, fg, col.axis, col.lab, col.main, col.sub, col, and usr 
##          are R arguments, see par for documentation
## line.color  - sets fg, col, col.axis, col.lab, col.main, and col.sub to 
##               a single input color
## drawNMR parameters: pos.color, neg.color, proj.color, conDisp, nlevels,
##                     clevel, w1Range, w2Range, and type. See drawNMR for 
##                     documentation
## perspective parameters: theta, phi, asp, see persp for documentation
## peak display parameters: peak.color, peak.disp, noiseFilt see pdisp
## 1D file settings: thresh.1D, position.1D, offset, and overlay.text, 
##									 see peakPick2D, vp, and overlay for documentation
## 1D projections: proj.mode, proj.type, proj.direct, filter, see proj1D
## roi parameters: roi.multi, roiMain, roiMax, roi.bcolor, roi.tcolor
## Note: All changes are applied to the files in fileFolder, except:
##       offset, peak.disp, thresh.1D, position.1D, roiMain, roiMax, 
##				proj.direct, and filter.
##       These exceptions are modified in the globalSettings list
setGraphics <- function (file.name = currentSpectrum, all.files = FALSE, 
		save.backup = TRUE, refresh.graphics = FALSE, bg = NULL, fg = NULL, 
		col.axis = NULL, col.lab = NULL, col.main = NULL,	col.sub = NULL, 
		col = NULL, usr = NULL, line.color = NULL, pos.color = NULL, 
		neg.color = NULL, proj.color = NULL, conDisp = NULL, nlevels = NULL,	
		clevel = NULL, type = NULL, theta = NULL, phi = NULL,	asp = NULL,	
		peak.color = NULL, peak.disp = NULL, peak.noiseFilt = NULL, peak.pch = NULL,
		peak.cex = NULL, peak.labelPos = NULL, thresh.1D = NULL, position.1D = NULL, 
		offset = NULL, proj.mode = NULL, proj.type = NULL,	proj.direct = NULL, 
		filter = NULL, roi.multi = NULL, roiMain = NULL, roiMax = NULL, 
		roi.bcolor = NULL, roi.tcolor = NULL, roi.lwd = NULL, roi.lty = NULL, 
		roi.cex = NULL, roi.labelPos = NULL, roi.noiseFilt = NULL, roi.w1 = NULL, 
		roi.w2 = NULL, roi.pad = NULL, w1Range = NULL, w2Range = NULL, 
		overlay.text = NULL){
	
	## Set global graphics changes
	if( !is.null(offset) ){
		if(is.numeric(offset))
			globalSettings$offset <- offset
		else
			print('offset must be a numeric value', quote = FALSE)		
	}
	if(!is.null(proj.mode)){
		if( is.logical(proj.mode))
			globalSettings$proj.mode <- proj.mode
		else
			print('proj.mode must be either TRUE or FALSE', quote = FALSE)		
	}
	if(!is.null(proj.type)){
		if(proj.type %in% c('l', 'p', 'b'))
			globalSettings$proj.type <- proj.type
		else
			print('proj.type must be either "l", "p", or "b"', quote = FALSE)			
	}
	if(!is.null(proj.direct)){
		if(proj.direct == 1 || proj.direct == 2 )
			globalSettings$proj.direct <- proj.direct
		else
			print('proj.direct must be either 1 or 2', quote = FALSE)				
	}
	if(!is.null(filter)){
		if(is.function(filter))
			globalSettings$filter <- filter
		else
			print('filter must be a function', quote = FALSE)	
	}
	if( !is.null(peak.disp) ){
		if(is.logical(peak.disp))
			globalSettings$peak.disp <- peak.disp
		else
			print('peak.disp must be either TRUE or FALSE', quote = FALSE)		
	}
	if( !is.null(peak.noiseFilt) ){
		if( any(peak.noiseFilt == c(0, 1, 2)) )
			globalSettings$peak.noiseFilt <- peak.noiseFilt
		else
			print('peak.noiseFilt must be 0, 1, or 2', quote = FALSE)			
	}
	if (!is.null(peak.pch)){
		if (is.numeric(peak.pch) || nchar(peak.pch) == 1)
			globalSettings$peak.pch <- peak.pch
		else
			print('peak.pch must be numeric or a single ASCII character', quote=FALSE)			
	}
	if (!is.null(peak.cex)){
		if (is.numeric(peak.cex))
			globalSettings$peak.cex <- peak.cex
		else
			print('peak.cex must be a numeric value', quote=FALSE)			
	}
	if (!is.null(peak.labelPos)){
		if (peak.labelPos %in% c('top', 'bottom', 'left', 'right', 'center'))
			globalSettings$peak.labelPos <- peak.labelPos
		else
			print(paste('peak.labelPos must be either "top", "bottom", "left",', 
							'"right", or "center"'), quote=FALSE)			
	}
	if( !is.null(thresh.1D) ){
		if(is.numeric(thresh.1D))
			globalSettings$thresh.1D <- thresh.1D
		else
			print('thresh.1D must be a numeric value', quote = FALSE)			
	}
	if( !is.null(position.1D) ){
		if(is.numeric(position.1D))
			globalSettings$position.1D <- position.1D
		else
			print('position.1D must be a numeric value', quote = FALSE)		
	}
	if( !is.null(roiMain)){
		if(is.logical(roiMain))
			globalSettings$roiMain <- roiMain
		else
			print('roiMain must be either TRUE or FALSE', quote = FALSE)		
	}
	if( !is.null(roiMax)){
		if(is.logical(roiMax))
			globalSettings$roiMax <- roiMax
		else
			print('roiMax must be either TRUE or FALSE', quote = FALSE)			
	}
	if(!is.null(roi.bcolor)){
		colErr <- TRUE
		if(length(roi.bcolor) == 2){
			colErr <- FALSE
			for (i in roi.bcolor){
				colTest <- try(col2rgb(i), silent=TRUE)
				if (class(colTest) == 'try-error')
					colErr <- TRUE
			}
		}
		if (!colErr)
			globalSettings$roi.bcolor <- roi.bcolor
		else
			print('ROI box color must be a vector of colors of length 2', 
					quote = FALSE)	
	}
	if(!is.null(roi.tcolor)){
		colErr <- TRUE
		if(length(roi.tcolor) == 2){
			colErr <- FALSE
			for (i in roi.tcolor){
				colTest <- try(col2rgb(i), silent=TRUE)
				if (class(colTest) == 'try-error')
					colErr <- TRUE
			}
		}
		if (!colErr)
			globalSettings$roi.tcolor <- roi.tcolor
		else
			print('ROI text color must be a vector of colors of length 2', 
					quote = FALSE)	
	}
	if (!is.null(roi.lwd)){
		if (is.numeric(roi.lwd) && length(roi.lwd) == 2)
			globalSettings$roi.lwd <- roi.lwd
		else
			print('roi.lwd must be a numeric vector of length 2', quote=FALSE)			
	}
	if (!is.null(roi.lty)){
		if (roi.lty %in% c('solid', 'dashed', 'dotted', 'dotdash', 'longdash', 
				'twodash', 'blank') && length(roi.lty) == 2)
			globalSettings$roi.lty <- roi.lty
		else
			print(paste('roi.lty must be a vector of length 2. Valid options include', 
							'"solid", "dashed", "dotted", "dotdash", "longdash", "twodash",',
							'or "blank"'), quote=FALSE)			
	}
	if (!is.null(roi.cex)){
		if (is.numeric(roi.cex) && length(roi.cex) == 2)
			globalSettings$roi.cex <- roi.cex
		else
			print('roi.cex must be a numeric vector of length 2', quote=FALSE)			
	}
	if (!is.null(roi.labelPos)){
		if (roi.labelPos %in% c('top', 'bottom', 'left', 'right', 'center'))
			globalSettings$roi.labelPos <- roi.labelPos
		else
			print(paste('roi.labelPos must be either "top", "bottom", "left",', 
							'"right", or "center"'), quote=FALSE)					
	}
	if (!is.null(roi.noiseFilt)){
		if (roi.noiseFilt %in% c(0, 1, 2))
			globalSettings$roi.noiseFilt <- roi.noiseFilt
		else
			print('roi.noiseFilt must be 0, 1, or 2', quote = FALSE)			
	}
	if (!is.null(roi.w1)){
		if (is.numeric(roi.w1))
			globalSettings$roi.w1 <- roi.w1
		else
			print('roi.w1 must be a numeric value', quote=FALSE)			
	}
	if (!is.null(roi.w2)){
		if (is.numeric(roi.w2))
			globalSettings$roi.w2 <- roi.w2
		else
			print('roi.w2 must be a numeric value', quote=FALSE)			
	}
	if (!is.null(roi.pad)){
		if (is.numeric(roi.pad))
			globalSettings$roi.pad <- roi.pad
		else
			print('roi.pad must be a numeric value', quote=FALSE)			
	}
	if(!is.null(overlay.text)){
		if( is.logical(overlay.text))
			globalSettings$overlay.text <- overlay.text
		else
			print('overlay.text must be either TRUE or FALSE', quote = FALSE)		
	}
	
	## Assign global parameters
	myAssign( 'globalSettings', globalSettings, save.backup = FALSE )
	
	
	## Define the files to be modified
	if(all.files)
		current <- 1:length(fileFolder)
	else     
		current <- match(file.name, names(fileFolder))
	
	## Update file settings
	for( i in current){  
		current.gpar <- fileFolder[[i]]$graphics.par
		current.fpar <- fileFolder[[i]]$file.par
		nDim <- fileFolder[[i]]$file.par$number_dimensions
		
		
		## Set all line colors
		if(!is.null(line.color))
			fg <- col.axis <- col.lab <- col.main <- col.sub <- col <- line.color
		
		## Change general graphics parameters related to par
		if(!is.null(bg))
			current.gpar$bg <- bg
		if(!is.null(fg))
			current.gpar$fg <- fg
		if(!is.null(col.axis))
			current.gpar$col.axis <- col.axis
		if(!is.null(col.lab))  
			current.gpar$col.lab <- col.lab
		if(!is.null(col.main))
			current.gpar$col.main <- col.main
		if(!is.null(col.sub))
			current.gpar$col.sub <- col.sub
		if(!is.null(col))
			current.gpar$col <- col
		if(!is.null(usr)){
			usr <- suppressWarnings(as.numeric(usr))
			if( !any(is.na(usr)) && length(usr) == 4){
				if( diff(usr[1:2]) == 0 || diff(usr[3:4]) == 0  )
					print('The plot ranges must be greater than zero', quote = FALSE)
				else
					current.gpar$usr <- usr
			}else
				print(paste('The plot vector "usr" must be a numeric vector with four', 
								'elements'),	quote = FALSE)
		} 
		
		## Change rNMR graphics parameters
		if(!is.null(pos.color))
			current.gpar$pos.color <- pos.color
		if(!is.null(neg.color))
			current.gpar$neg.color <- neg.color
		if(!is.null(proj.color))
			current.gpar$proj.color <- proj.color
		if(!is.null(conDisp) && is.logical(conDisp) && length(conDisp) == 2 )
			current.gpar$conDisp <- conDisp	
		if(!is.null(nlevels)){
			nlevels <- suppressWarnings(as.integer(nlevels))
			if( is.na(nlevels) || nlevels < 1 || nlevels > 1000)
				err(paste('The number of contour levels must be an integer greater', 
								'than 0 and less than or equal to 1000'))
			else
				current.gpar$nlevels <- nlevels
		}
		if(!is.null(clevel)){
			clevel <- suppressWarnings(as.numeric(clevel))
			if( is.na(clevel) || clevel < 0 )
				err('The minimum contour level must be greater than 0')
			else{
				if( clevel != current.gpar$clevel)
					current.gpar$tiles <- NULL
				current.gpar$clevel <- clevel
			}
		}
		if(!is.null(type)){
			if (nDim == 1){
				if( any (type == c('auto', 'l', 'p', 'b' )))
					current.gpar$type <- type
				else{
					cat(paste('Plot type must be a string (in quotes) named:', '\n', 
									'auto, l, p, or b', '\n'))
				}
			}else{
				if( any (type == c('auto', 'image', 'contour', 'filled', 'persp' )))
					current.gpar$type <- type
				else{
					cat(paste('Plot type must be a string (in quotes) named:', '\n', 
									'auto, image, filled, or persp', '\n'))
				}
			}
		}		
		if(!is.null(theta)){
			if(is.numeric(theta))
				current.gpar$theta <- theta
			else
				print('theta must be a numeric value', quote = FALSE)	
			
		}
		if(!is.null(phi)){
			if( is.numeric(phi) )
				current.gpar$phi <- phi 	
			else
				print('phi must be a numeric value', quote = FALSE)	
		}                         
		if(!is.null(asp)){
			if( is.numeric(asp) )
				current.gpar$asp <- asp 	
			else
				print('asp must be a numeric value', quote = FALSE)			
		}
		if(!is.null(peak.color))
			current.gpar$peak.color <- peak.color
		if(!is.null(roi.multi)){
			if(is.logical(roi.multi) && length(roi.multi) == 1)
				current.gpar$roi.multi <- roi.multi
			else
				print('roi.multi must be either TRUE or FALSE', quote = FALSE)				
		}
		
		## Change file parameters
		if (!is.null(w1Range)){
			w1Range <- suppressWarnings(as.numeric(w1Range))
			if (any(is.na(w1Range)))
				print('Chemical shift values must be numeric', quote = FALSE)
			else{
				if (nDim == 1)
					current.gpar$usr[3:4] <- sort(w1Range)
				else
					current.gpar$usr[3:4] <- rev(sort(w1Range))
			}
		}
		if (!is.null(w2Range)){
			w2Range <- suppressWarnings(as.numeric(w2Range))
			if (any(is.na(w2Range)))
				print('Chemical shift values must be numeric', quote = FALSE)
			else
				current.gpar$usr[1:2] <- rev(sort(w2Range))
		}
		
		## Update the file folder
		fileFolder[[i]]$graphics.par <- current.gpar
		fileFolder[[i]]$file.par <- current.fpar
	}       
	
	## Update graphics parameters
	if( !is.null(usr) && save.backup )
		myAssign("zoom", fileFolder )
	else
		myAssign("fileFolder", fileFolder, save.backup = save.backup)
	
	## Refresh plots
	if(refresh.graphics)
		refresh()
}

##Refresh active windows
refresh <- function(main.plot = TRUE, overlay = TRUE, sub.plot = TRUE, 
		multi.plot = TRUE, ...){
	
	current <- wc()
	
	## Refresh the main plot
	if(main.plot){
		drawNMR(...)
		if( globalSettings$roiMain  && !is.null(roiTable) && nrow(roiTable) > 0)
			showRoi()  		
		
		## Display peaks if appropriate
		pList <- fileFolder[[current]]$peak.list
		if( globalSettings$peak.disp )
			pdisp()       
		
		## Display 1D projection if appropriate
		if(globalSettings$proj.mode && 
				(fileFolder[[current]]$file.par$number_dimensions > 1))
			proj1D() 
		
		## Add overlays
		if(exists('overlayList') && overlay && !is.null(overlayList) &&
				fileFolder[[current]]$graphics.par$type != 'persp')
			ol(askUsr=FALSE)		
		
		## Add menus if not present
		if (.Platform$OS == 'windows' && .Platform$GUI == 'Rgui' &&
				!length(grep('$Graph2', winMenuNames(), fixed=TRUE))){
			devGui('main')
			popupGui('main')
		}
	}
	
	## Refresh the roi sub plot
	if(length(which(dev.list() == 3)) == 1 && sub.plot)
		rvs() 
	
	## Refresh the roi sub plot
	if(length(which(dev.list() == 4)) == 1 && multi.plot)
		rvm() 
}


## Internal graphics function findTiles
## Finds 2D NMR sparky tiles above user defined noise threshold
## in.folder  - rNMR spectral header file to be searched
## internal - if TRUE, changes are made to in.folder and returned, rather than
##						fileFolder
## returns (invisible) an updated file folder list of tiles with viewable 
findTiles <- function(in.folder=fileFolder[[wc()]], internal=FALSE){
	
	## Define some local variables
	filePar <- in.folder$file.par
	nDim <- filePar$number_dimensions
	bs <- filePar$block_size
	upShifts <- filePar$block_upfield_ppms
	ms <- filePar$matrix_size
	fileName <- filePar$file.name
	
	## Find total number of tiles
	if (nDim == 1)
		return(in.folder)
	if (is.null(upShifts)){
		tiles <- ceiling(ms / bs)
		if (nDim == 2){
			tiles[3] <- 1
			bs[3] <- 1
		}
		tiles <- (tiles[1] * tiles[2] * tiles[3]) - 1
		lRow <- bs[2]
		lCol <- bs[1]
		w1Above <- ceiling(ms[2] / bs[2]) 
		n <- bs[1] * bs[2] * bs[3]
	}else{
		tiles <- length(bs$w1) - 1
	}
	zlim <- filePar$noise_est * in.folder$graphics.par$clevel
	endFormat <- filePar$endian
	
	## Open binary connection
	outTiles <- NULL
	con <- myFile(fileName, "rb")
	seek(con, where=filePar$binary_location, origin="start")
	
	## Read binary	and find the viewable tiles 
	for (i in 0:tiles){
		if (!is.null(upShifts)){
			lCol <- bs$w1[i + 1]
			n <- bs$w1[i + 1] * bs$w2[i + 1]
		}
		cTile <- matrix(abs(readBin(con, size=4, what='double', endian=endFormat, 
								n=n)), ncol=lCol) 
		if (any(cTile > zlim)){
			outTiles <- c(outTiles, i)
			if (is.null(upShifts)){
				if (any(cTile[, lCol] > zlim))
					outTiles <- c(outTiles, i + w1Above)
				if (any(cTile[, 1] > zlim))
					outTiles <- c(outTiles, i - w1Above) 			
				if (any(cTile[lRow, ] > zlim))
					outTiles <- c(outTiles, i + 1)
				if (any(cTile[1, ] > zlim))
					outTiles <- c(outTiles, i - 1)
			}
		}
	}
	close(con)
	
	## Assign tiles to global environment
	tiles <- unique(outTiles[outTiles <= tiles])
	in.folder$graphics.par$tiles <- tiles
	if (internal)
		return(in.folder)
	fileNames <- sapply(fileFolder, function(x) x$file.par$file.name)
	fileFolder[[match(fileName, fileNames)]]$graphics.par$tiles <- tiles
	myAssign("fileFolder", fileFolder, save.backup=FALSE)
	
	invisible(in.folder)
}


################################################################################
##                                                                            ##
##                    Internal plotting functions                             ##
##                                                                            ##
################################################################################

## Internal plotting function pdisp
## Displays current peak list and prints any non NA labels
## col  - color for labels (see points)
## cex  - Character expansion (see points)
## pch  - Integer from 1:26 used to define label type (see points)
## ... - Additional arguments can be passed points
pdisp <- function(col, cex, pch, pos, offset, ...){
	
	## Define current spectrum
	current <- wc()
	lineCol <- fileFolder[[current]]$graphics.par$fg
	if (length(which(dev.list() == 2)) == 0)
		refresh(sub.plot=FALSE, multi.plot=FALSE)
	inFolder <- fileFolder[[current]]
	nDim <- inFolder$file.par$number_dimensions
	peaklist <- inFolder$peak.list
	labels <- which(peaklist$Assignment != 'NA')
	
	## Make sure something has been peak picked
	#if(length(peaklist$w2) == 0)
	#	return(invisible())
	
	## Set peak color
	if( missing(col) )
		col <- inFolder$graphics.par$peak.color
	
	## Set peak label size
	if (nDim == 1)
		w2Range <- inFolder$file.par$downfield_ppm[1] - 
				inFolder$file.par$upfield_ppm[1]
	else
		w2Range <- inFolder$file.par$downfield_ppm[2] - 
				inFolder$file.par$upfield_ppm[2]
	currRange <- inFolder$graphics.par$usr[1] - inFolder$graphics.par$usr[2]
	zmFactor <- w2Range / currRange
	zmFactor <- zmFactor^(1 / (.9 * zmFactor))
	if (missing(cex)){
		cex <- globalSettings$peak.cex
		cex <- cex * zmFactor
	}
	
	## Set peak label alignment
	if (missing(pos)){
		if (globalSettings$peak.labelPos == 'top')
			pos <- 3
		else if (globalSettings$peak.labelPos == 'bottom')
			pos <- 1
		else if (globalSettings$peak.labelPos == 'left')
			pos <- 2
		else if (globalSettings$peak.labelPos == 'right')
			pos <- 4
		else
			pos <- NULL
	}
	if (missing(offset))
		offset <- .3
	
	## Set graphics for peak display    
	if(nDim > 1){
		if( missing(pch) )
			pch <- globalSettings$peak.pch 
		if(is.null(peaklist$Multiplet))
			mainShifts <- NULL
		else
			mainShifts <- which( is.na(peaklist$Multiplet)  )
		if(length(mainShifts) != 0 )
			points(peaklist$w2[mainShifts], peaklist$w1[mainShifts], col = col, 
					cex = cex, pch = 7, ... )
		
		points( peaklist$w2, peaklist$w1, col = col, cex = cex, pch = pch, ... )
		y <- peaklist$w1[labels]
	}else{
		abline( h = inFolder$file.par$noise_est * globalSettings$thresh.1D +
						inFolder$file.par$zero_offset, col=lineCol )
		if( missing(pch) )
			pch = 25
		points(peaklist$w2, peaklist$Height, col = col, pch = pch, cex = cex, ... )
		y <- peaklist$Height[labels]
	}
	
	## Add assignment labels
	if(length(labels) > 0)
		text(peaklist$w2[labels], y, labels = peaklist$Assignment[labels], 
				cex = cex * .8, col = col, pos = pos, offset = offset)
	
	## Leave the console active
	bringFocus(-1) 
	
	invisible()	
}

##Internal graphics wrapper function drawNMR
## note: this function implements all of the lower level draw functions
##Draws an NMR spectrum from a binary connection.
##in.folder - Header of the file to be plotted, default is current spectrum
##w1Range - Chemical shift range in the indirect dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)          
##w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
##pos.zlim - Min and max positive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##neg.zlim - Max and min negative intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##type  - specifies the type of plot to be generated: 2D data can be draw as
##        'auto', 'image', 'contour', 'filled', and 'persp'.
##        Image plots are the fastest, contour plots are more detailed, filled 
##        produces a filled contour plot, persp generates a 3D perspective plot,
##        and auto (the default) switches between image and contour depending on 
##        the amount of data being displayed.
##        1D values can also be passed as a type. Arguments include 'l', 'p',
##        and 'b' for line, point, and both line and points, respectively. 1D 
##        spectra default to 'l'. 2D data, when passes any of the 1D arguments 
##        will invoke proj1D and 'l', 'p' or 'b' will be passed to proj1D.
##        If type = NULL, type is taken from the spectrum's last setting. 
##pos.color - color of positive contours, default is the most recent setting
##         for the file, see colors() for the many color options
##neg.color - color of negative contours, default is the most recent setting
##         for the file, see colors() for the many color options
##col    - color for 1D data and 1D slices/projections of 2D data
##note:  All 2D plots use pos.color for positive intensities, and neg.color for 
##       negative intensities. 3D perspective plots use pos.color for all data,
##       and all 1D plots use col.
##nlevels - the number of contour intervals to be drawn, the default is the most
##         recent setting used for the file
##xlab    - x axis label, default is the direct detected nucleus in PPM
##ylab    - y axis label, default is the indirect detected nucleus in PPM
##main    - main title for plot, default is the spectrum name
##conDisp    - logical vector, c(TRUE, TRUE) plots positive and negative 
##           contours, c(TRUE, FALSE) plots only positive, c(FALSE, TRUE) plots
##           only the negative contours, c(FALSE, FALSE) plots no contours
## bg, fg, col.axis, col.lab, col.main, col.sub, col - see par()
##add       - logical argument, TRUE adds new data to an existing plot, FALSE 
##            generates a new plot
##p.window  -  The window to be used, can be 'main', 'sub', 'multi', or 'stats'
##axes      - logical argument, TRUE makes pretty labels
##offset    - Numeric argument expressing the % of total z range with which to 
##            displace a spectrum. This is used to create stacked 1D spectra
##...       - Additional graphics parameters can be passed to par()
##returns   - a plot of a 2D NMR spectrum
drawNMR <- function ( in.folder = fileFolder[[wc()]], w1Range, w2Range, 
		pos.zlim, neg.zlim, type, pos.color, neg.color, nlevels, conDisp,
		bg, fg, col.axis, col.lab, col.main, col.sub, col, xlab = NULL, ylab = NULL,
		main = in.folder$file.par$user_title, add = FALSE, p.window = 'main', 
		axes = TRUE, offset = 0, ...){
	
	## Supply graphics parameters to data missing graphics.par
	if ( is.null(in.folder$graphics.par) )
		in.folder$graphics.par <- defaultSettings
	
	## Update graphics.par with any specified parameters
	if( !missing(w1Range) )
		in.folder$graphics.par$usr[3:4] <- w1Range
	if( !missing(w2Range) )
		in.folder$graphics.par$usr[1:2] <- w2Range
	if( !missing(type) )
		in.folder$graphics.par$type <- type
	if( !missing(pos.color) )
		in.folder$graphics.par$pos.color <- pos.color 
	if( !missing(neg.color) )
		in.folder$graphics.par$neg.color <- neg.color
	if( !missing(nlevels) )
		in.folder$graphics.par$nlevels <- nlevels
	if( !missing(conDisp) )
		in.folder$graphics.par$conDisp <- conDisp
	if( !missing(bg) )
		in.folder$graphics.par$bg <- bg
	if( !missing(fg) )
		in.folder$graphics.par$fg <- fg
	if( !missing(col.axis) )
		in.folder$graphics.par$col.axis <- col.axis 
	if( !missing(col.lab) )
		in.folder$graphics.par$col.lab <- col.lab	
	if( !missing(col.main) )
		in.folder$graphics.par$col.mainv <- col.main
	if( !missing(col.sub) )
		in.folder$graphics.par$col.sub <- col.sub
	if( !missing(col) )
		in.folder$graphics.par$col <- in.folder$graphics.par$proj.color <- col
	
	## Calculate pos/neg zlims if missing	
	if( missing(pos.zlim) )
		pos.zlim <- c( in.folder$file.par$noise_est * in.folder$graphics.par$clevel,
				in.folder$file.par$noise_est * in.folder$graphics.par$clevel * 
						in.folder$graphics.par$nlevels )
	if( missing(neg.zlim) )
		neg.zlim <- -(rev(pos.zlim))
	
	##Set plotting window
	setWindow( 
			p.window = p.window, 
			bg = in.folder$graphics.par$bg, 
			fg = in.folder$graphics.par$fg, 
			col.axis = in.folder$graphics.par$col.axis, 
			col.lab = in.folder$graphics.par$col.lab, 
			col.main = in.folder$graphics.par$col.main, 
			col.sub = in.folder$graphics.par$col.sub, 
			col = in.folder$graphics.par$col
	)
	
	## Remove labels when appropriate
	if(p.window == 'multi')
		xlab <- ylab <- main <- ''
	if(p.window == 'sub')
		xlab <- ylab <- ''
	
	## Plot 1D data, slices, projections
	if( in.folder$file.par$number_dimensions == 1 ){
#		if (!is.null(in.folder$file.par$block_upfield_ppms))
#			plotRsd1D( in.folder = in.folder, xlab = xlab, ylab = ylab, main = main, 
#					add = add, axes = axes, offset = offset, ...)
#		else
		plot1D( in.folder = in.folder, xlab = xlab, ylab = ylab, main = main, 
				add = add, axes = axes, offset = offset, ...)
	}else{
		
		## Set axis labels
		if( is.null(xlab) )
			xlab <- paste(in.folder$file.par$nucleus[2])#, 'PPM', sep=' ')
		if( is.null(ylab) )
			ylab <- paste(in.folder$file.par$nucleus[1])# , 'PPM', sep=' ')
		
		## Plot data in the multiple file/subplot windows, or data in memory
		if (in.folder$graphics.par$type != 'persp' && 
				(p.window != 'main' || (!is.null(in.folder$data) && 
						!is.null(in.folder$w1) && !is.null(in.folder$w2)))){
			draw2D( in.folder = in.folder, pos.zlim = pos.zlim, neg.zlim = neg.zlim,
					xlab = xlab, ylab = ylab, main = main, add = add, axes = axes, ...)
			
			
		}else if (!is.null(in.folder$file.par$block_upfield_ppms)){
			
			## Plot RSD file
			if (in.folder$graphics.par$type != 'persp')
				plotRsd2D( in.folder = in.folder, pos.zlim = pos.zlim, 
						neg.zlim = neg.zlim, xlab = xlab, ylab = ylab, main = main, 
						add = add, axes = axes, ...)
			else
				perspRsd(in.folder = in.folder, xlab = xlab, ylab = ylab, main = main, 
						...) 
			
		}else if (in.folder$file.par$number_dimensions == 2){
			
			## Plot 2D UCSF file
			if (in.folder$graphics.par$type != 'persp')
				plot2D( in.folder = in.folder, pos.zlim = pos.zlim, 
						neg.zlim = neg.zlim, xlab = xlab, ylab = ylab, main = main, 
						add = add, axes = axes, ...)
			else
				persp2D(in.folder = in.folder, xlab = xlab, ylab = ylab, main = main, 
						...) 
			
		}else if (in.folder$file.par$number_dimensions == 3){
			
			## Plot 3D UCSF file
			if (in.folder$graphics.par$type != 'persp')
				plot3D( in.folder = in.folder, pos.zlim = pos.zlim, 
						neg.zlim = neg.zlim, xlab = xlab, ylab = ylab, main = main, 
						add = add, axes = axes, ...)
			else
				persp2D(in.folder = in.folder, xlab = xlab, ylab = ylab, main = main, 
						...) 
		}
	}
	
	bringFocus(-1) #return focus to console
}


##Internal graphics wrapper function plot2D
##Draws a 2D NMR spectrum from a binary connection
##in.folder - Header of the file to be plotted, default is current spectrum
##w1Range - Chemical shift range in the indirect dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)          
##w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
##pos.zlim - Min and max poisitive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##neg.zlim - Max and min negitive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##type  - specifies the type of plot to be generated: 'image' is the fastest, 
##        'contour' produces a contour plot, 'filled' is a filled contour plot 
##         and 'persp' produces a 3D perspective plot. Default is the most 
##         recent type used with the file
##pos.color - color of positive contours, default is the most recent setting
##         for the file, see colors() for the many color options
##neg.color - color of negative contours, default is the most recent setting
##         for the file, see colors() for the many color options
##nlevels - the number of contour intervals to be drawn, the default is the most
##         recent setting used for the file
##xlab    - x axis label, default is the direct detected nucleus in PPM
##ylab    - y axis label, default is the indirect detected nucleus in PPM
##main    - main title for plot, default is the file name
##conDisp    - logical vector, c(TRUE, TRUE) plots positive and negative 
##           contours, c(TRUE, FALSE) plots only positive, c(FALSE, TRUE) plots
##           only the negative contours, c(FALSE, FALSE) plots no contours
##add       - logical argument, TRUE adds new data to an existing plot, FALSE 
##            generates a new plot
##p.window  -  The window to be used, can be 'main', 'sub', 'multi', or 'stats'
##axes      - logical argument, TRUE draws axes
##...       - Additinal graphics paramaters can be passed to par()
##returns   - a plot of a 2D NMR spectrum  
plot2D <- function(     
		in.folder = fileFolder[[wc()]],
		w1Range = in.folder$graphics.par$usr[3:4],
		w2Range = in.folder$graphics.par$usr[1:2],
		pos.zlim = c(in.folder$file.par$noise_est * in.folder$graphics.par$clevel,
				in.folder$file.par$noise_est * in.folder$graphics.par$clevel *
						in.folder$graphics.par$nlevels),
		neg.zlim = -(rev(pos.zlim)),
		type = in.folder$graphics.par$type,
		pos.color = in.folder$graphics.par$pos.color,
		neg.color = in.folder$graphics.par$neg.color,
		nlevels = in.folder$graphics.par$nlevels,
		conDisp = in.folder$graphics.par$conDisp,
		xlab = paste(in.folder$file.par$nucleus[2]), 
		ylab = paste(in.folder$file.par$nucleus[1]), 
		main = in.folder$file.par$user_title, add = FALSE, axes = TRUE, ...){
	
	## Find total usable tiles if none exists
	if(is.null(in.folder$graphics.par$tiles))
		in.folder <- findTiles(in.folder = in.folder)
	
	## Define some local variables
	bs <- in.folder$file.par$block_size
	ms <- in.folder$file.par$matrix_size
	uf <- in.folder$file.par$upfield_ppm
	df <- in.folder$file.par$downfield_ppm
	endFormat <- in.folder$file.par$endian
	binLoc <- in.folder$file.par$binary_location
	
	## Find best chemical shift match
	in.folder$w1 <- seq(uf[1], df[1], length.out = ms[1])
	in.folder$w2 <- seq(uf[2], df[2],	length.out = ms[2])	
	w1Range <- sort(w1Range); w2Range <- sort(w2Range)
	out <- NULL
	t1 <- findInterval(w1Range, in.folder$w1, all.inside = TRUE)
	d1 <- findInterval(w2Range, in.folder$w2, all.inside = TRUE)
	t2 <- t1 + 1; d2 <- d1 + 1
	for(i in 1:2){
		out$w1[i] <- switch( which.min(c(
								abs(w1Range[i] - in.folder$w1[t1[i]]),
								abs(w1Range[i] - in.folder$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch( which.min(c(
								abs(w2Range[i] - in.folder$w2[d1[i]]),
								abs(w2Range[i] - in.folder$w2[d2[i]]))), d1[i], d2[i])
	}
	
	## Invert w1/w2 selection to match binary data format
	out$w1 <- sort(ms[1] - out$w1) + 1
	out$w2 <- sort(ms[2] - out$w2) + 1
	
	## Find sparky tiles that will be plotted
	w1Tiles <- (ceiling(out$w1[1] / bs[1]): ceiling(out$w1[2] / bs[1]))
	w2Tiles <- (ceiling(out$w2[1] / bs[2]): ceiling(out$w2[2] / bs[2]))
	tiles <- NULL
	for ( i in 1:length(w1Tiles))
		tiles <- c(tiles, ((w1Tiles[i]-1) * (ceiling(ms[2] / bs[2])) + (w2Tiles-1)))
	
	if(!add){
		
		## Set new axes and 'clear' old plot with a box
		plot(0, 0, axes=FALSE, type = 'n', xlab=xlab, ylab=ylab, main=main, 
				xaxs='i', yaxs='i', cex.main=in.folder$graphics.par$cex.main)
		par(usr = c(w2Range[2:1], w1Range[2:1]))
		rect(c(w2Range[2], w2Range[2], w2Range[2], uf[2] ),  
				c(w1Range[2], uf[1], w1Range[1], w1Range[1] ),
				c(w2Range[1], w2Range[1], df[2], w2Range[1] ),
				c(df[1], w1Range[1], w1Range[2], w1Range[2]), 
				col = "grey", border = NA)
		
		## Draw plot labels
		box(col=in.folder$graphics.par$fg, bty='o')
		if(axes){
			par(usr = c(rev(par('usr')[1:2]), rev(par('usr')[3:4]))) 
			xlabvals <- pretty(w2Range, 10)    
			xlabvals <- c(xlabvals, par('usr')[2])
			n1 <- length(xlabvals)
			if (!is.na(in.folder$graphics.par$xtck) && 
					in.folder$graphics.par$xtck == 1)
				xlty <- 2
			else
				xlty <- 1
			if (!is.na(in.folder$graphics.par$ytck) && 
					in.folder$graphics.par$ytck == 1)
				ylty <- 2
			else
				ylty <- 1
			axis(side=1, at=min(w2Range) + (max(w2Range)-xlabvals),  
					labels = c( xlabvals[-n1], paste('    ', xlab)), lty=xlty,
					tck=in.folder$graphics.par$xtck, 
					cex.axis=in.folder$graphics.par$cex.axis)   
			ylabvals <- pretty(w1Range, 10)
			ylabvals <- c(ylabvals, par('usr')[4] )
			n1 <- length(ylabvals)
			axis(side=2, at=min(w1Range) + (max(w1Range) - ylabvals),  
					labels = c( ylabvals[-n1], paste('    ', ylab)), lty=ylty, 
					tck=in.folder$graphics.par$ytck, 
					cex.axis=in.folder$graphics.par$cex.axis) 
			par(usr = c(rev(par('usr')[1:2]), rev(par('usr')[3:4]))) 
		}
	}
	
	## Set plot function for auto mode
	if (!type %in% c('auto', 'image', 'contour', 'filled'))
		type <- 'auto'
	if(type == 'auto'){
		if((length(w1Tiles) + length(w2Tiles)) < 17)
			type <- 'contour'
		else
			type <- 'image'
	}
	
	## Set plotting function
	plotCur <- switch( which(c('image', 'contour', 'filled') == type),
			function(...){ image(add = TRUE, ...)},
			function(zlim, ...){ contour(zlim, add = TRUE, nlevels = nlevels, 
						levels = seq(zlim[1], zlim[2], length.out = nlevels),  
						drawlabels = FALSE, ...)},
			function(zlim, ...){ fillCon(
						levels = seq(zlim[1], zlim[2], length.out = nlevels), ...)}
	)
	
	
	in.folder$w1 <- 1:((ms[1] %/% bs[1] + 1) * bs[1]) * 
			((df[1] - uf[1]) / (ms[1] - 1))
	in.folder$w1 <- in.folder$w1 + (df[1] - rev(in.folder$w1)[1] ) 
	in.folder$w2 <- 1:((ms[2] %/% bs[2] + 1) * bs[2]) * 
			((df[2] - uf[2]) / (ms[2] - 1))
	in.folder$w2 <- in.folder$w2 + (df[2] - rev(in.folder$w2)[1] ) 
	
	## Open connection to binary file
	con <- myFile(in.folder$file.par$file.name, "rb")
	outData <- NULL
	
	##Read binary data for each tile
	w2TileNum <- ceiling(ms[2] / bs[2] )
	if(type != 'image'){
		w2Slice <- rep(NA, length(in.folder$w2))
		w1Slice <- rep(NA, length(in.folder$w1))
	} 
	
	for(i in tiles){
		## define current w1/w2 range
		w1 <- ceiling( (i + 1) / w2TileNum )
		w1B <- (1:bs[1]) + bs[1] * (w1 - 1) 
		w2 <- (i + 1) - (w1 * w2TileNum ) + w2TileNum
		w2B <- (1:bs[2]) + bs[2] * (w2 - 1) 
		
		##skip tiles with no data above the threshold
		if( length( which(in.folder$graphics.par$tiles == (i))) == 0 ){
			if(type != 'image'){
				w2Slice[w2B] <- rep(NA, length(w2B))
				w1Slice[w1B] <- rep(NA, length(w1B))
			}
			next() 
		}
		
		## read binary
		w1 <- rev(in.folder$w1)[w1B]
		w2 <- rev(in.folder$w2)[w2B]
		w1 <- sort(w1); w2=sort(w2)
		seek(con, bs[1] * bs[2] * 4 * i + binLoc, origin = 'start')
		outData <- matrix(rev(readBin(con, size=4, what='double',
								endian = endFormat, n=(bs[1] * bs[2]))), ncol=bs[1])
		
		## Overlap tile with previous tile to correct edge effects
		if(type != 'image'){   
			edge <- in.folder$w1[(which(in.folder$w1 == rev(w1)[1])) + 1]
			if(length(edge) != 0 && !is.na(edge)){    
				w1 <- c(w1, edge)
				outData <- cbind(outData, w2Slice[w2B])
			}  
			w2Slice[w2B] <- outData[, 1]
			
			edge <- in.folder$w2[(which(in.folder$w2 == rev(w2)[1])) + 1]
			if(length(edge) != 0 && !is.na(edge)){    
				w2 <- c(w2, edge)
				outData <- suppressWarnings(rbind(outData, w1Slice[w1B]))
			}  
			w1Slice[w1B] <- outData[1, (1:length(w1B))]             
		}
		
		## Plot the current tile
		if(conDisp[1])
			plotCur(x = w2, y = w1, z = outData, zlim = pos.zlim, 
					col = pos.color, ...)
		if(conDisp[2])
			plotCur(x = w2, y = w1, z= outData, zlim = neg.zlim, col = neg.color, ...)
	}
	
	## Close binary conection
	closeAllConnections()
}


##Internal graphics wrapper function plot2D
##Draws a single 2D slice from a 3D NMR spectrum from binary connection
##in.folder - Header of the file to be plotted, default is current spectrum
##w1Range - Chemical shift range in the indirect dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)          
##w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
##pos.zlim - Min and max poisitive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##neg.zlim - Max and min negitive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##type  - specifies the type of plot to be generated: 'image' is the fastest, 
##        'contour' produces a contour plot, 'filled' is a filled contour plot 
##         and 'persp' produces a 3D perspective plot. Default is the most 
##         recent type used with the file
##pos.color - color of positive contours, default is the most recent setting
##         for the file, see colors() for the many color options
##neg.color - color of negative contours, default is the most recent setting
##         for the file, see colors() for the many color options
##nlevels - the number of contour intervals to be drawn, the default is the most
##         recent setting used for the file
##xlab    - x axis label, default is the direct detected nucleus in PPM
##ylab    - y axis label, default is the indirect detected nucleus in PPM
##main    - main title for plot, default is the file name
##conDisp    - logical vector, c(TRUE, TRUE) plots positive and negative 
##           contours, c(TRUE, FALSE) plots only positive, c(FALSE, TRUE) plots
##           only the negative contours, c(FALSE, FALSE) plots no contours
##add       - logical argument, TRUE adds new data to an existing plot, FALSE 
##            generates a new plot
##p.window  -  The window to be used, can be 'main', 'sub', 'multi', or 'stats'
##axes      - logical argument, TRUE draws axes
##...       - Additinal graphics paramaters can be passed to par()
##returns   - a plot of a 2D NMR spectrum  
plot3D <- function(in.folder=fileFolder[[wc()]],
		w1Range=in.folder$graphics.par$usr[3:4],
		w2Range=in.folder$graphics.par$usr[1:2],
		pos.zlim=c(in.folder$file.par$noise_est * in.folder$graphics.par$clevel,
				in.folder$file.par$noise_est * in.folder$graphics.par$clevel *
						in.folder$graphics.par$nlevels),
		neg.zlim=-(rev(pos.zlim)), type=in.folder$graphics.par$type, 
		pos.color=in.folder$graphics.par$pos.color,
		neg.color= in.folder$graphics.par$neg.color,
		nlevels=in.folder$graphics.par$nlevels, 
		conDisp=in.folder$graphics.par$conDisp,
		xlab=paste(in.folder$file.par$nucleus[2]), 
		ylab=paste(in.folder$file.par$nucleus[1]), 
		main=in.folder$file.par$user_title, add=FALSE, axes=TRUE, ...){
	
	## Find total usable tiles if none exists
	if (is.null(in.folder$graphics.par$tiles))
		in.folder <- findTiles(in.folder=in.folder)
	
	## Define some local variables
	filePar <- in.folder$file.par
	graphicsPar <- in.folder$graphics.par
	bs <- filePar$block_size
	ms <- filePar$matrix_size
	uf <- filePar$upfield_ppm
	df <- filePar$downfield_ppm
	endFormat <- filePar$endian
	binLoc <- filePar$binary_location
	
	## Find best chemical shift match
	in.folder$w1 <- seq(uf[1], df[1], length.out=ms[1])
	in.folder$w2 <- seq(uf[2], df[2],	length.out=ms[2])	
	in.folder$w3 <- seq(uf[3], df[3],	length.out=ms[3])	
	w1Range <- sort(w1Range); w2Range <- sort(w2Range)
	w3Range <- rep(filePar$z_value, 2)
	t1 <- findInterval(w1Range, in.folder$w1, all.inside=TRUE)
	d1 <- findInterval(w2Range, in.folder$w2, all.inside=TRUE)
	z1 <- findInterval(w3Range, in.folder$w3, all.inside=TRUE)
	t2 <- t1 + 1; d2 <- d1 + 1; z2 <- z1 + 1
	out <- NULL
	for (i in 1:2){
		out$w1[i] <- switch(which.min(c(abs(w1Range[i] - in.folder$w1[t1[i]]),
								abs(w1Range[i] - in.folder$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch(which.min(c(abs(w2Range[i] - in.folder$w2[d1[i]]),
								abs(w2Range[i] - in.folder$w2[d2[i]]))), d1[i], d2[i])
		out$w3[i] <- switch(which.min(c(abs(w3Range[i] - in.folder$w3[z1[i]]),
								abs(w3Range[i] - in.folder$w3[z2[i]]))), z1[i], z2[i])
	}
	
	## Invert w1/w2 selection to match binary data format
	out$w1 <- sort(ms[1] - out$w1) + 1
	out$w2 <- sort(ms[2] - out$w2) + 1
	
	## Find sparky tiles that will be plotted
	w1Tiles <- (ceiling(out$w1[1] / bs[1]):ceiling(out$w1[2] / bs[1]))
	w2Tiles <- (ceiling(out$w2[1] / bs[2]):ceiling(out$w2[2] / bs[2]))
	w3Tiles <- (ceiling(out$w3[1] / bs[3]):ceiling(out$w3[2] / bs[3]))
	numTiles <- ceiling(ms / bs)
	tiles <- NULL
	for (i in w1Tiles)
		tiles <- c(tiles, (i - 1) * numTiles[2] + (w2Tiles - 1))
	tiles <- tiles + (w3Tiles - 1) * numTiles[1] * numTiles[2]
	
	if (!add){
		
		## Set new axes and 'clear' old plot with a box
		plot(0, 0, axes=FALSE, type='n', xlab=xlab, ylab=ylab, main=main,	xaxs='i', 
				yaxs='i', cex.main=graphicsPar$cex.main)
		par(usr=c(w2Range[2:1], w1Range[2:1]))
		rect(c(w2Range[2], w2Range[2], w2Range[2], uf[2]), 
				c(w1Range[2], uf[1], w1Range[1], w1Range[1] ),
				c(w2Range[1], w2Range[1], df[2], w2Range[1]), 
				c(df[1], w1Range[1], w1Range[2], w1Range[2]), col="grey", border=NA)
		
		## Draw plot labels
		box(col=graphicsPar$fg, bty='o')
		if (axes){
			par(usr=c(rev(par('usr')[1:2]), rev(par('usr')[3:4]))) 
			xlabvals <- pretty(w2Range, 10)    
			xlabvals <- c(xlabvals, par('usr')[2])
			n1 <- length(xlabvals)
			if (!is.na(graphicsPar$xtck) && 
					graphicsPar$xtck == 1)
				xlty <- 2
			else
				xlty <- 1
			if (!is.na(graphicsPar$ytck) && 
					graphicsPar$ytck == 1)
				ylty <- 2
			else
				ylty <- 1
			axis(side=1, at=min(w2Range) + (max(w2Range) - xlabvals),  
					labels=c( xlabvals[-n1], paste('    ', xlab)), lty=xlty,
					tck=graphicsPar$xtck, 
					cex.axis=graphicsPar$cex.axis)   
			ylabvals <- pretty(w1Range, 10)
			ylabvals <- c(ylabvals, par('usr')[4] )
			n1 <- length(ylabvals)
			axis(side=2, at=min(w1Range) + (max(w1Range) - ylabvals),  
					labels = c( ylabvals[-n1], paste('    ', ylab)), lty=ylty, 
					tck=graphicsPar$ytck, 
					cex.axis=graphicsPar$cex.axis) 
			par(usr=c(rev(par('usr')[1:2]), rev(par('usr')[3:4]))) 
		}
	}
	
	## Set plot function for auto mode
	if (!type %in% c('auto', 'image', 'contour', 'filled'))
		type <- 'auto'
	if (type == 'auto'){
		if ((length(w1Tiles) + length(w2Tiles)) < 17)
			type <- 'contour'
		else
			type <- 'image'
	}
	
	## Set plotting function
	plotCur <- switch(which(c('image', 'contour', 'filled') == type),
			function(...) image(add=TRUE, ...),
			function(zlim, ...) contour(zlim, add=TRUE, nlevels=nlevels, 
						levels=seq(zlim[1], zlim[2], length.out=nlevels), drawlabels=FALSE, 
						...),
			function(zlim, ...) fillCon(levels=seq(zlim[1], zlim[2], 
								length.out=nlevels), ...))
	
	
	in.folder$w1 <- 1:((ms[1] %/% bs[1] + 1) * bs[1]) * 
			((df[1] - uf[1]) / (ms[1] - 1))
	in.folder$w1 <- in.folder$w1 + (df[1] - rev(in.folder$w1)[1]) 
	in.folder$w2 <- 1:((ms[2] %/% bs[2] + 1) * bs[2]) * 
			((df[2] - uf[2]) / (ms[2] - 1))
	in.folder$w2 <- in.folder$w2 + (df[2] - rev(in.folder$w2)[1]) 
	
	## Read binary data for each tile
	outData <- NULL
	tileSize <- bs[1] * bs[2] * bs[3] * 4
	w2TileNum <- ceiling(ms[2] / bs[2])
	if (type != 'image'){
		w2Slice <- rep(NA, length(in.folder$w2))
		w1Slice <- rep(NA, length(in.folder$w1))
	} 
	con <- myFile(filePar$file.name, "rb")
	for (i in tiles){
		
		## Define current w1/w2 range
		tile2D <- i - (w3Tiles - 1) * numTiles[1] * numTiles[2]
		w1 <- ceiling((tile2D + 1) / w2TileNum)
		w1B <- (1:bs[1]) + bs[1] * (w1 - 1) 
		w2 <- (tile2D + 1) - (w1 * w2TileNum ) + w2TileNum
		w2B <- (1:bs[2]) + bs[2] * (w2 - 1) 
		
		## Skip tiles with no data above the threshold
		if (!i %in% graphicsPar$tiles){
			if (type != 'image'){
				w2Slice[w2B] <- rep(NA, length(w2B))
				w1Slice[w1B] <- rep(NA, length(w1B))
			}
			next() 
		}
		
		## Define data location for current tile
		tileLoc <- tileSize * i + binLoc
		if (bs[3] > 1)
			zPos <- (out$w3[1] - 1) * bs[3]
		else
			zPos <- 0
		dataLoc <- tileLoc + bs[1] * bs[2] * 4 * zPos
		
		## Read binary
		seek(con, dataLoc, origin='start')
		outData <- matrix(rev(readBin(con, size=4, what='double', endian=endFormat, 
								n=bs[1] * bs[2])), ncol=bs[1])
		
		## Overlap tile with previous tile to correct edge effects
		w1 <- rev(in.folder$w1)[w1B]
		w2 <- rev(in.folder$w2)[w2B]
		w1 <- sort(w1); w2=sort(w2)
		if (type != 'image'){   
			edge <- in.folder$w1[(which(in.folder$w1 == rev(w1)[1])) + 1]
			if (length(edge) != 0 && !is.na(edge)){    
				w1 <- c(w1, edge)
				outData <- cbind(outData, w2Slice[w2B])
			}  
			w2Slice[w2B] <- outData[, 1]
			edge <- in.folder$w2[(which(in.folder$w2 == rev(w2)[1])) + 1]
			if (length(edge) != 0 && !is.na(edge)){    
				w2 <- c(w2, edge)
				outData <- suppressWarnings(rbind(outData, w1Slice[w1B]))
			}  
			w1Slice[w1B] <- outData[1, (1:length(w1B))]             
		}
		
		## Plot the current tile
		if (conDisp[1])
			plotCur(x=w2, y=w1, z=outData, zlim=pos.zlim, col=pos.color, ...)
		if (conDisp[2])
			plotCur(x=w2, y=w1, z=outData, zlim=neg.zlim, col=neg.color, ...)
	}
	
	## Close binary conection
	close(con)
}


##Internal graphics wrapper function plotRsd2D
##Draws a 2D RSD NMR spectrum from a binary connection
##in.folder - Header of the file to be plotted, default is current spectrum
##w1Range - Chemical shift range in the indirect dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)          
##w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
##pos.zlim - Min and max poisitive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##neg.zlim - Max and min negitive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##type  - specifies the type of plot to be generated: 'image' is the fastest, 
##        'contour' produces a contour plot, 'filled' is a filled contour plot 
##         and 'persp' produces a 3D perspective plot. Default is the most 
##         recent type used with the file
##pos.color - color of positive contours, default is the most recent setting
##         for the file, see colors() for the many color options
##neg.color - color of negative contours, default is the most recent setting
##         for the file, see colors() for the many color options
##nlevels - the number of contour intervals to be drawn, the default is the most
##         recent setting used for the file
##xlab    - x axis label, default is the direct detected nucleus in PPM
##ylab    - y axis label, default is the indirect detected nucleus in PPM
##main    - main title for plot, default is the file name
##conDisp    - logical vector, c(TRUE, TRUE) plots positive and negative 
##           contours, c(TRUE, FALSE) plots only positive, c(FALSE, TRUE) plots
##           only the negative contours, c(FALSE, FALSE) plots no contours
##add       - logical argument, TRUE adds new data to an existing plot, FALSE 
##            generates a new plot
##p.window  -  The window to be used, can be 'main', 'sub', 'multi', or 'stats'
##axes      - logical argument, TRUE draws axes
##...       - Additinal graphics paramaters can be passed to par()
##returns   - a plot of a 2D NMR spectrum  
plotRsd2D <- function(in.folder=fileFolder[[wc()]], 
		w1Range=in.folder$graphics.par$usr[3:4],
		w2Range=in.folder$graphics.par$usr[1:2],
		pos.zlim=c(in.folder$file.par$noise_est * in.folder$graphics.par$clevel,
				in.folder$file.par$noise_est * in.folder$graphics.par$clevel *
						in.folder$graphics.par$nlevels),
		neg.zlim=-(rev(pos.zlim)), type=in.folder$graphics.par$type,
		pos.color=in.folder$graphics.par$pos.color,
		neg.color=in.folder$graphics.par$neg.color,
		nlevels=in.folder$graphics.par$nlevels,
		conDisp=in.folder$graphics.par$conDisp,
		xlab=paste(in.folder$file.par$nucleus[2]), 
		ylab=paste(in.folder$file.par$nucleus[1]), 
		main=in.folder$file.par$user_title, add=FALSE, axes=TRUE, ...){
	
	## Find total usable tiles if none exists
	if (is.null(in.folder$graphics.par$tiles))
		in.folder <- findTiles(in.folder=in.folder)
	
	## Define some local variables
	filePar <- in.folder$file.par
	graphicsPar <- in.folder$graphics.par
	uf <- filePar$upfield_ppm
	df <- filePar$downfield_ppm
	binLoc <- filePar$binary_location
	
	## Find best w1/w2 matches	
	w1Range <- sort(w1Range)
	w2Range <- sort(w2Range)
	in.folder$w1 <- seq(filePar$upfield_ppm[1], filePar$downfield_ppm[1], 
			length.out=filePar$matrix_size[1])
	in.folder$w2 <- seq(filePar$upfield_ppm[2], filePar$downfield_ppm[2], 
			length.out=filePar$matrix_size[2])
	t1 <- findInterval(w1Range, in.folder$w1, all.inside=TRUE)
	d1 <- findInterval(w2Range, in.folder$w2, all.inside=TRUE)
	t2 <- t1 + 1
	d2 <- d1 + 1
	out <- list(w1=NULL, w2=NULL)
	for (i in 1:2){
		out$w1[i] <- switch(which.min(c(abs(w1Range[i] - in.folder$w1[t1[i]]),
								abs(w1Range[i] - in.folder$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch(which.min(c(abs(w2Range[i] - in.folder$w2[d1[i]]),
								abs(w2Range[i] - in.folder$w2[d2[i]]))), d1[i], d2[i])
	}
	w1Range <- c(in.folder$w1[(out$w1[1])], in.folder$w1[(out$w1[2])])
	w2Range <- c(in.folder$w2[(out$w2[1])], in.folder$w2[(out$w2[2])])
	winW1 <- in.folder$w1[(out$w1[1]:out$w1[2])]
	winW2 <- in.folder$w2[(out$w2[1]:out$w2[2])]
	
	## Find tiles that will be plotted
	tiles <- NULL
	upShifts <- filePar$block_upfield_ppms
	downShifts <- filePar$block_downfield_ppms
	blockSizes <- filePar$block_size
	for (tNum in seq_along(filePar$block_size$w1)){
		
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
	
	if (!add){
		
		## Set new axes and 'clear' old plot with a box
		plot(0, 0, axes=FALSE, type='n', xlab=xlab, ylab=ylab, main=main, 
				xaxs='i', yaxs='i', cex.main=graphicsPar$cex.main)
		par(usr=c(w2Range[2:1], w1Range[2:1]))
		rect(c(w2Range[2], w2Range[2], w2Range[2], uf[2]),  
				c(w1Range[2], uf[1], w1Range[1], w1Range[1]),
				c(w2Range[1], w2Range[1], df[2], w2Range[1]),
				c(df[1], w1Range[1], w1Range[2], w1Range[2]), 
				col="grey", border=NA)
		
		## Draw plot labels
		box(col=graphicsPar$fg, bty='o')
		if (axes){
			par(usr=c(rev(par('usr')[1:2]), rev(par('usr')[3:4]))) 
			xlabvals <- pretty(w2Range, 10)    
			xlabvals <- c(xlabvals, par('usr')[2])
			n1 <- length(xlabvals)
			if (!is.na(graphicsPar$xtck) && graphicsPar$xtck == 1)
				xlty <- 2
			else
				xlty <- 1
			if (!is.na(graphicsPar$ytck) && graphicsPar$ytck == 1)
				ylty <- 2
			else
				ylty <- 1
			axis(side=1, at=min(w2Range) + (max(w2Range) - xlabvals),  
					labels=c(xlabvals[-n1], paste('    ', xlab)), lty=xlty,
					tck=graphicsPar$xtck, cex.axis=graphicsPar$cex.axis)   
			ylabvals <- pretty(w1Range, 10)
			ylabvals <- c(ylabvals, par('usr')[4])
			n1 <- length(ylabvals)
			axis(side=2, at=min(w1Range) + (max(w1Range) - ylabvals),  
					labels = c( ylabvals[-n1], paste('    ', ylab)), lty=ylty, 
					tck=graphicsPar$ytck, cex.axis=graphicsPar$cex.axis) 
			par(usr=c(rev(par('usr')[1:2]), rev(par('usr')[3:4]))) 
		}
	}
	
	## Set plot function for auto mode
	if (!type %in% c('auto', 'image', 'contour', 'filled'))
		type <- 'auto'
	if (type == 'auto'){
		if (length(tiles) < 64)
			type <- 'contour'
		else
			type <- 'image'
	}
	
	## Set plotting function
	plotCur <- switch(which(c('image', 'contour', 'filled') == type),
			function(...) image(add=TRUE, ...),
			function(zlim, ...) contour(zlim, add=TRUE, nlevels=nlevels, 
						levels=seq(zlim[1], zlim[2], length.out=nlevels),  
						drawlabels=FALSE, ...),
			function(zlim, ...) fillCon(levels=seq(zlim[1], zlim[2], 
								length.out=nlevels), ...))
	
	## Define data locations for each block
	blockLoc <- binLoc
	for (i in seq_along(filePar$block_size$w1))
		blockLoc <- c(blockLoc, blockLoc[i] + 4 * filePar$block_size$w1[i] * 
						filePar$block_size$w2[i])
	
	## Read binary data for each tile
	con <- myFile(filePar$file.name, "rb")
	outData <- NULL
	for (tNum in tiles){
		
		## Skip tiles with no data above the threshold
		if (!(tNum - 1) %in% graphicsPar$tiles)
			next()
		
		## Define current w1/w2 range
		w1 <- seq(upShifts$w1[tNum], downShifts$w1[tNum], 
				length.out=filePar$block_size$w1[tNum])
		w2 <- seq(upShifts$w2[tNum], downShifts$w2[tNum], 
				length.out=filePar$block_size$w2[tNum])
		
		## Read data
		seek(con, blockLoc[tNum], origin='start')
		outData <- matrix(rev(readBin(con, size=4, what='double', 
								endian=filePar$endian, 
								n=filePar$block_size$w1[tNum] * filePar$block_size$w2[tNum])), 
				ncol=filePar$block_size$w1[tNum])
		
		## Plot the current tile
		if (conDisp[1])
			plotCur(x=w2, y=w1, z=outData, zlim=pos.zlim, col=pos.color, ...)
		if (conDisp[2])
			plotCur(x=w2, y=w1, z=outData, zlim=neg.zlim, col=neg.color, ...)
	}
	
	## Close binary conection
	close(con)
}


##Internal graphics wrapper function draw2D
##Draws a 2D NMR spectrum from a binary connection
##note:    this replaces plot2D for the roi subplots and multiple file windows
##         for batch operations, this function is more efficient.       
##in.folder - Header of the file to be plotted, default is current spectrum
##w1Range - Chemical shift range in the indirect dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)          
##w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
##pos.zlim - Min and max poisitive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##neg.zlim - Max and min negitive intensities to be displayed, default is the 
##          most recent setting used with the file, the format is c(lower,upper)
##type  - specifies the type of plot to be generated: 'image' is the fastest, 
##        'contour' produces a contour plot, 'filled' is a filled contour plot 
##         and 'persp' produces a 3D perspective plot. Default is the most 
##         recent type used with the file
##pos.color - color of positive contours, default is the most recent setting
##         for the file, see colors() for the many color options
##neg.color - color of negative contours, default is the most recent setting
##         for the file, see colors() for the many color options
##nlevels - the number of contour intervals to be drawn, the default is the most
##         recent setting used for the file
##xlab    - x axis label, default is the direct detected nucleus in PPM
##ylab    - y axis label, default is the indirect detected nucleus in PPM
##main    - main title for plot, default is the spectrum name
##conDisp    - logical vector, c(TRUE, TRUE) plots positive and negative 
##           contours, c(TRUE, FALSE) plots only positive, c(FALSE, TRUE) plots
##           only the negative contours, c(FALSE, FALSE) plots no contours
##add       - logical argument, TRUE adds new data to an existing plot, FALSE 
##            generates a new plot
##axes      - logical argument, TRUE makes pretty labels
##roiMax    - logical argument, TRUE plots a point on the maximum
##            visible signal in the window
##...       - Additinal graphics paramaters can be passed to par()
##returns   - a plot of a 2D NMR spectrum  
draw2D <- function (
		in.folder = fileFolder[[wc()]],
		w1Range = in.folder$graphics.par$usr[3:4],
		w2Range = in.folder$graphics.par$usr[1:2],
		pos.zlim = c(in.folder$file.par$noise_est * in.folder$graphics.par$clevel,
				in.folder$file.par$noise_est * in.folder$graphics.par$clevel *
						in.folder$graphics.par$nlevels),
		neg.zlim = -(rev(pos.zlim)),
		type = in.folder$graphics.par$type,
		pos.color = in.folder$graphics.par$pos.color,
		neg.color = in.folder$graphics.par$neg.color,
		nlevels = in.folder$graphics.par$nlevels,
		conDisp = in.folder$graphics.par$conDisp,
		xlab = paste(in.folder$file.par$nucleus[2], 'PPM', sep=' '),
		ylab = paste(in.folder$file.par$nucleus[1], 'PPM', sep=' '),
		main = in.folder$file.par$user_title, 
		roiMax = globalSettings$roiMax,	add = FALSE, axes = TRUE, ...){
	
	## Open dataset
	w1Range <- sort(w1Range); w2Range <- sort(w2Range)
	if(is.matrix(in.folder$data) && !is.null(in.folder$w1) && 
			!is.null(in.folder$w2)){
		plotFile <- in.folder
		standardPlot <- TRUE
		if (!(xlab == '' && ylab == ''))
			roiMax <- FALSE
	}else{
		plotFile <- ucsf2D(file.name = in.folder$file.par$file.name,
				w1Range = w1Range, w2Range = w2Range, file.par = in.folder$file.par)
		standardPlot <- FALSE
	}
	if(is.matrix(plotFile$data))
		plotFile$data <- matrix(rev(plotFile$data), ncol = ncol(plotFile$data))
	
	## Set window to match the data 
	if(is.matrix(plotFile$data)){
		if (standardPlot){
			shiftRange <- matchShift(in.folder, w1=w1Range, w2=w2Range)
			minW1 <- which.min(abs(plotFile$w1 - shiftRange$w1[1]))
			minW2 <- which.min(abs(plotFile$w2 - shiftRange$w2[1]))
			maxW1 <- which.min(abs(plotFile$w1 - shiftRange$w1[2]))
			maxW2 <- which.min(abs(plotFile$w2 - shiftRange$w2[2]))
			plotFile$w1 <- plotFile$w1[minW1:maxW1]
			plotFile$w2 <- plotFile$w2[minW2:maxW2]
			plotFile$data <- plotFile$data[minW2:maxW2, minW1:maxW1]
		}else{
			w1Range <- range(plotFile$w1)
			w2Range <- range(plotFile$w2)
		}
	}
	
	## Set new axes and 'clear' old plot with a box
	if(!add){
		uf <- in.folder$file.par$upfield_ppm
		df <- in.folder$file.par$downfield_ppm
		plot(0, 0, axes=FALSE, type = 'n', xlab=xlab, ylab=ylab, main=main, 
				xaxs='i', yaxs='i')
		par(usr = c(w2Range[2:1], w1Range[2:1]))
		rect(c(w2Range[2], w2Range[2], w2Range[2], uf[2] ),  
				c(w1Range[2], uf[1], w1Range[1], w1Range[1] ),
				c(w2Range[1], w2Range[1], df[2], w2Range[1] ),
				c(df[1], w1Range[1], w1Range[2], w1Range[2]), 
				col = "grey", border = NA)
	}
	
	## Plot 'NA' for out of range ROIs
	if(!is.matrix(plotFile$data)){
		par(usr = c(-1,1,-1,1))
		text( 0, 0, "NA")	
		box(col=in.folder$graphics.par$fg, bty='o')
		return(invisible())
	}
	
	## Set plot function for auto mode
	if(!type %in% c('auto', 'image', 'contour', 'filled'))
		type <- 'auto'
	if(type == 'auto'){
		if (standardPlot){
			if(length(plotFile$data) < 1100000)
				type <- 'contour'
			else
				type <- 'image'
		}else{
			if(length(plotFile$data) > 150000)
				type <- 'image'
			else
				type <- 'contour'  
		}
	}
	
	## Set plotting function
	plotCur <- switch( which(c('image', 'contour', 'filled') == type),
			function(...){ image(add = TRUE, ...)},
			function(zlim, ...){ contour(zlim, add = TRUE, nlevels = nlevels, 
						levels = seq(zlim[1], zlim[2], length.out = nlevels),  
						drawlabels = FALSE, ...)},
			function(zlim, ...){ fillCon(
						levels = seq(zlim[1], zlim[2], length.out = nlevels), ...)}
	)
	
	## Plot the data
	if( conDisp[1] )
		plotCur(x=plotFile$w2, y=plotFile$w1, z=plotFile$data, zlim = pos.zlim, 
				col = pos.color, ...)
	if( conDisp[2] )
		plotCur(x=plotFile$w2, y=plotFile$w1, z=plotFile$data, zlim = neg.zlim, 
				col = neg.color, ...)
	if( roiMax ){
		mShift <- maxShift(plotFile, invert = TRUE, conDisp = conDisp)
		points( mShift$w2, mShift$w1)
	}
	
	## Draw plot labels
	box(col=in.folder$graphics.par$fg, bty='o')
	if(axes){
		par(usr = c(rev(par('usr')[1:2]), rev(par('usr')[3:4]))) 
		xlabvals <- pretty(w2Range, 10)    
		xlabvals <- c(xlabvals, par('usr')[2])
		n1 <- length(xlabvals)
		if (!is.na(in.folder$graphics.par$xtck) && 
				in.folder$graphics.par$xtck == 1)
			xlty <- 2
		else
			xlty <- 1
		if (!is.na(in.folder$graphics.par$ytck) && 
				in.folder$graphics.par$ytck == 1)
			ylty <- 2
		else
			ylty <- 1
		axis(side=1, at=min(w2Range) + (max(w2Range)-xlabvals),  
				labels = c( xlabvals[-n1], paste('    ', xlab)), lty=xlty,
				tck=in.folder$graphics.par$xtck, 
				cex.axis=in.folder$graphics.par$cex.axis)   
		ylabvals <- pretty(w1Range, 10)
		ylabvals <- c(ylabvals, par('usr')[4] )
		n1 <- length(ylabvals)
		axis(side=2, at=min(w1Range) + (max(w1Range) - ylabvals),  
				labels = c( ylabvals[-n1], paste('    ', ylab)), lty=ylty, 
				tck=in.folder$graphics.par$ytck, 
				cex.axis=in.folder$graphics.par$cex.axis) 
		par(usr = c(rev(par('usr')[1:2]), rev(par('usr')[3:4]))) 
	}
}

## Internal graphics function persp2D
## Generates a 3D perspective plot of a 2D NMR spectrum
##in.folder - Header of the file to be plotted, default is current spectrum
##w1Range - Chemical shift range in the indirect dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)          
##w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
##color   - main color for the plot 
##xlab    - x axis label, default is the direct detected nucleus in PPM
##ylab    - y axis label, default is the indirect detected nucleus in PPM
##main    - main title for plot, default is the file name
##axes      - logical argument, TRUE plots axis labels
##...       - Additinal graphics paramaters can be passed to par()
##returns   - a 3D perspective plot of a 2D NMR spectrum   
persp2D <- function (
		in.folder = fileFolder[[wc()]], 
		w1Range = in.folder$graphics.par$usr[3:4],
		w2Range = in.folder$graphics.par$usr[1:2], 
		color = in.folder$graphics.par$pos.color,
		xlab = paste(in.folder$file.par$nucleus[2], 'PPM', sep=' '),
		ylab = paste(in.folder$file.par$nucleus[1], 'PPM', sep=' '),
		main = in.folder$file.par$user_title,                     
		axes = TRUE, expand = .25, r = 10, ...){
	
	## Find the total number tiles that will have to be read
	in.folder$w1 <- seq(in.folder$file.par$upfield_ppm[1],
			in.folder$file.par$downfield_ppm[1],
			length.out = in.folder$file.par$matrix_size[1])
	in.folder$w2 <- seq(in.folder$file.par$upfield_ppm[2],
			in.folder$file.par$downfield_ppm[2],
			length.out = in.folder$file.par$matrix_size[2])
	w1Range <- sort(w1Range); w2Range <- sort(w2Range)
	out <- NULL
	t1 <- findInterval(w1Range, in.folder$w1, all.inside = TRUE)
	d1 <- findInterval(w2Range, in.folder$w2, all.inside = TRUE)
	t2 <- t1 + 1; d2 <- d1 + 1
	for(i in 1:2){
		out$w1[i] <- switch( which.min(c(
								abs(w1Range[i] - in.folder$w1[t1[i]]),
								abs(w1Range[i] - in.folder$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch( which.min(c(
								abs(w2Range[i] - in.folder$w2[d1[i]]),
								abs(w2Range[i] - in.folder$w2[d2[i]]))), d1[i], d2[i])
	}
	w1Tiles <- (ceiling(out$w1[1] / in.folder$file.par$block_size[1]):
				ceiling(out$w1[2] / in.folder$file.par$block_size[1]))
	w2Tiles <- (ceiling(out$w2[1] / in.folder$file.par$block_size[2]):
				ceiling(out$w2[2] / in.folder$file.par$block_size[2]))
	
	## Redirect to contour/image plot if too much data is involved
	if((length(w1Tiles) + length(w2Tiles)) > 6 ){
		print('Perspective plots need a small spectral window, use zi()', 
				quote= FALSE)
		plot2D(in.folder = in.folder, w1Range = w1Range, w2Range = w2Range, 
				type = 'auto')
	}else{  
		## Turn axes off 
		if( !axes ){
			xlab <- ylab <- zlab <- ''
			box <- FALSE
		}else{
			box <- TRUE 
			zlab <- 'Intensity'
		}
		
		## Read data from binary
		plotFile <- ucsf2D(file.name = in.folder$file.par$file.name,
				w1Range =w1Range, w2Range = w2Range, file.par = in.folder$file.par)
		if(!is.matrix (plotFile$data) ){
			ud()
			err('Perspective plots can not be scrolled outside the plot region')			
		}
		
		## Generate the plot       
		persp(x = plotFile$w2, y = plotFile$w1, z = plotFile$data, 
				col = color, theta = in.folder$graphics.par$theta, 
				phi = in.folder$graphics.par$phi, asp = in.folder$graphics.par$asp, 
				box = box, main = main, xlab = xlab, ylab = ylab, zlab = zlab, 
				expand = expand, r = 10, ...)
	}     
}      


## Internal graphics function perspRsd
## Generates a 3D perspective plot of an RSD spectrum
##in.folder - Header of the file to be plotted, default is current spectrum
##w1Range - Chemical shift range in the indirect dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)          
##w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
##color   - main color for the plot 
##xlab    - x axis label, default is the direct detected nucleus in PPM
##ylab    - y axis label, default is the indirect detected nucleus in PPM
##main    - main title for plot, default is the file name
##axes      - logical argument, TRUE plots axis labels
##...       - Additinal graphics paramaters can be passed to par()
##returns   - a 3D perspective plot of a 2D NMR spectrum   
perspRsd <- function(in.folder=fileFolder[[wc()]], 
		w1Range=in.folder$graphics.par$usr[3:4],
		w2Range=in.folder$graphics.par$usr[1:2],
		color=in.folder$graphics.par$pos.color,
		xlab=paste(in.folder$file.par$nucleus[2], 'PPM', sep=' '),
		ylab=paste(in.folder$file.par$nucleus[1], 'PPM', sep=' '),
		main=in.folder$file.par$user_title, axes=TRUE, expand=.25, r=10, ...){
	
	## Find best w1/w2 matches	
	w1Range <- sort(w1Range)
	w2Range <- sort(w2Range)
	filePar <- in.folder$file.par
	in.folder$w1 <- seq(filePar$upfield_ppm[1], filePar$downfield_ppm[1], 
			length.out=filePar$matrix_size[1])
	in.folder$w2 <- seq(filePar$upfield_ppm[2], filePar$downfield_ppm[2], 
			length.out=filePar$matrix_size[2])
	t1 <- findInterval(w1Range, in.folder$w1, all.inside=TRUE)
	d1 <- findInterval(w2Range, in.folder$w2, all.inside=TRUE)
	t2 <- t1 + 1
	d2 <- d1 + 1
	out <- NULL
	for (i in 1:2){
		out$w1[i] <- switch(which.min(c(abs(w1Range[i] - in.folder$w1[t1[i]]),
								abs(w1Range[i] - in.folder$w1[t2[i]]))), t1[i], t2[i])
		out$w2[i] <- switch(which.min(c(abs(w2Range[i] - in.folder$w2[d1[i]]),
								abs(w2Range[i] - in.folder$w2[d2[i]]))), d1[i], d2[i])
	}
	w1Range <- c(in.folder$w1[(out$w1[1])], in.folder$w1[(out$w1[2])])
	w2Range <- c(in.folder$w2[(out$w2[1])], in.folder$w2[(out$w2[2])])
	winW1 <- in.folder$w1[(out$w1[1]:out$w1[2])]
	winW2 <- in.folder$w2[(out$w2[1]:out$w2[2])]
	
	## Find tiles that will be plotted
	tiles <- NULL
	upShifts <- filePar$block_upfield_ppms
	downShifts <- filePar$block_downfield_ppms
	blockSizes <- filePar$block_size
	for (tNum in seq_along(filePar$block_size$w1)){
		
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
	
	## Redirect to contour/image plot if too much data is involved
	if (length(tiles) > 6){
		print('Perspective plots need a small spectral window, use zi()', 
				quote=FALSE)
		plotRsd2D(in.folder=in.folder, w1Range=w1Range, w2Range=w2Range, 
				type='auto')
	}else{  
		
		## Turn axes off 
		if (!axes){
			xlab <- ylab <- zlab <- ''
			box <- FALSE
		}else{
			box <- TRUE 
			zlab <- 'Intensity'
		}
		
		## Read data from binary
		plotFile <- rsd2D(file.name=in.folder$file.par$file.name,	w1Range=w1Range, 
				w2Range=w2Range, file.par=in.folder$file.par)
		if (!is.matrix(plotFile$data)){
			ud()
			err('Perspective plots can not be scrolled outside the plot region')			
		}
		
		## Generate the plot       
		persp(x=plotFile$w2, y=plotFile$w1, z=plotFile$data, col=color, 
				theta=in.folder$graphics.par$theta, phi=in.folder$graphics.par$phi, 
				asp=in.folder$graphics.par$asp,	box=box, main=main, xlab=xlab, 
				ylab=ylab, zlab=zlab, expand=expand, r=10, ...)
	}     
} 


##Internal graphics function fillCon
##x  - Acending numeric vector
##y  - Acending numeric vector
##z  - Data matrix with x rows and y columns
##levels - Numeric vector with the breaks for the contour plot
##col - Used as a place holder for compatibility
##returns a filled contour plot
fillCon <- function(x, y, z, levels, col, ...){
	col <- NULL
	par(...)
	if(min(levels) >= 0)
		col <- topo.colors(n = length(levels)) 
	else 
		col <- cm.colors( n = length(levels))	
	if (!is.double(z)) 
		storage.mode(z) <- "double"
	.Internal(filledcontour(as.double(x), as.double(y), z, as.double(levels), 
					col = col))
}


##Internal graphics wrapper function plot1D
##Draws a 1D NMR spectrum from a binary connection  
##in.folder - Header of the file to be plotted, default is current spectrum
##w1Range - Z limits for the plot          
##w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
##col    - color for 1D data and 1D slices/projections of 2D data
##type  -  Can be 'l' (line), 'p' (points), or 'b' (both line and points)
##xlab    - x axis label, default is the appropriate nucleus in PPM
##ylab    - y axis label,default is 'intensity'
##main    - main title for plot, default is the file name
##roiMax    - logical argument, TRUE plots a point on the maximum
##            visible signal in the window
##add       - logical argument, TRUE adds new data to an existing plot, FALSE 
##            generates a new plot
##axes      - logical argument, TRUE makes pretty labels
##offset    - Numeric argument expressing the % of total z range with which to 
##            displace a spectrum. This is used to create stacked 1D spectra
##note: offset and vertical position (set by vp()) are not equivalent. 
##      vp() resets the zero point of the plot without affecting the max of the 
##      zlimit. Offset shifts a given plot up/down from the vp() specified zero.
##...       - Additinal graphics paramaters can be passed to par()
##returns   - a plot of a 2D NMR spectrum  
plot1D <- function(
		in.folder = fileFolder[[wc()]],
		w1Range=in.folder$graphics.par$usr[3:4],
		w2Range=in.folder$graphics.par$usr[1:2],
		col = in.folder$graphics.par$proj.color, 
		type = in.folder$graphics.par$type,
		xlab = NULL, ylab = NULL,
		main = in.folder$file.par$user_title,
		roiMax = globalSettings$roiMax,
		add = FALSE, axes = TRUE, offset = 0, ... ){
	
	## Remove any non line types
	if(!any(type == c('l', 'b', 'p')))
		type <- 'l'
	
	## Redirect 2D NMR data to slice/projection function
	if(in.folder$file.par$number_dimensions > 1 )
		proj1D(in.folder = in.folder, w1Range = w1Range, w2Range = w2Range,
				col = col, main = main, add = add, axes = axes, type = type, ...)
	else{
		
		## Force vertical position for all 1D plots
		w1Range <- c(in.folder$file.par$zero_offset - 
						(w1Range[2] - in.folder$file.par$zero_offset) * 
						globalSettings$position.1D, w1Range[2])
		
		## Expand w1Range by offset
		col <- col
		offset <- diff(w1Range) * (offset / 100)
		
		## Erase old plot if add is false
		if(!add){
			w2Range <- sort(w2Range) 
			if(is.null(xlab))
				xlab <- paste(in.folder$file.par$nucleus[1]) #, 'PPM', sep=' ')
			if(is.null(ylab))
				ylab <- 'Intensity'
			plot(0,0, axes=FALSE, type = 'n', xlab = xlab, ylab = ylab,
					main=main, xaxs='i',yaxs='i')
			par(usr = c(w2Range[2:1],w1Range[1:2]))
			rect(w2Range[2], w1Range[1], w2Range[1], w1Range[2], 
					col = 'grey', border = NA)
			rect(in.folder$file.par$downfield_ppm[1], w1Range[1], 
					in.folder$file.par$upfield_ppm[1], w1Range[2], 
					col= in.folder$graphics.par$bg, border = NA)	
		}
		
		## Draw plot labels
		if(!(add)){
			box(col=in.folder$graphics.par$fg, bty='o')
			if(axes){
				par(usr = c(rev(par('usr')[1:2]),par('usr')[3:4])) 
				xlabvals <- pretty(w2Range, 10)
				xlabvals <- c(xlabvals, par('usr')[2])
				n1 <- length(xlabvals)
				if (!is.na(in.folder$graphics.par$xtck) && 
						in.folder$graphics.par$xtck == 1)
					xlty <- 2
				else
					xlty <- 1
				if (!is.na(in.folder$graphics.par$ytck) && 
						in.folder$graphics.par$ytck == 1)
					ylty <- 2
				else
					ylty <- 1
				axis(side=1, at=min(w2Range) + (max(w2Range)-xlabvals),  
						labels = c( xlabvals[-n1], paste('    ', xlab)), lty=xlty, 
						tck=in.folder$graphics.par$xtck, 
						cex.axis=in.folder$graphics.par$cex.axis)     
				axis(side=2, lty=ylty, tck=in.folder$graphics.par$ytck, 
						cex.axis=in.folder$graphics.par$cex.axis)
				par(usr = c(rev(par('usr')[1:2]),par('usr')[3:4]))
			}
		}
		
		## Read new dataset and plot
		if( is.null(c(in.folder$data, in.folder$w2)) ){
			new.folder <- ucsf1D(file.name = in.folder$file.par$file.name,
					w2Range = w2Range, file.par = in.folder$file.par)
			in.folder$file.par <- new.folder$file.par
			in.folder$w2 <- new.folder$w2
			in.folder$data <- new.folder$data
		}
		lines(x=in.folder$w2, y=rev(in.folder$data) + offset, col=col, type=type)
		if( roiMax &&  dev.cur() != 2 ){
			mShift <- maxShift( in.folder )
			points( mShift$w2, mShift$Height)
		}
	}
}

## Internal graphics function proj1D
## Projects 2D spectrum into a single dimension
## in.folder - Header from which projection data should be derived, by default 
##            data is derived from the current spectrum
## w1Range - Chemical shift range in the indirect dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)          
## w2Range - Chemical shift range in the direct dimension, default is the most
##          recent setting used with the file, the format is c(lower,upper)
## col    - color for 1D data and 1D slices/projections of 2D data
## proj.direct - 1 projects data across the direct axis, 2 across the indirect
## filter    - A vector capable function (e.g. min, max, sd) to filter data, 
##            non function arguments prompt users to select a slice 
## type - The type of plot, 'l' = lines, 'p' = points, 'b' = lines and points
## xy   - x and y coordinates can be passed from locator(1)
## ... - additional arguments can be passed to higher level functions (i.e - 
##			drawNMR), but are only present here to prevent argument mismatches
## returns the 1D trace/projection of the current spectrum
proj1D <- function (
		in.folder = fileFolder[[wc()]], 
		w1Range = in.folder$graphics.par$usr[3:4],
		w2Range = in.folder$graphics.par$usr[1:2],
		col = in.folder$graphics.par$proj.color,
		filter = globalSettings$filter,
		proj.direct = globalSettings$proj.direct,
		type = globalSettings$proj.type,
		xy = NULL, ...){
	
	## Set chemical shift range from current spectrum
	if( in.folder$file.par$number_dimensions < 2 )
		err("1D projections can only be generated from 2D data")
	current.par <- c(in.folder$file.par, in.folder$graphics.par)
	lineCol <- fileFolder[[wc()]]$graphics.par$fg
	
	## Generate data for 1D slices
	if( !is.function(filter) ){
		
		## Have user select the slice and match click location to data
		if( is.null(xy) || length(unlist(xy)) != 2)
			xy <- locator(1)
		
		if(proj.direct  == 1 ){
			abline( h = xy$y, col=lineCol )
			w1Range <- rep(xy$y, 2)
			w2Range <- current.par$usr[1:2]
		}
		
		if(proj.direct == 2 ){
			abline(v = xy$x, col=lineCol )
			w1Range <- current.par$usr[3:4]
			w2Range <- rep(xy$x, 2)
		}
		
		## Find 1D slice
		data.folder <- ucsf2D(in.folder$file.par$file.name, w1Range = w1Range,
				w2Range=w2Range, file.par = in.folder$file.par)
		
		## Generate data for projections
	}else{
		
		## Read 2D file
		data.folder <- ucsf2D(in.folder$file.par$file.name, w1Range = w1Range,
				w2Range=w2Range, file.par = in.folder$file.par)
		
		## Generate projection
		data.folder$data <- apply(data.folder$data, proj.direct, filter)
	}
	
	## Set z limits for new plot
	zlim <- c( 0, current.par$clevel * current.par$nlevels *
					current.par$noise_est )
	zlim[1] <- current.par$zero_offset - (zlim[2] - current.par$zero_offset) * 
			globalSettings$position.1D
	
	## Setup outgoing file folder
	if( proj.direct == 1){
		in.folder$data <- data.folder$data
		in.folder$w2 <- data.folder$w2	
		newRange <- c( sort(current.par$usr[1:2], decreasing = TRUE), zlim )
		
	}else{
		in.folder$w2 <- data.folder$data
		in.folder$data <- data.folder$w1	
		newRange <- c( zlim, sort(current.par$usr[3:4], decreasing = TRUE) )
	}
	in.folder$file.par$number_dimensions <- 1
	in.folder$graphics.par$usr <- newRange
	op <- par('usr')
	par( usr = newRange )
	
	## Plot the slice/projection
	plot1D(in.folder, add = TRUE, col = col, type = type)
	par(usr = op)
	bringFocus(-1) 
	return(invisible(data.folder))
	
}


## Finds the absolute max of a vector but returns original sign
## This function is the default for proj1D
pseudo1D <- function(x){range(x)[which.max(abs(range(x)))]}


################################################################################
##                                                                            ##
##                   Plotting functions for users                             ##
##                                                                            ##
################################################################################

## User file function fo
## Opens a sparky format spectrum or multiple spectra and generates a plot
## fileName - character string or vector; full pathname for file(s) to be opened
## ...  - Additional plotting options can be passed to drawNMR and par()
fo <- function(fileName, ...){
	
	## Create any/all of the rNMR objects that are missing
	createObj()
	
	## Have user select all files they wish to open
	if (missing(fileName)){
		usrList <- sort(myOpen())
		if(!length(usrList) || !nzchar(usrList))
			return(invisible())
	}else
		usrList <- fileName
	
	## Read selected files
	errors <- FALSE
	fileNames <- names(fileFolder)
	userTitles <- NULL
	if (!is.null(fileFolder))
		userTitles <- sapply(fileFolder, function(x) x$file.par$user_title)
	for( i in 1:length(usrList) ){
		
		##Read Sparky Header and file info from binary
		if( length(usrList) == 1 ){
			new.file <- tryCatch(ucsfHead(file.name=usrList[i], print.info=TRUE), 
					error=function(er){
						errors <<- TRUE
						return(er$message)})
			if (errors)
				err(new.file)
		}else{
			new.file <- tryCatch(ucsfHead(file.name=usrList[i], print.info=FALSE), 
					error=function(er){
						errors <<- TRUE
						paste('\nOpening file "', basename(usrList[i]), '" produced an', 
								' error:\n"', er$message, '"', sep='')
					})
			if (!is.list(new.file)){
				cat(new.file, '\n\n')
				flush.console()
				next()
			}
		}
		
		## Make sure input files are of the correct format
		if( length(new.file$file.par) == 0 ){
			print( paste('ERROR:', basename(usrList)[i], "is unreadable" ), 
					quote=FALSE)
			flush.console()
			next()			
		}
		
		## Fetch the default graphics settings 
		new.file$graphics.par <- defaultSettings
		
		## Set initial plotting range
		if( new.file$file.par$number_dimensions == 1 ) {
			new.file$graphics.par$usr <- c( new.file$file.par$downfield_ppm[1],
					new.file$file.par$upfield_ppm[1], 
					new.file$file.par$zero_offset - 
							(new.file$file.par$max_intensity - new.file$file.par$zero_offset) 
							* globalSettings$position.1D,
					new.file$file.par$max_intensity )
		}else{         
			new.file$graphics.par$usr <- c( new.file$file.par$downfield_ppm[2],
					new.file$file.par$upfield_ppm[2], 
					new.file$file.par$downfield_ppm[1],
					new.file$file.par$upfield_ppm[1] )
		}    
		
		## Make a new entry in the file folder if file is not already present 
		filePar <- new.file$file.par
		if(!new.file$file.par$file.name %in% fileNames){
			
			## Add 1D/2D spectra to the file folder
			if (new.file$file.par$number_dimensions < 3){
				if (new.file$file.par$user_title %in% userTitles)
					new.file$file.par$user_title <- new.file$file.par$file.name
				fileFolder[[(length(fileFolder) + 1)]] <- new.file
				names(fileFolder)[length(fileFolder)] <- new.file$file.par$file.name
			}else{
				
				## Make duplicate entries in fileFolder for each z-slice in 3D spectra
				w3 <- seq(filePar$upfield_ppm[3], filePar$downfield_ppm[3], 
						length.out=filePar$matrix_size[3])
				for (j in seq_along(w3)){
					userTitle <- paste(basename(filePar$file.name), ' (z=', w3[j], ')', 
							sep='')
					new.file$file.par$user_title <- userTitle
					new.file$file.par$z_value <- w3[j]
					fileFolder[[length(fileFolder) + 1]] <- new.file					
					names(fileFolder)[length(fileFolder)] <- userTitle
				}
			}
		}else{
			
			## Update fileFolder entry if file is already present in fileFolder
			fLoc <- match(new.file$file.par$file.name, fileNames)
			if (new.file$file.par$number_dimensions < 3){
				fileFolder[[fLoc]] <- new.file
				if (new.file$file.par$user_title %in% userTitles)
					new.file$file.par$user_title <- new.file$file.par$file.name
			}else{
				for (j in fLoc){
					zVal <- fileFolder[[j]]$file.par$z_value
					new.file$file.par$user_title <- paste(basename(filePar$file.name), 
							' (z=', zVal, ')', sep='')
					new.file$file.par$z_value <- zVal
					fileFolder[[j]] <- new.file
				}
			}
		}
		
		## Reassign currentSpectrum
		if (new.file$file.par$number_dimensions < 3)
			currentSpectrum <- new.file$file.par$file.name
		else
			currentSpectrum <- userTitle
		
		## Tell user which files have been loaded
		print( basename(usrList)[i], quote = FALSE )
		flush.console()
	}
	
	## Assign the new objects to the global environment
	myAssign("fileFolder", fileFolder, save.backup = FALSE)
	myAssign("currentSpectrum", currentSpectrum, save.backup = FALSE)
	
	## Save an undo point and refresh the active graphics
	if( !is.null(fileFolder) ){
		myAssign("currentSpectrum", currentSpectrum, save.backup = TRUE)
		refresh(...)   
	}
	
	##display error dialog
	if (errors)
		myMsg(paste('Errors occurred while opening files ',
						'Check the R console for details.', sep='\n'), icon='error')
	
	return(invisible(usrList))
}

## User file function fc
## Closes a user defined file from a list
## usrList - character string/vector; files to close
fc <- function(usrList=NULL){
	
	## Make list of all files
	current <- wc()
	allFiles <- names(fileFolder)    
	fileNames <- getTitles(allFiles, FALSE)
	
	## Have user select files to close   
	if (is.null(usrList)){
		usrList <- mySelect(fileNames, multi=TRUE, title='Select files to close:', 
				index=TRUE, preselect=fileNames[current])
		if ( length(usrList) == 0 || !nzchar(usrList) )
			return(invisible())
	}else{
		usrList <- as.vector(na.omit(match(usrList, allFiles)))
		if (!length(usrList))
			return(invisible())
	}
	
	## Reassign current spectrum if current is being deleted
	redraw <- FALSE
	if( !is.na(match(current, usrList)) ){
		redraw <- TRUE
		
		allFiles <- 1:length(allFiles)
		allFiles <- allFiles[-usrList]
		
		new.current <- rev(allFiles[allFiles < current])[1]
		if(is.na(new.current))
			new.current <- allFiles[allFiles > current][1]
		if(is.na(new.current))
			myAssign("currentSpectrum", NULL, save.backup = FALSE)
		else
			myAssign("currentSpectrum", names(fileFolder)[new.current],  
					save.backup = FALSE)
	}
	
	## Remove selected files from the overlay list
	if( !is.null(overlayList) ){
		oldOl <- match( names(fileFolder)[usrList], overlayList )
		if( any(is.na(oldOl)) ) 
			oldOl <- oldOl[ -which(is.na(oldOl)) ]
		if( length(oldOl) > 0 ){
			overlayList <- overlayList[ -oldOl ]
			if( length( overlayList) == 0 )
				overlayList <- NULL
			redraw <- TRUE    
			myAssign('overlayList', overlayList , save.backup = FALSE)			
		}
	}
	
	
	## Delete user selected files from file folder      
	fileFolder <- fileFolder[-usrList]
	if(length(fileFolder) == 0){
		fileFolder <- NULL
		redraw <- FALSE
		print('The file folder is now empty', quote = FALSE )
		
		if(length(which(dev.list() == 2)) == 1){
			dev.set(which = 2)
			plot(1, 1, col='transparent', axes=FALSE, xlab='', ylab='')
			text(1, 1, 'No files are open.\nUse fo()', cex=1)            
			
		}
		
		if(length(which(dev.list() == 3)) == 1){
			dev.set(which = 3)
			plot(1, 1, col='transparent', axes=FALSE, xlab='', ylab='')
			text(1, 1, 'ROIs will apear here \nuse roi() to designate an ROI', 
					cex=1)       
		}
		
		if(length(which(dev.list() == 4)) == 1){
			dev.set(which = 4)          
			plot(1, 1, col='transparent', axes=FALSE, xlab='', ylab='')
			text(1, 1, 'Active ROIs will appear here \nuse rs()', cex=1) 
		}
		
		## Leave main plot window and console active
		if(length(which(dev.list() == 2)) == 1)          
			dev.set(which = 2)
		bringFocus(-1)
	}
	
	## Assign fileFolder and save backup
	if ( !redraw )
		myAssign('fileFolder', fileFolder)
	else{
		myAssign('fileFolder', fileFolder, save.backup = FALSE)
		myAssign('currentSpectrum', currentSpectrum, save.backup = TRUE)
	}
	
	## Refresh open plots
	if(exists('fileFolder') && !is.null(fileFolder)){
		if( redraw )
			refresh()
		else
			refresh(main.plot = FALSE, sub.plot = FALSE)
	}        
}

## User file function ss
## Switch the active spectrum to another file in memory
## ...  - Additional plotting options can be passed to drawNMR and par()
ss <- function(...){
	
	##Generate a list of file names    
	current <- wc()
	fileNames <- getTitles(names(fileFolder), FALSE)
	
	##Have the user select a spectrum
	usrList <- mySelect(fileNames, multi=FALSE, preselect = fileNames[current], 
			title='Select a spectrum:', index=TRUE)
	
	## Do nothing if user selects cancel
	if ( length(usrList) == 0 || !nzchar(usrList) )
		return(invisible())
	
	##Set new file as current spectrum and refresh the plots
	myAssign('currentSpectrum', names(fileFolder)[usrList])
	refresh(multi.plot = FALSE, ...)
	
}

## User graphics function ol
## Overlay open spectra onto the current spectrum
## askUser - Logical argument, TRUE opens the overlay GUI
## offset    - Numeric argument expressing the % of total z range with which to 
##            displace each spectrum. This is used to create stacked 1D spectra
##            and is not passed to 2D plots
## note: offset and vertical position (set by vp()) are not equivalent. 
##      vp() resets the zero point of the plot without affecting the max of the 
##      zlimit. Offset shifts a given plot up/down from the vp() specified zero.
## ...  - Additional plotting options can be passed to drawNMR and par()
ol <- function(askUsr = TRUE, offset = NULL, ...){
	
	## Define current spectrum
	current <- wc()
	current.par <- fileFolder[[ current ]]$graphics.par
	c.nDim <- fileFolder[[current]]$file.par$number_dimensions
	
	## Open GUI for making overlay list
	if(!exists('overlayList') )	
		myAssign('overlayList', NULL )
	
	if(askUsr==TRUE || is.null(overlayList)){
		os('ol')
		return(invisible())
	} 
	
	## Fetch the offset parameter
	if( is.null(offset) )
		offset <- globalSettings$offset
	
	## Remove the current spectrum from the overlay list
	if(currentSpectrum %in% overlayList)
		overlayList <- overlayList[-(which( overlayList == currentSpectrum))]
	if(length(overlayList) == 0)
		return(invisible())		
	
	## Plot the overlay list
	o.nDim <- NULL
	plot.list <- fileFolder[[current]]$file.par$user_title
	if(c.nDim > 1)
		col.list <- current.par$pos.color
	else
		col.list <- current.par$proj.color	
	newset <- offset
	for(i in overlayList){
		o.nDim <- fileFolder[[i]]$file.par$number_dimensions
		
		## Overlay spectra on main plot 
		if(o.nDim == c.nDim){
			
			## Plot 2D overlay
			drawNMR(fileFolder[[i]], type=current.par$type, add = TRUE, 
					w1Range = current.par$usr[3:4], w2Range=current.par$usr[1:2],
					offset = newset, ...)	
		}else if (o.nDim == 1 && c.nDim > 1){
			
			## Read 1D file
			in.folder <- fileFolder[[i]]
			data.folder <- ucsf1D(fileFolder[[i]]$file.par$file.name)
			
			## Setup plot range
			in.folder$data <- data.folder$data
			in.folder$w2 <- data.folder$w2	
			newRange <- c(current.par$usr[1:2], min(data.folder$data), 
					max(data.folder$data))
			in.folder$graphics.par$usr <- newRange
			op <- par('usr')
			par(usr=newRange)
			
			## Plot 1D overlay
			plot1D(in.folder, add=TRUE, offset=newset,
					col=fileFolder[[i]]$graphics.par$proj.color, 
					type=fileFolder[[i]]$graphics.par$type)
			par(usr=op)
		}
		
		## Keep track of overlaid spectra
		newset <- newset + offset
		plot.list <- c(plot.list, fileFolder[[i]]$file.par$user_title)
		if(o.nDim == 1)
			col.list <- c(col.list, 
					fileFolder[[i]]$graphics.par$proj.color)
		else
			col.list <- c(col.list, 
					fileFolder[[i]]$graphics.par$pos.color)		
	}
	
	## Add a legend if there are files other than the current spectrum
	if( length(plot.list) > 1 && globalSettings$overlay.text)
		legend("topleft", rev(plot.list), pch=NULL, bty='n', 
				text.col = rev(col.list))
}

## User edit function ud
## Undo last action
ud <- function(){
	
	current <- wc()
	
	if( !exists('oldFolder') || oldFolder$undo.index < 2 ){
		cat('Cannot undo \n')
		return(invisible())
	}
	
	## Set undo index
	oldFolder$undo.index <- oldFolder$undo.index - 1 
	
	## Reset each of the global files    
	save.list <- names(oldFolder)
	for(i in 1:length(save.list)){
		if(names(oldFolder)[i] %in% c('undo.index', 'assign.index', 'zoom.list', 
				'zoom.history'))
			next()
		out.file <- oldFolder[[i]][[oldFolder$undo.index]]
		suppressWarnings( if(!length(out.file[[1]][1]) || 
						is.na( out.file[[1]][1] )) out.file <- NULL )   
		myAssign( save.list[i], out.file, save.backup = FALSE)
		
	}
	
	## Add new zoom changes to oldFolder index
	if(oldFolder$zoom.history[[oldFolder$undo.index]])
		oldFolder$zoom.list[[(length(oldFolder$zoom.list) + 1)]] <- 
				fileFolder[[wc()]]$graphics.par$usr
	
	## Save oldFolder to global environment 
	myAssign( "oldFolder", oldFolder, save.backup = FALSE) 
	refresh()  
}

## User edit function rd
## Redo last action
rd <- function(){
	
	if(!exists('oldFolder') || is.null(oldFolder$undo.index) ||  
			oldFolder$undo.index >= length(oldFolder$fileFolder) ){
		cat('Cannot redo \n')
		return(invisible())
	}
	
	## Set undo index
	oldFolder$undo.index <-  oldFolder$undo.index + 1
	
	## Reset each of the global files
	save.list <- names(oldFolder)
	for(i in 1:length(save.list)){
		if(!save.list[i] %in% c('undo.index', 'assign.index', 'zoom.list', 
				'zoom.history')){
			out.file <- oldFolder[[i]][[oldFolder$undo.index]]
			suppressWarnings( if(is.na( out.file[[1]][1] )) 	out.file <- NULL )   
			myAssign( save.list[i], out.file, save.backup = FALSE)
		}
	}
	
	## Save oldFolder to global environment 
	myAssign( "oldFolder", oldFolder, save.backup = FALSE)
	refresh()     
	
}

## Refreshes the main plot without changing settings 
## ...  - Additional plotting options can be passed to drawNMR and par() 
dd <- function (...) {
	
	##Redraw the open spectra
	refresh(sub.plot = FALSE, multi.plot = FALSE, ...)
}

## Redraws the plot with the graphic type automatically set
## ...  - Additional plotting options can be passed to drawNMR and par() 
## note: this requires fo() to be used first  
da <- function (...) {
	
	setGraphics(type = 'auto')
	
	##Redraw the open spectra
	refresh(sub.plot = FALSE, multi.plot = FALSE, ...)
}

## Redraws the plot as an image map 
## ...  - Additional plotting options can be passed to drawNMR and par() 
## note: this requires fo() to be used first  
di <- function (...) {
	
	setGraphics(type = 'image')
	
	##Redraw the open spectra
	refresh(sub.plot = FALSE, multi.plot = FALSE, ...)
}

## Redraws the plot as a contour plot
## ...  - Additional plotting options can be passed to drawNMR and par() 
## note: this requires fo() to be used first
dr <- function (nlevels=20, ...) {
	
	setGraphics(type = 'contour', nlevels=nlevels)
	
	## redraw the current spectrum
	refresh(sub.plot = FALSE, multi.plot = FALSE, ...)
}

## Redraws the plot as a filled contour map
## ...  - Additional plotting options can be passed to drawNMR and par() 
## note: this requires fo() to be used first
drf <- function (...) {
	
	setGraphics(type='filled')
	
	## Draw the new spectrum                    
	refresh(sub.plot = FALSE, multi.plot = FALSE, ...)
}

## Draws the image as a perspective plot
## ...  - Additional plotting options can be passed to drawNMR and par() 
## note: this requires fo() to be used first
dp <- function (...) {
	
	setGraphics(type='persp')
	
	## Draw the new spectrum                    
	refresh(overlay = FALSE, sub.plot = FALSE, multi.plot = FALSE, ...)
	
}

## Rotates a perspective plot clockwise
## ...  - Additional plotting options can be passed to drawNMR and par()
rotc <- function(degrees = 10, ...){
	
	current <- wc()
	newRot <- fileFolder[[current]]$graphics.par$theta + degrees
	setGraphics(type='persp', theta = newRot)
	
	## Draw the new spectrum                    
	refresh(overlay = FALSE, sub.plot = FALSE, multi.plot = FALSE, ...)
}

## Rotates a perspective plot counter clockwise
## ...  - Additional plotting options can be passed to drawNMR and par()
rotcc <- function(degrees = 10, ...){
	rotc (degrees = -degrees, ...)
}

## Rotates a perspective plot up
## ...  - Additional plotting options can be passed to drawNMR and par()
rotu <- function(degrees = 10, ...){
	
	current <- wc()
	newRot <- fileFolder[[current]]$graphics.par$phi + degrees
	setGraphics(type='persp', phi = newRot)
	
	## Draw the new spectrum                    
	refresh(overlay = FALSE, sub.plot = FALSE, multi.plot = FALSE, ...)
}

## Rotates a perspective plot down
## ...  - Additional plotting options can be passed to drawNMR and par()  
rotd <- function(degrees = 10, ...){
	rotu(degrees = -degrees, ...)
}

## Rotates a perspective plot 360 degrees in steps of 10 degrees
## ...  - Additional plotting options can be passed to drawNMR and par() 
spin <- function (...){
	degrees <- 10
	current <- wc()
	for( i in 1:36){
		newRot <- fileFolder[[current]]$graphics.par$theta + degrees
		setGraphics(type='persp', theta = newRot, save.backup = FALSE )
		refresh(overlay = FALSE, sub.plot = FALSE, multi.plot = FALSE, ...)
	}
}

## User function vp
## Sets the vertical position of all 1D spectra and slices
## position - numeric value between 0 and 100 that expresses the percentage of 
##          the visible range shown below the mean spectral noise level.
##					The default value 5, creates plots with 5% of the intensity range
##          below the average noise.
## note: if no offset is given, then the current vertical offset is returned
## note2: This function modifies all of the open spectra 
## returns refreshed plots with new vertical positions if offset is not NULL or
##         the current vertical offset if offset is NULL
vp <- function(position = NULL){
	
	
	## Print the current vertical position if offset is NULL
	if(is.null(position)){
		
		position <- globalSettings$position.1D	
		if(position <= 1)
			position <- (position) / 2 * 100
		else
			position <- 100 - (1 / position) * 50 
		print('Current vertical position:', quote = FALSE)
		return(position)
	}
	
	## Check for valid offset values
	if(is.na(suppressWarnings(as.integer(position))) || position < 0 || 
			position >= 100)
		err('Vertical position value must be between 0 and 100 (5 is the default)')
	
	## Update vertical position with new offset values
	if(position <= 50)
		position <- position / 50
	else
		position <- .5 / ((100 - position ) / 100) 
	
	setGraphics( position.1D = position, refresh.graphics = TRUE)					
} 

## User function vpu
## Increases vertical position of all 1D spectra and slices
## p - numeric value between 0 and 100; the amount to increase the 
##	vertical position by
vpu <- function(p=5){
	
	## Check for valid offset values
	if(is.na(suppressWarnings(as.integer(p))) || p < 0 || 
			p >= 100)
		err('Vertical position value must be between 0 and 100 (5 is the default)')
	
	## Update vertical position with new offset values
	if (p <= 50)
		p <- p / 50
	else
		p <- .5 / ((100 - p ) / 100) 
	
	prevPos <- globalSettings$position.1D		
	setGraphics(position.1D=prevPos + p, refresh.graphics=TRUE)					
} 

## User function vpd
## Decreases vertical position of all 1D spectra and slices
## p - numeric value between 0 and 100; the amount to decrease the 
##	vertical position by
vpd <- function(p=5){
	
	## Check for valid offset values
	if(is.na(suppressWarnings(as.integer(p))) || p < 0 || 
			p >= 100)
		err('Vertical position value must be between 0 and 100 (5 is the default)')
	
	## Update vertical position with new offset values
	if (p <= 50)
		p <- p / 50
	else
		p <- .5 / ((100 - p ) / 100) 
	
	prevPos <- globalSettings$position.1D		
	setGraphics(position.1D=prevPos - p, refresh.graphics=TRUE)					
}


################################################################################
#                                                                              #
#                        Internal zoom functions                               #
#                                                                              #
################################################################################  

## Internal utility function newRange
## Returns an expanded or contracted range
## x  - a optional numeric list from which range is calculated
## r  - A numeric range (length 2) to be extended or contracted
## f  - Numeric expansion/contraction factor, positive values are treated
##      as an expansion factor, negative values are treated as a contraction
##      factor. 
## checkF - logical; if TRUE values less than -1 will be reset to .9999
## returns a new numeric range of length two
newRange <- function(x, r = range(x, na.rm = TRUE), f = 0.05, checkF = TRUE){
	
	## Error checking
	f <- suppressWarnings(as.numeric(f))
	if( is.na(f) )
		stop('The new range factor must be numeric')
	r <- suppressWarnings(as.numeric(r))
	if( any(is.na(r)) || length(r) != 2 )
		stop('Only numeric ranges can be used')	
	f <- f/2
	
	## Change range
	if( f > 0 )
		return(r + c(-f, f) * diff(r))
	if( f < 0 ){
		f <- -f
		if( checkF && f > 1 )
			f <- 0.4999
		return( r - c(-f, f) * diff(r) )		
	}
	
	return(r)
}

## Internal function pan
## direction - can be set to 'u', 'd', 'l' or 'r' for up, down, left or right,
##             these valuse can also be combined in a list input: c('l', 'u')
## p         - Numeric argument, percentage of the current window to move 
## save.backup - Logical argument, TRUE saves an undo point
## ... - Additional parameters can be passed to drawNMR
pan <- function( direction, p = 5, save.backup = TRUE, ...){
	
	## Error checking
	if(missing(direction))
		err("No pan direction was provided")
	if( all( is.na(match(direction, c('u', 'd', 'l', 'r'))) ))
		err("The pan direction must be set to u, d, l, or r")
	p <- suppressWarnings(as.numeric(p))
	if( is.na(p) )
		err('The panning percentage must be numeric')
	
	## Define current
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	usr <- fileFolder[[current]]$graphics.par$usr
	p <- p/100
	
	## Set new window
	if( any(direction == 'r' ))
		usr[1:2] <- usr[1:2] - p * diff( sort(usr[1:2]) )
	if( any(direction == 'l' ))
		usr[1:2] <- usr[1:2] - (-p) * diff( sort(usr[1:2]) )	
	if( any(direction == 'u' )){
		if(nDim > 1)
			usr[3:4] <- usr[3:4] - p * diff( sort(usr[3:4]) )
		else
			usr[4] <- max(usr[3:4]) + p * max(usr[3:4])
	}
	if( any(direction == 'd' )){
		if(nDim > 1)
			usr[3:4] <- usr[3:4] - (-p) * diff( sort(usr[3:4]) )
		else
			usr[4] <- max(usr[3:4]) + (-p) * max(usr[3:4])
	}
	
	## Assign the new window and refresh
	setGraphics( usr = usr, save.backup = save.backup )
	refresh(  sub.plot = FALSE, multi.plot = FALSE, ...)
	
} 


################################################################################
#                                                                              #
#                     2D zoom functions for users                              #
#                                                                              #
################################################################################  

## User zoom function zp
## Zoom the plot to previous zoom set
zp <- function(){
	current <- wc()
	zoom.par <- oldFolder$zoom.list
	usr <- unlist(rev(zoom.par)[2])
	
	## Check for valid previous zoom
	if(length( zoom.par ) > 1 && !is.null(usr) && !is.na(usr) ){
		fileFolder[[current]]$graphics.par$usr <- usr
		myAssign('zoom', fileFolder)
		
		oldFolder$zoom.list <- zoom.par[-(length(zoom.par))]   
		myAssign("oldFolder", oldFolder, save.backup = FALSE)
		refresh(sub.plot = FALSE, multi.plot = FALSE)
	}else
		print('Cannot zoom previous', quote=FALSE)
}

## User zoom function zi
## Zooms the plot in to a narrower chemical shift range
## p  - The percentage reduction in range to be applied
## ...  - Additional plotting options can be passed to drawNMR and par()
zi <- function ( p = 25, ...) {
	
	p <- suppressWarnings(as.numeric(p))
	if( is.na(p) )
		err('The zoom factor must be numeric')
	if (p > 100)
		err('The zoom factor may not exceed 100')
	
	## Find current parameters
	current <- wc()
	usr <- fileFolder[[current]]$graphics.par$usr 
	
	## Set new Ranges
	usr[1:2] <- rev(sort(newRange(usr[1:2], f = -p/100)))
	if(fileFolder[[current]]$file.par$number_dimensions > 1)
		usr[3:4] <- rev(sort(newRange(usr[3:4], f = -p/100)))	
	
	## Draw the new spectrum                    
	setGraphics( usr = usr )
	refresh(sub.plot = FALSE, multi.plot = FALSE, ...)
}

## User zoom function zo
## Zooms the plot in to a wider chemical shift range
## p  - The fractional reduction in range to be applied
## ...  - Additional plotting options can be passed to drawNMR and par()
zo <- function (p = 25, ...) {
	zi( p = -p, ...)
}

## User pan function pr
## Pans spectrum to the right
## p   - The percentage of the current window to move the window
## ... - Additional parameters can be passed to drawNMR
pr <- function( p = 5, ... ){
	
	pan( direction = 'r', p = p, ...)
	
}

## User pan function pl
## Pans spectrum to the left
## p   - The percentage of the current window to move the window
## ... - Additional parameters can be passed to drawNMR
pl <- function( p = 5, ...){
	
	pan( direction = 'l', p = p, ...)
	
}

## User pan function pu
## Pans spectrum up
## p   - The percentage of the current window to move the window
## ... - Additional parameters can be passed to drawNMR
pu <- function( p = 5, ... ){
	
	pan( direction = 'u', p = p, ...)
	
}

## User pan function pd
## Pans spectrum down
## p   - The percentage of the current window to move the window
## ... - Additional parameters can be passed to drawNMR
pd <- function( p = 5, ... ){
	
	pan( direction = 'd', p = p, ...)
	
}

## Redraws spectrum at full chemical shift range as an image
## ...  - Additional plotting options can be passed to drawNMR and par()
ff <- zf <- function (...) {
	## Find current spectrum
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	
	## Reset chemical shift range
	if(nDim > 1){
		fileFolder[[current]]$graphics.par$usr = c(
				fileFolder[[current]]$file.par$downfield_ppm[2],
				fileFolder[[current]]$file.par$upfield_ppm[2],
				fileFolder[[current]]$file.par$downfield_ppm[1],
				fileFolder[[current]]$file.par$upfield_ppm[1])
	}else{
		fileFolder[[current]]$graphics.par$usr <- c( 
				fileFolder[[current]]$file.par$downfield_ppm[1],
				fileFolder[[current]]$file.par$upfield_ppm[1], 
				fileFolder[[current]]$file.par$zero_offset - 
						(fileFolder[[current]]$file.par$max_intensity - 
							fileFolder[[current]]$file.par$zero_offset) 
						* globalSettings$position.1D,
				fileFolder[[current]]$file.par$max_intensity )
	}                   
	
	## Draw the new spectrum                    
	myAssign('zoom', fileFolder)
	refresh(sub.plot = FALSE, multi.plot = FALSE, ...) 
}

## User zoom/pan function zz
## Interactive click zooming and panning
## ...  - Additional plotting options can be passed to drawNMR and pan 
zz <- function (...) {
	
	current <- wc() 
	lineCol <- fileFolder[[current]]$graphics.par$fg
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	
	## Opens the main plot window if not currently opened
	if (is.na(match(2, dev.list())))
		refresh(multi.plot=FALSE, sub.plot=FALSE)
	cw(dev=2)
	
	## Give the user some instructions
	cat(paste('In the main plot window:\n',  
					' Left-click two points inside the plot to zoom\n',  
					' Left-click outside the plot to pan\n', 
					' Right-click to exit\n'))
	flush.console()
	hideGui()
	
	while(TRUE){
		
		## Tell the user what to do
		op <- par('font')
		par( font = 2 )
		legend("topleft", c('LEFT CLICK TO ZOOM','RIGHT CLICK TO EXIT'), 
				pch=NULL, bty='n', text.col=lineCol)
		par(font = op)
		
		xy <- data.frame(locator(1))
		if(length(xy) == 0)
			break()
		
		## Pan if click is outside the plotting range
		direction <- NULL
		if( xy$x > fileFolder[[current]]$graphics.par$usr[1] )
			direction <- c(direction, 'l')
		if( xy$x < fileFolder[[current]]$graphics.par$usr[2] )
			direction <- c(direction, 'r')		
		if( xy$y > max(par('usr')[3:4]) )
			direction <- c(direction, 'd')
		if( xy$y < min(par('usr')[3:4]) )
			direction <- c(direction, 'u')
		if( !is.null(direction) ){
			pan(direction = direction, save.backup = FALSE, ...)
			next()	
		}
		
		## Zoom if first click inside the plotting area	
		abline(v=xy$x, col=lineCol)
		if( nDim != 1 )
			abline(h=xy$y, col=lineCol )    
		xy2 <- data.frame(locator(1))
		if(length(xy2) == 0)
			break()
		abline(v=xy2$x, col=lineCol)
		if (nDim != 1)
			abline(h=xy2$y, col=lineCol)   
		xy <- rbind(xy, xy2)
		
		## Do not rescale lower bound on 1D data
		if (nDim == 1){
			xy$y <- sort(xy$y)
			abline( h = xy$y[2], col=lineCol )
			xy$y[1] <- fileFolder[[current]]$file.par$zero_offset - 
					(xy$y[2] - fileFolder[[current]]$file.par$zero_offset) * 
					globalSettings$position.1D
		}else
			xy$y <- rev(sort(xy$y))
		
		## Assign the new plotting regions and refresh
		setGraphics( usr = c(rev(sort(xy$x)), xy$y), save.backup = FALSE )	
		refresh(sub.plot = FALSE, multi.plot = FALSE, ...)
	}
	
	## Assign the new plotting regions to the correct file
	showGui()
	myAssign("zoom", fileFolder, save.backup = TRUE)	
	refresh( sub.plot = FALSE, multi.plot = FALSE )
	
}

## Automatically zoom in on a point using mouse interface
## w1Delta  - Chemical shift range for new w1 window, NULL sets window to 
##            2.5ppm for all nuclei other than 1H and 0.25 ppm for 1H
## w2Delta  - Chemical shift range for new w2 window, NULL sets window to 
##            2.5ppm for all nuclei other than 1H and 0.25 ppm for 1H
## ...  - Additional plotting options can be passed to drawNMR and par()
pz <- function (w1Delta = NULL, w2Delta = NULL, ...) {
	
	## Find current spectrum and establish chemical shift range
	current <- wc()
	lineCol <- fileFolder[[current]]$graphics.par$fg
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	
	## Opens the main plot window if not currently opened
	if (is.na(match(2, dev.list())))
		refresh(multi.plot=FALSE, sub.plot=FALSE)
	cw(dev=2)
	
	## Give the user some instructions
	cat(paste('\nIn the main plot window:\n',  
					' Left-click to view chemical shifts\n',  
					' Right-click to exit\n\n')) 
	flush.console()
	hideGui()
	
	## Tell the user what to do
	op <- par('font')
	par(font=2)
	legend("topleft", c('LEFT CLICK TO ZOOM','RIGHT CLICK TO EXIT'), 
			pch=NULL, bty='n', text.col=lineCol)
	par(font=op)
	
	## Set the chemical shift ranges of the point zoom window
	if(is.null(w1Delta)){
		if(fileFolder[[current]]$file.par$nucleus[1] != '1H')
			w1Delta <- 2.5 / 2
		else
			w1Delta <- .1 / 2
	}
	if(nDim == 1 && is.null(w2Delta))
		w2Delta <- w1Delta
	if(is.null(w2Delta)){
		if(fileFolder[[current]]$file.par$nucleus[2] != '1H')
			w2Delta <- 2.5 / 2
		else
			w2Delta <- .1 / 2
	}
	
	## Have user locate the place to zoom
	xy=data.frame(locator(1, type='n'))
	if(length(xy) == 0){
		showGui()
		return(invisible())
	}
	abline(v=xy$x, col=lineCol )
	abline(h=xy$y, col=lineCol )
	
	## Set new chemical shift ranges
	w2Range <- c(xy$x + w2Delta, xy$x - w2Delta)
	if(nDim != 1)
		w1Range <- c(xy$y + w1Delta, xy$y - w1Delta) 
	else
		w1Range <- c(fileFolder[[current]]$file.par$zero_offset - 
						(xy$y - fileFolder[[current]]$file.par$zero_offset) * 
						globalSettings$position.1D, xy$y)
	fileFolder[[current]]$graphics.par$usr <- c(w2Range, w1Range) 
	myAssign('zoom', fileFolder)
	showGui()
	
	## Draw the new spectrum                    
	refresh(sub.plot = FALSE, multi.plot = FALSE, ...)
}

## Centers the window on the largest visable peak
## massCenter  - logical argument; TRUE centers peaks by center of mass,
##               false centers peaks by maximum signal observed
## note: graphics settings are used for choosing between negative and positive 
##       signals.
zc <- function ( massCenter = TRUE ){
	
	if( !is.logical (massCenter) ){
		massCenter = FALSE
		err('massCenter must be set to either TRUE or FALSE')
	}
	
	## Find the biggest peak in the window
	current <- wc()
	w1Range <- fileFolder[[current]]$graphics.par$usr[3:4]
	w2Range <- fileFolder[[current]]$graphics.par$usr[1:2]
	conDisp <- fileFolder[[current]]$graphics.par$conDisp
	maxRes <- maxShift( ucsf2D( file.name = currentSpectrum, 
					w1Range = w1Range, w2Range = w2Range, 
					file.par = fileFolder[[current]]$file.par ), conDisp = conDisp, 
			massCenter = massCenter )
	if(is.null(maxRes))
		return(invisible())
	
	## Set new range
	if( fileFolder[[current]]$file.par$number_dimensions != 1 )
		w1Range <- c(maxRes$w1 + abs(diff(w1Range))/2,  
				maxRes$w1 - abs(diff(w1Range))/2  )
	w2Range <- c(maxRes$w2 + abs(diff(w2Range))/2,  
			maxRes$w2 - abs(diff(w2Range))/2  ) 
	
	## Print warning or reset the window
	fileFolder[[current]]$graphics.par$usr <- c(w2Range, w1Range ) 
	myAssign('zoom', fileFolder)
	
	## Draw the new spectrum                    
	refresh(sub.plot = FALSE, multi.plot = FALSE)
}    

## Changes contours to a higher level
## n  - Number of standard deviations to raise the plotting threshold
## ...  - Additional plotting options can be passed to drawNMR and par()
ctu <- function (n = 1, ...) {
	
	## Update contour levels and recalculate the viewable tiles
	current <- wc()
	uClevel <- fileFolder[[ current ]]$graphics.par$clevel + n
	
	## Reset the graphics and refresh the open plots 
	setGraphics(clevel = uClevel)
	refresh(...)  
	
}

## Changes contours to a lower level
## n  - Number of standard deviations to decrease plotting threshold
## ...  - Additional plotting options can be passed to drawNMR and par()
ctd <- function (n = 1, ...) {
	ctu(n = -n, ...)  
}

## Find the 2D location of the pointer
## Returns chemical shifts rounded to four places
loc <- function(){
	
	current <- wc()
	lineCol <- fileFolder[[current]]$graphics.par$fg
	
	## Opens the main plot window if not currently opened
	if (is.na(match(2, dev.list())))
		refresh(multi.plot=FALSE, sub.plot=FALSE)
	cw(dev=2)
	
	## Give the user some instructions
	cat(paste('\nIn the main plot window:\n',  
					' Left-click to view chemical shifts\n',  
					' Right-click to exit\n\n')) 
	flush.console()
	hideGui()
	
	##Print chemical shifts in the console 
	if(fileFolder[[current]]$file.par$number_dimensions == 1)
		locName <- c(fileFolder[[current]]$file.par$nucleus[1], 'Intensity')
	else    
		locName <- c(fileFolder[[current]]$file.par$nucleus[2], 
				fileFolder[[current]]$file.par$nucleus[1]) 
	
	i <- 1
	out <- NULL
	while(TRUE){
		
		## Tell the user what to do
		op <- par('font')
		par( font = 2 )
		legend("topleft", c('LEFT CLICK FOR SHIFTS','RIGHT CLICK TO EXIT'), 
				pch=NULL, bty='n', text.col=lineCol)
		par(font = op)
		
		xy = data.frame(locator(1, type='n'))
		if(length(xy) == 0)		
			break()
		if( i > 1 )
			refresh( sub.plot = FALSE, multi.plot = FALSE)
		abline( v = xy$x, h = xy$y )
		
		if( i == 1)
			cat('\n', locName, '\n')
		
		cat(unlist(round(xy, 4)), '\n')
		i <- 2
		out <- xy
		
		flush.console()
	}
	
	#return focus to console and print	
	showGui()
	if(!is.null(out))
		names(out) <- locName
	refresh( sub.plot = FALSE, multi.plot = FALSE)
	invisible(out)
}

## Find the chemical shift range in Hz and PPM between user-defined points
## Returns the difference between points in Hz and PPM rounded to four places
delta <- function(){
	
	current <- wc()
	lineCol <- fileFolder[[current]]$graphics.par$fg
	
	## Opens the main plot window if not currently opened
	if (is.na(match(2, dev.list())))
		refresh(multi.plot=FALSE, sub.plot=FALSE)
	cw(dev=2)
	
	## Give the user some instructions
	cat(paste('\nIn the main plot window:\n',  
					' Left-click on two points\n',  
					' Right-click to exit\n\n')) 
	flush.console()
	hideGui()
	
	##Print chemical shifts in the console
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	if( nDim == 1 ){
		locName <- c(fileFolder[[current]]$file.par$nucleus[1], 'Intensity')
		
		
	}else{
		locName <- c(fileFolder[[current]]$file.par$nucleus[2], 
				fileFolder[[current]]$file.par$nucleus[1]) 		
	}    
	
	out <- NULL
	i <- j <- 1
	while(TRUE){
		
		## Tell the user what to do
		op <- par('font')
		par( font = 2 )
		legend("topleft", c('LEFT CLICK FOR DELTA','RIGHT CLICK TO EXIT'), 
				pch=NULL, bty='n', text.col=lineCol)
		par(font = op)
		
		## Let user select locations on spectrum
		xy <- data.frame(locator(1, type='n'))
		if(length(xy) == 0)		
			break()
		if( i == 1 && j > 1)
			refresh( sub.plot = FALSE, multi.plot = FALSE)
		
		## Show selected points with ablines
		abline( v = xy$x, h = xy$y)
		j <- 2
		
		## Create the output table for printing chemical shift deltas
		if( i == 1 ){
			out <- xy
			i <- 2
			next()
		}
		
		out <- rbind(out, xy)
		names(out) <- locName	
		
		out <- round(rbind( abs(out[1,]-out[2,]), abs(out[1,]-out[2,]) * 
								rev(fileFolder[[wc()]]$file.par$transmitter_MHz) ), 4)
		row.names(out) <- c('PPM', 'Hz')
		if( nDim == 1 )
			out[2,2] <- NA
		print(out)
		flush.console()
		i <- 1
	}
	
	#return focus to console 	
	showGui()
	if(!is.null(out))
		names(out) <- locName
	refresh( sub.plot = FALSE, multi.plot = FALSE)
	invisible(out)
}

################################################################################
##                                                                            ##
##                   1D projection functions for users                        ##
##                                                                            ##
################################################################################

## View 1D slice of 2D spectrum
## proj.direct  - Integer of value 1 or 2 indicating the direction of the slice;
##                1 returns direct slices, 2 returns indirect slices
## ...  - Additional plotting options can be passed to draw1D, par, and proj1D
vs <- function (proj.direct = NULL, ...) {
	
	## Stop if current spectrum is not 2D
	current <- wc()
	lineCol <- fileFolder[[current]]$graphics.par$fg
	in.folder <- fileFolder[[current]]
	if( in.folder$file.par$number_dimensions < 2 )
		err("Only 2D data can be projected into 1D")
	
	## Have user define slice dimension 
	if (!any(proj.direct == c(1,2))){
		usrSel <- mySelect(c('Direct dimension', 'Indirect dimension'), 
				title = 'View slices in:')
		if( length(usrSel) == 0 || !nzchar(usrSel) )
			return(invisible())
		if(usrSel == 'Direct dimension')
			proj.direct <- 1
		else
			proj.direct <- 2
	}
	
	## Opens the main plot window if not currently opened
	if (is.na(match(2, dev.list())))
		refresh(multi.plot=FALSE, sub.plot=FALSE)
	cw(dev=2)
	
	## Give the user some instructions
	cat(paste('In the main plot window:\n',  
					' Left-click inside the plot to view slice\n',  
					' Right-click to exit\n'))
	flush.console()
	hideGui()
	
	## Generate slices
	xy <- outFile <- NULL
	
	while( TRUE ){
		
		## Tell the user what to do
		op <- par('font')
		par( font = 2 )
		legend("topleft", c('LEFT CLICK FOR SLICE','RIGHT CLICK TO EXIT'), 
				pch=NULL, bty='n', text.col=lineCol)
		par(font = op)
		
		xy <- locator(1)
		if(is.null(xy))
			break()
		refresh( sub.plot = FALSE, multi.plot = FALSE)
		outFile <- proj1D( in.folder, filter = 0, 
				proj.direct = proj.direct, xy = xy, ...)
		
	}
	showGui()
	refresh( sub.plot = FALSE, multi.plot = FALSE)
	invisible(outFile)
}

## User function for toggling the 1D projection display
pjv <- function(){
	if (globalSettings$proj.mode){
		setGraphics(proj.mode=FALSE)
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		print('1D projection display off', quote=FALSE)
	}else{
		setGraphics(proj.mode=TRUE)
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		print('1D projection display on', quote=FALSE)
	}
}

################################################################################
##                                                                            ##
##               Peak picking functions for users                             ##
##                                                                            ##
################################################################################

## Peak picks full sweep width of current spectrum
pa <- function(...){
	
	## Error checking
	wc()
	
	## Peak pick active window    
	peakPick(append = FALSE, ...)
	
	## Refresh graphics and save a backup
	setGraphics(peak.disp = TRUE,  save.backup = FALSE)
	refresh(sub.plot = FALSE, multi.plot = FALSE)
	
}

## Peak picks full sweep width in all of the spectra in the file folder 
paAll <- function(...){
	
	## Error checking
	wc()
	
	## Peak pick each spectrum
	peakPick(fileName = names(fileFolder), append = FALSE, ...)
	
	## Refresh graphics and save backup copy  
	setGraphics(peak.disp = TRUE,  save.backup = FALSE)
	refresh(sub.plot = FALSE, multi.plot = FALSE)
	
}

## Peak pick a region in the current spectrum
## fileName - character string or vector, names for the files to peak pick
## append  - logical, TRUE apppends new peaks to old list
pReg <- function(fileName = currentSpectrum, append = TRUE, ...){
	
	## Define the current spectrum
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	lineCol <- fileFolder[[current]]$graphics.par$fg
	
	## Opens the main plot window if not currently opened
	if (is.na(match(2, dev.list())))
		refresh(multi.plot=FALSE, sub.plot=FALSE)
	cw(dev=2)
	
	## Give the user some instructions
	hideGui()
	cat(paste('In the main plot window:\n',  
					' Left-click two points inside the plot to define region\n'))
	flush.console()
	op <- par('font')
	par(font=2)
	legend("topleft", c('LEFT CLICK TO DEFINE REGION', 'RIGHT CLICK TO CANCEL'), 
			pch=NULL, bty='n', text.col=lineCol)
	par(font=op)
	
	##define the first boundary for the region
	xy <- data.frame(locator(1))
	if (length(xy) == 0){
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		showGui()
		return(invisible())
	}
	abline(v=xy$x, col=lineCol )
	if (nDim != 1)
		abline(h=xy$y, col=lineCol )    
	
	##define other boundary for the region
	xy2 <- data.frame(locator(1))
	if (length(xy2) == 0){
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		showGui()
		return(invisible())
	}
	abline(v=xy2$x, col=lineCol )
	if (nDim != 1)
		abline(h=xy2$y, col=lineCol )   
	xy <- rbind(xy, xy2)
	
	## Peak pick region
	if (nDim == 1)
		peakPick(fileName, w2Range=c(rev(sort(xy$x))), append=append, ...)
	else
		peakPick(fileName, w1Range=c(rev(sort(xy$y))), 
				w2Range=c(rev(sort(xy$x))), append=append, ...)	
	
	## Refresh graphics
	setGraphics(peak.disp=TRUE, save.backup=FALSE)
	refresh(sub.plot = FALSE, multi.plot = FALSE)
	showGui()
}

## User function regionMax
## fileName - character string or vector; spectrum name(s) as returned by 
##						names(fileFolder)
## redraw - logical, TRUE refreshes the spectrum before exiting 
## noiseCheck - logical, TRUE excludes data below the noise threshold
## Returns chemical shifts at absolute max intensity in a user-defined region 
regionMax <- function( fileName=currentSpectrum, redraw=TRUE, noiseCheck=TRUE ){
	
	## Define the current spectrum
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	lineCol <- fileFolder[[current]]$graphics.par$fg
	
	## Opens the main plot window if not currently opened
	if (is.na(match(2, dev.list())))
		refresh(multi.plot=FALSE, sub.plot=FALSE)
	cw(dev=2)
	
	## Give the user some instructions
	hideGui()
	cat(paste('In the main plot window:\n',  
					' Left-click two points inside the plot to define region\n'))
	flush.console()
	op <- par('font')
	par(font=2)
	legend("topleft", c('LEFT CLICK TO DEFINE REGION', 'RIGHT CLICK TO CANCEL'), 
			pch=NULL, bty='n', text.col=lineCol)
	par(font=op)
	
	##define the first boundary for the region
	xy <- data.frame(locator(1))
	if (length(xy) == 0){
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		showGui()
		return(invisible())
	}
	abline(v=xy$x, col=lineCol )
	if (nDim != 1)
		abline(h=xy$y, col=lineCol )    
	
	##define other boundary for the region
	xy2 <- data.frame(locator(1))
	if (length(xy2) == 0){
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		showGui()
		return(invisible())
	}
	abline(v=xy2$x, col=lineCol )
	if (nDim != 1)
		abline(h=xy2$y, col=lineCol )   
	xy <- rbind(xy, xy2)
	showGui()
	
	## Find max observable signal for each spectrum 
	outFile <- NULL
	outNames <- NULL
	for( i in fileName ){
		
		## Define variables for the current spectrum
		cNum <- match(i, names(fileFolder))
		cFile <- fileFolder[[cNum]]
		cDim <- cFile$file.par$number_dimensions
		outNames <- c(outNames, i)
		cRange <- matchShift(cFile, w2 = xy$x, w1 = xy$y, w1.pad = 1, w2.pad = 1, 
				overRange = TRUE)
		
		## Skip spectra outside the user-defined chemical shift ranges
		if( any(is.na(unlist(cRange))) ){
			cData <- rep(NA, 3)
			names(cData) <- c('w1', 'w2', 'Height')
			outFile <- rbind(outFile, cData ) 
			next
		}
		
		## Find the absolute maximum point in the range
		cData <- maxShift(inFile=ucsf2D(file.name=i, w1Range=cRange$w1, 
						w2Range=cRange$w2, file.par=cFile$file.par),
				conDisp=cFile$graphics.par$conDisp)
		
		## Exclude data outside the spectral window
		if( is.null(cData) ){
			cData <- rep(NA, 3)
			names(cData) <- c('w1', 'w2', 'Height')
			outFile <- rbind(outFile, cData ) 
			next
		}
		
		## Exclude data below the noise threshold
		if(noiseCheck){
			if( cDim > 1 && abs(cData$Height) < 
					cFile$file.par$noise_est * cFile$graphics.par$clevel )
				cData <- rep(NA, 3)
			if( cDim == 1 && abs(cData$Height) < 
					globalSettings$thresh.1D * cFile$file.par$noise_est + 
					cFile$file.par$zero_offset )
				cData <- rep(NA, 3)
			names(cData) <- c('w1', 'w2', 'Height')
		}
		outFile <- rbind(outFile, cData ) 
	}
	
	## Format output data
	outFile <- suppressWarnings(data.frame(outFile))
	row.names(outFile) <- outNames
	
	## Refresh the graphics
	if(redraw)
		refresh(multi.plot=FALSE, sub.plot=FALSE)
	cInc <- match(names(fileFolder[current]), row.names(outFile))
	abline(v = outFile$w2[cInc], h = outFile$w1[cInc], lty = 2 )
	
	return(outFile)
}

## Peak pick the maximum intensity within a region
## fileName - character string or vector; spectrum name(s) as returned by 
##						names(fileFolder)
## append - logical; TRUE apppends new peaks to old list
pm <- function(fileName=currentSpectrum, append = TRUE, ...){
	pReg(fileName = fileName, append = append, maxOnly = TRUE, ...)
}

## Peak pick current window in current spectrum
## append  - logical argument, TRUE apppends new peaks to old list
pw <- function(append = TRUE, ...){
	
	## Define the current spectrum
	current <- wc()
	w1Range <- fileFolder[[current]]$graphics.par$usr[3:4]
	w2Range <- fileFolder[[current]]$graphics.par$usr[1:2]
	
	
	## Peak pick active window
	peakPick(w1Range = w1Range, w2Range= w2Range, append = append, ...)
	setGraphics(peak.disp = TRUE,  save.backup = FALSE)
	if( !append )
		refresh(sub.plot = FALSE, multi.plot = FALSE)
	else
		pdisp()
}

## Peak pick current window in all spectra
## append  - logical argument, TRUE apppends new peaks to old list
pwAll <- function( append = TRUE, ... ){
	
	##Checks that spectra have the same nuclei on the same axis
	wc()
	fileName <- names(fileFolder)
	if (length(fileName) > 1){
		for (i in fileName){	
			if (fileFolder[[i]]$file.par$number_dimensions != 
					fileFolder[[1]]$file.par$number_dimensions){
				if (fileFolder[[i]]$file.par$number_dimensions == 1){
					if (match(fileFolder[[i]]$file.par$nucleus,
							fileFolder[[1]]$file.par$nucleus) != 2)
						stop('All spectra must have the same nuclei, on the same axis', 
								quote=FALSE)
				}else if (match(fileFolder[[i]]$file.par$nucleus,
						fileFolder[[1]]$file.par$nucleus)[2] != 1)
					stop('All spectra must have the same nuclei, on the same axis', 
							quote=FALSE)
			}else if (!all(fileFolder[[i]]$file.par$nucleus == 
							fileFolder[[1]]$file.par$nucleus))
				stop('All spectra must have the same nuclei, on the same axis', 
						quote=FALSE)
		}
	}
	
	## Define the current spectrum
	current <- wc()
	w1Range <- fileFolder[[current]]$graphics.par$usr[3:4]
	w2Range <- fileFolder[[current]]$graphics.par$usr[1:2]
	
	## Peak pick each spectrum
	peakPick(fileName = names(fileFolder), w1Range = w1Range, 
			w2Range = w2Range, append = append, ...)
	
	## Refresh graphics and save backup copy  
	setGraphics(peak.disp = TRUE,  save.backup = FALSE)
	if( !append )
		refresh(sub.plot = FALSE, multi.plot = FALSE)
	else
		pdisp()
}

## User peak picking function rp
## Peak picks inside or outside ROIs 
## fileName - string or character vector; spectrum name(s) as returned by 
##						names(fileFolder)
## append  - logical argument, TRUE apppends new peaks to old list
## ...     - arguments can be passed to internal peak picking functions
## Saves the new peak list to the file folder and displays new peaks
rp <- function( fileName = currentSpectrum, append = TRUE, parent=NULL, ...){
	
	## Error checking
	current <- wc()
	if(!exists('roiTable') || is.null(roiTable) || nrow(roiTable) == 0)
		err('No ROIs have been designated, use roi()')
	
	## Prompt user for ranges to be picked  
	usrSel <- mySelect(c('Inside ROIs', 'Maxima of ROIs', 'Outside ROIs'), 
			multi = FALSE, preselect = 'Inside', title = 'Peak pick:', parent=parent)
	if ( length(usrSel) == 0 || !nzchar(usrSel) )
		return(invisible())
	
	## Have user select the type of peak picking	
	if( usrSel != 'Outside ROIs' ){
		
		## Have user select rois to peakPick 
		usrROI <- mySelect(roiTable$Name, multi = TRUE, index = TRUE,
				preselect = roiTable$Name[which(roiTable$ACTIVE == TRUE)], 
				title = 'Select ROIs to peak pick', parent=parent)
		if ( length(usrROI) == 0 || !nzchar(usrROI) )
			return(invisible())
		usrROI <- roiTable[usrROI,]
		
	}else
		usrROI <- roiTable
	
	## Peak pick each spectrum
	for(j in fileName ){
		
		## Set parameters
		cNum <- which( names(fileFolder) == j )
		oList <- fileFolder[[cNum]]$peak.list
		cDim <- fileFolder[[cNum]]$file.par$number_dimensions
		
		## Peak pick entire spectrum
		tList <- peakPick( fileName = j, internal = TRUE, ...)
		
		## Find subset of peaks inside/outside ROIs
		out <- NULL
		for( i in 1:nrow(usrROI) ){		
			
			## Find w2 subset
			subList <- tList[tList$w2 < usrROI$w2_downfield[i], ]
			subList <- subList[subList$w2 > usrROI$w2_upfield[i], ]
			if( usrROI$nDim[i] == 1 || cDim == 1 ){
				if (usrSel == 'Maxima of ROIs')
					subList <- subList[which.max(abs(subList$Height)), ]
				out <- rbind(out, subList)
				next()
			}
			
			## Find w1 subset		
			subList <- subList[subList$w1 < usrROI$w1_downfield[i], ]
			subList <- subList[subList$w1 > usrROI$w1_upfield[i], ]
			if (usrSel == 'Maxima of ROIs')
				subList <- subList[which.max(abs(subList$Height)), ]	
			out <- rbind(out, subList )
		}
		
		## Invert peak selection for outside roi option was selected
		if( usrSel == 'Outside ROIs' )
			nList <- tList[which(is.na(match(tList$Index, out$Index))),]
		else
			nList <- out
		
		## Tell user which file was peak picked
		cat(paste(basename(j), '\n'))
		
		## update appended lists
		if( append ){
			
			if( length(oList) && nrow(nList) ){
				nList <- appendPeak( newList = nList, oldList = oList )
				cat(paste(' Total peaks:', nrow(nList), '\n', 
								'New peaks:', nrow(nList) - nrow(oList), '\n'))				
			}
			
			if( !length(oList) && nrow(nList) ){
				row.names(nList) <- NULL
				nList$Index <- 1:nrow(nList)
				cat(paste(' Total peaks:', nrow(nList), '\n', 
								'New peaks:', nrow(nList), '\n'))	
			}
			
			if( length(oList) && !nrow(nList) ){
				nList <- oList
				cat(paste(' Total peaks:', nrow(nList), '\n', 
								'New peaks:', 0, '\n'))	
			}
			
			if( !length(oList) && !nrow(nList) ){
				cat(paste(' Total peaks:', 0, '\n'))
				nList <- NULL	
			}
			
			## update non-appended lists
		}else{
			if( nrow(nList) ){
				cat(paste(' Total peaks:', nrow(nList), '\n'))
				row.names(nList) <- NULL
				nList$Index <- 1:nrow(nList)
			}else{
				cat(paste(' Total peaks:', 0, '\n'))
				nList <- NULL
			}
		}
		
		## Save new peak list to file folder
		fileFolder[[cNum]]$peak.list <- nList
		flush.console()
	}
	
	## Assign file folder and refresh the graphics
	myAssign("fileFolder", fileFolder, save.backup = TRUE)
	setGraphics(peak.disp = TRUE,  save.backup = FALSE)
	if( !append )
		refresh(sub.plot = FALSE, multi.plot = FALSE)
	else
		pdisp()
}



## User function rpAll
## Peak pick ROIs in all files
## append  - logical argument, TRUE apppends new peaks to old list
## ...     - arguments can be passed to internal peak picking functions
rpAll <- function( append = TRUE, ...){
	
	wc()
	rp( fileName = names(fileFolder), append = append, ... )
	
}

## User peak function
## Allow users to pick peaks by hand
## forcePoint - Logical argument, when TRUE, chemical shifts and intensity
##              will be taken from the closest data point in the spectrum;
##              when FALSE the intensity is taken from the closest data point
##              but chemical shifts will not be corrected to match the spectrum
## Note: rNMR does not interpolate between data points. The default behavior
##       of this function is to allows users to specify any chemical shift, but 
##       the intensities of these locations are derived from the closest 
##       neighboring point. The most reliable method for finding the maximum
##       intensity of a peak is to use ROI summary.
## returns a list of the unique hand picked peaks and appends these data
##       to the peak list for the active spectrum.
ph <- function( forcePoint = FALSE){
	
	## Check to make sure the requisite files are present
	current <- wc()
	lineCol <- fileFolder[[current]]$graphics.par$fg
	
	## Bring main into focus and show any active peaks
	if(length(which(dev.list() == 2)) != 1)
		drawNMR()
	cw(dev=2);	pdisp()
	
	## Give the user some instructions
	cat(paste('In the main plot window:\n',  
					' Left-click inside the plot to peak pick\n',  
					' Right-click to exit\n'))
	flush.console()
	hideGui()
	
	## Have user select peaks
	print('New peaks:', quote = FALSE)
	outList <- NULL
	while( TRUE ){
		
		## Tell the user what to do
		op <- par('font')
		par( font = 2 )
		legend("topleft", c('LEFT CLICK TO PICK','RIGHT CLICK TO EXIT'), 
				pch=NULL, bty='n', text.col=lineCol)
		par(font = op)
		
		xy <- locator(1)
		if(is.null(xy))
			break()
		
		## Force chemical shifts to the closest datapoint
		if( forcePoint ){
			xy <- matchShift( w1 = xy$y, w2 =xy$x )
			peakFile <- ucsf2D( currentSpectrum, w1Range = xy$w1, 
					w2Range = xy$w2, file.par = fileFolder[[current]]$file.par )
			
			## Do not force chemical shifts, Height is taken from closest datapoint	
		}else{
			peakFile <- list( w1 = xy$y, w2 = xy$x )
			xy <- matchShift( w1 = xy$y, w2 =xy$x )
			peakFile$data <- ucsf2D(currentSpectrum, w1Range = xy$w1, 
					w2Range = xy$w2, file.par = fileFolder[[current]]$file.par )$data
		}
		
		
		## Make a new peak list or append to the old list
		if( fileFolder[[current]]$file.par$number_dimensions  > 1 )
			nPeak <- data.frame( list(Index = 1,  w1 = peakFile$w1, w2 = peakFile$w2, 
							Height = peakFile$data, Assignment = "NA" ), 
					stringsAsFactors = FALSE)
		else
			nPeak <- data.frame(list( Index = 1, w1 = NA, w2 = peakFile$w2, 
							Height = peakFile$data, 
							Assignment = "NA" ), stringsAsFactors = FALSE)
		
		fileFolder[[current]]$peak.list <- appendPeak(nPeak, 
				fileFolder[[current]]$peak.list)
		
		## Assign new peak list
		print(nPeak[2:4], quote=FALSE)
		flush.console()
		outList <- unique (rbind( outList, nPeak ))
		myAssign("fileFolder", fileFolder, save.backup = FALSE)	
		pdisp()
	}
	
	## Assign the final version of the file and print the new peaks
	showGui()
	setGraphics(peak.disp = TRUE,  save.backup = TRUE)
	refresh( sub.plot = FALSE, multi.plot = FALSE)
	row.names( outList ) <- NULL
	invisible( outList ) 
}

## Turn on/off peak display
pv <- function(){
	
	## Check to make sure the requisite files are present
	wc()
	
	## Turn peak view on/off
	if( globalSettings$peak.disp ){
		setGraphics( peak.disp = FALSE )		
		refresh(sub.plot = FALSE, multi.plot = FALSE)
		cat('Peak display off \n')
	}else{
		setGraphics( peak.disp = TRUE )   
		pdisp()	
		cat('Peak display on \n')
	}
}

## Clear the peak list for the current spectrum 
pDel <- function(){
	current <- wc()
	if ( is.null(fileFolder[[current]]$peak.list) )
		print('The current peak list is empty', quote=FALSE)
	else
		peakDel()	
}

## Internal function for peak delete
## fileName - A list of file names from fileFolder
peakDel <- function( fileName = currentSpectrum ){
	for (i in fileName)
		fileFolder[[i]]$peak.list <- NULL
	myAssign('fileFolder', fileFolder)
	refresh(sub.plot=FALSE, multi.plot=FALSE)
}

## Clear peak list for all open spectra 
pDelAll <- function(){
	
	## Check to make sure the requisite files are present
	current <- wc()
	peak.list <- fileFolder[[current]]$peak.list
	
	## Clear peak lists and turn off peak display
	for(i in 1:length(fileFolder))
		fileFolder[[i]]$peak.list <- NULL   
	
	myAssign("fileFolder", fileFolder, save.backup = FALSE)
	if( nrow(peak.list) > 0 )
		refresh(sub.plot = FALSE, multi.plot = FALSE) 
}

## User ROI function re
## Allows user to edit values in a peak list
pe <- function(table){
	
	##check for peak list
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	if (missing(table)){
		peakList <- fileFolder[[current]]$peak.list
		if (is.null(peakList))
			err('Peak table is empty, use pp() to pick peaks.')
	}else
		peakList <- table
	
	##make sure peak list is the correct format
	defCols <- c('Index', 'w1', 'w2', 'Height', 'Assignment')
	if (any(is.na(match(defCols, names(peakList)))))
		err(paste('Peak table is not the correct format, type "?import" in the R ',
						'console for more information.'))
	
	##reorder columns to match default structure
	extraCols <- names(peakList)[-match(defCols, names(peakList))]
	if (length(extraCols)){
		peakList <- data.frame(peakList$Index, peakList$w1, peakList$w2, 
				peakList$Height, peakList$Assignment, peakList[extraCols], 
				stringsAsFactors=FALSE)
		names(peakList) <- c(defCols, extraCols)
	}
	
	##coerce data to the proper format
	colModes <- c('integer', 'numeric', 'numeric', 'numeric', rep('character', 
					ncol(peakList) - 4))
	for (i in seq_along(colModes))
		suppressWarnings(storage.mode(peakList[, i]) <- colModes[i])
	
	##edit a table other than the current peak list
	if (!missing(table)){
		
		## Create verification functions
		indexVer <- function(x) return(all(!is.na(x)) && 
							!any(is.na(suppressWarnings(as.integer(x)))))
		verFun <- function(x) return(!any(is.na(x)))
		assignFun <- list(function(x) TRUE)
		errors <- c('Peak indices must be integers',
				rep('Chemical shifts must be numeric', 2), 
				'Peak heights must numeric', 
				rep(' ', ncol(peakList) - 4))
		
		## Call tableEdit to allow user to edit peaks
		hideGui()
		if (nDim == 1)
			peakList <- tableEdit(peakList, title='Edit Peaks', errMsgs=errors, 
					colVer=c(indexVer, assignFun, rep(list(verFun), 2), rep(assignFun, 
									ncol(peakList) - 4)))
		else
			peakList <- tableEdit(peakList, title='Edit Peaks', errMsgs=errors,
					colVer=c(indexVer, rep(list(verFun), 3), rep(assignFun, 
									ncol(peakList) - 4)))
		if (is.null(peakList)){
			showGui()
			return(invisible())
		}
		
		##return edited table
		showGui()
		return(peakList)
	}
	
	##store an original copy of the peak list
	origTable <- peakList
	
	##creates edit window
	dlg <- myToplevel('pe')
	if (is.null(dlg))
		return(invisible())
	tkwm.title(dlg, 'Edit Peaks')
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##create button to be invoked by view button in table
	onView <- function(){
		
		##get selected row
		usrSel <- as.numeric(tcl(tableList, 'curselection')) + 1
		if (!length(usrSel))
			return(invisible())
		nDim <- fileFolder[[current]]$file.par$number_dimensions
		
		## Set the chemical shift ranges of the point zoom window
		if (fileFolder[[current]]$file.par$nucleus[1] != '1H')
			w1Delta <- 2.5 / 2
		else
			w1Delta <- .1 / 2
		if (nDim == 1)
			w2Delta <- w1Delta
		else{
			if (fileFolder[[current]]$file.par$nucleus[2] != '1H')
				w2Delta <- 2.5 / 2
			else
				w2Delta <- .1 / 2
		}
		
		## Set new chemical shift ranges
		xy <- fileFolder[[current]]$peak.list[usrSel, ]
		w2Range <- c(xy$w2 + w2Delta, xy$w2 - w2Delta)
		if(nDim != 1){
			w1Range <- c(xy$w1 + w1Delta, xy$w1 - w1Delta) 
		}else{
			w1Range <- c(fileFolder[[current]]$file.par$zero_offset - 
							(xy$Height - fileFolder[[current]]$file.par$zero_offset) * 
							globalSettings$position.1D, xy$Height)
			w1Range[2] <- w1Range[2] + .05 * (diff(w1Range)) 
		}
		setGraphics(w1Range=w1Range, w2Range=w2Range, refresh=TRUE)
	}
	tkbutton(dlg, command=onView)
	
	##define columns for tablelist widget
	colNames <- colnames(peakList)
	colVals <- c('5', 'View', 'center')
	for (i in colNames)
		colVals <- c(colVals, '0', i, 'left')
	
	##create tablelist widget
	tableFrame <- ttkframe(dlg)
	xscr <- ttkscrollbar(tableFrame, orient='horizontal', command=function(...) 
				tkxview(tableList, ...))
	yscr <- ttkscrollbar(tableFrame, orient='vertical', command=function(...) 
				tkyview(tableList, ...))
	tableList <- tkwidget(tableFrame, 'tablelist::tablelist', columns=colVals, 
			activestyle='underline', height=15, width=110, bg='white', stretch='all',
			exportselection=FALSE, selectmode='extended', selecttype='cell',
			editselectedonly=TRUE, xscrollcommand=function(...) tkset(xscr, ...),
			yscrollcommand=function(...) tkset(yscr, ...))
	
	##add data to tablelist widget
	for (i in 1:nrow(peakList))
		tkinsert(tableList, 'end', c('', unlist(peakList[i, ])))
	for (i in 2:length(colNames)){
		tcl(tableList, 'columnconfigure', i, sortmode='dictionary', 
				editable=TRUE, labelcommand='tablelist::sortByColumn')
	}
	
	##clears tablelist widget and repopulates it using the current peak list
	fillTable <- function(){
		tcl(tableList, 'cancelediting')
		tkdelete(tableList, 0, 'end')
		peakList <- fileFolder[[current]]$peak.list
		if (is.null(peakList))
			return(invisible())
		for (i in 1:nrow(peakList)){
			tkinsert(tableList, 'end', c('', unlist(peakList[i, ])))
			tcl(tableList, 'cellconfigure', paste(i - 1, '0', sep=','), 
					window='createButton')
		}
		tkwm.deiconify(dlg)
		tkfocus(dlg)
	}
	
	##saves data after table is edited
	writeData <- function(refreshPlot=TRUE){
		
		##get the data from the GUI
		newData <- NULL
		numRows <- as.numeric(tcl(tableList, 'index', 'end'))
		if (numRows == 0){
			fileFolder[[current]]$peak.list <- NULL
			myAssign('fileFolder', fileFolder)
			if (refreshPlot)
				refresh()
			return(invisible())
		}
		for (i in 0:numRows)
			newData <- rbind(newData, as.character(tcl(tableList, 'get', i)))
		newData <- newData[, -1]
		
		##format data
		colnames(newData) <- colNames
		newData <- as.data.frame(newData, stringsAsFactors=FALSE)
		for (i in 1:ncol(newData))
			suppressWarnings(storage.mode(newData[, i]) <- colModes[i])
		if (identical(newData, fileFolder[[current]]$peak.list))
			return(invisible())
		
		##assign peak list and refresh
		fileFolder[[current]]$peak.list <- newData
		myAssign('fileFolder', fileFolder)
		setGraphics(peak.disp=TRUE, save.backup=FALSE)
		if (refreshPlot)
			refresh(sub.plot=FALSE, multi.plot=FALSE)
		pdisp()
		tkwm.deiconify(dlg)
	}
	
	##renumber indices when columns are sorted
	onSort <- function(){
		
		##renumber indices and save peak list
		peakList <- fileFolder[[current]]$peak.list
		for (i in 1:nrow(peakList))
			tcl(tableList, 'cellconfigure', paste(i - 1, '1', sep=','), text=i)
		writeData(FALSE)
		
		##remove data from tablelist widget and repopulate
		fillTable()
	}
	tkbind(tableList, '<<TablelistColumnSorted>>', onSort)
	
	##create image for view button
	createTclImage('view')
	
	##create a tcl procedure that creates a view button
	tcl('proc', 'createButton', 'tbl row col w', paste('button $w -image', 
					'view -width 0 -takefocus 0 -command {.pe.1 invoke}'))
	
	##configure first colum to display view buttons
	for (i in 1:nrow(peakList) - 1)
		tcl(tableList, 'cellconfigure', paste(i, '0', sep=','), 
				window='createButton')
	
	##select entire row when view button is pressed
	onViewButton <- function(W){
		if (!length(grep('k', W)))
			return(invisible())
		rowNum <- strsplit(W, '.*_k')[[1]][2]
		rowNum <- as.numeric(strsplit(rowNum, ',')[[1]][1])
		tkselection.clear(tableList, 0, 'end')
		tkselection.set(tableList, rowNum)
	}
	tkbind(dlg, '<Button-1>', onViewButton)
	
	##selects all rows Ctrl+A is pressed
	tkbind(tableList, '<Control-a>', function(...) 
				tkselect(tableList, 'set', 0, 'end'))	
	
	##wrapper function for rearranging rows in peak list
	onMove <- function(movement){
		
		##get selection
		tcl(tableList, 'finishediting')
		peakList <- fileFolder[[current]]$peak.list
		n <- nrow(peakList)
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel))
			return(invisible())
		usrSel <- usrSel + 1
		if (movement %in% c('top', 'up') && usrSel == 1)
			return(invisible())
		if (movement %in% c('bottom', 'down') && usrSel == n)
			return(invisible())
		
		##determine new position
		indices <- (1:n)[-usrSel]
		newPos <- switch(movement, 'top'=0, 'up'=usrSel - 2, 'down'=usrSel, 
				'bottom'=n - 1)
		
		##rearrange peak list
		peakList <- peakList[append(indices, usrSel, newPos), ]
		peakList$Index <- 1:n
		
		##save peak list
		fileFolder[[current]]$peak.list <- peakList
		myAssign('fileFolder', fileFolder)
		
		##remove data from tablelist widget and repopulate
		fillTable()
		tkselection.set(tableList, newPos)
		tcl(tableList, 'see', newPos)
	}
	
	##create top button
	optionFrame <- ttkframe(dlg)
	moveFrame <- ttklabelframe(optionFrame, text='Move selected rows', padding=6)
	topButton <- ttkbutton(moveFrame, text='Top', width=11, command=function(...) 
				onMove('top'))
	
	##create up button
	upButton <- ttkbutton(moveFrame, text='^', width=9, command=function(...) 
				onMove('up'))
	
	##create down button
	downButton <- ttkbutton(moveFrame, text='v', width=9, command=function(...) 
				onMove('down'))
	
	##create bottom button
	bottomButton <- ttkbutton(moveFrame, text='Bottom', width=11, 
			command=function(...) onMove('bottom'))
	
	##create sig. fig. spinbox
	sigFigFrame <- ttklabelframe(optionFrame, text='Display', padding=6)
	onSigFig <- function(){
		peakList <- fileFolder[[current]]$peak.list
		if (tclvalue(sigFigVal) == 'max'){
			for (i in 1:nrow(peakList)){
				newData <- c('', unlist(peakList[i, ]))
				tcl(tableList, 'rowconfigure', i - 1, text=newData)
			}
			return(invisible())
		}
		sigFig <- as.numeric(tclvalue(sigFigVal))
		for (i in seq_along(colNames)){
			if (any(is.logical(peakList[, i])))
				next
			newData <- tryCatch(signif(peakList[, i], sigFig), error=function(er) 
						return(peakList[, i]))
			newData[is.na(newData)] <- 'NA'
			tcl(tableList, 'columnconfigure', i, text=newData)
		}
	}
	sigFigVal <- tclVar('max')
	sigFigBox <- tkwidget(sigFigFrame, 'spinbox', width=6, wrap=TRUE,
			textvariable=sigFigVal, values=c('max', 1:9), command=onSigFig)
	sigFigLabel <- ttklabel(sigFigFrame, text='significant figures')
	
	##check interactively edited cells using functions provided in colVer
	onEdit <- function(widget, rowNum, colNum, newVal, tclReturn=TRUE){
		
		##format new cell value
		rowNum <- as.numeric(rowNum) + 1
		colNum <- as.numeric(colNum)
		suppressWarnings(storage.mode(newVal) <- colModes[colNum])
		
		##check edits to the chemical shift columns
		if (nDim == 1)
			shiftCols <- 3
		else
			shiftCols <- 2:3
		if (colNum %in% shiftCols && is.na(newVal)){
			myMsg('Chemical shifts must be numeric', icon='error', parent=dlg)
			tcl(tableList, 'cancelediting')
			if (!tclReturn)
				return(FALSE)
		}
		
		##check edits to the ACTIVE column
		if (colNum == 4 && is.na(newVal)){
			myMsg('Peak heights must be numeric', icon='error', parent=dlg)
			tcl(tableList, 'cancelediting')
			if (!tclReturn)
				return(FALSE)
		}
		
		##update the selected cell with the new value
		if (tclReturn)
			return(tclVar(as.character(newVal)))
		else
			return(TRUE)
	}
	tkconfigure(tableList, editendcommand=function(...) onEdit(...))
	
	##save the updated peak list after interactive cell editing
	tkbind(tableList, '<<TablelistCellUpdated>>', function(...) writeData(...))
	
	##create copy button
	rowEditFrame <- ttklabelframe(optionFrame, text='Edit rows', padding=6)
	clipboard <- NULL
	onCopy <- function(){
		tcl(tableList, 'finishediting')
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel) || usrSel == 0)
			return(invisible())
		tkselection.set(tableList, usrSel)
		selVals <- NULL
		for (i in usrSel)
			selVals <- rbind(selVals, as.character(tcl(tableList, 'get', i)))
		clipboard <<- selVals[, -1]
	}
	copyButton <- ttkbutton(rowEditFrame, text='Copy', width=10, command=onCopy)
	
	##create paste button
	onPaste <- function(){
		tcl(tableList, 'finishediting')
		if (is.null(clipboard))
			return(invisible())
		peakList <- rbind(fileFolder[[current]]$peak.list, clipboard)
		n <- nrow(peakList)
		peakList$Index <- 1:n
		for (i in 1:ncol(peakList))
			suppressWarnings(storage.mode(peakList[, i]) <- colModes[i])
		fileFolder[[current]]$peak.list <- peakList
		myAssign('fileFolder', fileFolder)
		fillTable()
		tkselection.set(tableList, nrow(peakList) - 1)
		tcl(tableList, 'see', nrow(peakList) - 1)
	}
	pasteButton <- ttkbutton(rowEditFrame, text='Paste', width=10, 
			command=onPaste)
	
	##create insert button
	onInsert <- function(){
		tcl(tableList, 'finishediting')
		n <- nrow(peakList)
		newRow <- c(n + 1, rep(NA, ncol(peakList) - 1))
		peakList <- rbind(fileFolder[[current]]$peak.list, newRow)
		for (i in 1:ncol(peakList))
			suppressWarnings(storage.mode(peakList[, i]) <- colModes[i])
		fileFolder[[current]]$peak.list <- peakList
		myAssign('fileFolder', fileFolder)
		fillTable()
		tkselection.set(tableList, n)
		tcl(tableList, 'see', n)
	}
	insertButton <- ttkbutton(rowEditFrame, text='Insert', width=10, 
			command=onInsert)
	
	##create delete button
	onDelete <- function(){
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel))
			return(invisible())
		for (i in rev(usrSel))
			tkdelete(tableList, i)
		tkselection.clear(tableList, 0, 'end')
		tkselection.set(tableList, usrSel[length(usrSel)] - length(usrSel))
		writeData()
	}
	deleteButton <- ttkbutton(rowEditFrame, text='Delete', width=10, 
			command=onDelete)
	
	##create cell editing textbox
	cellEditFrame <- ttklabelframe(optionFrame, text='Edit selected cells', 
			padding=6)
	usrEntry <- tclVar(character(0))
	textEntry <- ttkentry(cellEditFrame, width=13, justify='center', 
			textvariable=usrEntry)
	
	##update cell editing textbox with current cell selection value
	onCellSel <- function(){
		usrSel <- as.character(tcl(tableList, 'curcellselection'))
		if (!length(usrSel))
			tclObj(usrEntry) <- character(0)
		selVals <- as.character(tcl(tableList, 'getcells', usrSel))
		if (nzchar(selVals[1]) && 
				length(grep(selVals[1], selVals, fixed=TRUE)) == length(selVals))
			tclObj(usrEntry) <- selVals[1]
		else
			tclObj(usrEntry) <- character(0)
	}
	tkbind(tableList, '<<TablelistSelect>>', onCellSel)
	
	##create apply button
	onApply <- function(){
		tcl(tableList, 'finishediting')
		newVal <- tclvalue(usrEntry)
		usrSel <- as.character(tcl(tableList, 'curcellselection'))
		for (i in usrSel){
			rowNum <- unlist(strsplit(i, ','))[1]
			colNum <- unlist(strsplit(i, ','))[2]
			isValid <- onEdit(rowNum=rowNum, colNum=colNum, newVal=newVal, 
					tclReturn=FALSE)
			if (isValid)
				tcl(tableList, 'cellconfigure', i, text=newVal)
			else
				return(invisible())
		}
		writeData()
	}
	applyButton <- ttkbutton(cellEditFrame, text='Apply', width=8, 
			command=onApply)
	
	##create export button
	tableOptionFrame <- ttklabelframe(optionFrame, text='Table', padding=6)
	onExport <- function(){
		tcl(tableList, 'finishediting')
		peakList <- fileFolder[[current]]$peak.list
		tkwm.iconify(dlg)
		fileName <- mySave(initialfile='peakList', defaultextension='txt', 
				title='Export', filetypes=list('xls'='Excel Files', 'txt'='Text Files'))
		if (!length(fileName) || !nzchar(fileName)){
			tkwm.deiconify(dlg)
			return(invisible())
		}
		write.table(peakList, file=fileName, quote=FALSE, sep='\t', row.names=FALSE, 
				col.names=TRUE)
		tkwm.deiconify(dlg)
	}
	exportButton <- ttkbutton(tableOptionFrame, text='Export', width=11, 
			command=onExport)
	
	##create restore button
	onRestore <- function(){
		if (identical(origTable, fileFolder[[current]]$peak.list))
			return(invisible)
		fileFolder[[current]]$peak.list <- origTable
		myAssign('fileFolder', fileFolder)
		refresh()
		fillTable()
	}
	restoreButton <- ttkbutton(tableOptionFrame, text='Restore', width=11, 
			command=onRestore)
	
	##create refresh button
	onRefresh <- function(){
		current <<- wc()
		nDim <<- fileFolder[[current]]$file.par$number_dimensions
		fillTable()
	}
	refreshButton <- ttkbutton(tableOptionFrame, text='Refresh', width=11, 
			command=onRefresh)
	
	##add widgets to tableFrame
	tkgrid(tableFrame, column=1, row=1, sticky='nswe', pady=6, padx=6)
	tkgrid(tableList, column=1, row=1, sticky='nswe')
	tkgrid(xscr, column=1, row=2, sticky='we')
	tkgrid(yscr, column=2, row=1, sticky='ns')
	
	##make tableFrame stretch when window is resized
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=1)
	tkgrid.columnconfigure(tableFrame, 1, weight=1)
	tkgrid.rowconfigure(tableFrame, 1, weight=1)
	
	##add widgets to moveFrame
	tkgrid(optionFrame, column=1, row=2, pady=c(8, 0))
	tkgrid(moveFrame, column=1, row=1, padx=8)
	tkgrid(topButton, column=1, row=1, pady=2, padx=c(0, 4))
	tkgrid(upButton, column=2, row=1, pady=2, padx=1)
	tkgrid(downButton, column=3, row=1, padx=1, pady=2)
	tkgrid(bottomButton, column=4, row=1, pady=2, padx=c(4, 0))
	
	##add widgets to sigFigFrame
	tkgrid(sigFigFrame, column=2, row=1, padx=8)
	tkgrid(sigFigBox, column=1, row=1, padx=c(4, 2), pady=c(2, 4))
	tkgrid(sigFigLabel, column=2, row=1, padx=c(0, 4), pady=c(2, 4))
	
	##add widgets to rowEditFrame
	tkgrid(rowEditFrame, column=1, row=2, pady=4, padx=8)
	tkgrid(copyButton, column=1, row=1, padx=c(0, 2))
	tkgrid(pasteButton, column=2, row=1, padx=c(0, 8))
	tkgrid(insertButton, column=3, row=1, padx=c(0, 2))
	tkgrid(deleteButton, column=4, row=1, padx=c(0, 0))
	
	##add widgets to colEditFrame
	tkgrid(cellEditFrame, column=2, row=2, pady=4, padx=8)
	tkgrid(textEntry, column=1, row=1, padx=2)
	tkgrid(applyButton, column=3, row=1, padx=2)
	
	##add widgets to rightFrame
	tkgrid(tableOptionFrame, column=3, row=1, rowspan=2, padx=c(14, 10))
	tkgrid(exportButton, column=1, row=1)
	tkgrid(restoreButton, column=1, row=2, pady=6)
	tkgrid(refreshButton, column=1, row=3)
	tkgrid(ttksizegrip(dlg), column=1, row=3, sticky='se')
	
	##Allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (length(grep('.2.2.3.1$', focus)))
			onApply()
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter)
	tkfocus(tableList)
	
	return(invisible())
}

## Open Madison Metabolomics Consortium Database in a web browser
mmcd <- function(){browseURL("http://mmcd.nmrfam.wisc.edu")}

## Changes the noise filter for peak picking
## filt - the desired filter level; either 0, 1, or 2 for off, mild, and strong
nf <- function(noiseFilt){
	if (missing(noiseFilt)){
		filtLevel <- switch(globalSettings$peak.noiseFilt + 1, 'off', 'mild', 
				'strong')
		cat(paste('Current noise filter setting:', filtLevel, '\n' ))
		return(invisible())	
	}
	
	if (!any(noiseFilt == c(0, 1, 2)))
		stop('Invalid "noiseFilt" argument, use: 0 (off), 1 (mild) or 2 (strong)')
	
	filtLevel <- switch(noiseFilt + 1, 'off', 'mild', 'strong')
	setGraphics(peak.noiseFilt = noiseFilt)
	cat(paste('Peak picking noise filter has been set to:', filtLevel, '\n'))
}

################################################################################
##                                                                            ##
##               Defining and viewing Regions of interst                      ##
##                                                                            ##
################################################################################

## Internal utility function maxShift
## Finds chemical shifts of the maximum absolute intensity in the file folder
## inFile  - file parameters and data for desired spectrum as returned by ed()
## invert       - Logical argument, inverts the data before finding the max
##                shift. This is used in the graphics functions
## conDisp      - Logical vector of length 2; c(TRUE, TRUE) returns the 
##                absolute max, c(TRUE, FALSE) returns the max, c(TRUE, FALSE)
##                returns the min
## returns chemical shifts and intensity of the maximum intensity signal
maxShift <- function( inFile, invert = FALSE, conDisp = c(TRUE, TRUE), 
		massCenter = FALSE ){
	
	
	## Set function
	if( inFile$file.par$number_dimensions == 1 || all(conDisp )){
		if( invert )
			FUN <- function(x){ which.max(rev(abs(x)))}
		else
			FUN <- function(x){ which.max(abs(x))}
		
	}else{
		if( conDisp[1] ){
			if( invert )
				FUN <- function(x){ which.max(rev(x))}
			else
				FUN <- function(x){ which.max((x))}
			
		}else{
			if( invert )
				FUN <- function(x){ which.min(rev(x))}	
			else
				FUN <- function(x){ which.min((x))}		
			
		}	
	}
	
	if(inFile$file.par$number_dimensions > 1){ 
		if( !is.matrix(inFile$data) )
			return(NULL)
		
		## Find the location of the absolute max intensity in the roi 
		bs <- nrow(inFile$data)
		sMax <- FUN(inFile$data) - 1
		rNum <- sMax %% bs 
		cNum <- sMax %/% bs 
		w1 <- rev(inFile$w1)[cNum + 1]
		w2 <- rev(inFile$w2)[rNum + 1]
		Height <- inFile$data[sMax + 1]
		
	}else{
		if( length(inFile$data) < 2 )
			return(NULL)
		
		## Center w2 data by smoothed spectrum
		if( massCenter ){
			rNum <- try( FUN(smooth.spline(inFile$data, df = 5)$y ), silent = TRUE )
			if(class(rNum) == "try-error")
				rNum <- FUN(inFile$data)
		}else
			rNum <- FUN(inFile$data)
		w1 <- NA
		w2 <- rev(inFile$w2)[rNum]
		Height <- inFile$data[rNum]
		
	}
	return(data.frame(w1, w2, Height))
} 

## Internal roi utility function orderROI
## Removes any duplicates entries, renumbers ROIs, and sorts by ROI name
## roiTable  - An roi table object
## Returns an updated roi table
orderROI <- function( roiTable = NULL ){
	
	if( is.null(roiTable) )
		stop('No ROI table was entered')
	if( length(nrow(roiTable)) == 0 )
		return(roiTable)
	
	## Remove duplicate ROIs
	tName <- try(as.vector(sapply(roiTable[,1], 
							function(x){unlist(strsplit(x, ".", fixed = TRUE))[1]})),
			silent = TRUE)
	if(class(tName) == "try-error")
		tName <- roiTable$Name
	roiTable$Name <- tName
	roiTable <- unique(roiTable) 	
	
	## Number any duplacate roi names
	for( i in 1: length(roiTable$Name) ){
		tName <- which(roiTable$Name == roiTable$Name[i])
		if( roiTable$Name[i] == 'ROI' || length (tName) > 1 )
			roiTable$Name[tName] <- paste(roiTable$Name[i], 
					1:length(tName), sep ='.' )
	}	
	row.names(roiTable) <- NULL	
	
	return(roiTable)
}

## Internal graphics function showRoi
## Plots boxes (2D) or lines (1D) to indicate the location of ROIs
## rTable  - roiTable objects can be passed from other functions
## col     - line color vector [active, inactive]
## text.col	- text color vector [active, inactive]
## lw      - line width vector [active, inactive]
## lty     - line type vector [active, inactive] (see par)
## cex     - Text size (see par)
## Note: this function is used to show ROIs on the main plot
showRoi <- function ( rTable = roiTable, col = globalSettings$roi.bcolor, 
		text.col = globalSettings$roi.tcolor, lw = globalSettings$roi.lwd, 
		lty = globalSettings$roi.lty, cex = globalSettings$roi.cex) {
	
	## Check to make sure the requisite files are present
	if( !exists('roiTable') && is.null(rTable) )
		return('The ROI table is empty, use roi() to make a new roi')
	if( is.null(rTable) )
		rTable <- roiTable
	if( is.null(rTable$Name) || nrow(rTable) == 0 )
		return('The ROI table is empty, use roi() to make a new roi')	
	
	## Set ROI label alignment
	if (globalSettings$roi.labelPos == 'top')
		pos <- 3
	else if (globalSettings$roi.labelPos == 'bottom')
		pos <- 1
	else if (globalSettings$roi.labelPos == 'left')
		pos <- 2
	else if (globalSettings$roi.labelPos == 'right')
		pos <- 4
	else
		pos <- NULL
	
	## Define the current spectrum
	current <- wc()   
	nDim <- fileFolder[[current]]$file.par$number_dimensions    
	current.par <- fileFolder[[current]]$file.par 
	usr <- fileFolder[[current]]$graphics.par$usr
	if (is.na(match(2, dev.list())))
		refresh(sub.plot=FALSE, multi.plot=FALSE)
	
	for(rowNum in 1:nrow(rTable)){
		##Find roi PPM locations
		w2Range <- sort(unlist(rTable[rowNum, 2:3]))
		w1Range <- sort(unlist(rTable[rowNum, 4:5]))
		
		## Fudge the ROI table for 1D/2D compatibility
		if( rTable$nDim[rowNum] == 2 && nDim == 1)
			w1Range <- c(current.par$min_intensity, current.par$max_intensity)      
		if( rTable$nDim[rowNum] == 1 && nDim > 1)
			w1Range <- c(current.par$upfield_ppm[1], current.par$downfield_ppm[1]) 
		
		## Set color parameters for ROIs
		if( rTable[rowNum, 6] )
			i <- 1
		else
			i <- 2
		
		## Draw 1D rois as lines, 2D rois as boxes
		if(nDim > 1){
			rect(w2Range[1], w1Range[2], w2Range[2], w1Range[1], lwd = lw[i], 
					border = col[i], lty = lty[i], cex = cex[i])
			if (is.null(pos))
				textCoord <- c(mean(w2Range), mean(w1Range))
			else if (pos == 3)
				textCoord <- c(mean(w2Range), min(w1Range))
			else if (pos == 1)
				textCoord <- c(mean(w2Range), max(w1Range))
			else if (pos == 2)
				textCoord <- c(max(w2Range), mean(w1Range))
			else if (pos == 4)
				textCoord <- c(min(w2Range), mean(w1Range))
			else
				textCoord <- c(mean(w2Range), mean(w1Range))	
			text(textCoord[1], textCoord[2], rTable$Name[rowNum], cex = cex[i], 
					col = text.col[i], pos = pos, offset = .3)				
		}else{
			lines(x = rep( mean(w2Range), 2), y = c(w1Range[2], usr[4]* .75), 
					lty = lty[i], lwd = lw[i], col = col[i])
			lines(x = w2Range, y = rep(w1Range[2], 2), lty = lty[i], lwd = lw[i], 
					col = col[i])
			text(mean(w2Range), usr[4]*.88, rTable$Name[rowNum], cex = cex[i], 
					col = text.col[i], srt = 90, pos = pos, offset = .3)					
		}
	}  
}

## Plots all of the defined regions of interest (ROIs) in a new window
## ...  - Some plotting options can be passed to drawNMR and par()
rvs <- function ( ... ){
	
	## Define the current spectrum
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions 
	current.par <- c(fileFolder[[current]]$file.par,  
			fileFolder[[current]]$graphics.par) 
	
	## Make a new window with some user instructions if no ROIs are active
	if( is.null(roiTable) || nrow(roiTable) == 0 ){
		setWindow('sub', bg = current.par$bg, fg = current.par$fg, 
				col.axis = current.par$col.axis, col.lab = current.par$col.lab,
				col.main = current.par$col.main, col.sub = current.par$col.sub,
				col = current.par$col, mfrow = c(1,1), pty = 'm', 
				mar = globalSettings$mar.sub , xpd = FALSE )
		plot(1, 1, type = 'n', axes=FALSE, xlab='', ylab='' )
		text(1, 1, 'ROIs will apear here \nuse roi() to designate an ROI', cex=1)
		dev.set(which = 2)  
		bringFocus(-1)
		return(invisible())
	}
	
	## Set up a grid of roi sub plots for the roi plotting window   
	plot.grid <- c(ceiling(nrow(roiTable) / 10), 10)   
	setWindow('sub', bg=current.par$bg, fg=current.par$fg, 
			col.axis=current.par$col.axis, col.lab = current.par$col.lab, 
			col.main=current.par$col.main, col.sub =current.par$col.sub, 
			col=current.par$col, mfrow = plot.grid, pty = 'm', 
			mar = globalSettings$mar.sub, xpd = FALSE)
	
	
	## Make sure that plots are possible
	answer <- try(plot(1,1, type = 'n', axes=FALSE, xlab='', ylab=''), 
			silent = TRUE)
	if(class(answer) == "try-error"){
		par( mfrow = c(1,1) )
		plot(1, 1, type = 'n', axes=FALSE, xlab='', ylab='' )
		text(1, 1, paste('Too many ROIs for this window:\nresize the window and ', 
						'type refresh() or use rDel()', sep=''), cex=1)
		dev.set(which = 2)  
		bringFocus(-1)
		return(invisible())			
	}else
		par( mfrow = plot.grid )	
	
	
	## Generate plots for each roi in a sub window of the roi plot window           
	for (i in 1:nrow(roiTable)){
		
		##Find roi PPM locations
		w1Range <- unlist(roiTable[i, 4:5])
		w2Range <- unlist(roiTable[i, 2:3]) 
		
		## Fudge the ROI table for 1D/2D compatibility
		if( roiTable$nDim[i] == 2 && nDim == 1)
			w1Range <- c(current.par$min_intensity, current.par$max_intensity)
		if( roiTable$nDim[i] == 1 && nDim > 1)
			w1Range <- c(current.par$upfield_ppm[1], current.par$downfield_ppm[1])
		
		
		## Set the file parameters
		fileFolder[[current]]$graphics.par$usr <- c(w2Range, w1Range)    
		roi.name <- roiTable$Name[i]
		
		##Plot the current roi
		if( dev.cur() != 3 ){
			dd()
			break()	
		}else{
			drawNMR(in.folder = fileFolder[[current]],  main=roi.name, xlab='', 
					ylab='', p.window = 'sub', axes = FALSE, 
					cex = globalSettings$cex.roi.sub, ...)
			
			##Draw active roi red
			if(roiTable[i, 6]){
				rect(par('usr')[1], par('usr')[4], par('usr')[2], par('usr')[3],  
						lw=2, border='red')
			}
		}                   
	}
	
	dev.set(which = 2) 
	bringFocus(-1)
}

## Create a plot of ROIs from multiple files
## ...  - Some plotting options can be passed to drawNMR and par()
rvm <- function ( ... ){
	
	## Define the current spectrum
	current <- wc()  
	cPar <- c(fileFolder[[current]]$file.par, 
			fileFolder[[current]]$graphics.par) 
	
	## Plot a black box if nothing is active
	if(length(which(roiTable[, 6] == TRUE)) == 0){
		setWindow('multi', bg = cPar$bg, fg = cPar$fg, 
				col.axis = cPar$col.axis, col.lab = cPar$col.lab,
				col.main = cPar$col.main, col.sub = cPar$col.sub,
				col = cPar$col, mfrow = c(1,1), pty = 'm', 
				mar = globalSettings$mar.multi, oma=c(.5, 0, 0, .5), xpd = FALSE )
		plot(1, 1, type = 'n', axes=FALSE, xlab='', ylab='')
		text(1, 1, 'Active ROIs will appear here \nuse rs()', cex=1)
		dev.set(which = 2)
		bringFocus(-1) 
		return(invisible())
	}   
	
	## Find the active roi files
	actFile <- which(sapply(fileFolder, function(x){x$graphics.par$roi.multi}))
	
	## Suppress rvm if no files are active     
	if( length(actFile) == 0 ){
		setWindow('multi', bg = cPar$bg, fg = cPar$fg, 
				col.axis = cPar$col.axis, col.lab = cPar$col.lab,
				col.main = cPar$col.main, col.sub = cPar$col.sub,
				col = cPar$col, mfrow = c(1,1), pty = 'm', 
				mar = globalSettings$mar.multi, oma=c(.5, 0, 0, .5),  xpd = FALSE) 
		plot(1, 1, type='n', axes=FALSE, xlab='', ylab='')
		text(1, 1, 'Active spectra will appear here \nuse rsf()', cex=1)
		dev.set(which = 2)
		bringFocus(-1)
		return(invisible())
	}
	
	
	## Create grid for roi subplots   
	plot.grid =c(length(actFile) + 1, length(which(roiTable[, 6] == TRUE)) + 1)
	setWindow('multi', bg=cPar$bg, fg=cPar$fg, 
			col.axis=cPar$col.axis, col.lab = cPar$col.lab, 
			col.main=cPar$col.main, col.sub =cPar$col.sub, 
			col=cPar$col, mfrow = plot.grid, pty = "m", 
			mar = globalSettings$mar.multi, xpd=FALSE, oma=c(.5, 0, 0, .5)) 
	
	## Make sure that plots are possible
	answer <- try(plot(1,1, type = 'n', axes=FALSE, xlab='', ylab=''), 
			silent = TRUE)
	if(class(answer) == "try-error"){
		par( mfrow = c(1,1) )
		plot(1, 1, type = 'n', axes=FALSE, xlab='', ylab='' )
		text(1, 1, paste('Too many ROIs for this window:\nresize the window and ',
						'type refresh() or deactivate rois with rs()'), cex=1)
		dev.set(which = 2)  
		bringFocus(-1)
		return(invisible())			
	}else
		par( mfrow = plot.grid )	
	
	
	## Print ROI names in first row
	for(j in  c(0, which(roiTable[, 6] == TRUE))){
		plot(0, 0, type='n', axes=FALSE, xlab='', ylab='')
		if(j == 0)
			next()
		text(0, -.5, roiTable$Name[j], cex=globalSettings$cex.roi.multi, 
				col = cPar$fg)            
	}    
	
	## Plot active ROIs from each file
	for(i in 1:(length(actFile)) ){
		
		## Print File name in first column
		if( dev.cur() != 4 ){
			dd()
			break()
		}else{
			plot(0, 0, type = 'n', axes=FALSE, xlab='', ylab='')
			text(0, 0, basename(names(actFile)[i]), xpd=FALSE, 
					cex=globalSettings$cex.files.multi, col = cPar$fg) 			
		}
		
		## Plot the data from each ROI
		for(j in  which(roiTable[, 6] == TRUE)){
			w1Range <- as.numeric(roiTable[j, 4:5])
			w2Range <- as.numeric(roiTable[j, 2:3])
			rPar <- c(fileFolder[[actFile[i]]]$file.par,
					fileFolder[[actFile[i]]]$graphics.par)
			nDim <- rPar$number_dimensions
			
			## Fudge the ROI table for 1D/2D compatibility
			if( roiTable$nDim[j] == 2 && nDim == 1)
				w1Range <- c(rPar$min_intensity, rPar$max_intensity)
			if( roiTable$nDim[j] == 1 && nDim > 1)
				w1Range <- c(rPar$downfield_ppm[1], rPar$upfield_ppm[1])
			
			## Plot the roi
			if( dev.cur() != 4 ){
				dd()
				break()				
			}else
				drawNMR (fileFolder[[actFile[i]]], w1Range = w1Range, 
						w2Range = w2Range, fg = cPar$fg, col.axis = cPar$col.axis, 
						xlab = '', ylab = '', main = '', axes = FALSE,  
						p.window = 'multi', ...) 
		}         
	}
	#return focus to console  
	dev.set(which = 2) 
	bringFocus(-1) #return focus to console       
	
}

## Internal function changeRoi
## Modifies selected rois (use to shift, expand, contract etc.)
## ppmInc - logical argument, TRUE will interpret w1Inc and w2Inc in ppm,
##          FALSE will interpret w1Inc and w2Inc in number of points
## w1Inc - Numeric value expressing the ppm (ppmInc = TRUE) or percent change 
##         (ppmInc = FALSE) in an roi in the format c(downfield, upfield).
##          Positive increment values shift ROIs downfield (or up in 1D rois).
## Note:  - In 1D rois, only the second element of w1Inc is used 
## w2Inc - Numeric value expressing the ppm (ppmInc = TRUE) or percent change 
##         (ppmInc = FALSE) in an roi in the format c(downfield, upfield)
##          Positive increment values shift ROIs downfield
changeRoi <- function (ppmInc = FALSE, w1Inc = c(0, 0), w2Inc = c(0, 0), ...){
	
	## Check incoming data
	if( is.null(roiTable) || nrow(roiTable) == 0)
		err('No ROIs have been designated, use roi()')	
	if( nrow(roiTable[roiTable$ACTIVE,]) == 0 )
		err( 'No ROIs have been selected' )
	if(length(c(w1Inc, w2Inc)) != 4  || !is.numeric(c(w1Inc, w2Inc)))
		err( 'Increments must be numeric and in the form c(downfield, upfield)')
	
	## Define the current spectrum and find chemical shifts for each point
	actTable <- roiTable[roiTable$ACTIVE,]
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	if (nDim == 3)
		nDim <- 2
	df <- fileFolder[[current]]$file.par$downfield_ppm
	uf <- fileFolder[[current]]$file.par$upfield_ppm
	ms <- fileFolder[[current]]$file.par$matrix_size
	
	## Set default for cases where downfield/upfield roiTables are identical
	w1Min <- 0 * (df[1] - uf[1]) / (ms[1] - 1)
	if( nDim == 1 ){
		w2Min <- w1Min
		w1Min <- fileFolder[[current]]$file.par$noise_est
	}else
		w2Min <- 0 * (df[2] - uf[2]) / (ms[2] - 1)
	
	## Update roi nDim to current spectrum if nDim does not match roiTable$nDim
	if(any(actTable$nDim != nDim)){
		usrInput <- myMsg(type="yesno", message = 
						paste( "Do you want to convert the active ROIs to ", 
								nDim, "D ROIs?", sep=''))
		if( usrInput == 'yes' ){
			
			## Generate new list of w1 ranges
			if( nDim == 2 )
				newW1 <- c( df[1], uf[1] )
			else
				newW1 <- c(fileFolder[[current]]$file.par$min_intensity, 
						fileFolder[[current]]$file.par$max_intensity )
			
			## Update with the new ranges
			for(i in which(actTable$nDim != nDim))
				actTable[i,4:5] <- newW1
			actTable$nDim <- nDim
		}
	}
	
	## Update w1/w2 ranges with ppm offsets
	if(ppmInc){
		actTable[ , 2] <- actTable[ , 2] + w2Inc[1]
		actTable[ , 3] <- actTable[ , 3] + w2Inc[2]
		for(i in which(actTable$nDim == 2)){
			actTable[ i , 4 ] <- actTable[i  , 4] + w1Inc[1]
			actTable[ i , 5] <- actTable[ i  , 5] + w1Inc[2]
		}
	}else{
		
		## Update w2 ranges with percent offsets
		w1Inc <- w1Inc/50; w2Inc <- w2Inc/50
		for( i in 1:nrow(actTable) ){
			actTable[i,2:3] <- c(newRange(actTable[i, 2:3], f = w2Inc[1], ...)[2], 
					newRange(actTable[i, 2:3], f = -w2Inc[2], ...)[1])
			if( actTable$nDim[i] != nDim )
				next()
			
			## Update w1 ranges with percent offsets for 2D rois
			if (actTable$nDim[i] == 2){	
				actTable[i,4:5] <- c(newRange(actTable[i, 4:5], f = w1Inc[1], ...)[2],
						newRange(actTable[i, 4:5], f = -w1Inc[2], ...)[1])
				
				## Update w1 values for 1D rois in 1D files
			}else{
				## This allows the user functions mru() and mrd() to behave properly
				if(w1Inc[1] == w1Inc[2])
					w1tmpInc <- -w1Inc
				else
					w1tmpInc <- -rev(w1Inc)
				
				## Do not allow negative max and remove upfield/downfield difference 
				actTable[i, 5] <- actTable[i, 5] + (actTable[i, 5] * w1tmpInc[1])	
				if(actTable[i, 5] <= 0)
					actTable[i, 5] <- w1Min
			}															
		}
	}
	
	## Assign new roi table and refresh the plots
	roiTable[match(row.names(actTable), row.names(roiTable)),] <- actTable
	myAssign('roiTable', roiTable)
	refresh() 
	
}

## Define region of interest from the active plot
## ...  - Additional plotting options can be passed to drawNMR and par()
rn <- function( ... ){
	
	current <- wc() 
	lineCol <- fileFolder[[current]]$graphics.par$fg
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	
	##Open main and ROI subplot window if closed
	if(length(which(dev.list() == 2)) != 1)
		drawNMR()
	
	## Bring main into focus and show the rois 
	cw(dev=2);	showRoi()
	
	if(!exists('roiTable') || is.null(roiTable))
		roiTable <- list( Name = NULL, w2_downfield = NULL, w2_upfield = NULL,  
				w1_downfield = NULL,  w1_upfield = NULL, ACTIVE = NULL, nDim = NULL)
	
	## Give the user some instructions
	cat(paste('In the main plot window:\n',  
					' Left-click two points inside the plot to designate an ROI\n',   
					' Right-click to exit\n'))
	flush.console()
	hideGui()
	
	## Have user define the plotting range by selecting a region 
	repeat{
		
		## Tell the user what to do
		op <- par('font')
		par( font = 2 )
		legend("topleft", c('LEFT CLICK FOR ROI','RIGHT CLICK TO EXIT'), 
				pch=NULL, bty='n', text.col=lineCol)
		par(font = op)
		
		## Have user define the plotting range by selecting a region 
		xy <- data.frame(locator(1, type = 'p', col = 'red', pch = 3))
		if(length(xy) == 0)
			break()   
		xy2 <- data.frame(locator(1, type = 'p', col = 'red', pch = 3))
		if(length(xy2) == 0)
			break()
		xy <- rbind(xy, xy2)
		xy$x <- sort(xy$x); xy$y <- sort(xy$y)
		
		if( nDim == 1 ){
			
			## Show the new ROI and append it to the roi table
			abline( v = xy$x, col = 'red', lwd = 2 )
			newRoi <- list( Name = 'ROI', w2_downfield = xy$x[2], 
					w2_upfield = xy$x[1], 
					w1_downfield = fileFolder[[current]]$file.par$zero_offset - 
							(xy$y[2] - fileFolder[[current]]$file.par$zero_offset) * 
							globalSettings$position.1D, w1_upfield = xy$y[2], ACTIVE = TRUE, 
					nDim = nDim)
			if (!is.null(ncol(roiTable)))
				newRoi <- c(newRoi, rep(list(NA), ncol(roiTable) - 7))
			names(newRoi) <- names(roiTable)
			roiTable <- orderROI(rbind(roiTable, data.frame(newRoi, 
									stringsAsFactors = FALSE) ))
			
			drawNMR(); showRoi(rTable = roiTable)
			
		}else{
			
			## Show the new ROI and append it to the roi table
			rect(xleft = xy$x[2], ybottom = xy$y[2], xright = xy$x[1], 
					ytop = xy$y[1], border = 'red', lwd = 2 )
			newRoi <- list( Name = 'ROI', w2_downfield = xy$x[2], 
					w2_upfield = xy$x[1],	w1_downfield = xy$y[2],  w1_upfield = xy$y[1], 
					ACTIVE = TRUE, nDim = nDim)
			if (!is.null(ncol(roiTable)))
				newRoi <-  c(newRoi, rep(list(NA), ncol(roiTable) - 7))
			names(newRoi) <- names(roiTable)
			roiTable <- orderROI(rbind(roiTable, data.frame(newRoi, 
									stringsAsFactors = FALSE) ))
			showRoi(rTable = roiTable)			
		}	
	}
	showGui()
	
	## Assign the new roi table 	
	if (is.data.frame(roiTable))
		myAssign("roiTable", roiTable)
	
	## Redraw the spectrum   
	refresh(... )
	
}

## Automatically draw rois
## w1Delta - w1 chemical shift window for each roi
## w2Delta - w2 chemical shift window for each roi
## p - padding percentage to be added to peak widths in 2D spectra when creating 
##     ROIs, if w1Delta and w2Delta are not provided.
## noiseFilt - Integer argument that can be set to 0, 1 or 2; 
##              0 does not apply a noise filter, 1 applies a mild filter
##              (adjacent points in the direct dimension must be above the 
##              noise threshold), 2 applies a strong filter (all adjacent points
##              must be above the noise threshold
## ... - Additional arguments can be passed peakPick()
ra <- function(w1Delta=globalSettings$roi.w1, w2Delta=globalSettings$roi.w2, 
		p=globalSettings$roi.pad, noiseFilt=globalSettings$roi.noiseFilt, ...) {
	
	## Find current spectrum and establish chemical shift range
	p <- p/100 + .5
	current <- wc()
	usr <- fileFolder[[current]]$graphics.par$usr
	filePar <- fileFolder[[current]]$file.par
	nuc <- filePar$nucleus
	res <- (filePar$downfield_ppm - filePar$upfield_ppm ) / filePar$matrix_size	
	nDim <- filePar$number_dimensions 
	
	if( nDim > 1 ){
		
		## Tell the user that something is happening
		if( w1Delta == 0 && w2Delta == 0 )
			cat('Measuring peak widths...\n')
		else
			cat('Generating peak list...\n')
		flush.console()
		
		## Calculate the granularity constants
		gran <- NULL
		for( i in 1:2 ){
			if(nuc[i] == '1H')
				gran <- c(gran, .05)
			else
				gran <- c(gran, .5)
		}
		w1Gran <- gran[1] %/% res[1] + 1
		w2Gran <- gran[2] %/% res[2] + 1
		
		## Generate a fancy peak list 
		peakList <- peakPick( w1Range= usr[3:4], w2Range = usr[1:2], append = FALSE, 
				internal = TRUE, fancy = TRUE, w1Gran = w1Gran, w2Gran = w2Gran, 
				noiseFilt = noiseFilt, ... )	
		if( is.null(peakList) ){
			cat('No peaks were detected \n')
			return(invisible())
		}
		peakList <- peakList[which( is.na(peakList$Multiplet)),]
		
		## Set the peak widths
		if(w1Delta == 0)
			peakList$w1D <- (peakList$w1D * p) + res[1]
		else
			peakList$w1D <- w1Delta/2
		if(w2Delta == 0)
			peakList$w2D <- (peakList$w2D * p) + res[2]
		else
			peakList$w2D <- w2Delta/2
		
		## Translate fancy peak list to roi table
		peakList <- data.frame(cbind( peakList$w2 + peakList$w2D, 
						peakList$w2 - peakList$w2D, peakList$w1 + peakList$w1D, 
						peakList$w1 - peakList$w1D), stringsAsFactors = FALSE)
		names(peakList) <- c('w2_downfield', 'w2_upfield', 'w1_downfield', 
				'w1_upfield')	
		peakList$Name <- rep('ROI', nrow(peakList))
		peakList$ACTIVE <- TRUE
		peakList$nDim <- 2
		peakList <- peakList[, match(c('Name', 'w2_downfield', 'w2_upfield', 
								'w1_downfield', 'w1_upfield', 'ACTIVE', 'nDim'), 
						names(peakList))]
	}else{
		
		## Calculate the granularity constant		
		if( w2Delta == 0 && nuc[1] == '1H')
			w2Delta <- .05
		if( w2Delta == 0 && nuc[1] != '1H')
			w2Delta <- .5
		w2Gran <- w2Delta %/% res[1] + 1
		
		## Generate a peak list
		peakList <- peakPick(w2Range = usr[1:2], append = FALSE, internal = TRUE, 
				w2Gran = w2Gran, noiseFilt = noiseFilt, ...)
		if( is.null(peakList) ){
			cat('No peaks were detected \n')
			return(invisible())
		}
		
		## Translate peak list to roi table
		peakList <- data.frame(cbind( peakList$w2 + w2Delta/2, 
						peakList$w2 - w2Delta/2, filePar$zero_offset, 
						peakList$Height + peakList$Height * .15), stringsAsFactors = FALSE)
		names(peakList) <- c('w2_downfield', 'w2_upfield', 'w1_downfield', 
				'w1_upfield')	
		peakList$Name <- rep('ROI', nrow(peakList))
		peakList$ACTIVE <- TRUE
		peakList$nDim <- 1
		peakList <- peakList[, match(c('Name', 'w2_downfield', 'w2_upfield', 
								'w1_downfield', 'w1_upfield', 'ACTIVE', 'nDim'), 
						names(peakList))]
		
		## Center the new rois
		while( TRUE ){
			peakList <- rc(inTable = peakList)
			dup <- which(duplicated(peakList[,2:3]))
			if( length(dup) == 0 )
				break()	
			peakList <- peakList[-(dup),]	
		}
	}
	
	## Save a backup copy and refresh graphics
	if (!is.null(roiTable) && ncol(roiTable) > 7){
		for (i in 1:(ncol(roiTable) - 7))
			peakList <- cbind(peakList, rep(NA, nrow(peakList)))
		names(peakList) <- names(roiTable)
	}
	peakList$clevel <- fileFolder[[current]]$graphics.par$clevel
	roiTable <- orderROI(rbind(roiTable, peakList))
	myAssign("roiTable", roiTable )
	refresh( main.plot = FALSE )
	showRoi()
	
	invisible(roiTable)	
}

## User wrapper function for lower level plot selection functions
## Allows users to select or deselect ROIs in any active plotting window
## preSel - integer indicating the plot from which ROIs will be selected,
##             1 = list, 2 = main, 3 = sub plot, 4 = multiple file plot, 
##             5 = region in main
## ...  - Plotting options can be passed to drawNMR 
rs <- function( preSel = NULL, parent=NULL, ... ){
	
	##Checks appropriate objects
	wc()
	if(length(roiTable) < 1 )
		err('No ROIs have been designated (use: roi())' )
	
	##Build a readable table of open devices
	graphicsList <- c('List of ROIs', 'Main plot window', 
			'ROI subplot window', 'Multiple file window', 'Region in main plot')
	
	##Have user select the plotting window for selection    
	if(!any(preSel == 1:5) )
		usrList <- mySelect(graphicsList, multi=FALSE, title='Select ROIs from:', 
				parent=parent)
	else
		usrList <- switch(which(1:5 == preSel), 'List of ROIs', 'Main plot window', 
				'ROI subplot window', 'Multiple file window', 'Region in main plot' )
	
	## Invoke the correct selection function
	if(usrList == 'List of ROIs')
		selList(...)
	if(usrList == 'Main plot window')
		selMain(...)
	if(usrList == 'ROI subplot window')
		selSub(...)
	if(usrList == 'Multiple file window')
		selMulti(...)
	if(usrList == 'Region in main plot')
		selRegion(...)
	
}

## Internal helper function selList
## Allows users to activate/deactivate ROIs from a list 
## ...  - Plotting options can be passed to drawNMR 
selList <- function(...){
	
	## Have user select the ROIs to activate
	usr.sel <- mySelect(c('NONE', roiTable$Name), multi = TRUE, index = TRUE,  
			preselect = roiTable$Name[which(roiTable[, 6] == TRUE)], 
			title = 'Select ROIs to activate')
	if ( length(usr.sel) == 0 || !nzchar(usr.sel) )
		return(invisible())
	
	## Update ROI table
	roiTable$ACTIVE <- FALSE
	usr.sel <- usr.sel[ usr.sel != 1 ]
	if( length(usr.sel) != 0 )
		roiTable[usr.sel - 1,]$ACTIVE <- TRUE
	
	## Refresh the plots
	myAssign('roiTable', roiTable)
	refresh(...)
	showRoi()
	invisible(usr.sel)
}

## Internal helper function selMain
## Allows users to activate/deactivate ROIs from the main plot
## ...  - Plotting options can be passed to drawNMR 
selMain <- function(...){
	
	## Set the current spectrum
	current <- wc()
	lineCol <- fileFolder[[current]]$graphics.par$fg
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	if( is.null(roiTable) || nrow(roiTable) == 0 )
		err('No ROIs have been designated (use: roi())' )
	
	##Open main and ROI subplot window if closed
	if(length(which(dev.list() == 2)) != 1)
		drawNMR()
	cw(dev=2);	showRoi()
	
	
	cat(paste('\nIn the main plot window:\n',  
					' Left-click to activate/deactivate ROIs\n',  
					' Right-click to exit\n\n')) 
	flush.console()
	hideGui()
	
	## Have user select rois from the main plot
	while( TRUE ){
		
		## Tell the user what to do
		op <- par('font')
		par( font = 2 )
		legend("topleft", c('LEFT CLICK TO SELECT','RIGHT CLICK TO EXIT'), 
				pch=NULL, bty='n', text.col=lineCol)
		par(font = op)
		
		xy <- locator(1)		
		if(is.null(xy))
			break()		
		
		## Locate the selected ROI/s
		if(nDim == 1)
			index <- which(roiTable$w2_downfield >= xy$x & 
							roiTable$w2_upfield <= xy$x )
		else
			index <- which(roiTable$w2_downfield >= xy$x & 
							roiTable$w2_upfield <= xy$x & roiTable$w1_downfield >= xy$y &
							roiTable$w1_upfield <= xy$y )		
		if(length(index) == 0 )
			next()
		
		## Update selection
		for( i in 1:length(index) ){
			if( roiTable[index[i],]$ACTIVE )
				roiTable[index[i],]$ACTIVE <- FALSE
			else
				roiTable[index[i],]$ACTIVE <- TRUE
		}
		
		## Refresh the plot
		showRoi(rTable = roiTable)
	}
	
	## Save the final copy of the list and update the plot
	showGui()
	myAssign('roiTable', roiTable)
	refresh( ... )
	showRoi()
}	

## Internal helper function selRegion
## Allows users to activate ROIs from a region in the main plot window
## ...  - Plotting options can be passed to drawNMR 
selRegion <- function(...){
	
	## Define the current spectrum
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	lineCol <- fileFolder[[current]]$graphics.par$fg
	if( is.null(roiTable) || nrow(roiTable) == 0 )
		err('No ROIs have been designated (use: roi())' )
	
	## Open main and ROI subplot window if closed
	if (!2 %in% dev.list())
		drawNMR()
	cw(dev=2)	
	showRoi()
	
	## Give the user some instructions
	hideGui()
	cat(paste('In the main plot window:\n',  
					' Left-click two points inside the plot to define region\n'))
	flush.console()
	op <- par('font')
	par(font=2)
	legend("topleft", c('LEFT CLICK TO DEFINE REGION', 'RIGHT CLICK TO CANCEL'), 
			pch=NULL, bty='n', text.col=lineCol)
	par(font=op)
	
	##define the first boundary for the region
	usrCoord1 <- data.frame(locator(1))
	if (length(usrCoord1) == 0){
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		showGui()
		return(invisible())
	}
	abline(v=usrCoord1$x, col=lineCol )
	if (nDim != 1)
		abline(h=usrCoord1$y, col=lineCol )    
	
	##define other boundary for the region
	usrCoord2 <- data.frame(locator(1))
	if (length(usrCoord2) == 0){
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		showGui()
		return(invisible())
	}
	abline(v=usrCoord2$x, col=lineCol )
	if (nDim != 1)
		abline(h=usrCoord2$y, col=lineCol )   
	usrCoord <- rbind(usrCoord1, usrCoord2)
	usrCoord$x <- sort(usrCoord$x)
	usrCoord$y <- sort(usrCoord$y)
	showGui()
	
	## Identify the selected ROIs
	includeUp <- which(roiTable$w2_upfield <= usrCoord$x[2] & 
					roiTable$w2_upfield >= usrCoord$x[1])
	includeDown <- which(roiTable$w2_downfield <= usrCoord$x[2] & 
					roiTable$w2_downfield >= usrCoord$x[1])
	if (nDim == 1)
		selRois <- unique(c(includeUp, includeDown))
	else{
		w2Matches <- unique(c(includeUp, includeDown))
		includeUp <- which(roiTable$w1_upfield <= usrCoord$y[2] & 
						roiTable$w1_upfield >= usrCoord$y[1])
		includeDown <- which(roiTable$w1_downfield <= usrCoord$y[2] & 
						roiTable$w1_downfield >= usrCoord$y[1])
		w1Matches <- unique(c(includeUp, includeDown))
		selRois <- w1Matches[w1Matches %in% w2Matches]
	}
	
	## Update selection and refresh
	if (length(selRois) == 0){
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		showRoi()
		return(invisible())
	}
	newTable <- roiTable
	newTable[selRois, 'ACTIVE'] <- TRUE
	myAssign('roiTable', newTable)
	refresh(...)
	showRoi()
}	

## Internal helper function selSub
## Allows users to activate/deactivate ROIs from the sub plot
## ...  - Plotting options can be passed to drawNMR 
selSub <- function(...){
	
	##Open main and ROI subplot window if closed
	devClose <- FALSE
	if(length(which(dev.list() == 3)) != 1){
		rvs()
		devClose = TRUE
	}
	
	## Bring main into focus and reset par
	cw(dev=3) 	
	op <- par(mfg = c(1,1,par('mfg')[3:4])) 
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	cat(paste('\nIn the ROI subplot window:\n',  
					' Left-click to activate/deactivate ROIs\n',  
					' Right-click to exit\n\n')) 
	flush.console()
	hideGui()
	
	## Have user select rois from the sub plot
	while( TRUE ){
		
		## Have user select the roi or exit
		xy <- locator(1)
		if(is.null(xy))
			break()		
		xy$x <- trunc( grconvertX(xy$x, from = 'user', to = 'nic') * op$mfg[4] ) + 1
		xy$y <- trunc( op$mfg[3] - 
						grconvertY( xy$y, from = 'user', to = 'nic') * op$mfg[3] + 1 ) 
		userSel <- xy$x + (op$mfg[4] * (xy$y-1))
		if(userSel > nrow(roiTable) )
			next()
		
		## Update selection
		if(roiTable[userSel, 6]){
			col = 'white'
			roiTable[userSel, 6] <- FALSE
		}else{
			col = 'red'
			roiTable[userSel, 6] <- TRUE
		}
		
		## Refresh the plot
		par(mfg = c(unlist(rev(xy)), op$mfg[3:4]))
		box( which = 'plot', col = col)
	}
	
	## Save the final copy of the list and update the plot
	showGui()
	par( op )
	myAssign('roiTable', roiTable)
	if(devClose)
		dev.off(3)
	refresh( ... )
	showRoi()
}	

## Internal helper function selMulti
## Allows users to activate/deactivate ROIs from the ROI multi plot
## ...  - Plotting options can be passed to drawNMR 
selMulti <- function(...){
	
	## Open select list if no ROIs are active
	if(length(which(roiTable$ACTIVE)) < 1 ){
		actRoi <- selList() 
		if(length( actRoi ) < 1 )
			return(invisible())
	}
	
	## Open select list if no files are active
	if( length(which(sapply(fileFolder, 
							function(x){x$graphics.par$roi.multi}))) < 1 )
		rsf()
	
	
	##Open main and ROI subplot window if closed
	devClose <- FALSE
	if(length(which(dev.list() == 4)) != 1){
		rvm()
		devClose <- TRUE
	}
	
	## Bring main into focus and reset par
	cw( dev = 4 ) 	
	op <- par(mfg = c(1,1,par('mfg')[3:4]))
	if (.Platform$OS.type == 'windows')
		cat(paste('\nIn the multiple file window:\n',  
						' Left-click on file names to change files\n',  
						' Left-click on ROI names to change ROIs\n',
						' Left-click on spectra to view ROI in main window\n',
						' Right-click to exit\n\n'))
	else
		cat(paste('\nIn the multiple file window:\n',  
						' Left-click on spectra to view ROI in main window\n',
						' Right-click to exit\n\n'))
	flush.console()	
	hideGui()
	
	## Have user select rois from the sub plot
	while( TRUE ){
		
		## Have user select the roi or exit
		xy <- locator(1)
		if(is.null(xy) )
			break()		
		xy$x <- trunc( grconvertX(xy$x, from = 'user', to = 'nic') * op$mfg[4] ) 
		xy$y <- trunc( op$mfg[3] - 
						grconvertY( xy$y, from = 'user', to = 'nic') * op$mfg[3]  ) 
		
		## Skip cases where nothing is selected
		if (xy$x == 0 && xy$y == 0 )
			next()
		
		## Open ROI list if user selects an roi name
		if (xy$y == 0 && xy$x != 0){
			if (.Platform$OS.type == 'windows'){
				actRoi <- selList()
				if(length( actRoi ) < 1 ){
					cw(2)
					showGui()
					return(invisible())
				}
			}else
				next()
			cw(4)
			op <- par(mfg = c(1,1,par('mfg')[3:4]))
			break()
		}
		
		## Open active file list if user selects a file name
		if( xy$x ==0 && xy$y !=0 ){
			if (.Platform$OS.type == 'windows'){
				if (is.null(rsf())){
					showGui()
					return(invisible())
				}
			}else
				next()
			cw(4)
			op <- par(mfg = c(1,1,par('mfg')[3:4]))
			break()
		}
		
		
		## Change current spectrum 
		currentSpectrum <- names(which(sapply(fileFolder, 
								function(x){x$graphics.par$roi.multi})))[xy$y]
		myAssign('currentSpectrum', currentSpectrum, save.backup = FALSE)
		current <- wc()
		nDim <- fileFolder[[current]]$file.par$number_dimensions
		if (nDim == 3)
			nDim <- 2
		
		## Update zoom
		tusr <- as.numeric(roiTable[roiTable$ACTIVE,][xy$x,2:5])
		if ( roiTable[roiTable$ACTIVE,][1,]$nDim != nDim && nDim == 2)
			tusr[3:4] <- c(fileFolder[[current]]$file.par$downfield_ppm[1], 
					fileFolder[[current]]$file.par$upfield_ppm[1])
		if ( roiTable[roiTable$ACTIVE,][1,]$nDim != nDim && nDim == 1 )
			tusr[3:4] <- c(fileFolder[[current]]$file.par$min_intensity, 
					fileFolder[[current]]$file.par$max_intensity)
		setGraphics(usr = tusr)
		
		## Refresh the graphics
		refresh( multi.plot = FALSE, ...)
		cw(4)
	}
	showGui()
	par( op )
	if(devClose)
		dev.off(4)
	dev.set(2)
	showRoi()
}

## Activate all ROIs 
rsAll <- function(){
	if(is.null(roiTable))
		err('There are no ROIs to select')
	roiTable$ACTIVE <- TRUE
	myAssign('roiTable', roiTable)
	refresh()
}

## Deactivate all ROIs
rdAll <- function(){
	if(is.null(roiTable))
		err('There are no ROIs to select' )
	roiTable$ACTIVE <- FALSE
	myAssign('roiTable', roiTable)
	refresh()
}

## Allows user to delete ROIs 
##roiNames - character vector; names of ROIs to delete
rDel <- function(roiNames){
	if(is.null(roiTable))
		stop('There are no ROIs to delete', call.=FALSE)
	
	## Present users with possible ROIs to delete
	if (missing(roiNames)){
		del.list <- mySelect(roiTable$Name, 
				roiTable[roiTable$ACTIVE == TRUE, ]$Name, multi = TRUE, index=TRUE, 
				title = 'ROIs to be deleted')
		if( length(del.list) == 0 || !nzchar(del.list) )
			return(invisible())  
	}else{
		del.list <- unlist(na.omit(match(roiNames, roiTable$Name)))
		if (!length(del.list))
			return(invisible())
	}
	
	## Double check that the user wants to delete the ROIs
	userChoice <- myMsg(type = "okcancel",
			message=paste('Confirm deletion of ', length(del.list), ' ROI(s)?'))
	if(userChoice != 'ok')
		return(invisible())		
	
	## Remove selected rois and duplicates and renumber rois
	roiTable <- roiTable[- del.list, ]
	roiTable$Name <- as.vector(sapply(roiTable[,1], 
					function(x){unlist(strsplit(x, ".", fixed = TRUE))[1]}))
	roiTable <- unique(roiTable)
	for( i in 1: length(roiTable$Name) ){
		tName <- which(roiTable$Name == roiTable$Name[i])
		if( length (tName) != 1 )
			roiTable$Name[tName] <- paste(roiTable$Name[i], 
					1:length(tName), sep ='.' )
	}
	
	## Update file folder and refresh the graphics	
	row.names(roiTable) <- NULL
	if (nrow(roiTable) == 0)
		roiTable <- NULL
	myAssign('roiTable', roiTable)
	refresh()       
} 

## User ROI function rr
## Rename active ROIs
rr <- function(){
	
	##display in error if there are no ROIs
	if (is.null(roiTable) || !nrow(roiTable))
		err('No ROIs have been designated, use roi()')	
	
	##get active ROI names
	activeNames <- roiTable[roiTable$ACTIVE,]$Name
	if (all(activeNames == activeNames[1]))
		defName <- activeNames[1]
	else
		defName <- ''
	
	##ask user for new name
	newName <- myDialog('ROI name:', defName, 'Rename ROIs')
	if (is.null(newName))
		return(invisible())
	
	##assign name to active ROIs
	newTable <- roiTable
	newTable[roiTable$ACTIVE, 'Name'] <- newName
	newTable <- orderROI(newTable)
	myAssign('roiTable', newTable)
	refresh()
}

## User ROI function re
## Allows user to edit values in the ROI table
re <- function(table){
	
	##check ROI table
	if (missing(table)){
		if (!exists('roiTable') || is.null(roiTable) || nrow(roiTable) == 0)
			err('The ROI table is empty')
		usrTable <- roiTable
	}else
		usrTable <- table
	
	##coerce data to the proper format
	colModes <- c('character', 'numeric', 'numeric', 'numeric', 'numeric', 
			'logical', 'numeric', rep('character', ncol(usrTable) - 7))
	for (i in seq_along(colModes))
		suppressWarnings(storage.mode(usrTable[, i]) <- colModes[i])
	
	##edit a table other than the current ROI table
	if (!missing(table)){
		
		##create verification functions
		nameVer <- function(x) return(all(!is.na(x)) && 
							all(is.na(suppressWarnings(as.numeric(x)))))
		verFun <- function(x) return(!any(is.na(x)))
		nDimVer <- function(x) return(all(!is.na(x)) && all(x == 1 | x == 2))
		extraVer <- function(x) return(TRUE)
		errors <- c('Each ROI must have a name beginning with a character',
				rep('Chemical shifts must be numeric', 4), 
				'Activity must be either TRUE or FALSE',
				'The nDim column must contain integers 1 or 2 only', 
				rep(NA, ncol(usrTable) - 7))
		
		##call tableEdit to allow user to edit roiTable
		hideGui()
		usrTable <- tableEdit(usrTable, title='Edit ROIs', errMsgs=errors,
				colVer=c(nameVer, rep(list(verFun), 5), nDimVer, rep(list(extraVer), 
								ncol(usrTable) - 7)))
		if (is.null(usrTable)){
			showGui()
			return(invisible())
		}
		
		##remove duplicate ROIs, renumber, and sort ROIs
		usrTable <- orderROI(roiTable=usrTable)
		
		##checks that the shift columns' values are arranged correctly
		change <- which(usrTable$w2_downfield < usrTable$w2_upfield)
		if (length(change) > 0){
			tmp <- usrTable$w2_downfield[change]
			usrTable$w2_downfield[change] <- usrTable$w2_upfield[change]
			usrTable$w2_upfield[change] <- tmp
		}
		twods <- which(usrTable$nDim == 2)
		change <- which(usrTable$w1_downfield < usrTable$w1_upfield)
		change2D <- match(change, twods)
		change2D <- change2D[which(!is.na(change2D))]
		if (length(change2D)){
			tmp <- usrTable$w1_downfield[change2D]
			usrTable$w1_downfield[change2D] <- usrTable$w1_upfield[change2D]
			usrTable$w1_upfield[change2D] <- tmp
		}
		
		##return edited table
		showGui()
		return(usrTable)
	}
	
	##store an original copy of the ROI table
	origTable <- usrTable
	
	##creates edit window
	dlg <- myToplevel('re')
	if (is.null(dlg))
		return(invisible())
	tkwm.title(dlg, 'Edit ROIs')
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##create button to be invoked by view button in table
	onView <- function(){
		
		##get selected row
		current <- wc()
		usrSel <- as.numeric(tcl(tableList, 'curselection')) + 1
		if (!length(usrSel))
			return(invisible())
		nDim <- fileFolder[[current]]$file.par$number_dimensions
		
		##zoom in on an ROI
		tusr <- as.numeric(roiTable[usrSel, 2:5])
		if (roiTable$nDim[usrSel] != nDim && nDim == 2)
			tusr[3:4] <- c(fileFolder[[current]]$file.par$downfield_ppm[1], 
					fileFolder[[current]]$file.par$upfield_ppm[1])
		if (roiTable$nDim[usrSel] != nDim && nDim == 1 )
			tusr[3:4] <- c(fileFolder[[current]]$file.par$min_intensity, 
					fileFolder[[current]]$file.par$max_intensity)
		setGraphics(usr=tusr, refresh=TRUE)
	}
	tkbutton(dlg, command=onView)
	
	##define columns for tablelist widget
	colNames <- colnames(usrTable)
	colVals <- c('5', 'View', 'center')
	for (i in colNames)
		colVals <- c(colVals, '0', i, 'left')
	
	##create tablelist widget
	tableFrame <- ttkframe(dlg)
	xscr <- ttkscrollbar(tableFrame, orient='horizontal', command=function(...) 
				tkxview(tableList, ...))
	yscr <- ttkscrollbar(tableFrame, orient='vertical', command=function(...) 
				tkyview(tableList, ...))
	tableList <- tkwidget(tableFrame, 'tablelist::tablelist', columns=colVals, 
			activestyle='underline', height=15, width=120, bg='white', stretch='all',
			exportselection=FALSE, selectmode='extended', editselectedonly=TRUE,
			selecttype='cell', xscrollcommand=function(...) tkset(xscr, ...),
			yscrollcommand=function(...) tkset(yscr, ...))
	
	##add data to tablelist widget
	for (i in 1:nrow(roiTable))
		tkinsert(tableList, 'end', c('', unlist(roiTable[i, ])))
	for (i in seq_along(colNames)){
		tcl(tableList, 'columnconfigure', i, sortmode='dictionary', 
				editable=TRUE, labelcommand='tablelist::sortByColumn')
	}
	
	##clears tablelist widget and repopulates it using the current ROI table
	fillTable <- function(){
		tcl(tableList, 'cancelediting')
		tkdelete(tableList, 0, 'end')
		if (is.null(roiTable))
			return(invisible())
		for (i in 1:nrow(roiTable)){
			tkinsert(tableList, 'end', c('', unlist(roiTable[i, ])))
			tcl(tableList, 'cellconfigure', paste(i - 1, '0', sep=','), 
					window='createButton')
		}
		tkwm.deiconify(dlg)
		tkfocus(dlg)
	}
	
	##saves data after table is edited
	writeData <- function(refreshPlot=TRUE){
		
		##get the data from the GUI
		newData <- NULL
		numRows <- as.numeric(tcl(tableList, 'index', 'end'))
		if (numRows == 0){
			myAssign('roiTable', NULL)
			if (refreshPlot)
				refresh()
			return(invisible())
		}
		for (i in 0:numRows)
			newData <- rbind(newData, as.character(tcl(tableList, 'get', i)))
		newData <- newData[, -1]
		
		##format data
		colnames(newData) <- colNames
		newData <- as.data.frame(newData, stringsAsFactors=FALSE)
		for (i in 1:ncol(newData))
			suppressWarnings(storage.mode(newData[, i]) <- colModes[i])
		if (identical(newData, roiTable))
			return(invisible())
		
		##remove duplicate ROIs, renumber, and sort ROIs
		roiTable <- orderROI(roiTable=newData)
		
		##update GUI if it doesn't match roiTable
		if (!identical(newData, roiTable)){
			tkdelete(tableList, 0, 'end')
			for (i in 1:nrow(roiTable)){
				tkinsert(tableList, 'end', c('', unlist(roiTable[i, ])))
				tcl(tableList, 'cellconfigure', paste(i - 1, '0', sep=','), 
						window='createButton')
			}
		}
		
		##check that the shift columns' values are arranged correctly
		change <- which(roiTable$w2_downfield < roiTable$w2_upfield)
		if (length(change) > 0){
			tmp <- roiTable$w2_downfield[change]
			roiTable$w2_downfield[change] <- roiTable$w2_upfield[change]
			roiTable$w2_upfield[change] <- tmp
		}
		twods <- which(roiTable$nDim == 2)
		change <- which(roiTable$w1_downfield < roiTable$w1_upfield)
		change2D <- match(change, twods)
		change2D <- change2D[which(!is.na(change2D))]
		if (length(change2D) > 0){
			tmp <- roiTable$w1_downfield[change2D]
			roiTable$w1_downfield[change2D] <- roiTable$w1_upfield[change2D]
			roiTable$w1_upfield[change2D] <- tmp
		}
		
		##assign ROI table and refresh
		myAssign('roiTable', roiTable)
		if (refreshPlot)
			refresh()
		tkwm.deiconify(dlg)
	}
	
	##renumber indices when columns are sorted
	onSort <- function(){
		writeData(FALSE)
		fillTable()
	}
	tkbind(tableList, '<<TablelistColumnSorted>>', onSort)
	
	##create image for view button
	createTclImage('view')
	
	##create a tcl procedure that creates a view button
	tcl('proc', 'createButton', 'tbl row col w', paste('button $w -image', 
					'view -width 0 -takefocus 0 -command {.re.1 invoke}'))
	
	##configure first colum to display view buttons
	for (i in 1:nrow(roiTable) - 1)
		tcl(tableList, 'cellconfigure', paste(i, '0', sep=','), 
				window='createButton')
	
	##select entire row when view button is pressed
	onViewButton <- function(W){
		if (!length(grep('k', W)))
			return(invisible())
		rowNum <- strsplit(W, '.*_k')[[1]][2]
		rowNum <- as.numeric(strsplit(rowNum, ',')[[1]][1])
		tkselection.clear(tableList, 0, 'end')
		tkselection.set(tableList, rowNum)
	}
	tkbind(dlg, '<Button-1>', onViewButton)
	
	##selects all rows Ctrl+A is pressed
	tkbind(tableList, '<Control-a>', function(...) 
				tkselect(tableList, 'set', 0, 'end'))	
	
	##wrapper function for rearranging rows in ROI table
	onMove <- function(movement){
		
		##get selection
		tcl(tableList, 'finishediting')
		n <- nrow(roiTable)
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel))
			return(invisible())
		usrSel <- usrSel + 1
		if (movement %in% c('top', 'up') && usrSel == 1)
			return(invisible())
		if (movement %in% c('bottom', 'down') && usrSel == n)
			return(invisible())
		
		##determine new position
		indices <- (1:n)[-usrSel]
		newPos <- switch(movement, 'top'=0, 'up'=usrSel - 2, 'down'=usrSel, 
				'bottom'=n - 1)
		
		##rearrange ROI table and save
		roiTable <- roiTable[append(indices, usrSel, newPos), ]
		myAssign('roiTable', roiTable)
		
		##remove data from tablelist widget and repopulate
		fillTable()
		tkselection.set(tableList, newPos)
		tcl(tableList, 'see', newPos)
	}
	
	##create top button
	optionFrame <- ttkframe(dlg)
	moveFrame <- ttklabelframe(optionFrame, text='Move selected rows', padding=6)
	topButton <- ttkbutton(moveFrame, text='Top', width=11, command=function(...) 
				onMove('top'))
	
	##create up button
	upButton <- ttkbutton(moveFrame, text='^', width=9, command=function(...) 
				onMove('up'))
	
	##create down button
	downButton <- ttkbutton(moveFrame, text='v', width=9, command=function(...) 
				onMove('down'))
	
	##create bottom button
	bottomButton <- ttkbutton(moveFrame, text='Bottom', width=11, 
			command=function(...) onMove('bottom'))
	
	##create sig. fig. spinbox
	sigFigFrame <- ttklabelframe(optionFrame, text='Display', padding=6)
	onSigFig <- function(){
		if (tclvalue(sigFigVal) == 'max'){
			for (i in 1:nrow(roiTable)){
				newData <- c('', unlist(roiTable[i, ]))
				tcl(tableList, 'rowconfigure', i - 1, text=newData)
			}
			return(invisible())
		}
		sigFig <- as.numeric(tclvalue(sigFigVal))
		for (i in seq_along(colNames)){
			if (any(is.logical(roiTable[, i])))
				next
			newData <- tryCatch(signif(roiTable[, i], sigFig), error=function(er) 
						return(roiTable[, i]))
			newData[is.na(newData)] <- 'NA'
			tcl(tableList, 'columnconfigure', i, text=newData)
		}
	}
	sigFigVal <- tclVar('max')
	sigFigBox <- tkwidget(sigFigFrame, 'spinbox', width=6, wrap=TRUE,
			textvariable=sigFigVal, values=c('max', 1:9), command=onSigFig)
	sigFigLabel <- ttklabel(sigFigFrame, text='significant figures')
	
	##check interactively edited cells using functions provided in colVer
	onEdit <- function(widget, rowNum, colNum, newVal, tclReturn=TRUE){
		
		##format new cell value
		rowNum <- as.numeric(rowNum) + 1
		colNum <- as.numeric(colNum)
		suppressWarnings(storage.mode(newVal) <- colModes[colNum])
		
		##check edits to the Name column
		if (colNum == 1 && (is.na(newVal) || 
					!is.na(suppressWarnings(as.numeric(newVal))))){
			myMsg('Each ROI must have a name beginning with a character', 
					icon='error', parent=dlg)
			tcl(tableList, 'cancelediting')
			if (!tclReturn)
				return(FALSE)
		}
		
		##check edits to the chemical shift columns
		if (colNum %in% 2:5 && is.na(newVal)){
			myMsg('Chemical shifts must be numeric', icon='error', parent=dlg)
			tcl(tableList, 'cancelediting')
			if (!tclReturn)
				return(FALSE)
		}
		
		##check edits to the ACTIVE column
		if (colNum == 6 && is.na(newVal)){
			myMsg('Values in the ACTIVE column must be logical', icon='error', 
					parent=dlg)
			tcl(tableList, 'cancelediting')
			if (!tclReturn)
				return(FALSE)
		}
		
		##check edits to the nDim column
		if (colNum == 7 && is.na(newVal)){
			myMsg('The nDim column must contain integers 1 or 2 only', icon='error', 
					parent=dlg)
			tcl(tableList, 'cancelediting')
			if (!tclReturn)
				return(FALSE)
		}
		
		##update the selected cell with the new value
		if (tclReturn)
			return(tclVar(as.character(newVal)))
		else
			return(TRUE)
	}
	tkconfigure(tableList, editendcommand=function(...) onEdit(...))
	
	##save the updated ROI table after interactive cell editing
	tkbind(tableList, '<<TablelistCellUpdated>>', function(...) writeData(...))
	
	##create copy button
	rowEditFrame <- ttklabelframe(optionFrame, text='Edit rows', padding=6)
	clipboard <- NULL
	onCopy <- function(){
		tcl(tableList, 'finishediting')
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel) || usrSel == 0)
			return(invisible())
		tkselection.set(tableList, usrSel)
		selVals <- NULL
		for (i in usrSel)
			selVals <- rbind(selVals, as.character(tcl(tableList, 'get', i)))
		selVals <- selVals[, -1]
		if (is.null(nrow(selVals)))
			selVals <- t(selVals)
		clipboard <<- data.frame(selVals, stringsAsFactors=FALSE)
	}
	copyButton <- ttkbutton(rowEditFrame, text='Copy', width=10, command=onCopy)
	
	##create paste button
	onPaste <- function(){
		tcl(tableList, 'finishediting')
		if (is.null(clipboard))
			return(invisible())
		names(clipboard) <- colNames
		clipboard[, 1] <- paste('ROI', (1:nrow(clipboard) + nrow(roiTable)) - 1, 
				sep='.')
		roiTable <- rbind(roiTable, clipboard)
		n <- nrow(roiTable)
		for (i in 1:ncol(roiTable))
			suppressWarnings(storage.mode(roiTable[, i]) <- colModes[i])
		myAssign('roiTable', roiTable)
		fillTable()
		tkselection.set(tableList, nrow(roiTable) - 1)
		tcl(tableList, 'see', nrow(roiTable) - 1)
	}
	pasteButton <- ttkbutton(rowEditFrame, text='Paste', width=10, 
			command=onPaste)
	
	##create insert button
	onInsert <- function(){
		tcl(tableList, 'finishediting')
		nDim <- fileFolder[[currentSpectrum]]$file.par$number_dimensions
		clevel <- fileFolder[[currentSpectrum]]$graphics.par$clevel
		newRow <- c('New', rep(0, 4), FALSE, nDim, clevel, 
				rep(NA, ncol(roiTable) - 8))
		roiTable <- orderROI(rbind(roiTable, newRow))
		for (i in 1:ncol(roiTable))
			suppressWarnings(storage.mode(roiTable[, i]) <- colModes[i])
		myAssign('roiTable', roiTable)
		fillTable()
		tkselection.set(tableList, nrow(roiTable))
		tcl(tableList, 'see', nrow(roiTable))
	}
	insertButton <- ttkbutton(rowEditFrame, text='Insert', width=10, 
			command=onInsert)
	
	##create delete button
	onDelete <- function(){
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel))
			return(invisible())
		for (i in rev(usrSel))
			tkdelete(tableList, i)
		tkselection.clear(tableList, 0, 'end')
		tkselection.set(tableList, usrSel[length(usrSel)] - length(usrSel))
		writeData()
	}
	deleteButton <- ttkbutton(rowEditFrame, text='Delete', width=10, 
			command=onDelete)
	
	##create cell editing textbox
	cellEditFrame <- ttklabelframe(optionFrame, text='Edit selected cells', 
			padding=6)
	usrEntry <- tclVar(character(0))
	textEntry <- ttkentry(cellEditFrame, width=13, justify='center', 
			textvariable=usrEntry)
	
	##update cell editing textbox with current cell selection value
	onCellSel <- function(){
		usrSel <- as.character(tcl(tableList, 'curcellselection'))
		if (!length(usrSel))
			tclObj(usrEntry) <- character(0)
		selVals <- as.character(tcl(tableList, 'getcells', usrSel))
		if (nzchar(selVals[1]) && 
				length(grep(selVals[1], selVals, fixed=TRUE)) == length(selVals))
			tclObj(usrEntry) <- selVals[1]
		else
			tclObj(usrEntry) <- character(0)
	}
	tkbind(tableList, '<<TablelistSelect>>', onCellSel)
	
	##create apply button
	onApply <- function(){
		tcl(tableList, 'finishediting')
		newVal <- tclvalue(usrEntry)
		usrSel <- as.character(tcl(tableList, 'curcellselection'))
		for (i in usrSel){
			rowNum <- unlist(strsplit(i, ','))[1]
			colNum <- unlist(strsplit(i, ','))[2]
			isValid <- onEdit(rowNum=rowNum, colNum=colNum, newVal=newVal, 
					tclReturn=FALSE)
			if (isValid)
				tcl(tableList, 'cellconfigure', i, text=newVal)
			else
				return(invisible())
		}
		writeData()
	}
	applyButton <- ttkbutton(cellEditFrame, text='Apply', width=8, 
			command=onApply)
	
	##create export button
	tableOptionFrame <- ttklabelframe(optionFrame, text='Table', padding=6)
	onExport <- function(){
		tcl(tableList, 'finishediting')
		tkwm.iconify(dlg)
		fileName <- mySave(initialfile='roiTable', defaultextension='txt', 
				title='Export', filetypes=list('xls'='Excel Files', 'txt'='Text Files'))
		if (!length(fileName) || !nzchar(fileName)){
			tkwm.deiconify(dlg)
			return(invisible())
		}
		write.table(roiTable, file=fileName, quote=FALSE, sep='\t', row.names=FALSE, 
				col.names=TRUE)
		tkwm.deiconify(dlg)
	}
	exportButton <- ttkbutton(tableOptionFrame, text='Export', width=11, 
			command=onExport)
	
	##create restore button
	onRestore <- function(){
		if (identical(origTable, roiTable))
			return(invisible)
		myAssign('roiTable', origTable)
		refresh()
		fillTable()
	}
	restoreButton <- ttkbutton(tableOptionFrame, text='Restore', width=11, 
			command=onRestore)
	
	##create refresh button
	refreshButton <- ttkbutton(tableOptionFrame, text='Refresh', width=11, 
			command=fillTable)
	
	##add widgets to tableFrame
	tkgrid(tableFrame, column=1, row=1, sticky='nswe', pady=6, padx=6)
	tkgrid(tableList, column=1, row=1, sticky='nswe')
	tkgrid(xscr, column=1, row=2, sticky='we')
	tkgrid(yscr, column=2, row=1, sticky='ns')
	
	##make tableFrame stretch when window is resized
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=1)
	tkgrid.columnconfigure(tableFrame, 1, weight=1)
	tkgrid.rowconfigure(tableFrame, 1, weight=1)
	
	##add widgets to moveFrame
	tkgrid(optionFrame, column=1, row=2, pady=c(8, 0))
	tkgrid(moveFrame, column=1, row=1, padx=8)
	tkgrid(topButton, column=1, row=1, pady=2, padx=c(0, 4))
	tkgrid(upButton, column=2, row=1, pady=2, padx=1)
	tkgrid(downButton, column=3, row=1, padx=1, pady=2)
	tkgrid(bottomButton, column=4, row=1, pady=2, padx=c(4, 0))
	
	##add widgets to sigFigFrame
	tkgrid(sigFigFrame, column=2, row=1, padx=8)
	tkgrid(sigFigBox, column=1, row=1, padx=c(4, 2), pady=c(2, 4))
	tkgrid(sigFigLabel, column=2, row=1, padx=c(0, 4), pady=c(2, 4))
	
	##add widgets to rowEditFrame
	tkgrid(rowEditFrame, column=1, row=2, pady=4, padx=8)
	tkgrid(copyButton, column=1, row=1, padx=c(0, 2))
	tkgrid(pasteButton, column=2, row=1, padx=c(0, 8))
	tkgrid(insertButton, column=3, row=1, padx=c(0, 2))
	tkgrid(deleteButton, column=4, row=1, padx=c(0, 0))
	
	##add widgets to colEditFrame
	tkgrid(cellEditFrame, column=2, row=2, pady=4, padx=8)
	tkgrid(textEntry, column=1, row=1, padx=2)
	tkgrid(applyButton, column=3, row=1, padx=2)
	
	##add widgets to rightFrame
	tkgrid(tableOptionFrame, column=3, row=1, rowspan=2, padx=c(14, 10))
	tkgrid(exportButton, column=1, row=1)
	tkgrid(restoreButton, column=1, row=2, pady=6)
	tkgrid(refreshButton, column=1, row=3)
	tkgrid(ttksizegrip(dlg), column=1, row=3, sticky='se')
	
	##Allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (length(grep('.2.2.3.1$', focus)))
			onApply()
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter)
	tkfocus(tableList)
	
	return(invisible())
}

## User ROI function se
## Allows user to edit ROI Summary
se <- function(summary=NULL){
	
	if (is.null(summary) && (!exists('roiSummary') || is.null(roiSummary)))
		err( 'An ROI summary has not been generated, use rSum().' )
	
	if (is.null(summary))
		usrSum <- roiSummary$data
	else
		usrSum <- summary
	
	## Coerce data to the proper format
	colmodes <- c('character', rep('numeric', ncol(usrSum) - 1))
	for (i in seq_along(colmodes))
		suppressWarnings(storage.mode(usrSum[, i]) <- colmodes[i])
	
	## Call tableEdit to allow user to edit roiSummary
	hideGui()
	usrSum <- tableEdit(usrSum, title='Edit ROIs')
	if (is.null(usrSum)){
		showGui()
		return(invisible())
	}
	
	## Update ROI summary
	if (is.null(summary)){
		newSum <- roiSummary
		newSum$data <- usrSum
		myAssign('roiSummary', newSum)
		showGui()
	}else{
		showGui()
		return(summary)
	}
}

## Allow users to select the roi files in memory they wish to view in the
## multiple file window
rsf <- function(){
	
	##Check for open files
	wc()
	
	## Find the active roi files
	actFiles <- names(which(sapply(fileFolder, 
							function(x){x$graphics.par$roi.multi})))
	allFiles <- getTitles(names(fileFolder), FALSE)
	
	## Have user select files to display    
	usrList <- mySelect(allFiles, multiple = TRUE, preselect = actFiles,
			title = 'Select files for the ROI plot', index = TRUE )
	if( length(usrList) == 0 || !nzchar(usrList) )
		return(invisible())
	
	## Reset the file selection an refresh
	setGraphics(all.files = TRUE, roi.multi = FALSE, save.backup = FALSE)
	setGraphics(file.name = names(fileFolder)[usrList], roi.multi = TRUE, 
			save.backup = TRUE)
	refresh( main.plot = FALSE, overlay = FALSE, sub.plot = FALSE )
	invisible(names(fileFolder)[usrList])
}

## User function rSum
## Summerizes NMR spectral ROIs by intensity, area, or chemical shift
## ask - logical; if TRUE, a series of dialogs are displayed to obtain input 
##	parameters from the user and all other arguments will be ignored
## sumFiles - character string/vector; spectrum name(s) as returned by 
##						names(fileFolder)
## sumRois - character string/vector; ROIs to be included in the summary
## sumType - character string; indicates how the ROI data should be summarized,
##	must be one of "maximum", "minimum", "absMax", "area", "absArea", "w1", or 
##	"w2"
## normType - character string; indicates how the ROI data should be normalized,
##	must be one of "none", "internal", "crossSpec", "signal/noise", or "sum"
## normList - characters string or vector; one or more files or ROIs to be used
##	when normalizing the ROI data (only applicable if normType is set to 
##	"internal" or "crossSpec")
## Returns ROI summary data table
rSum <- function(ask=TRUE, sumFiles, sumRois, sumType, normType='none', 
		normList=NA){
	
	## Check to make sure the requisite files/ROIs are present
	wc()
	if (!exists('roiTable') || is.null(roiTable))
		err( 'No ROIs have been designated, use roi()')
	
	## Get summary parameters from user if ask is set to TRUE
	actFiles <- getTitles(names(which(sapply(fileFolder, function(x) 
										x$graphics.par$roi.multi))))
	
	if (ask){
		
		## Have user select the files to use for the summary
		sumFiles <- mySelect(getTitles(names(fileFolder), FALSE), 
				title='Select summary files:', preselect=actFiles, multiple=TRUE, 
				index=TRUE)
		if (!length(sumFiles) || !nzchar(sumFiles))
			return(invisible())	
		sumFiles <- names(fileFolder)[sumFiles]
		
		## Have user select the ROIs to use for the summary
		sumRois <- mySelect(roiTable$Name, title='Select summary ROIs:', 
				preselect=roiTable$Name[roiTable$ACTIVE], multiple=TRUE)
		if (!length(sumRois) || !nzchar(sumRois))
			return(invisible())	
		
		## Have user select the summary type 
		sumType <- mySelect(c('maximum', 'absolute max', 'minimum', 'area', 
						'absolute area', 'w1 shift', 'w2 shift', 'custom'), 
				preselect='Maximum', multiple=FALSE, title='Summarize ROI by:', 
				index=TRUE)
		if (!length(sumType) || !nzchar(sumType))
			return(invisible())	
		sumType <- c('maximum', 'absMax', 'minimum', 'area', 'absArea', 'w1', 
				'w2', 'custom')[sumType]
		if (sumType == 'custom'){
			funList <- NULL
			for (i in ls('.GlobalEnv')){
				if (is.function(get(i)))
					funList <- c(funList, i)
			}
			if (is.null(funList))
				err(paste('You must create a function in the global\nenvironment to',
								'use for the summary.'))
			usrFun <- NULL
			while (is.null(usrFun)){
				usrFun <- mySelect(funList, multiple=FALSE, 
						title='Select function name:')
				if (!nzchar(usrFun))
					return(invisible())
				if (is.null(formals(get(usrFun)))){
					usrSel <- myMsg(paste('You must select the name of a function from',
									'the global\nenvironment that takes at least one argument.'), 
							'okcancel', 'error')
					if (usrSel == 'cancel')
						return(invisible())
					else
						usrFun <- NULL
				}
			}
		}
		
		## Have user select normilization mode
		if (sumType == 'w1' || sumType == 'w2'){
			normType <- 'none'
		}else{
			normType <- mySelect(c('NONE', 'Internal standard', 'Across spectra', 
							'Signal to noise', 'Constant sum'), preselect='NONE',	
					title='Select normalization:', index=TRUE)
			if (!length(normType) || !nzchar(normType))
				return(invisible())
			normType <- c('none', 'internal', 'crossSpec', 'signal/noise', 
					'sum')[normType]
			if (normType == 'internal'){
				normList <- mySelect(sumRois, multiple=TRUE, 
						title='Identify Internal Standards:')
				if (!length(normList) || !nzchar(normList))
					return(invisible())
			}else if (normType == 'crossSpec'){
				normList <- mySelect(getTitles(sumFiles, FALSE), title='Select spectra:', 
						multiple=TRUE, index=TRUE)
				if (!length(normList) || !nzchar(normList))
					return(invisible())
				normList <- sumFiles[normList]
			}else{
				normList <- NA
			}
		}
	}else{
		if (missing(sumType))
			err('The "sumType" argument must be provided')
		if (sumType == 'custom'){
			funList <- NULL
			for (i in ls('.GlobalEnv')){
				if (is.function(get(i)))
					funList <- c(funList, i)
			}
			if (is.null(funList))
				err(paste('You must create a function in the global\nenvironment to',
								'use for the summary.'))
			usrFun <- NULL
			while (is.null(usrFun)){
				usrFun <- mySelect(funList, multiple=FALSE, 
						title='Select function name:')
				if (!nzchar(usrFun))
					return(invisible())
				if (is.null(formals(get(usrFun)))){
					usrSel <- myMsg(paste('You must select the name of a function from',
									'the global\nenvironment that takes at least one argument.'), 
							'okcancel', 'error')
					if (usrSel == 'cancel')
						return(invisible())
					else
						usrFun <- NULL
				}
			}
		}
		if (sumType == 'w1' || sumType == 'w2'){
			normType <- 'none'
		}else{
			if (normType == 'internal' || normType == 'crossSpec'){
				if (is.na(normList[1]))
					err('The "normList" argument is required')
			}else{
				normList <- NA
			}
		}
		if (missing(sumFiles))
			sumFiles <- actFiles
	}
	
	## Convert user selections into functions
	sumFun <- switch(match(sumType, c('maximum', 'absMax', 'minimum', 'area', 
							'absArea', 'w1', 'w2', 'custom')), 
			function(x, parm){max(x$data)}, 
			function(x, parm){x$data[which.max(abs(x$data))]},
			function(x, parm){min(x$data)},    
			function(x, parm){x$graphics.par=parm; return(peakVolume(x))}, 
			function(x, parm){x$data=abs(x$data); x$graphics.par=parm; 
				return(peakVolume(x))}, 
			function(x, parm){maxShift(x, conDisp=parm$conDisp)$w1},  
			function(x, parm){maxShift(x, conDisp=parm$conDisp)$w2}, 
			get(usrFun))
	if (is.null(sumFun))
		err(paste('Summary type must be either "maximum", "absMax", "minimum",',
						'"area", "absArea", "w1", "w2", or "custom"', sep=''))
	if (length(formals(sumFun)) < 2)
		formals(sumFun) <- c(formals(sumFun), alist(...=))
	
	## Generate summary for each active ROI
	fileData <- outData <- NULL
	cat('Processing files: \n')
	for (i in sumFiles){
		cat(paste(basename(i), '. . . ' ))
		flush.console()
		currPar <- fileFolder[[i]]$file.par
		nDim <- currPar$number_dimensions
		if (nDim == 3)
			nDim <- 2
		fileData <- NULL
		
		## Read data from active ROIs
		for (j in  match(sumRois, roiTable$Name)){
			
			w1Range <- as.numeric(roiTable[j, 4:5])
			w2Range <- as.numeric(roiTable[j, 2:3])
			
			## Fudge the ROI table for 1D/2D compatibility
			if (roiTable$nDim[j] == 1 && nDim == 2)
				w1Range <- c(currPar$downfield_ppm[1], currPar$upfield_ppm[1])
			
			## Read roi from binary and reject ROIs outside of the spectral window
			roiData <- ucsf2D(i, w1Range=w1Range, w2Range=w2Range, file.par=currPar)
			if ((nDim == 2 && (length(roiData$w1) < 2 || length(roiData$w2) < 2)) ||
					(nDim == 1 && length(roiData$data) < 2 ))
				fileData <- c(fileData, as.numeric(NA))
			else
				fileData <- c(fileData, sumFun(roiData, fileFolder[[i]]$graphics.par))      
		}
		
		## Normalize data
		names(fileData) <- sumRois
		if (normType == 'internal'){
			
			## Normalize by ROIs
			fileData <- fileData / mean(fileData[normList])
		}else if (normType == 'signal/noise'){
			
			## Normalize by noise level
			fileData <- fileData / fileFolder[[i]]$file.par$noise_est
		}else if (normType == 'sum'){
			
			## Normalize by sum of spectral data
			fileData <- fileData / sum(ucsf2D(i, 
							file.par=fileFolder[[i]]$file.par)$data)
		}
		outData <- rbind(outData, fileData)
		cat('done \n' )
		flush.console()
	}
	if (normType == 'crossSpec'){
		
		## Normalize by spectra
		rownames(outData) <- sumFiles
		if (length(normList) > 1)
			normData <- mean(data.frame(outData[normList, ]))
		else
			normData <- unlist(outData[normList, ])
		if (ncol(outData) > 1)
			outData <- t(apply(outData, 1, function(x) x / normData))
		else{
			outData <- apply(outData, 1, function(x) x / normData)
		}
		normList <- getTitles(names(fileFolder), FALSE)[match(normList, 
						names(fileFolder))]
	}
	
	## Format data
	outData <- data.frame(outData, row.names=NULL)
	colnames(outData) <- sumRois
	fileNames <- getTitles(names(fileFolder), FALSE)[match(sumFiles, 
					names(fileFolder))]
	outData <- data.frame(fileNames, outData, stringsAsFactors=FALSE)
	names(outData)[1] <- 'File'
	
	## Set up outgoing file structure
	sumPar <- list(sumType, normType, normList)
	names(sumPar) <- c('summary.type', 'normalization', 'norm.data.source')
	newSum <- list(outData, sumPar)
	names(newSum) <- c('data', 'summary.par')
	
	## Update summary table and print ROI data
	myAssign('roiSummary', newSum)
	se()
	
	return(invisible(newSum))
}

## User ROI function rc 
## Centers slected rois about the max peak in each active ROI
## massCenter  - logical argument; TRUE centers peaks by center of mass,
##               false centers peaks by maximum signal observed
## inTable		-  Used by internal functions only
## note: graphics settings are used for choosing between negative and positive 
##       signals.
rc <- function ( massCenter = TRUE, inTable ){
	
	if( !is.logical (massCenter) ){
		err('massCenter must argument must be either TRUE or FALSE')
	}
	
	if( !missing(inTable) )
		roiTable <- inTable
	if( is.null(roiTable) || nrow(roiTable) == 0)
		err('No ROIs have been designated, use roi()')	
	if( length(roiTable$ACTIVE) < 1 )
		err('No ROIs have been selected')
	
	## Define the current spectrum
	current <- wc()
	nDim <- fileFolder[[current]]$file.par$number_dimensions
	conDisp <- fileFolder[[current]]$graphics.par$conDisp
	
	##Open main and ROI subplot window if closed
	if(length(which(dev.list() == 2)) != 1)
		drawNMR()
	
	## Bring main into focus and show the rois 
	cw(dev=2);	showRoi()
	
	
	## Apply function to all active ROIs  
	for(i in which(roiTable$ACTIVE)){
		
		## Find current chemical shift range
		w1Range <- sort(as.numeric(roiTable[i, 4:5]))
		w2Range <- sort(as.numeric(roiTable[i, 2:3])) 
		
		## Find the max shift for the current ROI
		current.roi <- maxShift(ucsf2D(currentSpectrum, w1Range = w1Range, 
						w2Range = w2Range, file.par = fileFolder[[current]]$file.par), 
				conDisp = conDisp, massCenter = massCenter )
		if(is.null(current.roi))
			next()
		
		## Update ROI table
		roiTable[i, 2:3 ] <- c(current.roi$w2 + diff(w2Range)/2, 
				current.roi$w2 - diff(w2Range)/2)
		if( nDim > 1 && roiTable$nDim[i] > 1 ){
			roiTable[i, 4:5 ] <- c(current.roi$w1 + diff(w1Range)/2, 
					current.roi$w1 - diff(w1Range)/2)			
		}    
	}
	
	## Assign roi table to global environment and refresh the plot
	if(missing(inTable)){
		myAssign( 'roiTable', roiTable )
		refresh() 		
	}
	invisible(roiTable)   
}

## move ROI upfield in direct dimension (right)
##p - percentage to move ROI by
rmr <- function (p=1){
	changeRoi(w2Inc = c(-p, -p))
}

## move ROI downfield in direct dimension (left)
##p - percentage to move ROI by
rml <- function (p=1){
	changeRoi(w2Inc = c(p, p))
}

## move ROI upfield in indirect dimension (right)
##p - percentage to move ROI by
rmu <- function (p=1){
	changeRoi(w1Inc = c(-p, -p))
}

## move ROI downfield in indirect dimension (right)
##p - percentage to move ROI by
rmd <- function (p=1){
	changeRoi(w1Inc = c(p, p))
}

## Expand roi in direct dimension
##p - percentage to expand ROI by
red <- function (p=1){
	changeRoi(w2Inc = c(p, -p))
}

## Contract roi in direct dimension
##p - percentage to contract ROI by
rcd <- function (p=1){
	changeRoi(w2Inc = c(-p, p))
}

## Expand roi in the indirect dimension
##p - percentage to expand ROI by
rei <- function (p=1){
	changeRoi(w1Inc = c(p, -p))
}

## Contract roi in the indirect dimension
##p - percentage to contract ROI by
rci <- function (p=1){
	changeRoi(w1Inc = c(-p, p))
}

## User function for toggling the ROI display within the main plot window
rv <- function(){
	if (globalSettings$roiMain){
		setGraphics(roiMain=FALSE)
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		cat('ROI display off \n')
	}else{
		setGraphics(roiMain=TRUE)
		showRoi()
		cat('ROI display on \n')
	}
}

############################################################
#                                                          #
#    User functions to Load/save objects and workspaces    #
#                                                          #
############################################################

## Import data from file
## object - character string; name of rNMR object to import
import <- function(object, parent=NULL){
	
	## Have user select type of file to import
	tclCheck()
	current <- wc()
	if (missing(object)){
		usrSel <- mySelect(c('ROI table', 'ROI summary', 'Peak list'), 
				title='Import file type:', parent=parent)
		if ( length(usrSel) == 0 || !nzchar(usrSel) )
			return(invisible())
	}else
		usrSel <- object
	title <- switch(usrSel, 'ROI table'='Import ROI table', 
			'ROI summary'='Import ROI summary', 'Peak list'='Import peak list')
	
	## Have user select a file
	fileName <- myOpen(initialfile='', title=title, defaultextension='txt',
			filetypes=list('xls'='Excel Files', 'txt'='Text Files'))
	if (length(fileName) == 0)
		return(invisible())
	overAppend <- 'Append'
	
	## Import an ROI table
	if (usrSel == 'ROI table'){
		
		## Checks for the correct columns
		newRoi <- read.table(fileName, header=FALSE, nrows=1, sep='\t', 
				stringsAsFactors=FALSE)
		if (sum(newRoi ==  c('Name', 'w2_downfield', 'w2_upfield', 'w1_downfield', 
						'w1_upfield', 'ACTIVE','nDim')) < 7)
			err(paste('ROI tables must be tab delimited text files with the',
							'following columns:\n\n', 
							'                           1. Name', '\n', 
							'                           2. w2_downfield', '\n', 
							'                           3. w2_upfield', '\n', 
							'                           4. w1_downfield', '\n', 
							'                           5. w1_upfield', '\n', 
							'                           6. ACTIVE', '\n', 
							'                           7. nDim'))
		
		## Read ROI table and check with user for overwrite
		newRoi <- read.table(fileName, header=TRUE, sep='\t',	
				stringsAsFactors=FALSE)
		if (exists('roiTable') && length(roiTable) > 0)
			overAppend <- buttonDlg('An ROI table already exists.', c('Overwrite', 
							'Append', 'Cancel'), default='Cancel', parent=parent)
		if (overAppend == 'Cancel')
			return(invisible())
		
		## Checks that the ROI table has the correct format
		newRoi <- re(newRoi)
		if (is.null(newRoi))
			return(invisible())
		
		## Append new ROIs to existing table
		if (overAppend == 'Append'){
			
			##check for matching columns in the two tables
			newNames <- colnames(newRoi)
			oldNames <- colnames(roiTable)
			if (!is.null(newNames) && !identical(newNames, oldNames)){
				
				##add any columns from the new table missing from the existing table
				for (i in newNames[-match(oldNames, newNames, nomatch=0)]){
					roiTable <- cbind(roiTable, rep(NA, nrow(roiTable)))
					colnames(roiTable)[ncol(roiTable)] <- i
				}
				
				##add any columns from the existing table missing from the new table
				for (i in oldNames[-match(newNames, oldNames, nomatch=0)]){
					newRoi <- cbind(newRoi, rep(NA, nrow(newRoi)))
					colnames(newRoi)[ncol(newRoi)] <- i
				}
			}
		}
		
		## Assigns the ROI table to the global environment
		myAssign('roiTable', newRoi)		
		refresh()
		
		## Open roi subplot window if it is closed
		if(length(which(dev.list() == 2)) == 1)
			showRoi()       
	}
	
	## Import an ROI summary
	if (usrSel == 'ROI summary'){
		
		## Checks for the correct columns
		newSum <- read.table(fileName, header=FALSE, nrows=1, sep='\t', 
				stringsAsFactors = FALSE)
		fileIndex <- which(newSum == 'FILE')
		groupIndex <- which(newSum == 'GROUP')
		if (length(fileIndex) != 1 || length(groupIndex) > 1 ||
				any(!is.na(suppressWarnings(as.numeric(newSum[2:length(newSum)])))))
			err(paste('ROI summaries must be tab delimited text files with:\n',
							'1. A single "GROUP" column', '\n', 
							'2. A single "FILE" column and', '\n',
							'3. Columns for each ROI', '\n',
							' (with headings beginning with a character)'))
		
		## Checks that the columns are in the correct order
		newSum <- read.table(fileName, header=TRUE, sep='\t',	
				stringsAsFactors=FALSE)
		if (length(groupIndex) == 0){
			tmp <- rep('Group 1', length(newSum$FILE))
			newSum <- data.frame(tmp, newSum, stringsAsFactors=FALSE)
			names(newSum)[1] <- 'GROUP'
			groupIndex <- which(names(newSum) == 'GROUP')
			fileIndex <- which(names(newSum) == 'FILE')		
		}
		if (groupIndex != 1){
			tmp <- newSum[, groupIndex]
			newSum <- newSum[, -groupIndex]
			newSum <- data.frame(tmp, newSum, stringsAsFactors=FALSE)
			names(newSum)[1] <- 'GROUP'
			groupIndex <- which(names(newSum) == 'GROUP')
			fileIndex <- which(names(newSum) == 'FILE')
		}
		if (fileIndex != 2){
			tmp <- newSum[, fileIndex]
			newSum <- newSum[, -fileIndex]
			newSum <- data.frame(newSum$GROUP, tmp, newSum[, -1], 
					stringsAsFactors=FALSE)
			names(newSum)[1:2] <- c('GROUP', 'FILE')
		}
		
		## Checks that the ROI summary has the correct format
		newSum <- re(newSum)
		if (is.null(newSum))
			return(invisible())
		
		## Assigns the ROI summary to the global environment
		roiSummary <- NULL
		roiSummary$data <- newSum 
		roiSummary$summary.par$summary.type <- NA
		roiSummary$summary.par$normalization <- NA
		roiSummary$summary.par$norm.data.source <- NA
		myAssign('roiSummary', roiSummary)		     
	}
	
	## Import a peak list
	if (usrSel == 'Peak list'){
		
		## Checks for the correct columns
		newPeak <- read.table(fileName, header=FALSE, nrows=1, sep='\t', 
				stringsAsFactors=FALSE)
		w2Index <- which(newPeak == 'w2')
		w1Index <- which(newPeak == 'w1')
		heightIndex <- which(newPeak == 'Height')
		assignIndex <- which(newPeak == 'Assignment')
		inIndex <- which(newPeak == 'Index')
		if (length(inIndex) > 1 || length(w1Index) > 1 || length(w2Index) > 1 || 
				length(heightIndex) > 1 || length(assignIndex) > 1)
			err(paste('Peak lists must contain only one of each of the following',
							'columns:\n\n', 
							'                          1. w2', '\n', 
							'                          2. w1', '\n', 
							'                          3. Height', '\n', 
							'                          4. Assignment', '\n', 
							'                          5. Index'))
		
		if (fileFolder[[current]]$file.par$number_dimensions > 1){
			if (length(w1Index) == 0 || length(w2Index) == 0)
				err('Peak lists for 2D spectra must contain a w1 and w2 column.')
		}else{
			if (length(w2Index) == 0)
				err('Peak lists for 1D spectra must contain a w2 column.')
		}
		
		## Read peak list and check with user for overwrite
		newPeak <- read.table(fileName, header=TRUE, sep='\t', 
				stringsAsFactors=FALSE)
		if (length(fileFolder[[current]]$peak.list) > 0)
			overAppend <- buttonDlg('A peak list already exists.', c('Overwrite', 
							'Append', 'Cancel'), default='Cancel', parent=parent)
		if (overAppend == 'Cancel')
			return(invisible())
		
		## Adds missing columns
		if (length(w1Index) == 0){
			w1 <- rep(NA, length(newPeak$w2))
			newPeak <- data.frame(newPeak, w1, stringsAsFactors=FALSE)
		}
		if (length(heightIndex) == 0){
			Height <- rep(NA, length(newPeak$w2))
			newPeak <- data.frame(newPeak, Height, stringsAsFactors=FALSE)
		}
		if (length(assignIndex) == 0){
			Assignment <- rep(NA, length(newPeak$w2))
			newPeak <- data.frame(newPeak, Assignment, stringsAsFactors=FALSE)
		}
		if (length(inIndex) == 0){
			Index <- 1:length(newPeak$w2)
			newPeak <- data.frame(newPeak, Index, stringsAsFactors=FALSE)
		}
		
		## open peak list editor
		newPeak <- pe(newPeak)
		if (is.null(newPeak))
			return(invisible())
		
		## Assigns the peak list to the global environment		
		newPeak$w1 <- as.numeric(newPeak$w1)
		newPeak$w2 <- as.numeric(newPeak$w2)
		if (overAppend == 'Append')
			newPeak <- appendPeak(newPeak, fileFolder[[current]]$peak.list)
		fileFolder[[current]]$peak.list <- newPeak
		setGraphics(peak.disp=TRUE, save.backup=FALSE)
		pdisp()
		myAssign('fileFolder', fileFolder)	
		refresh(sub.plot=FALSE, multi.plot=FALSE)
	}
}

## Export a data table to tab delimited file
## object - character string; name of rNMR object to export
export <- function(object, parent=NULL){
	
	## Have user select type of file to export
	current <- wc()
	usrList <- NULL
	if (!is.null(roiTable))
		usrList <- c(usrList, 'ROI table')
	if (exists('roiSummary') && !is.null(roiSummary$data))
		usrList <- c(usrList, 'ROI summary')
	if (!is.null(fileFolder[[current]]$peak.list))
		usrList <- c(usrList, 'Peak list')
	if (is.null(usrList))
		err('There are currently no data tables to export.')
	if (missing(object)){
		usrSel <- mySelect(usrList, title='Export file type:', parent=parent)
		if (length(usrSel) == 0 || !nzchar(usrSel))
			return(invisible())
	}else
		usrSel <- object
	
	## Have user select file name
	initFile <- switch(usrSel, 'ROI table'='roiTable', 
			'ROI summary'='roiSummary', 'Peak list'='peakList')
	fileName <- mySave(defaultextension='txt', initialfile=initFile, 
			title='Export', filetypes=list('xls'='Excel Files', 'txt'='Text Files'))
	if (length(fileName) == 0 || !nzchar(fileName))
		return(invisible())
	
	##writes the data table to the given file name
	dataTable <- switch(usrSel, 'ROI table'=roiTable, 
			'ROI summary'=roiSummary$data, 
			'Peak list'=fileFolder[[current]]$peak.list)
	write.table(dataTable, file=fileName, quote=FALSE, sep='\t', row.names=FALSE, 
			col.names=TRUE)
	print(paste('The data were saved to: ', fileName), quote=FALSE)
}

## Extract data from rNMR objects
## Returns selected object and prints a summary to the console
ed <- function(){
	
	## Have user select object to extract data from
	current <- wc()
	usrList <- c('Main plot window', 'Slice')
	if (!is.null(roiTable))
		usrList <- c(usrList, 'ROI table')
	if (exists('roiSummary') && !is.null(roiSummary$data))
		usrList <- c(usrList, 'ROI summary')
	if (!is.null(fileFolder[[current]]$peak.list))
		usrList <- c(usrList, 'Peak list')
	usrSel <- mySelect(usrList, title='Extract from:')
	if ( length(usrSel) == 0 || !nzchar(usrSel) )
		return(invisible())
	
	## Extract data from the main plot window
	if (usrSel == 'Main plot window'){
		nDim <- fileFolder[[current]]$file.par$number_dimensions
		w1Range <- fileFolder[[current]]$graphics.par$usr[3:4]
		w2Range <- fileFolder[[current]]$graphics.par$usr[1:2]	
		return(ucsf2D(file.name = currentSpectrum, w1Range = w1Range, 
						w2Range = w2Range, file.par = fileFolder[[current]]$file.par))
	}
	
	## Extract data from a 1D slice
	if (usrSel == 'Slice'){
		tmp <- vs()
		return(tmp)
	}
	
	## Extract data from an ROI table
	if (usrSel == 'ROI table')
		return(roiTable)
	
	## Extract data from an ROI summary
	if (usrSel == 'ROI summary'){
		return(roiSummary[1:2])
	}
	
	## Extract data from a peak list
	if (usrSel == 'Peak list'){
		return(fileFolder[[current]]$peak.list)
	}
}

## Load an R workspace
## fileName - character string, the file path for the workspace to load
## plot - logical, replots the currentSpectrum if TRUE
## clearAll - logical, clears all previous objects if TRUE, otherwise only rNMR
##	          objects are cleared
load <- wl <- function(fileName, plot=TRUE, clearAll=TRUE){
	
	if (missing(fileName))
		fileName <- myOpen(filetypes=list('RData'='R image'), 
				defaultextension='RData', multiple=FALSE, title='Load Workspace')
	if (length(fileName) == 0 || !nzchar(fileName))
		stop('Load cancelled')
	backup <- file.path(Sys.getenv('HOME'), 'zal3waozq')
	save.image(backup)
	tryCatch({if (clearAll)
					suppressWarnings(rm(list=ls(envir=.GlobalEnv), envir=.GlobalEnv))
				else{
					rNMRob <- c('fileFolder', 'currentSpectrum', 'oldFolder', 'roiTable', 
							'roiSummary', 'pkgVar', 'globalSettings', 'overlayList')
					suppressWarnings(rm(rNMRob, envir=.GlobalEnv))
				}
				suppressWarnings(base::load(file=fileName, envir=.GlobalEnv))
				rNMR:::patch()
				gui()
				if (exists('fileFolder') && !is.null(fileFolder) && plot)
					dd()
				cat('"', fileName, '"', ' successfully loaded','\n', sep='')}, 
			error=function(er){
				if (length(grep('magic', er$message))){
					base::load(file=backup, envir=.GlobalEnv)
					suppressWarnings(file.remove(backup))
					err('Invalid workspace, no data loaded.')
				}
				suppressWarnings(file.remove(backup))
				return(er)
			})
	invisible(suppressWarnings(file.remove(backup)))
}

## Save an R workspace
## fileName - character string, the file path for the workspace to save to
ws <- function(fileName){
	
	if (missing(fileName))
		fileName <- mySave(defaultextension='RData', title='Save Workspace',
				filetypes=list('RData'='R image'))
	if (length(fileName) == 0 || !nzchar(fileName))
		return(invisible())
	base::save.image(file=fileName)
	
	cat(paste('Workspace saved to ','"', fileName, '"', '\n', sep=''))
}

## Restore an R workspace
rb <- function(){
	backupFile <- file.path(path.expand('~'), '.rNMRbackup')
	if (!file.exists(backupFile))
		return('No backup to restore, load cancelled.')
	tryCatch(wl(backupFile), error=function(er) 
				print('Unable to restore workspace.'))
}

############################################################
#                                                          #
#      General rNMR fileFolder object utility functions    #
#                                                          #
############################################################

## Internal function for checking existence of files within fileFolder
## halt - logical, stops execution after updating files if TRUE
updateFiles <- function(halt=TRUE){
	
	if (is.null(fileFolder))
		return(invisible())
	
	## Create list of files that need to be updated
	fileNames <- names(fileFolder)
	updateList <- file.access(unique(fileNames))
	updateList <- names(updateList[which(updateList == -1)])
	if (!length(updateList))
		return(invisible())
	
	## Have the user select files to update
	usr <- myMsg(paste('Could not find previously opened file(s), press OK to', 
					'update file locations'), type='okcancel', icon='error')
	
	## Do nothing if user selects cancel
	if (usr == 'cancel')
		stop('File location update cancelled.', call.=FALSE)
	
	## Allow user to select files to update
	prevPaths <- mySelect(updateList, multiple=TRUE, 
			title='Select files to update')
	
	## Do nothing if user selects cancel
	if (!length(prevPaths) || !nzchar(prevPaths))
		stop('File location update cancelled.', call.=FALSE)
	
	## Close spectra the user chose not to update
	newFolder <- fileFolder
	newCS <- NULL
	newOL <- overlayList
	if (length(prevPaths) != length(updateList)){
		closeList <- updateList[-as.vector(na.omit(match(prevPaths, updateList)))]
		message <- paste('The following files will be closed:', paste(closeList, 
						collapse=' \n  '), sep='\n  ')
		usr <- myMsg(message, icon='info', type='okcancel')
		
		## Do nothing if user selects cancel
		if (usr == 'cancel')
			stop('File location update cancelled.', call.=FALSE)
		
		newFolder <- newFolder[-match(closeList, fileNames)]
	}
	
	## Get new file location
	newPath <- myOpen(title=paste('Update location for "', basename(prevPaths[1]),
					'"', sep=''), multiple=FALSE)
	
	## Do nothing if user selects cancel
	if (!length(newPath) || !nzchar(newPath))
		stop('File location update cancelled.', call.=FALSE)
	
	## Updates selected file
	i <- match(prevPaths[1], fileNames)
	names(newFolder)[i] <- newPath
	prevUpfield <- newFolder[[i]]$file.par$upfield_ppm
	prevDownfield <- newFolder[[i]]$file.par$downfield_ppm
	newFolder[[i]]$file.par <- ucsfHead(newPath, FALSE)$file.par
	newFolder[[i]]$file.par$upfield_ppm <- prevUpfield
	newFolder[[i]]$file.par$downfield_ppm <- prevDownfield
	newDir <- dirname(newPath)
	if (currentSpectrum == prevPaths[1])
		newCS <- newPath
	if (!is.null(newOL)){
		overMatch <- match(prevPaths[1], newOL)
		if (!is.na(overMatch))
			newOL[overMatch] <- newPath
	}
	prevPaths <- prevPaths[-1]
	
	## Updates remaining files
	if (length(prevPaths)){
		remaining <- TRUE
		while(remaining){
			
			## Looks for file matches in provided directory
			newDirFiles <- list.files(newDir, full.names=TRUE)
			fileMatches <- na.omit(match(basename(prevPaths), basename(newDirFiles)))
			if (length(fileMatches)){
				newPaths <- newDirFiles[fileMatches]
				prevPathMatches <- match(basename(newPaths), basename(prevPaths))
				dirPrevPaths <- prevPaths[prevPathMatches]
				prevPaths <- prevPaths[-prevPathMatches]
				
				## Updates files that match
				for (newPath in newPaths){
					i <- match(dirPrevPaths[1], fileNames)
					names(newFolder)[i] <- newPath
					prevUpfield <- newFolder[[i]]$file.par$upfield_ppm
					prevDownfield <- newFolder[[i]]$file.par$downfield_ppm
					newFolder[[i]]$file.par <- ucsfHead(newPath, FALSE)$file.par
					newFolder[[i]]$file.par$upfield_ppm <- prevUpfield
					newFolder[[i]]$file.par$downfield_ppm <- prevDownfield
					if (currentSpectrum == newPath)
						newCS <- newPath
					if (!is.null(newOL)){
						overMatch <- match(newPath, newOL)
						if (!is.na(overMatch))
							newOL[overMatch] <- newPath
					}
					dirPrevPaths <- dirPrevPaths[-1]
				}
				
				## Tells the user which files were updated using previosly provided dir.
				cat(paste('The following files were found in "', newDir, '",\n', 
								'and were automatically updated:\n  ', paste(basename(newPaths), 
										collapse=' \n  '), '\n',	sep=''))
				flush.console()
				
				## Checks for files that still need to be updated
				if (!length(prevPaths))
					remaining <- FALSE
			}else{
				
				## Allows the user to select a new directory
				newPath <- myOpen(title=paste('Update location for "', prevPaths[1],
								'"', sep=''), multiple=FALSE)
				
				## Do nothing if user selects cancel
				if (!length(newPath) || !nzchar(newPath))
					stop('File location update cancelled.', call.=FALSE)
				
				## Updates selected file
				i <- match(prevPaths[1], fileNames)
				names(newFolder)[i] <- newPath
				prevUpfield <- newFolder[[i]]$file.par$upfield_ppm
				prevDownfield <- newFolder[[i]]$file.par$downfield_ppm
				newFolder[[i]]$file.par <- ucsfHead(newPath, FALSE)$file.par
				newFolder[[i]]$file.par$upfield_ppm <- prevUpfield
				newFolder[[i]]$file.par$downfield_ppm <- prevDownfield
				newDir <- dirname(newPath)
				if (currentSpectrum == newPath)
					newCS <- newPath
				if (!is.null(newOL)){
					overMatch <- match(newPath, newOL)
					if (!is.na(overMatch))
						newOL[overMatch] <- newPath
				}
				
				## Checks for files that still need to be updated
				prevPaths <- prevPaths[-1]
				if (!length(prevPaths))
					remaining <- FALSE
			}
		}
	}	
	
	## Assigns new objects to global environment
	if (length(newFolder) && is.null(newCS))
		newCS <- names(newFolder)[length(newFolder)]
	myAssign('currentSpectrum', newCS, save.backup=FALSE)
	myAssign('overlayList', newOL, save.backup=FALSE)
	myAssign('fileFolder', newFolder)
	refresh()
	if (halt)
		stop('Files updated, previous function may need to be recalled.', 
				call.=FALSE)
}

## Internal function for getting the current spectrum
## fileName - logical; returns the file name for the current spectrum if TRUE
## Returns the current spectrum's index in the file folder
wc <- function(fileName=FALSE){
	
	##Checks for open files
	if (!exists("fileFolder") || is.null(fileFolder))
		err('The file folder is empty, use fo()')
	
	##Checks for currentSpectrum
	if (!exists("currentSpectrum") || is.null(currentSpectrum))
		err('The file folder is empty, use fo()')
	
	##Find the current spectrum in fileFolder
	current <- match(currentSpectrum, names(fileFolder))
	
	##Return the full file path for the current spectrum
	if (fileName)
		return(fileFolder[[current]]$file.par$file.name)
	
	##Return the fileFolder index for the current spectrum
	return(current)
}


############################################################
#                                                          #
#       Internal replacement functions and dialogs         #
#                                                          #
############################################################

## Internal function getTitles
## Given a vector of file names (as in names(fileFolder), returns user titles
## inNames - numeric or character vector, the file names to retrieve titles for
## index - logical argument, if TRUE, appends indices to the items in the list
## returns a vector of length inNames containing user titles
getTitles <- function( inNames, index = TRUE ){
	
	## Get the user_title field for each file name
	inNames <- as.vector(sapply(fileFolder[inNames], function(x) 
						x$file.par$user_title))
	
	## Append index number to list
	if (index)
		inNames <- paste(seq_along(inNames), inNames, sep=') ')
	
	return(inNames)
}

##Internal function 'mySelect'
##platform independant version of select.list()
##uses a modified version of tk_select.list
##index - logical; if TRUE returns the index for the selected item rather than
##        the list item itself
##parent - specifies a tktoplevel to be the parent window for the dialog 
mySelect <- function(list, preselect=NULL, multiple=FALSE, title=NULL, 
		index=FALSE, parent=NULL){
	
	##Append indices to list
	inList <- paste(seq_along(list), list, sep=') ')
	
	##Default to R's list selection dialog on Windows platforms
	if (.Platform$OS.type == 'windows'){
		if( !is.null(preselect) ){
			preselect <- match(preselect, list)
			preselect <- inList[ preselect ]
		}
		usrList <- select.list( inList, preselect = preselect, multiple=multiple, 
				title=title)
		usrList <- match(usrList, inList)
		if( length(usrList) == 0 || is.na(usrList) )
			return("")
		if( index )
			return( usrList )
		return( list[usrList] )
	}
	
	##Checks for valid arguments
	if (is.null(preselect))
		preselect <- 1
	else{
		if (!is.character(preselect))
			stop('Invalid preselect argument')
		preselect <- as.numeric(na.exclude(match(preselect, list)))
		if (length(preselect) == 0)
			preselect <- 1	
	}
	if (!is.logical(multiple))
		stop('Invalid multiple argument')
	if (!is.null(title) && !is.character(title))
		stop('Invalid title argument')
	
	##creates main window
	tclCheck()
	if (is.null(parent))
		dlg <- tktoplevel()
	else
		dlg <- myToplevel('dlg', parent=parent)
	tkwm.title(dlg, 'Selection')
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##determine size of list box
	vscr <- hscr <- FALSE
	ht <- length(inList)
	if (ht > 35){
		ht <- 35
		vscr <- TRUE
	}
	wd <- max(nchar(inList))
	if (wd > 40){
		wd <- 40
		hscr <- TRUE
	}
	wd <- wd + 5
	if (wd < 15)
		wd <- 15
	
	##create font for listFrame
	fonts <- tcl('font', 'name')
	if (!'listFont' %in% as.character(fonts)){
		listFont <- as.character(tcl('font', 'configure', 'TkDefaultFont'))
		tcl('font', 'create', 'listFont', listFont[1], listFont[2], listFont[3], 
				listFont[4], listFont[5], 'bold', listFont[7], listFont[8], listFont[9], 
				listFont[10], listFont[11], listFont[12])
	}
	
	##create list box
	if (is.null(title))
		title <- 'Select:'
	label <- ttklabel(dlg, text=title)
	listFrame <- ttklabelframe(dlg, padding=3, labelwidget=label)
	tcl(label, 'configure', '-font', 'listFont')
	lvar <- tclVar()
	tclObj(lvar) <- inList
	listBox <- tklistbox(listFrame, height=ht, width=wd, listvariable=lvar, 
			selectmode=ifelse(multiple,'extended', 'browse'), active='dotbox', 
			exportselection=FALSE,  bg='white',
			xscrollcommand=function(...) tkset(xscr, ...), 
			yscrollcommand=function(...) tkset(yscr, ...))
	xscr <- ttkscrollbar(listFrame, orient='horizontal', 
			command=function(...) tkxview(listBox, ...))
	yscr <- ttkscrollbar(listFrame, command=function(...) tkyview(listBox, ...))
	if (length(inList) > 2){
		for (i in seq(0, length(inList) - 1, 2))
			tkitemconfigure(listBox, i, background='#ececff')
	}
	for (i in preselect)
		tkselection.set(listBox, i - 1)
	tcl(listBox, 'see', i - 1)
	
	##create ok button
	bottomFrame <- ttkframe(dlg)
	returnVal <- ''
	onOK <- function() {
		usrSel <- as.integer(tkcurselection(listBox))
		if (length(usrSel) != 0){
			if (index)
				returnVal <<- 1 + usrSel
			else
				returnVal <<- list[1 + usrSel]
		}
		tkgrab.release(dlg)
		tkdestroy(dlg)
	}
	okButton <- ttkbutton(bottomFrame, text='OK', width=10, command=onOK)
	
	##create cancel button
	onCancel <- function() {
		tkgrab.release(dlg)
		tkdestroy(dlg)
	}
	cancelButton <- ttkbutton(bottomFrame, text='Cancel', width=10, 
			command=onCancel)
	tkbind(dlg, '<Destroy>', onCancel)
	
	##add widgets to listFrame
	tkgrid(listFrame, column=1, row=1, sticky='nswe', pady=10, padx=c(14, 0))
	tkgrid(listBox, column=1, row=1, sticky='nswe')
	if (vscr)
		tkgrid(yscr, column=2, row=1, sticky='ns')
	if (hscr)
		tkgrid(xscr, column=1, row=2, sticky='we')
	
	##make listFrame stretch when window is resized
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=10)
	tkgrid.columnconfigure(listFrame, 1, weight=1)
	tkgrid.rowconfigure(listFrame, 1, weight=1)
	
	##add buttons to bottom of toplevel
	tkgrid(bottomFrame, column=1, row=2, padx=c(22, 0))
	tkgrid(okButton, column=1, row=1, padx=4)
	tkgrid(cancelButton, column=2, row=1, padx=4)
	tkgrid(ttksizegrip(dlg), column=3, row=3, sticky='se')
	
	##Allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (length(grep('.2.1$', focus)))
			onOK()
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter) 
	tkbind(listBox, '<Double-Button-1>', onOK)
	tkactivate(listBox, max(preselect) - 1)
	
	##configure dialog window
	tkwm.deiconify(dlg)
	if (as.logical(tkwinfo('viewable', dlg)))
		tkgrab.set(dlg)
	tkfocus(listBox)
	tkwait.window(dlg)
	
	return(returnVal)
}

## Internal function 'myDialog'
## Tk version of winDialogString, creates a dialog with ok\cancel buttons and a 
##   text entry widget
## message - character string; message to display in the dialog
## default - character string; default text in the entry widget
## title - character string; title for the window
## entryWidth - positive integer; horizontal length of the entry widget
## parent - specifies a tktoplevel to be the parent window for the dialog 
myDialog <- function(message='', default='', title='rNMR', entryWidth=20, 
		parent=NULL){
	
	##creates main window
	tclCheck()
	if (is.null(parent))
		dlg <- tktoplevel()
	else
		dlg <- myToplevel('dlg', parent=parent)
	tkwm.title(dlg, title)
	tkwm.resizable(dlg, FALSE, FALSE)
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	if (.Platform$OS == 'windows')
		tcl('wm', 'attributes', dlg, toolwindow=TRUE)
	tkfocus(dlg)
	
	##creates message label
	msgLabel <- ttklabel(dlg, text=message)
	
	##creates text entry widget
	usrEntry <- tclVar(default)
	textEntry <- ttkentry(dlg, width=entryWidth, justify='center', 
			textvariable=usrEntry)
	tkselection.range(textEntry, 0, nchar(default))
	
	##creates ok button
	returnVal <- NULL
	onOK <- function(){
		returnVal <<- tclvalue(usrEntry)
		tkgrab.release(dlg)
		tkdestroy(dlg)
	}
	okButton <- ttkbutton(dlg, text="OK", width=8, command=onOK)
	
	##creates cancel button
	onCancel <- function(){
		tkgrab.release(dlg)
		tkdestroy(dlg)
	}
	cancelButton <- ttkbutton(dlg, text="Cancel", width=8, command=onCancel)
	
	##add widgets to toplevel
	tkgrid(msgLabel, column=1, columnspan=2, row=1, pady=c(8, 5), padx=6, 
			sticky='w')
	tkgrid(textEntry, column=1, columnspan=2, row=2, pady=5, padx=20)
	tkgrid(okButton, column=1, row=3, pady=8, padx=c(6, 1))
	tkgrid(cancelButton, column=2, row=3, pady=8, padx=c(1, 6))
	
	##selects the text in the entry widget when Ctrl+A is pressed
	onCtrlA <- function(){
		tkfocus(textEntry)
		tkselection.range(textEntry, 0, nchar(tclvalue(usrEntry)))
	}
	tkbind(dlg, '<Control-a>', onCtrlA)
	
	##allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (length(grep('.2$', focus)))
			onOK()
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter)
	
	##configure dialog window
	tkwm.deiconify(dlg)
	if (as.logical(tkwinfo('viewable', dlg)))
		tkgrab.set(dlg)
	tkfocus(textEntry)
	tkwait.window(dlg)
	
	if (!is.null(returnVal))
		return(returnVal)
	invisible(returnVal)
}

## Internal function 'myDir'
## Modified version of tkchooseDirectory that saves and uses the last directory
## initialdir - specifies the initial directory displayed in the dialog
## parent - specifies a tktoplevel to be the parent window for the dialog 
## title - specifies a string to display as the title of the dialog
## mustexist - specifies whether or not the user must select an existing dir.
## see tcl/tk manual for additional documentation
myDir <- function(initialdir='', parent=NULL, title='', mustexist=TRUE){
	
	## Get saved directory if no initial directory is entered
	if( initialdir == '' && !is.null(pkgVar$prevDir) )
		initialdir <- pkgVar$prevDir
	
	## Let the user choose a directory using tk dialog
	tclCheck()
	if (!is.null(parent))
		returnVal <- tclvalue(tkchooseDirectory(initialdir=initialdir, title=title,
						parent=parent, mustexist=mustexist))
	else
		returnVal <- tclvalue(tkchooseDirectory(initialdir=initialdir, title=title, 
						mustexist=mustexist))
	
	## Save the selected (not canceled) directory
	if (length(returnVal) && nzchar(returnVal)){
		returnVal <- gsub('\\', '/', returnVal, fixed=TRUE)
		pkgVar$prevDir <- returnVal
		myAssign("pkgVar", pkgVar, save.backup = FALSE)
	}
	
	return(returnVal)
}

## Internal function 'myOpen'
## Modified version of tkgetOpenFile
## defaultextension - a string specifying the file extension (without ".") for 
##										the default filetype to be displayed in	the dialog (must 
##										match one of the extensions provided in filetypes)
## filetypes - adds the provided file types to the file types listbox in the
##             open dialog if supported by the platform, must be in list format,
##             as such: list(txt = "Text File", xls = "Excel File")
## initialfile - specifies a filename to be displayed initially in the dialog
## initialdir - specifies the initial directory displayed in the dialog
## multiple - logical, should users be able to select more than one file?
## title - specifies a string to display as the title of the dialog
## parent - specifies a tktoplevel to be the parent window for the dialog 
## see tcl/tk manual for additional documentation
myOpen <- function( defaultextension='', filetypes='', initialfile='', 
		initialdir='', multiple=TRUE, title='', parent=NULL){
	
	## Get saved directory if no initial directory is entered
	if( initialdir == '' && !is.null(pkgVar$prevDir) )
		initialdir <- pkgVar$prevDir
	
	## Reformat filetypes parameters to work with tkgetOpenFile
	if (is.list(filetypes)){
		tkParse <- NULL
		for (i in seq_along(filetypes)){
			if (names(filetypes)[i] == defaultextension)
				next
			tkParse <- paste(c(tkParse, paste('{{', filetypes[[i]],'} ', '{.',
									names(filetypes)[i], '}}', sep='')), collapse=' ')
		}
		defIn <- match(defaultextension, names(filetypes))
#		if (!is.na(defIn)){
			sysInfo <- Sys.info()
			if (sysInfo['release'] == 'Vista' || sysInfo['release'] == '7'){
				tkParse <- paste(tkParse, paste('{{', filetypes[[defIn]],'} ', '{.',
								names(filetypes)[i], '}}', sep=''))
				tkParse <- paste('{{All Files} *}', tkParse)
			}else{
				tkParse <- paste(paste('{{', filetypes[[defIn]],'} ', '{.', 
								names(filetypes)[i], '}}', sep=''), tkParse)
				tkParse <- paste(tkParse, '{{All Files} *}')
			}
#		}
	}else
		tkParse <- ''
	
	## Get the path to the file/files the user enters
	tclCheck()
	if (multiple){
		if (!is.null(parent))
			returnVal <- as.character(tkgetOpenFile(filetypes=tkParse, title=title,
							initialdir=initialdir, initialfile=initialfile, parent=parent, 
							multiple=multiple))
		else
			returnVal <- as.character(tkgetOpenFile(filetypes=tkParse, title=title,
							initialdir=initialdir, initialfile=initialfile, 
							multiple=multiple))
	}else{
		if (!is.null(parent))
			returnVal <- tclvalue(tkgetOpenFile(filetypes=tkParse, title=title,
							initialdir=initialdir, initialfile=initialfile, parent=parent, 
							multiple=multiple))
		else
			returnVal <- tclvalue(tkgetOpenFile(filetypes=tkParse, title=title,
							initialdir=initialdir, initialfile=initialfile, 
							multiple=multiple))
	}
	
	## Save the selected (not canceled) directory
	if (length(returnVal) > 0 && nzchar(returnVal)){
		pkgVar$prevDir <- dirname(returnVal[1])
		myAssign("pkgVar", pkgVar, save.backup=FALSE)
	}
	return( returnVal )
}

## Internal function 'mySave'
## Modified version of tkgetSaveFile
## defaultextension - a string specifying the file extension to be appended to
##                    the file name if one is not provided
## filetypes - adds the provided file types to the file types listbox in the
##             open dialog if supported by the platform, must be in list format,
##             as such: list(txt = "Text File", xls = "Excel File")
## initialfile - specifies a filename to be displayed initially in the dialog
## initialdir - specifies the initial directory displayed in the dialog
## title - specifies a string to display as the title of the dialog
## parent - specifies a tktoplevel to be the parent window for the dialog 
## see tcl/tk manual for additional documentation
mySave <- function(defaultextension='', filetypes='', initialfile='', 
		initialdir='', title='', parent=NULL){
	
	## Get saved directory if no initial directory is entered
	if (initialdir == '' && !is.null(pkgVar$prevDir))
		initialdir <- pkgVar$prevDir
	
	## Make sure a '.' is included in defaultextension argument (Linux issue)
	if (nzchar(defaultextension) && 
			!length(grep('.', defaultextension, fixed=TRUE)))
		defaultextension <- paste('.', defaultextension, sep='')
	
	## Reformat filetypes parameters to work with tkgetSaveFile
	if (is.list(filetypes)){
		tkParse <- NULL
		for (i in seq_along(filetypes)){
			if (names(filetypes)[i] == defaultextension)
				next
			tkParse <- paste(c(tkParse, paste('{{', filetypes[[i]],'} ', '{.',
									names(filetypes)[i], '}}', sep='')), collapse=' ')
		}
		defIn <- match(defaultextension, names(filetypes))
		if (!is.na(defIn)){
			sysInfo <- Sys.info()
			if (sysInfo['release'] == 'Vista' || sysInfo['release'] == '7')
				tkParse <- paste(tkParse, paste('{{', filetypes[[defIn]],'} ', '{.',
								names(filetypes)[i], '}}', sep=''))
			else
				tkParse <- paste(paste('{{', filetypes[[defIn]],'} ', '{.', 
								names(filetypes)[i], '}}', sep=''), tkParse)
		}
		tkParse <- paste('{{All Files} *}', tkParse)
	}else
		tkParse <- ''
	
	## Get the path to the file/files the user enters
	tclCheck()
	if (!is.null(parent))
		returnVal <- tclvalue(tkgetSaveFile(filetypes=tkParse, title=title,
						defaultextension=defaultextension, initialdir=initialdir,
						initialfile=initialfile, parent=parent))
	else
		returnVal <- tclvalue(tkgetSaveFile(filetypes=tkParse, title=title,
						defaultextension=defaultextension, initialdir=initialdir,
						initialfile=initialfile))
	
	## Save the selected (not canceled) directory
	if (length(returnVal) > 0 && nzchar(returnVal)){
		pkgVar$prevDir <- dirname(returnVal[1])
		myAssign("pkgVar", pkgVar, save.backup=FALSE)
	}
	return(returnVal)
}

## Internal function 'myMessageBox'
## message - character string, the message to display in the dialog
## type - character string, the type of buttons to display in the dialog
## icon - character string, the type of icon to display in the dialog
## title - character string, the title for the dialog box
## parent - specifies a tktoplevel to be the parent window for the dialog 
## tk version of winDialog, tcl/tk manual for additional documentation
myMsg <- function(message='', type='ok', icon='question', title='rNMR', 
		parent=NULL){
	
	tclCheck()
	if (!is.null(parent))
		return(tclvalue(tkmessageBox(message=message, type=type, icon=icon, 
								title='rNMR', parent=parent)))
	else
		return(tclvalue(tkmessageBox(message=message, type=type, icon=icon, 
								title='rNMR')))
}

## Internal utility function for returning errors, invokes stop and 
## opens the error message in a tk window
## message - the desired error message
## parent - specifies a tktoplevel to be the parent window for the dialog 
## halt - logical, stops code execution if TRUE
err <- function(message, parent=NULL, halt=TRUE){
	
	##display error message
	myMsg(message, icon='error', parent=parent)
	
	##return focus to console
	bringFocus(-1)
	
	##halt code execution
	if (halt)
		stop(message, call.=FALSE)
}

## Internal version of file
## Opens the updateFile function if a file path has changed
## fileName - character string; full path name for the spectrum to open a file
##						connection for
## open - character string; see R documentation for "file" function
myFile <- function(fileName, open){
	suppressWarnings(tryCatch(file(fileName, open), error=function(er){
						updateFiles()}))
}

## Internal function for creating a Tk dialog with up to three buttons
## message - character string; message to display in the dialog
## buttons - character vector; names for the buttons to display
## default - character string; specifies the default button and return value
## checkBox - logical; TRUE indicates that the last button should be a checkbox
## title - character string, the title for the dialog box
## parent - specifies a tktoplevel to be the parent window for the dialog 
buttonDlg <- function(message, buttons, checkBox=FALSE, default=buttons[1], 
		title='rNMR', parent=NULL){	
	
	##creates dialog window
	if (is.null(parent))
		dlg <- tktoplevel()
	else
		dlg <- myToplevel('dlg', parent=parent)
	tkwm.title(dlg, title)
	tkwm.resizable(dlg, FALSE, FALSE)
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	if (checkBox)
		checkVal <- tclVar(0)
	returnVal <- default
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##displays message
	msgLabel <- ttklabel(dlg, text=message, justify='left')
	tkgrid(msgLabel, column=1, row=1, pady=c(15, 0), padx=15)
	
	##determines width of buttons
	if (checkBox)
		butWidth <- max(nchar(buttons[1:(length(buttons) - 1)]))
	else
		butWidth <- max(nchar(buttons))
	if (butWidth < 8)
		butWidth <- 8
	
	##creates buttons
	buttonFrame <- ttkframe(dlg)
	tkgrid(buttonFrame, column=1, row=2, pady=10)
	buttonList <- as.list(buttons)
	for (i in seq_along(buttons)){
		if (i != length(buttons) || !checkBox){
			onButton <- function(){
				usrSel <- tclvalue(tkcget(tkfocus(), '-text'))
				if (checkBox){
					returnVal <<- data.frame(usrSel, 
							as.logical(as.integer(tclvalue(checkVal))), 
							stringsAsFactors=FALSE)
					names(returnVal) <<- c('button', 'checked')
				}else
					returnVal <<- usrSel
				tkgrab.release(dlg)
				tkdestroy(dlg)
			}
			buttonList[[i]] <- ttkbutton(buttonFrame, text=buttons[i], width=butWidth, 
					command=onButton)
		}else
			buttonList[[i]] <- ttkcheckbutton(buttonFrame, text=buttons[i], 
					variable=checkVal)
		if (i == 1)
			tkgrid(buttonList[[i]], column=i, row=1, padx=c(12, 3))
		else if (i == length(buttons)){
			if (checkBox)
				tkgrid(buttonList[[i]], column=i, row=1, padx=c(10, 12))
			else
				tkgrid(buttonList[[i]], column=i, row=1, padx=c(3, 12))
		}else
			tkgrid(buttonList[[i]], column=i, row=1, padx=3)
	}
	
	##configure dialog window
	defButton <- buttonList[[match(default, buttons)]]
	tkconfigure(defButton, state='active')
	tkbind(dlg, '<Destroy>', function(...) return(returnVal))
	tkbind(dlg, '<Return>', function(...) tryCatch(tkinvoke(tkfocus()), 
						error=function(er){}))
	tkwm.deiconify(dlg)
	if (as.logical(tkwinfo('viewable', dlg)))
		tkgrab.set(dlg)
	tkfocus(defButton)
	tkwait.window(dlg)
	
	return(returnVal)
}


############################################################
#                                                          #
#       User Functions for changing R GUI settings         #
#                                                          #
############################################################

## Changes R console settings to SDI mode
sdi <- function(){
	
	## Doesn't run if Rgui isn't running
	if (.Platform$OS.type != 'windows' || .Platform$GUI != 'Rgui')
		return(invisible())
	
	## Reads in the Rconsole file from the R user directory
	conPath <- file.path(Sys.getenv('R_USER'), 'Rconsole')
	if (file.exists(file.path(Sys.getenv('R_USER'), 'Rconsole'))){
		readCon <- file(conPath)
		conText <- readLines(readCon)
		close(readCon)
		file.remove(conPath)
		
		## Reads in the Rconsole file from the R home directory
	}else if (file.access(file.path(R.home('etc'), 'Rconsole'), 2) == 0){
		conPath <- file.path(R.home('etc'), 'Rconsole')
		readCon <- file(conPath)
		conText <- readLines(readCon)
		close(readCon)
		file.remove(conPath)
		
		## Copies Rconsole file from R home directory to R user directory
	}else{
		conPath <- file.path(R.home('etc'), 'Rconsole')
		readCon <- file(conPath)
		conText <- readLines(readCon)
		close(readCon)
		file.copy(conPath, file.path(Sys.getenv('R_USER'), 'Rconsole'))
	}
	
	## Writes out a new Rconsole file
	outFile <- conText
	file.create(conPath)
	writeCon <- file(conPath, 'w')
	matches <- NULL
	for (i in c('MDI = yes', 'MDI= yes', 'MDI =yes', 'MDI=yes'))
		matches <- c(matches, length(grep(i, outFile)) != 0)
	if (any(matches)){
		for (i in c('MDI = yes', 'MDI= yes', 'MDI =yes', 'MDI=yes'))
			outFile <- gsub(i, 'MDI = no', outFile)
		writeLines(outFile, writeCon)
	}else
		writeLines(outFile, writeCon)
	close(writeCon)	
	invisible(myMsg(paste('             R console settings updated.', '\n', 
							'R must be restarted for changes to take effect.'), icon='info'))
}

## Checks that the R console is in SDI mode
## dispMsg - if FALSE, returns TRUE if Rgui is in SDI mode, returns FALSE if 
##	in MDI mode, and does not display a message
sdiCheck <- function(dispMsg=TRUE){
	
	## Doesn't check Rconsole if Rgui isn't running
	if (.Platform$OS.type != 'windows' || .Platform$GUI != 'Rgui')
		return(TRUE)
	
	## Doesn't check if sdi is set to FALSE in defaultSettings
	if (!defaultSettings$sdi)
		return(FALSE)
	
	## Check R user directory for Rconsole file
	if (file.exists(file.path(Sys.getenv('R_USER'), 'Rconsole')))
		conPath <- file.path(Sys.getenv('R_USER'), 'Rconsole')
	
	## Uses Rconsole file in R home directory
	else
		conPath <- file.path(R.home('etc'), 'Rconsole')
	
	## Reads in the Rconsole file
	readCon <- file(conPath)
	conText <- readLines(readCon)
	close(readCon)
	
	## Checks for lines in Rconsole file that set MDI to yes
	mdiYes <- 0
	for (i in c('MDI = yes', 'MDI= yes', 'MDI =yes', 'MDI=yes')){
		matchedLines <- grep(i, conText)
		for (j in matchedLines){
			matchedText <- unlist(strsplit(conText[j], '#'))
			if (length(grep(i, matchedText[1])) != 0)
				mdiYes <- j
		}
	}
	
	## Checks for lines in Rconsole file that set MDI to no
	mdiNo <- 0
	for (i in c('MDI = no', 'MDI= no', 'MDI =no', 'MDI=no')){
		matchedLines <- grep(i, conText)
		for (j in matchedLines){
			matchedText <- unlist(strsplit(conText[j], '#'))
			if (length(grep(i, matchedText[1])) != 0)
				mdiNo <- j
		}
	}
	if (mdiNo <= mdiYes)
		mdiMode <- TRUE
	else
		mdiMode <- FALSE
	if (!dispMsg)
		return(!mdiMode)
	
	## Warns user about running R in MDI mode
	if (mdiMode){
		usr <- buttonDlg(paste('R is currently running in MDI mode.  For rNMR, we',
						' suggest\nconfiguring R to display windows separately (SDI mode).',
						'\n\nWould you like to switch to SDI mode?', sep=''), 
				buttons=c('Yes', 'No', 'Don\'t display this message again'), TRUE, 
				default='No')
		if (usr[1] == 'Yes')
			sdi()
		
		## Edit defaultSettings if user doesn't want message to be displayed again
		if (as.logical(usr[2])){
			defaultSettings$sdi <- FALSE
			writeDef(defSet=defaultSettings)
			myAssign('defaultSettings', defaultSettings)
		}
	}
}

############################################################
#                                                          #
#                       Tk GUIs                            #
#                                                          #
############################################################

## Internal function used on file lists in Tk GUIs
## resets file and overlay lists to match any changes made to fileFolder
reset <- function(lists, boxes, prevPaths, update='files', dims='both'){
	
	## Restructure inputs if only one list (the files list) is being reset
	if (length(lists) == 1){
		lists <- list(lists, NULL)
		boxes <- list(boxes, NULL)
		prevPaths <- list(prevPaths, NULL)
		update <- c('files', NULL)
	}
	
	## Assign names to inputs
	names(lists) <- names(boxes) <- names(prevPaths) <- update
	
	## Reset file lists
	if ('files' %in% update){
		
		## Update file list using the names in fileFolder 
		if (dims == '1D')
			newPaths <- names(fileFolder)[which(sapply(fileFolder, 
									function(x){x$file.par$number_dimensions}) == 1)]
		else if (dims == '2D')
			newPaths <- names(fileFolder)[which(sapply(fileFolder, 
									function(x){x$file.par$number_dimensions}) > 1)]
		else
			newPaths <- names(fileFolder)
		if (!is.null(newPaths)){
			if ('overlays' %in% update){
				overlayMatches <- match(overlayList, newPaths)
				if (length(overlayMatches))
					newPaths <- newPaths[-overlayMatches]
			}
			tclObj(lists$files) <- getTitles(newPaths)
			
			## Get previous selection and reset
			prevSel <- prevPaths$files[as.integer(tkcurselection(boxes$files)) + 1]
			if (length(prevSel)){
				tkselection.clear(boxes$files, 0, 'end')
				curSel <- match(prevSel, newPaths, nomatch=0) - 1
				for (i in curSel)
					tkselection.set(boxes$files, i)
			}
			
			## Alternate colors in listbox
			if (length(newPaths) > 2){
				for (i in seq(0, length(newPaths) - 1, 2))
					tkitemconfigure(boxes$files, i, background='#ececff')
			}
		}else
			tclObj(lists$files) <- ''
	}
	
	## Reset overlay lists
	if ('overlays' %in% update){
		
		## Update overlay list using overlayList 
		if (!is.null(overlayList)){
			tclObj(lists$overlays) <- getTitles(overlayList)
			
			## Get previous selection and reset
			prevSel <- prevPaths$overlays[as.integer(tkcurselection(boxes$overlays)) + 
							1]
			if (length(prevSel)){
				tkselection.clear(boxes$overlays, 0, 'end')
				curSel <- match(prevSel, overlayList, nomatch=0) - 1
				for (i in curSel)
					tkselection.set(boxes$overlays, i)
			}
			
			## Alternate colors in listbox
			if (length(overlayList) > 2){
				for (i in seq(0, length(overlayList) - 1, 2))
					tkitemconfigure(boxes$overlays, i, background='#ececff')
			}
		}else
			tclObj(lists$overlays) <- character(0)
	}
}	

## Internal function for changing colors within Tk GUIs
## parent - the tktoplevel to be used as the parent window for the color widget
## type - the type of color change (eg. 'peak')
## usrFiles - list of files to apply color changes to
changeColor <- function(parent, type, usrFiles=NULL){
	
	## Display color selection dialogue
	initCol <- switch(type, 'peak'=defaultSettings$peak.color,
			'bg'=defaultSettings$bg,
			'axes'=defaultSettings$col.axis,
			'pos'=defaultSettings$pos.color,
			'neg'=defaultSettings$neg.color,
			'proj'=defaultSettings$proj.color,
			'1D'=defaultSettings$proj.color,
			'abox'=defaultSettings$roi.bcolor[1],
			'ibox'=defaultSettings$roi.bcolor[2],
			'atext'=defaultSettings$roi.tcolor[1],
			'itext'=defaultSettings$roi.tcolor[2])
	usrColor <- tclvalue(tcl("tk_chooseColor", parent=parent, 
					initialcolor=initCol))
	
	## Set color
	if (nzchar(usrColor)){
		switch(type, 
				'peak'=setGraphics(usrFiles, peak.color=usrColor),
				'bg'=setGraphics(usrFiles, bg=usrColor),
				'axes'=setGraphics(usrFiles, line.color=usrColor),
				'pos'=setGraphics(usrFiles, pos.color=usrColor),
				'neg'=setGraphics(usrFiles, neg.color=usrColor),
				'proj'=setGraphics(usrFiles, proj.color=usrColor),
				'1D'=setGraphics(usrFiles, proj.color=usrColor),
				'abox'=setGraphics(roi.bcolor=c(usrColor, 
								globalSettings$roi.bcolor[2])),
				'ibox'=setGraphics(roi.bcolor=c(globalSettings$roi.bcolor[1], 
								usrColor)),
				'atext'=setGraphics(roi.tcolor=c(usrColor, 
								globalSettings$roi.tcolor[2])),
				'itext'=setGraphics(roi.tcolor=c(globalSettings$roi.tcolor[1], 
								usrColor)))
		refresh()
		tkfocus(parent)
		tkwm.deiconify(parent)
		bringFocus()
	}
}

## Interactive GUI for handling perspective plots
per <- function(){
	
	## GUI doesn't open if currentSpectrum is a 1D file
	current <- wc()
	if (fileFolder[[current]]$file.par$number_dimensions == 1)
		err(paste('The perspective GUI can only be opened if the current spectrum',
						'is two-dimensional.'))
	
	##creates main window
	tclCheck()
	dlg <- myToplevel('per', padx=3, pady=5)
	if (is.null(dlg))
		return(invisible())
	setGraphics(type='persp', save.backup=FALSE, refresh.graphics=TRUE)
	tkwm.title(dlg, 'Perspective')
	tkwm.resizable(dlg, FALSE, FALSE)
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	if (.Platform$OS == 'windows')
		tcl('wm', 'attributes', dlg, toolwindow=TRUE)
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	winClose <- function(name){
		tryCatch(setGraphics(type='auto', refresh.graphics=TRUE), 
				error=function(er){})
		closeGui(name)
	}
	tkwm.protocol(dlg, 'WM_DELETE_WINDOW', function(...) winClose('per'))
	
	##create radiobuttons
	rbVal <- tclVar('rotate')
	onRotate <- function(){
		tkconfigure(upButton, text='^')
		tkconfigure(downButton, text='v')
		tkconfigure(leftButton, text='<', state='normal')
		tkconfigure(rightButton, text='>', state='normal')
		tkfocus(dlg)
	}
	rotButton <- ttkradiobutton(dlg, variable=rbVal, value='rotate', 
			text='rotate', command=onRotate)
	
	onZoom <- function(){
		tkconfigure(upButton, text='In')
		tkconfigure(downButton, text='Out')
		tkconfigure(leftButton, state='disabled')
		tkconfigure(rightButton, state='disabled')
		tkfocus(dlg)
	}
	zoomButton <- ttkradiobutton(dlg, variable=rbVal, value='zoom', 
			text='zoom', command=onZoom)
	
	onScroll <- function(){
		tkconfigure(upButton, text='^')
		tkconfigure(downButton, text='v')
		tkconfigure(leftButton, text='<', state='normal')
		tkconfigure(rightButton, text='>', state='normal')
		tkfocus(dlg)
	}
	scrollButton <- ttkradiobutton(dlg, variable=rbVal, value='scroll', 
			text='scroll', command=onScroll)
	
	##create arrow buttons
	arrowFrame <- ttkframe(dlg)
	inc <- tclVar(5)
	onArrow <- function(type, direct, n){
		type=tclvalue(type)
		tryCatch({n <- as.numeric(tclvalue((inc)))
					if (n < 0)
						warning()
				}, warning = function(w){
					err('Increment value must be a positive number', parent=dlg)
				})
		if (type == 'rotate'){
			switch(direct, 'up'=rotu(n), 
					'down'=rotd(n), 
					'left'=rotc(n), 
					'right'=rotcc(n))
		}else if (type == 'scroll'){
			switch(direct, 'up'=pu(n), 
					'down'=pd(n), 
					'left'=pl(n), 
					'right'=pr(n))
		}else{
			switch(direct, 'up'=zi(n), 'down'=zo(n)) 
		}	
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	upButton <- ttkbutton(arrowFrame, text='^', width=5, command=function(...) 
				onArrow(rbVal, 'up', inc))
	downButton <- ttkbutton(arrowFrame, text='v', width=5, command=function(...) 
				onArrow(rbVal, 'down', inc))
	leftButton <- ttkbutton(arrowFrame, text='<', width=4, command=function(...) 
				onArrow(rbVal, 'left', inc))
	rightButton <- ttkbutton(arrowFrame, text='>', width=4, command=function(...) 
				onArrow(rbVal, 'right', inc))
	editEntry <- ttkentry(arrowFrame, textvariable=inc, width=5, justify='center')
	
	##create center button
	onZc <- function(){
		zc()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	centerButton <- ttkbutton(dlg, text='Center', width=6, command=onZc)
	
	##create peak spin button
	onSpin <- function(){
		spin()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	spinButton <- ttkbutton(dlg, text='Spin', width=6, command=onSpin)
	
	##add widgets to dlg
	tkgrid(rotButton, column=1, row=1, sticky='e', padx=c(4, 0), sticky='e')
	tkgrid(zoomButton, column=2, row=1, padx=2)
	tkgrid(scrollButton, column=3, row=1, sticky='w', padx=c(0, 4), sticky='w')
	
	tkgrid(arrowFrame, column=1, columnspan=3, row=2)
	tkgrid(upButton, column=2, row=1, sticky='s', pady=c(3, 0))
	tkgrid(leftButton, column=1, row=2, sticky='e')
	tkgrid(editEntry, column=2, row=2)
	tkgrid(rightButton, column=3, row=2, sticky='w')
	tkgrid(downButton, column=2, row=3, sticky='n', pady=c(0, 4))
	
	tkgrid(centerButton, column=1, row=3)
	tkgrid(spinButton, column=3, row=3)
	
	##turn off perspective when GUI is closed
	tkbind(dlg, '<Return>', function(...) tryCatch(tkinvoke(tkfocus()), 
						error=function(er){}))
	
	invisible()
}

## Interactive GUI for manipulating plot settings
ps <- function(dispPane='co'){
	
	##create main window
	current <- wc()
	tclCheck()
	dlg <- myToplevel('ps')
	if (is.null(dlg)){
		if (dispPane == 'co')
			tkselect('.ps.1', 0)
		else if (dispPane == 'ct1D')
			tkselect('.ps.1', 1)
		else
			tkselect('.ps.1', 2)
		return(invisible())
	}
	tkwm.title(dlg, 'Plot Settings')
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##create paned notebook
	plotBook <- ttknotebook(dlg, padding=3)
	
	##create plot settings panes
	coFrame <- ttkframe(plotBook, padding=c(0, 0, 2, 12)) 
	onedFrame <- ttkframe(plotBook, padding=c(0, 0, 2, 12))
	twodFrame <- ttkframe(plotBook, padding=c(0, 0, 12, 12))
	tkadd(plotBook, coFrame, text='Plot Colors')
	tkadd(plotBook, onedFrame, text='1D Spectra')
	tkadd(plotBook, twodFrame, text='2D Spectra')
	
	##add widgets to toplevel
	tkgrid(plotBook, column=1, row=1, sticky='nsew', padx=c(6, 0), pady=c(6, 0))
	tkgrid(ttksizegrip(dlg), column=2, row=2, sticky='se')
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=1)		
	
	##switch to the appropriate notebook pane
	if (dispPane == 'co')
		tkselect(plotBook, 0)
	else if (dispPane == 'ct1D')
		tkselect(plotBook, 1)
	else
		tkselect(plotBook, 2)
	
	####create widgets for coFrame
	##create file list box
	coFileFrame <- ttklabelframe(coFrame, text='Files')
	coFileList <- tclVar()
	coFileNames <- names(fileFolder)
	tclObj(coFileList) <- getTitles(coFileNames)
	coFileBox <- tklistbox(coFileFrame, width=30, listvariable=coFileList, 
			selectmode='extended', active='dotbox',	exportselection=FALSE, bg='white',
			xscrollcommand=function(...) tkset(coXscr, ...), 
			yscrollcommand=function(...) tkset(coYscr, ...))
	coXscr <- ttkscrollbar(coFileFrame, orient='horizontal',
			command=function(...) tkxview(coFileBox, ...))
	coYscr <- ttkscrollbar(coFileFrame, orient='vertical', 
			command=function(...) tkyview(coFileBox, ...))
	if (length(coFileNames) > 2){
		for (i in seq(0, length(coFileNames) - 1, 2))
			tkitemconfigure(coFileBox, i, background='#ececff')
	}
	tkselection.set(coFileBox, wc() - 1)
	tcl(coFileBox, 'see', wc() - 1)
	
	##export fileBox selections to other tabs
	coSelect <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		onedFiles <- names(fileFolder)[which(sapply(fileFolder, function(x)
								{x$file.par$number_dimensions}) == 1)]
		twodFiles <- names(fileFolder)[which(sapply(fileFolder, function(x)
								{x$file.par$number_dimensions}) > 1)]
		if (!is.null(usrSel)){
			onedIndices <- na.omit(match(names(fileFolder)[usrSel], onedFiles))
			if (length(onedIndices)){
				tkselection.clear(onedFileBox, 0, 'end')
				for (i in onedIndices)
					tkselection.set(onedFileBox, i - 1)
			}
			twodIndices <- na.omit(match(names(fileFolder)[usrSel], twodFiles))
			if (length(twodIndices)){
				tkselection.clear(twodFileBox, 0, 'end')
				for (i in twodIndices)
					tkselection.set(twodFileBox, i - 1)
			}
		}
		coConfigGui()
	}
	tkbind(coFileBox, '<<ListboxSelect>>', coSelect)
	
	##switches spectra on left-mouse double-click
	coDouble <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFile <- coFileNames[usrSel]
		else
			usrFile <- NULL
		if (!is.null(usrFile) && currentSpectrum != usrFile){
			myAssign('currentSpectrum', usrFile)
			refresh(multi.plot=FALSE)
			bringFocus()
			tkwm.deiconify(dlg)
			tkfocus(coFileBox)
		}
	}
	tkbind(coFileBox, '<Double-Button-1>', coDouble)
	
	##create set axes color button
	coOptionFrame <- ttklabelframe(coFrame, text='Color options', padding=5)
	onAxes <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		changeColor(dlg, 'axes', usrFiles)
	}
	axesColButton <- ttkbutton(coOptionFrame, text='Axes', width=11, 
			command=onAxes)
	
	##create set background color button
	onBg <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		changeColor(dlg, 'bg', usrFiles)
	}
	bgColButton <- ttkbutton(coOptionFrame, text='BG', width=11, command=onBg)
	
	##create set peak color button
	onPeak <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		changeColor(dlg, 'peak', usrFiles)
	}
	peakColButton <- ttkbutton(coOptionFrame, text='Peak labels', width=11, 
			command=onPeak)
	
	##create set 1D color button
	onProj <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		changeColor(dlg, 'proj', usrFiles)
	}
	projColButton <- ttkbutton(coOptionFrame, width=11, text='1D', 
			command=onProj)
	
	##create set positive contour color button
	onPos <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		changeColor(dlg, 'pos', usrFiles)
	}
	posColButton <- ttkbutton(coOptionFrame, width=11, text='+ Contour', 
			command=onPos)
	
	##create set negative contour color button
	onNeg <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		changeColor(dlg, 'neg', usrFiles)
	}
	negColButton <- ttkbutton(coOptionFrame, width=11, text='- Contour', 
			command=onNeg)
	
	##create ROI box color buttons
	boxColLabel <- ttklabel(coOptionFrame, text='ROI Boxes:')
	aboxColButton <- ttkbutton(coOptionFrame, text='Active', width=9, 
			command=function(...) changeColor(dlg, 'abox'))
	iboxColButton <- ttkbutton(coOptionFrame, text='Inactive', width=9, 
			command=function(...) changeColor(dlg, 'ibox'))
	
	##create ROI label color buttons
	textColLabel <- ttklabel(coOptionFrame, text='ROI Labels:')
	atextColButton <- ttkbutton(coOptionFrame, text='Active', width=9, 
			command=function(...) changeColor(dlg, 'atext'))
	itextColButton <- ttkbutton(coOptionFrame, text='Inactive', width=9, 
			command=function(...) changeColor(dlg, 'itext'))
	
	##create print graphics button
	onContrast <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		setGraphics(usrFiles, bg='white', line.color='black', pos.color='black', 
				neg.color='black', proj.color='black', peak.color='black', 
				roi.bcolor=c('red', 'black'), roi.tcolor=c('red', 'black'),
				refresh.graphics=TRUE)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	contrastButton <- ttkbutton(coOptionFrame, text='High contrast', 
			command=onContrast)
	
	##create default colors button
	onDefaultColors <- function(){
		usrSel <- 1 + as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		setGraphics(usrFiles, bg=defaultSettings$bg, 
				line.color=defaultSettings$col.axis, 
				pos.color=defaultSettings$pos.color, 
				neg.color= defaultSettings$neg.color, 
				proj.color=defaultSettings$proj.color,
				peak.color=defaultSettings$peak.color,
				roi.bcolor=defaultSettings$roi.bcolor, 
				roi.tcolor=defaultSettings$roi.tcolor,
				refresh.graphics=TRUE)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	defaultButton <- ttkbutton(coOptionFrame, text='Defaults', 
			command=onDefaultColors)
	
	##add widgets to fileFrame
	tkgrid(coFileFrame, column=1, row=1, sticky='nswe', pady=c(6, 4),	padx=8)
	tkgrid(coFileBox, column=1, row=1, sticky='nswe')
	tkgrid(coYscr, column=2, row=1, sticky='ns')
	tkgrid(coXscr, column=1, row=2, sticky='we')
	
	##make fileFrame stretch when window is resized
	tkgrid.columnconfigure(coFrame, 1, weight=1)
	tkgrid.rowconfigure(coFrame, 1, weight=10)
	tkgrid.columnconfigure(coFileFrame, 1, weight=1)
	tkgrid.rowconfigure(coFileFrame, 1, weight=1)
	
	##add widgets to coOptionFrame
	tkgrid(coOptionFrame, column=2, row=1, padx=c(4, 10))
	tkgrid(axesColButton, column=1, row=1, pady=c(3, 1), padx=1)
	tkgrid(bgColButton, column=2, row=1, pady=c(3, 1), padx=1)
	tkgrid(peakColButton, column=1, row=2, pady=1, padx=1)
	tkgrid(projColButton, column=2, row=2, pady=1, padx=1)
	tkgrid(posColButton, column=1, row=3, pady=1, padx=1)
	tkgrid(negColButton, column=2, row=3, pady=1, padx=1)
	tkgrid(boxColLabel, column=1, row=4, pady=c(8, 1), padx=1, sticky='w')
	tkgrid(aboxColButton, column=1, row=5, pady=1, padx=c(3, 1), sticky='e')
	tkgrid(iboxColButton, column=2, row=5, pady=1, padx=1, sticky='w')
	tkgrid(textColLabel, column=1, row=6, pady=c(6, 1), padx=1, sticky='w')
	tkgrid(atextColButton, column=1, row=7, pady=1, padx=c(3, 1), sticky='e')
	tkgrid(itextColButton, column=2, row=7, pady=1, padx=1, sticky='w')
	tkgrid(contrastButton, column=1, columnspan=2, row=8, pady=c(16, 1), 
			padx=25, sticky='we')
	tkgrid(defaultButton, row=8, column=1, columnspan=2, row=9, pady=6, padx=25, 
			sticky='we')
	
	##make optionFrame stretch when window is resized
	tkgrid.rowconfigure(coOptionFrame, 0, weight=1)
	tkgrid.rowconfigure(coOptionFrame, 9, weight=1)
	
	##reconfigures widgets in GUI according to which spectra are open
	coConfigGui <- function(){
		usrSel <- 1 +	as.integer(tkcurselection(coFileBox))
		if (length(usrSel))
			usrFiles <- coFileNames[usrSel]
		else
			usrFiles <- currentSpectrum
		twoD <- FALSE
		for (i in usrFiles){
			if (fileFolder[[i]]$file.par$number_dimensions > 1){
				twoD <- TRUE
				break
			}
		}
		if (twoD){
			tkconfigure(posColButton, state='normal')
			tkconfigure(negColButton, state='normal')
		}else{
			tkconfigure(posColButton, state='disabled')
			tkconfigure(negColButton, state='disabled')
		}
	}
	coConfigGui()	
	
	##resets file list and options whenever the mouse enters the GUI
	coMouse <- function(){
		reset(coFileList, coFileBox, coFileNames)
		coFileNames <<- names(fileFolder)
	}
	tkbind(coFrame, '<Enter>', coMouse)
	tkbind(coFrame, '<FocusIn>', coMouse)
	
	####create widgets for onedFrame
	##create file list box
	current <- wc()
	onedFileFrame <- ttklabelframe(onedFrame, text='Files')
	onedFileList <- tclVar()
	onedFileNames <- names(fileFolder)[which(sapply(fileFolder, 
							function(x){x$file.par$number_dimensions}) == 1)]
	tclObj(onedFileList) <- getTitles(onedFileNames)
	onedFileBox <- tklistbox(onedFileFrame, width=30, listvariable=onedFileList, 
			selectmode='extended', active='dotbox',	exportselection=FALSE, bg='white',
			xscrollcommand=function(...) tkset(onedXscr, ...), 
			yscrollcommand=function(...) tkset(onedYscr, ...))
	onedXscr <- ttkscrollbar(onedFileFrame, orient='horizontal',
			command=function(...) tkxview(onedFileBox, ...))
	onedYscr <- ttkscrollbar(onedFileFrame, orient='vertical', 
			command=function(...) tkyview(onedFileBox, ...))
	if (length(onedFileNames) > 2){
		for (i in seq(0, length(onedFileNames) - 1, 2))
			tkitemconfigure(onedFileBox, i, background='#ececff')
	}
	if (fileFolder[[current]]$file.par$number_dimensions == 1){
		tkselection.set(onedFileBox, match(currentSpectrum, onedFileNames) - 1)
		tcl(onedFileBox, 'see', match(currentSpectrum, onedFileNames) - 1)
	}
	
	##export fileBox selections to other tabs
	onedSelect <- function(){
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		usrFile <- onedFileNames[usrSel]
		onedFiles <- names(fileFolder)[which(sapply(fileFolder, function(x)
								{x$file.par$number_dimensions}) == 1)] 
		selIndices <- match(onedFiles[usrSel], names(fileFolder))
		tkselection.clear(coFileBox, 0, 'end')
		for (i in selIndices)
			tkselection.set(coFileBox, i - 1)
		onedConfigGui()
	}
	tkbind(onedFileBox, '<<ListboxSelect>>', onedSelect)
	
	##switches spectra on left-mouse double-click
	onedDouble <- function(){
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		if (length(usrSel))
			usrFile <- onedFileNames[usrSel]
		else
			usrFile <- NULL
		if (!is.null(usrFile) && currentSpectrum != usrFile){
			myAssign('currentSpectrum', usrFile)
			refresh(multi.plot=FALSE)
			bringFocus()
			tkwm.deiconify(dlg)
			tkfocus(onedFileBox)
		}
	}
	tkbind(onedFileBox, '<Double-Button-1>', onedDouble)
	
	##creates switch number of dimensions radio buttons
	onedOptionFrame <- ttkframe(onedFrame)
	
	##create plot type radiobuttons
	onedTypeFrame <- ttklabelframe(onedOptionFrame, text='Plot type')
	ptype <- switch(fileFolder[[current]]$graphics.par$type, 'auto'='line',
			'p'='points', 'b'='both')
	if (is.null(ptype))
		ptype <- ''
	onedPlotType <- tclVar(ptype)
	onedType <- function(){
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		if (length(usrSel))
			usrFiles <- onedFileNames[usrSel]
		else{
			if (currentSpectrum %in% onedFileNames)
				usrFiles <- currentSpectrum
			else{
				tclObj(onedPlotType) <- 'line'
				err(paste('You must select a spectrum from the list before changing',
								'plot options'), parent=dlg)
			}
		}
		pType <- switch(tclvalue(onedPlotType), 'line'='auto', 'points'='p', 
				'both'='b')
		setGraphics(usrFiles, type=pType, refresh.graphics=TRUE)	
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	rbLine <- ttkradiobutton(onedTypeFrame, variable=onedPlotType, value='line',
			text='Line', command=onedType)
	rbPoints <- ttkradiobutton(onedTypeFrame, variable=onedPlotType, 
			value='points', text='Points', command=onedType)
	rbBoth <- ttkradiobutton(onedTypeFrame, variable=onedPlotType, value='both',
			text='Both', command=onedType)
	
	##create vertical position label
	vpFrame <- ttklabelframe(onedOptionFrame, text='Baseline')
	postn <- globalSettings$position.1D
	if(postn <= 1)
		postn <- (postn) / 2 * 100
	else
		postn <- 100 - (1 / postn) * 50 
	positionVal <- tclVar(postn)
	positionLab <- ttklabel(vpFrame, text='Position:')
	valLab <-	ttklabel(vpFrame, textvariable=positionVal, width=2)
	
	##creates vertical position slider
	posSlider <- tkscale(vpFrame, from=99, to=0, variable=positionVal, 
			orient='vertical', showvalue=F,	tickinterval=99, length=110, width=13, 
			bg=as.character(tkcget(dlg, '-background')))
	onPosSlider <- function(){
		invisible(vp(as.numeric(tclObj(positionVal))))
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	tkbind(posSlider, '<ButtonRelease>', onPosSlider)	
	tkbind(posSlider, '<Return>', onPosSlider)	
	
	##create default button
	onedDefault <- function(){
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		if (length(usrSel))
			usrFiles <- onedFileNames[usrSel]	
		else{
			if (currentSpectrum %in% onedFileNames)
				usrFiles <- currentSpectrum
			else
				err(paste('You must select a spectrum from the list before changing',
								'plot options'), parent=dlg)
		}
		if (defaultSettings$type %in% c('p', 'b'))
			pType <- defaultSettings$type
		else
			pType <- 'l'		
		tclObj(onedPlotType) <- switch(pType, 'l'='line', 'p'='points', 'b'='both')
		postn <- defaultSettings$position.1D
		if (postn <= 1)
			postn <- (postn) / 2 * 100
		else
			postn <- 100 - (1 / postn) * 50 
		tclObj(positionVal) <- postn
		setGraphics(usrFiles, type=pType, proj.color=defaultSettings$proj.color, 
				save.backup=FALSE)
		invisible(vp(postn))
	}
	defaultButton <- ttkbutton(onedOptionFrame, text='Defaults', width=11, 
			command=onedDefault)
	
	##add widgets to fileFrame
	tkgrid(onedFileFrame, column=1, row=1, sticky='nswe', pady=c(6, 4),	padx=8)
	tkgrid(onedFileBox, column=1, row=1, sticky='nswe')
	tkgrid(onedYscr, column=2, row=1, sticky='ns')
	tkgrid(onedXscr, column=1, row=2, sticky='we')
	
	##make fileFrame stretch when window is resized
	tkgrid.columnconfigure(onedFrame, 1, weight=1)
	tkgrid.rowconfigure(onedFrame, 1, weight=10)
	tkgrid.columnconfigure(onedFileFrame, 1, weight=1)
	tkgrid.rowconfigure(onedFileFrame, 1, weight=1)
	
	##add widgets to optionFrame
	tkgrid(onedOptionFrame, column=2, row=1, sticky='nswe', pady=c(10, 2), 
			padx=c(4, 0))
	tkgrid(onedTypeFrame, column=1, row=2, padx=3, sticky='nsew')
	tkgrid(rbLine, column=1, row=1, padx=3, pady=6, sticky='w')
	tkgrid(rbPoints, column=1, row=2, padx=3, pady=6, sticky='w')
	tkgrid(rbBoth, column=1, row=3, padx=3, pady=6, sticky='w')
	
	tkgrid(defaultButton, column=1, row=3, padx=2, sticky='s')
	
	tkgrid(vpFrame, column=2, row=2, rowspan=2, padx=c(10, 15), sticky='nsew')
	tkgrid(positionLab, column=1, row=1, sticky='e', padx=c(1, 0))
	tkgrid(valLab, column=2, row=1, sticky='w', padx=2)
	tkgrid(posSlider, column=1, row=2, columnspan=2, padx=c(0, 5), sticky='ns')
	
	##make optionFrame stretch when window is resized
	tkgrid.rowconfigure(onedOptionFrame, 0, weight=1)
	tkgrid.rowconfigure(onedOptionFrame, 4, weight=1)
	
	##reconfigures widgets in GUI according to which spectra are open
	onedConfigGui <- function(){
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		if (length(usrSel))
			usrFile <- onedFileNames[usrSel]
		else{
			if (length(names(fileFolder)) && currentSpectrum %in% onedFileNames)
				usrFile <- currentSpectrum
			else
				return(invisible())
		}
		if (length(usrFile) == 1){
			ptype <- switch(fileFolder[[usrFile]]$graphics.par$type, 'auto'='line',
					'l'='line', 'p'='points', 'b'='both')
			if (is.null(ptype))
				ptype <- ''
			tclObj(onedPlotType) <- ptype
		}else{
			allEqual <- TRUE
			for (i in 2:length(usrFile)){
				if (fileFolder[[usrFile[i]]]$graphics.par$type != 
						fileFolder[[usrFile[i - 1]]]$graphics.par$type){
					allEqual <- FALSE
					break
				}
			}
			if (allEqual)
				tclObj(onedPlotType) <- 
						switch(fileFolder[[usrFile[1]]]$graphics.par$type, 'auto'='line', 
								'l'='line', 'p'='points', 'b'='both')
			else
				tclObj(onedPlotType) <- ''	
		}
		postn <- globalSettings$position.1D
		if (postn <= 1)
			postn <- (postn) / 2 * 100
		else
			postn <- 100 - (1 / postn) * 50 
		tclObj(positionVal) <- postn
	}
	onedConfigGui()
	
	##resets file list and options whenever the mouse enters the GUI
	onedMouse <- function(){
		reset(onedFileList, onedFileBox, onedFileNames, dims='1D')
		onedFileNames <<- names(fileFolder)[which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) == 1)]
		onedConfigGui()
	}
	tkbind(onedFrame, '<Enter>', onedMouse)
	tkbind(onedFrame, '<FocusIn>', onedMouse)
	
	####create widgets for twodFrame
	##create file list box
	current <- wc()
	twodFileFrame <- ttklabelframe(twodFrame, text='Files')
	twodFileList <- tclVar()
	twodFileNames <- names(fileFolder)[which(sapply(fileFolder, 
							function(x){x$file.par$number_dimensions}) > 1)]
	tclObj(twodFileList) <- getTitles(twodFileNames)
	twodFileBox <- tklistbox(twodFileFrame, width=35, listvariable=twodFileList, 
			selectmode='extended', active='dotbox',	exportselection=FALSE, bg='white', 
			xscrollcommand=function(...) tkset(twodXscr, ...), 
			yscrollcommand=function(...) tkset(twodYscr, ...))
	twodXscr <- ttkscrollbar(twodFileFrame, orient='horizontal',
			command=function(...) tkxview(twodFileBox, ...))
	twodYscr <- ttkscrollbar(twodFileFrame, orient='vertical', 
			command=function(...) tkyview(twodFileBox, ...))
	if (length(twodFileNames) > 2){
		for (i in seq(0, length(twodFileNames) - 1, 2))
			tkitemconfigure(twodFileBox, i, background='#ececff')
	}
	if (fileFolder[[current]]$file.par$number_dimensions > 1){
		tkselection.set(twodFileBox, match(currentSpectrum, twodFileNames) - 1)
		tcl(twodFileBox, 'see', match(currentSpectrum, twodFileNames) - 1)
	}
	
	##exports fileBox selections to other tabs and resets values in GUI
	twodSelect <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		usrFiles <- twodFileNames[usrSel]
		selIndices <- match(usrFiles, names(fileFolder))
		tkselection.clear(coFileBox, 0, 'end')
		for (i in selIndices)
			tkselection.set(coFileBox, i - 1)
		twodConfigGui()
		
		if (length(usrFiles) == 1){
			
			##resets contour threshold slider
			clevel <- fileFolder[[usrFiles]]$graphics.par$clevel
			if (clevel > 25){
				if (!log10(clevel) %% 1)
					threshMax <- clevel
				else{
					digits <- nchar(as.character(clevel))
					threshMax <- 10^digits
				}
				threshRes <- threshMax / 100
			}else{
				threshMax <- 25
				threshRes <- .1
			}
			tkconfigure(threshSlider, fg='black', from=0, to=threshMax, 
					tickinterval=threshMax, resolution=threshRes)
			tclObj(threshVal) <- clevel
			
			##resets contour level slider
			nlevels <- fileFolder[[usrFiles]]$graphics.par$nlevels
			if (nlevels <= 100)
				levelMax <- 100
			else
				levelMax <- 1000
			tkconfigure(levelSlider, fg='black', from=levelMax / 100, to=levelMax, 
					tickinterval=levelMax - levelMax / 100, resolution=levelMax / 100)
			tclObj(levelVal) <- nlevels
		}
	}
	tkbind(twodFileBox, '<<ListboxSelect>>', twodSelect)
	
	##switches spectra on left-mouse double-click
	twodDouble <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		if (length(usrSel))
			usrFile <- twodFileNames[usrSel]
		else
			usrFile <- NULL
		if (!is.null(usrFile) && currentSpectrum != usrFile){
			myAssign('currentSpectrum', usrFile)
			refresh(multi.plot=FALSE)
			bringFocus()
			tkwm.deiconify(dlg)
			tkfocus(twodFileBox)
		}
	}
	tkbind(twodFileBox, '<Double-Button-1>', twodDouble)
	
	##create plot type radio buttons
	twodOptionFrame <- ttkframe(twodFrame)
	twodTypeFrame <- ttklabelframe(twodOptionFrame, text='Plot type', padding=3)
	pType <- fileFolder[[current]]$graphics.par$type
	if (is.null(pType))
		pType <- ''
	twodPlotType <- tclVar(pType)
	twodType <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		if (length(usrSel))
			usrFiles <- twodFileNames[usrSel]
		else{
			if (currentSpectrum %in% twodFileNames)
				usrFiles <- currentSpectrum
			else
				err(paste('You must select a spectrum from the list before changing',
								'plot options'), parent=dlg)
		}
		plotType <- tclvalue(twodPlotType)
		if (plotType == 'persp')
			per()
		else{
			closeGui('per')
			setGraphics(usrFiles, type=plotType, refresh.graphics=TRUE)	
			tkfocus(dlg)
			tkwm.deiconify(dlg)
			bringFocus()
		}
	}
	topFrame <- ttkframe(twodTypeFrame)
	rbAuto <- ttkradiobutton(topFrame, variable=twodPlotType, value='auto',	
			text='auto', command=twodType)
	rbCon <- ttkradiobutton(topFrame, variable=twodPlotType, value='contour',	
			text='contour', command=twodType)
	rbImage <- ttkradiobutton(topFrame, variable=twodPlotType, value='image',	
			text='image', command=twodType)
	bottomFrame <- ttkframe(twodTypeFrame)
	rbFilled <- ttkradiobutton(bottomFrame, variable=twodPlotType, 
			value='filled', text='filled contour', command=twodType)
	rbPer <- ttkradiobutton(bottomFrame, variable=twodPlotType, value='persp',	
			text='perspective', command=twodType)
	
	##create contour display radio buttons
	dispFrame <- ttklabelframe(twodOptionFrame, text='Contour display', 
			padding=3)
	if (all(fileFolder[[current]]$graphics.par$conDisp)){
		whichCon <- tclVar('both')
	}else if (fileFolder[[current]]$graphics.par$conDisp[1]){
		whichCon <- tclVar('positive')
	}else{
		whichCon <- tclVar('negative')
	} 
	onDisp <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		if (length(usrSel))
			usrFiles <- twodFileNames[usrSel]
		else{
			if (currentSpectrum %in% twodFileNames)
				usrFiles <- currentSpectrum
			else
				err(paste('You must select a spectrum from the list before changing',
								'plot options'), parent=dlg)
		}
		con <- tclvalue(whichCon)
		con <- switch(con, 'both'=c(TRUE, TRUE), 'positive'=c(TRUE, FALSE), 
				'negative'=c(FALSE, TRUE))
		setGraphics(usrFiles, conDisp=con, refresh.graphics=TRUE)	
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	rbPos <- ttkradiobutton(dispFrame, variable=whichCon, value='positive',	
			text='positive', command=onDisp)
	rbNeg <- ttkradiobutton(dispFrame, variable=whichCon, value='negative',	
			text='negative', command=onDisp)
	rbBoth <- ttkradiobutton(dispFrame, variable=whichCon, value='both', 
			text='both', command=onDisp)
	
	##create minimum threshold slider
	threshFrame <- ttklabelframe(twodOptionFrame, text='Contour threshold')
	clevel <- fileFolder[[current]]$graphics.par$clevel 
	threshVal <- tclVar(clevel)
	if (clevel <= 25){
		threshMax <- 25
		threshRes <- .1
	}else if (is.integer(log10(clevel))){
		threshMax <- clevel
		threshRes <- threshMax/100
	}else{
		digits <- nchar(as.character(clevel))
		threshMax <- 10^digits
		threshRes <- threshMax/100
	}
	threshSlider <- tkscale(threshFrame, from=0, to=threshMax, variable=threshVal, 
			orient='horizontal', showvalue=T, tickinterval=threshMax, width=11, 
			length=120, resolution=threshRes, 
			bg=as.character(tkcget(dlg, '-background')))
	onThreshSlider <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		if (length(usrSel))
			usrFiles <- twodFileNames[usrSel]
		else{
			if (currentSpectrum %in% twodFileNames)
				usrFiles <- currentSpectrum
			else
				err(paste('You must select a spectrum from the list before changing',
								'plot options'), parent=dlg)
		}
		tkconfigure(threshSlider, fg='black')
		setGraphics(usrFiles, clevel=as.numeric(tclObj(threshVal)), 
				refresh.graphics=TRUE)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	tkbind(threshSlider, '<ButtonRelease>', onThreshSlider)	
	
	##create slider limit decrease button
	onMaxDec <- function(slider){
		if (slider == 'thresh'){
			curMax <- as.numeric(tclvalue(tkcget(threshSlider, '-to')))
			if (curMax == 25){
				newMax <- curMax
				newRes <- .1
			}else if (curMax == 100){
				newMax <- 25
				newRes <- .1
			}else{
				newMax <- curMax / 10
				newRes <- newMax / 100
			}
			curVal <- as.numeric(tclvalue(tkget(threshSlider)))
			if (curVal > newMax){
				tkset(threshSlider, newMax)
				onThreshSlider()
			}
			tkconfigure(threshSlider, from=0, to=newMax, tickinterval=newMax,	
					resolution=newRes)
		}else{
			newMax <- 100
			curVal <- as.numeric(tclvalue(tkget(levelSlider)))
			if (curVal > newMax){
				tkset(levelSlider, newMax)
				onThreshSlider()
			}
			tkconfigure(levelSlider, from=1, to=100, tickinterval=99, 
					resolution=1)
		}
		twodConfigGui()
	}
	threshDecButton <- ttkbutton(threshFrame, text='<', width=2, 
			command=function(...) onMaxDec('thresh'))
	
	##create slider limit increase button
	onMaxInc <- function(slider){
		if (slider == 'thresh'){
			curMax <- as.numeric(tclvalue(tkcget(threshSlider, '-to')))
			curVal <- as.numeric(tclvalue(tkget(threshSlider)))
			if (curMax == 25)
				newMax <- 100
			else
				newMax <- curMax * 10
			newRes <- newMax / 100
			tkconfigure(threshSlider, from=0, to=newMax, tickinterval=newMax, 
					resolution=newRes)
			tclObj(threshVal) <- ceiling(curVal / newRes) * newRes
			onThreshSlider()
		}else{
			tkconfigure(levelSlider, from=10, to=1000, tickinterval=990, 
					resolution=10)
			onLevelSlider()
		}
	}
	threshIncButton <- ttkbutton(threshFrame, text='>', width=2, 
			command=function(...) onMaxInc('thresh'))
	
	##create contour slider
	levelFrame <- ttklabelframe(twodOptionFrame, text='Number of contours')
	nlevels <- fileFolder[[current]]$graphics.par$nlevels
	levelVal <- tclVar(nlevels)
	if (nlevels <= 100)
		levelMax <- 100
	else
		levelMax <- 1000
	levelSlider <- tkscale(levelFrame, from=levelMax / 100, to=levelMax, 
			variable=levelVal, orient='horizontal', showvalue=T,	
			tickinterval=levelMax - levelMax / 100, width=11, length=120, 
			resolution=levelMax / 100, bg=as.character(tkcget(dlg, '-background')))
	onLevelSlider <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		if (length(usrSel))
			usrFiles <- twodFileNames[usrSel]
		else{
			if (currentSpectrum %in% twodFileNames)
				usrFiles <- currentSpectrum
			else
				err(paste('You must select a spectrum from the list before changing',
								'plot options'), parent=dlg)
		}
		tkconfigure(levelSlider, fg='black')
		setGraphics(usrFiles, nlevels=as.numeric(tclObj(levelVal)), 
				refresh.graphics=TRUE)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	tkbind(levelSlider, '<ButtonRelease>', onLevelSlider)	
	
	##create slider limit decrease and increase buttons
	levelDecButton <- ttkbutton(levelFrame, text='<', width=2, 
			command=function(...) onMaxDec('level'))
	levelIncButton <- ttkbutton(levelFrame, text='>', width=2, 
			command=function(...) onMaxInc('level'))
	
	##create default button
	twodDefault <- function(){
		
		##check user selection
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		if (length(usrSel))
			usrFiles <- twodFileNames[usrSel]
		else{
			if (currentSpectrum %in% twodFileNames)
				usrFiles <- currentSpectrum
			else
				err(paste('You must select a spectrum from the list before changing',
								'plot options'), parent=dlg)
		}
		
		##display default plot type
		if (defaultSettings$type %in% c('auto', 'image', 'contour', 'filled', 
				'persp'))
			plotType <- defaultSettings$type
		else
			plotType <- 'auto'
		tclObj(twodPlotType) <- plotType
		
		##display default contour display
		if (all(defaultSettings$conDisp))
			conDisp <- 'both'
		else if (defaultSettings$conDisp[1])
			conDisp <- 'positive'
		else
			conDisp <- 'negative'
		tclObj(whichCon) <- conDisp
		
		##display default contour threshold
		clevel <- defaultSettings$clevel
		if (clevel <= 25){
			threshMax <- 25
			threshRes <- .1
		}else if (is.integer(log10(clevel))){
			threshMax <- clevel
			threshRes <- threshMax/100
		}else{
			digits <- nchar(as.character(clevel))
			threshMax <- 10^digits
			threshRes <- threshMax/100
		}
		tkconfigure(threshSlider, from=0, to=threshMax, tickinterval=threshMax, 
				resolution=threshRes)
		tclObj(threshVal) <- clevel
		
		##display default number of contour levels
		nlevels <- defaultSettings$nlevels
		if (nlevels <= 100)
			levelMax <- 100
		else
			levelMax <- 1000
		tkconfigure(levelSlider, from=levelMax / 100, to=levelMax, 
				tickinterval=levelMax - levelMax / 100, resolution=levelMax / 100)
		tclObj(levelVal) <- nlevels
		
		##apply default graphics settings
		if (length(usrFiles) != 0)
			setGraphics(usrFiles, clevel=defaultSettings$clevel, 
					nlevels=defaultSettings$nlevels, type=plotType, 
					conDisp=defaultSettings$conDisp, pos.color=defaultSettings$pos.color, 
					neg.color=defaultSettings$neg.color, refresh.graphics=TRUE)
	}
	defaultButton <- ttkbutton(twodOptionFrame, text='Restore Defaults', 
			command=function(...) twodDefault())
	
	##add widgets to fileFrame
	tkgrid(twodFileFrame, column=1, row=1, sticky='nswe', pady=c(6, 0),	padx=8)
	tkgrid(twodFileBox, column=1, row=1, sticky='nswe')
	tkgrid(twodYscr, column=2, row=1, sticky='ns')
	tkgrid(twodXscr, column=1, row=2, sticky='we')
	
	##make fileFrame stretch when window is resized
	tkgrid.columnconfigure(twodFrame, 1, weight=1)
	tkgrid.rowconfigure(twodFrame, 1, weight=10)
	tkgrid.columnconfigure(twodFileFrame, 1, weight=1)
	tkgrid.rowconfigure(twodFileFrame, 1, weight=1)
	
	##add widgets to optionFrame
	tkgrid(twodOptionFrame, column=2, row=1, pady=c(12, 0), sticky='ns')
	tkgrid(twodTypeFrame, row=2, sticky='we', pady=2)
	tkgrid(topFrame, row=1, sticky='we')
	tkgrid(rbAuto, column=1, row=1, sticky='w')
	tkgrid(rbCon, column=2, row=1, sticky='w', padx=3)
	tkgrid(rbImage, column=3, row=1, sticky='w')
	tkgrid(bottomFrame, row=2, sticky='we')
	tkgrid(rbFilled, column=1, row=1, sticky='w')
	tkgrid(rbPer, column=2, row=1, sticky='w', padx=1)
	
	tkgrid(dispFrame, row=3, sticky='we', pady=2)
	tkgrid(rbPos, column=1, row=1)
	tkgrid(rbNeg, column=2, row=1)
	tkgrid(rbBoth, column=3, row=1)
	
	tkgrid(threshFrame, row=4, sticky='we', pady=2)
	tkgrid(threshSlider, column=1, row=1, padx=c(0, 3))
	tkgrid(threshDecButton, column=2, row=1)
	tkgrid(threshIncButton, column=3, row=1, padx=c(0, 3))
	
	tkgrid(levelFrame, row=5, sticky='we', pady=2)
	tkgrid(levelSlider, column=1, row=1, padx=c(0, 3))
	tkgrid(levelDecButton, column=2, row=1)
	tkgrid(levelIncButton, column=3, row=1, padx=c(0, 3))
	
	tkgrid(defaultButton, row=6, padx=25, pady=c(6, 0), sticky='we')
	
	##make optionFrame stretch when window is resized
	tkgrid.rowconfigure(twodOptionFrame, 0, weight=1)
	tkgrid.rowconfigure(twodOptionFrame, 7, weight=1)
	
	##reconfigures widgets in GUI according to which spectra are open
	twodConfigGui <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		if (length(usrSel))
			usrFile <- twodFileNames[usrSel]
		else{
			if (length(names(fileFolder)) && currentSpectrum %in% twodFileNames)
				usrFile <- currentSpectrum
			else
				return(invisible())
		}
		if (length(usrFile) == 1){
			equalType <- equalDisp <- equalThresh <- equalLevel <- TRUE
		}else{
			
			##determine which plot settings for the selected files are the same
			equalType <- TRUE
			for (i in 2:length(usrFile)){
				if (fileFolder[[usrFile[i]]]$graphics.par$type != 
						fileFolder[[usrFile[i - 1]]]$graphics.par$type){
					equalType <- FALSE
					break
				}
			}
			equalDisp <- TRUE
			for (i in 2:length(usrFile)){
				if (fileFolder[[usrFile[i]]]$graphics.par$conDisp[1] != 
						fileFolder[[usrFile[i - 1]]]$graphics.par$conDisp[1] ||
						fileFolder[[usrFile[i]]]$graphics.par$conDisp[2] != 
						fileFolder[[usrFile[i - 1]]]$graphics.par$conDisp[2]){
					equalDisp <- FALSE
					break
				}
			}
			equalThresh <- TRUE
			for (i in 2:length(usrFile)){
				if (fileFolder[[usrFile[i]]]$graphics.par$clevel != 
						fileFolder[[usrFile[i - 1]]]$graphics.par$clevel){
					equalThresh <- FALSE
					break
				}
			}
			equalLevel <- TRUE
			for (i in 2:length(usrFile)){
				if (fileFolder[[usrFile[i]]]$graphics.par$nlevels != 
						fileFolder[[usrFile[i - 1]]]$graphics.par$nlevels){
					equalLevel <- FALSE
					break
				}
			}
		}
		
		##resets radiobutton values
		if (equalType){
			pType <- fileFolder[[usrFile[1]]]$graphics.par$type
			if (is.null(pType))
				pType <- 'auto'
			tclObj(twodPlotType) <- pType
		}else
			tclObj(twodPlotType) <- ''	
		if (equalDisp){
			if (all(fileFolder[[usrFile[1]]]$graphics.par$conDisp)){
				tclObj(whichCon) <- 'both'
			}else{
				if (fileFolder[[usrFile[1]]]$graphics.par$conDisp[1]){
					tclObj(whichCon) <- 'positive'
				}else{
					tclObj(whichCon) <- 'negative'
				}
			}
		}else
			tclObj(whichCon) <- ''
		
		##resets contour threshold slider
		if (equalThresh){
			clevel <- fileFolder[[usrFile[1]]]$graphics.par$clevel
			if (clevel > 25){
				if (!log10(clevel) %% 1)
					threshMax <- clevel
				else{
					digits <- nchar(as.character(clevel))
					threshMax <- 10^digits
				}
				threshRes <- threshMax / 100
			}else{
				threshMax <- 25
				threshRes <- .1
			}
			tkconfigure(threshSlider, fg='black', from=0, to=threshMax, 
					tickinterval=threshMax, resolution=threshRes)
			tclObj(threshVal) <- clevel
		}else
			tkconfigure(threshSlider, fg='grey')
		
		##resets contour level slider
		if (equalLevel){
			nlevels <- fileFolder[[usrFile[1]]]$graphics.par$nlevels
			if (nlevels <= 100)
				levelMax <- 100
			else
				levelMax <- 1000
			tkconfigure(levelSlider, fg='black', from=levelMax / 100, to=levelMax, 
					tickinterval=levelMax - levelMax / 100, resolution=levelMax/100)
			tclObj(levelVal) <- nlevels
		}else
			tkconfigure(levelSlider, fg='grey')
	}
	twodConfigGui()
	
	##resets file list and options whenever the mouse enters the GUI
	twodMouse <- function(){
		reset(twodFileList, twodFileBox, twodFileNames, dims='2D')
		twodFileNames <<- names(fileFolder)[which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) > 1)]
		twodConfigGui()
	}
	tkbind(twodFrame, '<Enter>', twodMouse)
	tkbind(twodFrame, '<FocusIn>', twodMouse)
	
	##Allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (length(grep('.1.1.1.1$', focus)))
			coDouble()
		else if (length(grep('.1.2.1.1$', focus)))
			onedDouble()
		else if (length(grep('.1.3.1.1$', focus)))
			twodDouble()
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter) 
	
	##enable\disable panes depending on which files are open
	onMouse <- function(){
		if (any(which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) == 1)))
			tcl(plotBook, 'tab', 1, state='normal')
		else
			tcl(plotBook, 'tab', 1, state='disabled')
		if (any(which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) > 1)))
			tcl(plotBook, 'tab', 2, state='normal')
		else
			tcl(plotBook, 'tab', 2, state='disabled')
	}
	tkbind(dlg, '<Enter>', onMouse)
	tkbind(dlg, '<FocusIn>', onMouse)
	
	invisible()
}

## Wrapper function, displays the plot colors pane in ps()
co <- function(){
	ps('co')
}

## Wrapper function, displays the plot settings panes in ps()
ct <- function(){
	current <- wc()
	if (fileFolder[[current]]$file.par$number_dimensions == 1)
		ps('ct1D')
	else
		ps('ct2D')
}

## Interactive GUI for manipulating overlays and shift referencing
os <- function(dispPane='ol'){
	
	##create main window
	current <- wc()
	tclCheck()
	dlg <- myToplevel('os')
	if (is.null(dlg)){
		if (dispPane == 'ol'){
			tkwm.title('.os', 'Overlays')
			tkselect('.os.1', 0)
		}else{
			tkwm.title('.os', 'Shift Referencing')
			if (dispPane == 'sr1D')
				tkselect('.os.1', 1)
			else
				tkselect('.os.1', 2)
		}
		return(invisible())
	}
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	if (dispPane == 'ol')
		tkwm.title(dlg, 'Overlays')
	else
		tkwm.title(dlg, 'Shift Referencing')
	
	##create paned notebook
	osBook <- ttknotebook(dlg, padding=3)
	
	##create overlay and referencing panes
	olFrame <- ttkframe(osBook, padding=c(0, 0, 2, 12)) 
	onedFrame <- ttkframe(osBook, padding=c(0, 0, 12, 12))
	twodFrame <- ttkframe(osBook, padding=c(0, 0, 12, 12))
	tkadd(osBook, olFrame, text='   Overlays   ')
	tkadd(osBook, onedFrame, text='1D Referencing')
	tkadd(osBook, twodFrame, text='2D Referencing')
	
	##add widgets to toplevel
	tkgrid(osBook, column=1, row=1, sticky='nsew', padx=c(6, 0), pady=c(6, 0))
	tkgrid(ttksizegrip(dlg), column=2, row=2, sticky='se')
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=1)
	
	##switch to the appropriate notebook pane
	if (dispPane == 'ol')
		tkselect(osBook, 0)
	else if (dispPane == 'sr1D')
		tkselect(osBook, 1)
	else
		tkselect(osBook, 2)
	
	####create widgets for olFrame
	##create file list box
	olFileFrame <- ttklabelframe(olFrame, text='Files')
	olFileList <- tclVar()
	olFileNames <- names(fileFolder)
	overlayMatches <- match(overlayList, olFileNames)
	if (length(overlayMatches))
		olFileNames <- olFileNames[-overlayMatches]
	tclObj(olFileList) <- getTitles(olFileNames)
	olFileBox <- tklistbox(olFileFrame, height=13, width=25, 
			listvariable=olFileList, selectmode='extended', active='dotbox', 
			exportselection=FALSE, bg='white', 
			xscrollcommand=function(...) tkset(olXscr, ...), 
			yscrollcommand=function(...) tkset(olYscr, ...))
	olXscr <- ttkscrollbar(olFileFrame, orient='horizontal',
			command=function(...) tkxview(olFileBox, ...))
	olYscr <- ttkscrollbar(olFileFrame, orient='vertical', 
			command=function(...) tkyview(olFileBox, ...))
	if (length(olFileNames) > 2){
		for (i in seq(0, length(olFileNames) - 1, 2))
			tkitemconfigure(olFileBox, i, background='#ececff')
	}
	currMatch <- match(currentSpectrum, olFileNames)
	if (!is.na(currMatch)){
		tkselection.set(olFileBox, currMatch - 1)
		tcl(olFileBox, 'see', currMatch - 1)
	}
	
	##export fileBox selections to other tabs
	olSelect <- function(){
		usrSel <- 1 + as.integer(tkcurselection(olFileBox))
		onedFiles <- names(fileFolder)[which(sapply(fileFolder, function(x)
								{x$file.par$number_dimensions}) == 1)]
		twodFiles <- names(fileFolder)[which(sapply(fileFolder, function(x)
								{x$file.par$number_dimensions}) > 1)]
		if (!is.null(usrSel)){
			onedIndices <- na.omit(match(olFileNames[usrSel], onedFiles))
			if (length(onedIndices)){
				tkselection.clear(onedFileBox, 0, 'end')
				for (i in onedIndices)
					tkselection.set(onedFileBox, i - 1)
			}
			twodIndices <- na.omit(match(olFileNames[usrSel], twodFiles))
			if (length(twodIndices)){
				tkselection.clear(twodFileBox, 0, 'end')
				for (i in twodIndices)
					tkselection.set(twodFileBox, i - 1)
			}
		}
		olConfigGui()
	}
	tkbind(olFileBox, '<<ListboxSelect>>', olSelect)
	
	##create add button
	middleFrame <- ttkframe(olFrame)
	buttonFrame <- ttkframe(middleFrame)
	onAdd <- function(){
		
		##get selection
		usrSel <- 1 + as.integer(tkcurselection(olFileBox))
		if (!length(usrSel))
			err('You must select a file from the files list to overlay')
		
		##update global object overlayList
		overlayList <- c(overlayList, olFileNames[usrSel])
		myAssign('overlayList', overlayList)
		refresh(sub.plot=FALSE, multi.plot=FALSE)
		
		##update contents of overlayBox
		if (is.null(overlayList))
			overlayNames <<- character(0)
		else
			overlayNames <<- overlayList
		tclObj(overlaysList) <- getTitles(overlayNames)
		for (i in seq_along(usrSel))
			tkselection.set(overlayBox, length(overlayNames) - i)
		tcl(overlayBox, 'see', length(overlayNames) - 1)
		
		##update contents of olFileBox
		olFileNames <<- names(fileFolder)
		overlayMatches <- match(overlayNames, olFileNames)
		if (length(overlayMatches))
			olFileNames <<- olFileNames[-overlayMatches]
		tclObj(olFileList) <- getTitles(olFileNames)
		tkselection.clear(olFileBox, 0, 'end')
		
		##reconfigure GUI
		if (length(overlayNames) > 2){
			for (i in seq(0, length(overlayNames) - 1, 2))
				tkitemconfigure(overlayBox, i, background='#ececff')
		}
		olConfigGui()
		tkfocus(olFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	addButton <- ttkbutton(buttonFrame, text='Add -->', width=11, command=onAdd)
	
	##create remove button
	onRemove <- function(){
		
		##get selection
		usrSel <- 1 +	as.integer(tkcurselection(overlayBox))
		if (!length(usrSel))
			err('You must select a file from the overlays list to remove')
		selNames <- overlayNames[usrSel]
		
		##update global object overlayList
		overlayList <- overlayList[-usrSel]
		if (!length(overlayList))
			overlayList=NULL
		myAssign('overlayList', overlayList)
		refresh(sub.plot=FALSE, multi.plot=FALSE)
		
		##update contents overlayBox
		if (is.null(overlayList))
			overlayNames <<- character(0)
		else
			overlayNames <<- overlayList
		if (length(overlayNames))
			tclObj(overlaysList) <- getTitles(overlayNames)
		else
			tclObj(overlaysList) <- overlayNames
		tkselection.clear(overlayBox, 0, 'end')
		
		##update contents of olFileBox
		olFileNames <<- names(fileFolder)
		overlayMatches <- match(overlayNames, olFileNames)
		if (length(overlayMatches))
			olFileNames <<- olFileNames[-overlayMatches]
		tclObj(olFileList) <- getTitles(olFileNames)
		tkselection.clear(olFileBox, 0, 'end')
		for (i in selNames)
			tkselection.set(olFileBox, match(i, olFileNames) - 1)
		tcl(olFileBox, 'see', match(i, olFileNames) - 1)
		
		##reconfigure GUI
		if (length(overlayNames) > 2){
			for (i in seq(0, length(overlayNames) - 1, 2))
				tkitemconfigure(overlayBox, i, background='#ececff')
		}
		olConfigGui()
		tkfocus(olFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	removeButton <- ttkbutton(buttonFrame, text='Remove', width=11, 
			state='disabled', command=onRemove)
	
	##create offset label
	offsetFrame <- ttklabelframe(middleFrame, text='1D Offset')
	offsetVal <- tclVar(globalSettings$offset)
	offsetLab <- ttklabel(offsetFrame, text='Offset:')
	valLab <-	ttklabel(offsetFrame, textvariable=offsetVal, width=4)
	
	##creates offset slider
	offsetSlider <- tkscale(offsetFrame, from=100, to=-100,	variable=offsetVal,
			orient='vertical', showvalue=F,	tickinterval=100, 
			bg=as.character(tkcget(dlg, '-background')))
	onOffset <- function(){
		setGraphics(offset=as.integer(tclvalue(offsetVal)), refresh.graphics=TRUE)
		tkfocus(olFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	tkbind(offsetSlider, '<ButtonRelease>', onOffset)	
	
	##create overlays list box
	overlayFrame <- ttklabelframe(olFrame, text='Overlays')
	if (is.null(overlayList)){
		overlayNames <- character(0)
	}else{
		overlayNames <- overlayList
	}
	overlaysList <- tclVar()
	if (!is.null(overlayList))
		tclObj(overlaysList) <- getTitles(overlayNames)
	else
		tclObj(overlaysList) <- character(0)
	overlayBox <- tklistbox(overlayFrame,	height=7, width=25, 
			exportselection=FALSE, listvariable=overlaysList, selectmode='extended', 
			active='dotbox', bg='white', 
			xscrollcommand=function(...) tkset(overlayXscr, ...), 
			yscrollcommand=function(...) tkset(overlayYscr, ...))
	overlayXscr <- ttkscrollbar(overlayFrame, orient='horizontal', 
			command=function(...) tkxview(overlayBox, ...))
	overlayYscr <- ttkscrollbar(overlayFrame, orient='vertical',
			command=function(...) tkyview(overlayBox, ...))
	if (length(overlayNames) > 2){
		for (i in seq(0, length(overlayNames) - 1, 2))
			tkitemconfigure(overlayBox, i, background='#ececff')
	}
	currMatch <- match(currentSpectrum, overlayNames)
	if (!is.na(currMatch)){
		tkselection.set(overlayBox, currMatch - 1)
		tcl(overlayBox, 'see', currMatch - 1)
	}
	
	##switches spectra on left-mouse double-click
	olDouble <- function(box){
		usrSel <- 1 + as.integer(tkcurselection(box))
		if (length(usrSel)){
			if (box$ID == '.os.1.1.1.1')
				usrFile <- olFileNames[usrSel]
			else
				usrFile <- overlayList[usrSel]
		}else
			usrFile <- NULL
		if (!is.null(usrFile) && currentSpectrum != usrFile){
			myAssign('currentSpectrum', usrFile)
			refresh(multi.plot = FALSE)
			olConfigGui()
			tkwm.deiconify(dlg)
			tkfocus(box)
		}
	}
	tkbind(olFileBox, '<Double-Button-1>', function(...) olDouble(olFileBox))
	tkbind(overlayBox, '<Double-Button-1>', function(...) olDouble(overlayBox))
	
	##create set positive contour color button
	colFrame <- ttklabelframe(olFrame, text='Overlay colors')
	onPos <- function(){
		usrSel <- 1 +	as.integer(tkcurselection(overlayBox))
		usrFiles <- overlayList[usrSel]
		if (!length(usrFiles))
			err(paste('You must select a spectrum from the Overlays list before',
							'changing the positive contour color'))
		changeColor(dlg, 'pos', usrFiles)
	}
	posColButton <- ttkbutton(colFrame, text='+  Contour', width=13, command=onPos)
	
	##create set negative contour color button
	onNeg <- function(){
		usrSel <- 1 +	as.integer(tkcurselection(overlayBox))
		usrFiles <- overlayList[usrSel]
		if (!length(usrFiles))
			err(paste('You must select a spectrum from the Overlays list before',
							'changing the negative contour color'))
		changeColor(dlg, 'neg', usrFiles)
	}
	negColButton <- ttkbutton(colFrame, text='-  Contour', width=13, 
			command=onNeg)
	
	##create set 1D color button
	onProj <- function(){
		usrSel <- 1 +	as.integer(tkcurselection(overlayBox))
		usrFiles <- overlayList[usrSel]
		if (!length(usrFiles))
			err(paste('You must select a spectrum from the Overlays list before',
							'changing the 1D color'))
		changeColor(dlg, '1D', usrFiles)
	}
	projColButton <- ttkbutton(colFrame, text='1D', width=13, command=onProj)
	
	##create overlay text checkbutton
	textFrame <- ttkframe(olFrame)
	textVal <- tclVar(ifelse(globalSettings$overlay.text, 1, 0))
	onText <- function(){
		if (as.logical(as.integer(tclvalue(textVal)))){
			setGraphics(overlay.text=TRUE, save.backup=TRUE)
			refresh(sub.plot=FALSE, multi.plot=FALSE)
		}else{
			setGraphics(overlay.text=FALSE, save.backup=TRUE)
			refresh(sub.plot=FALSE, multi.plot=FALSE)
		}
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	textButton <- ttkcheckbutton(textFrame, variable=textVal, command=onText, 
			text='Display names of overlaid spectrum on plot')
	
	##add widgets to fileFrame
	tkgrid(olFileFrame, column=1, row=1, rowspan=3, sticky='nswe', pady=c(5, 8), 
			padx=6)
	tkgrid(olFileBox, column=1, row=1, sticky='nswe')
	tkgrid(olYscr, column=2, row=1, sticky='ns')
	tkgrid(olXscr, column=1, row=2, sticky='we')
	
	##make fileFrame stretch when window is resized
	tkgrid.columnconfigure(olFrame, 1, weight=1)
	tkgrid.rowconfigure(olFrame, 1, weight=1)
	tkgrid.columnconfigure(olFileFrame, 1, weight=1)
	tkgrid.rowconfigure(olFileFrame, 1, weight=1)
	
	##add widgets to middleFrame
	tkgrid(middleFrame, column=2, row=1, rowspan=2, sticky='nswe', pady=5, padx=2)
	tkgrid(buttonFrame, row=1, pady=c(28, 0))
	tkgrid(addButton, row=1)
	tkgrid(removeButton, row=2, pady=4)
	
	tkgrid(offsetFrame, row=2, pady=c(10, 0))
	tkgrid(offsetLab, column=1, row=1, sticky='e', padx=c(1, 0))
	tkgrid(valLab, column=2, row=1, sticky='w')
	tkgrid(offsetSlider, column=1, row=2, columnspan=2, padx=c(0, 5))
	tkgrid.rowconfigure(middleFrame, 2, weight=1)
	
	##add widgets to overlayFrame
	tkgrid(overlayFrame, column=3, row=1, sticky='nswe', pady=5, padx=6)
	tkgrid(overlayBox, column=1, row=1, sticky='nswe')
	tkgrid(overlayYscr, column=2, row=1, sticky='ns')
	tkgrid(overlayXscr, column=1, row=2, sticky='we')
	
	##make overlayFrame stretch when window is resized
	tkgrid.columnconfigure(olFrame, 3, weight=1)
	tkgrid.columnconfigure(overlayFrame, 1, weight=1)
	tkgrid.rowconfigure(overlayFrame, 1, weight=1)
	
	##add widgets to colFrame
	tkgrid(colFrame, column=3, row=2, sticky='we', padx=20)
	tkgrid(posColButton, column=2, row=1, pady=2)
	tkgrid(negColButton, column=2, row=2, pady=2)
	tkgrid(projColButton, column=2, row=3, pady=c(2, 4))
	tkgrid.columnconfigure(colFrame, 1, weight=1)
	tkgrid.columnconfigure(colFrame, 3, weight=1)
	
	##add widgets to textFrame
	tkgrid(textFrame, column=2, columnspan=2, row=3, sticky='we')
	tkgrid(textButton, sticky='w', padx=6, pady=6)
	
	##reconfigures widgets in GUI according to which spectra are open
	olConfigGui <- function(){
		if (length(as.integer(tkcurselection(olFileBox))))
			tkconfigure(addButton, state='normal')
		else
			tkconfigure(addButton, state='disabled')
		configList <- list(offsetSlider, offsetLab, valLab)
		dims <- sapply(fileFolder, function(x) x$file.par$number_dimensions)
		if (length(overlayList) && any(dims[match(overlayList, 
								names(fileFolder))] == 1)){
			for (i in configList)
				tkconfigure(i, state='normal')
			tkconfigure(offsetSlider, fg='black')
		}else{
			for (i in configList)
				tkconfigure(i, state='disabled')
			tkconfigure(offsetSlider, fg='grey')
		}
		usrSel <- 1 +	as.integer(tkcurselection(overlayBox))
		usrFiles <- overlayList[usrSel]
		configList <- list(posColButton, negColButton, projColButton, 
				removeButton)
		if (!length(usrSel)){
			for (i in configList)
				tkconfigure(i, state='disabled')
		}else{
			oneD <- FALSE
			for (i in usrFiles){
				if (fileFolder[[i]]$file.par$number_dimensions == 1){
					oneD <- TRUE
					break
				}
			}
			twoD <- FALSE
			for (i in usrFiles){
				if (fileFolder[[i]]$file.par$number_dimensions > 1){
					twoD <- TRUE
					break
				}
			}
			tkconfigure(removeButton, state='normal')
			if (oneD)
				tkconfigure(projColButton, state='normal')
			else
				tkconfigure(projColButton, state='disabled')
			if (twoD){
				tkconfigure(posColButton, state='normal')
				tkconfigure(negColButton, state='normal')
			}else{
				tkconfigure(posColButton, state='disabled')
				tkconfigure(negColButton, state='disabled')
			}
		}
		tclObj(offsetVal) <- globalSettings$offset
	}
	tkbind(overlayBox, '<<ListboxSelect>>', olConfigGui)
	olConfigGui()	
	
	##resets widgets whenever the mouse enters the GUI
	olMouse <- function(){
		reset(list(olFileList, overlaysList), list(olFileBox, overlayBox), 
				list(olFileNames, overlayNames), c('files', 'overlays'))
		olFileNames <<- names(fileFolder)
		overlayMatches <- match(overlayList, olFileNames)
		if (length(overlayMatches))
			olFileNames <<- olFileNames[-overlayMatches]
		if (is.null(overlayList))
			overlayNames <<- character(0)
		else
			overlayNames <<- overlayList
		olConfigGui()
	}
	tkbind(olFrame, '<Enter>', olMouse)
	tkbind(olFrame, '<FocusIn>', olMouse)
	
	####create widgets for onedFrame
	##create file list box
	onedFileFrame <- ttklabelframe(onedFrame, text='Files')
	onedFileList <- tclVar()
	onedFileNames <- names(fileFolder)[which(sapply(fileFolder, 
							function(x){x$file.par$number_dimensions}) == 1)]
	tclObj(onedFileList) <- getTitles(onedFileNames)
	onedFileBox <- tklistbox(onedFileFrame, height=11, width=30, bg='white', 
			listvariable=onedFileList, selectmode='extended', active='dotbox',
			exportselection=FALSE, xscrollcommand=function(...) tkset(onedXscr, ...), 
			yscrollcommand=function(...) tkset(onedYscr, ...))
	onedXscr <- ttkscrollbar(onedFileFrame, orient='horizontal',
			command=function(...) tkxview(onedFileBox, ...))
	onedYscr <- ttkscrollbar(onedFileFrame, orient='vertical', 
			command=function(...) tkyview(onedFileBox, ...))
	if (length(onedFileNames) > 2){
		for (i in seq(0, length(onedFileNames) - 1, 2))
			tkitemconfigure(onedFileBox, i, background='#ececff')
	}
	if (fileFolder[[current]]$file.par$number_dimensions == 1){
		tkselection.set(onedFileBox, match(currentSpectrum, onedFileNames) - 1)
		tcl(onedFileBox, 'see', match(currentSpectrum, onedFileNames) - 1)
	}
	
	##export fileBox selections to other tabs
	onedSelect <- function(){
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		usrFile <- onedFileNames[usrSel]
		selIndices <- match(onedFileNames[usrSel], names(fileFolder))
		tkselection.clear(olFileBox, 0, 'end')
		for (i in selIndices)
			tkselection.set(olFileBox, i - 1)
	}
	tkbind(onedFileBox, '<<ListboxSelect>>', onedSelect)
	
	##switches spectra on left-mouse double-click
	onedDouble <- function(){
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		if (length(usrSel))
			usrFile <- onedFileNames[usrSel]
		else
			usrFile <- NULL
		if (!is.null(usrFile) && currentSpectrum != usrFile){
			currentSpectrum <- usrFile
			myAssign('currentSpectrum', currentSpectrum)
			refresh(multi.plot = FALSE)
			tkwm.deiconify(dlg)
			tkfocus(onedFileBox)
		}
	}
	tkbind(onedFileBox, '<Double-Button-1>', onedDouble)
	
	##creates new shift textbox
	onedOptionFrame <- ttkframe(onedFrame)
	onedRefValFrame <- ttklabelframe(onedOptionFrame, 
			text='Reference value (ppm)', padding=3)
	onedRefVal <- tclVar(0)
	onedRefEntry <- ttkentry(onedRefValFrame, width=6, justify='center', 
			textvariable=onedRefVal)
	
	##creates get shift button
	onedLoc <- function(){
		
		##prompt user for type of shift selection
		usr <- mySelect(c('Designated point', 'Region maximum'), multiple=FALSE, 
				title='Get shifts at:',	preselect='Designated point', parent=dlg)
		if (length(usr) == 0 || !nzchar(usr))
			return(invisible())
		else if (usr == 'Region maximum'){
			tryCatch(shift <- regionMax(currentSpectrum)$w2, 
					error=function(er){
						showGui()
						refresh(multi.plot=FALSE, sub.plot=FALSE)
						stop('Shift not defined', call.=FALSE)})
			if (is.null(shift)){
				showGui()
				refresh(multi.plot=FALSE, sub.plot=FALSE)
				stop('Shift not defined', call.=FALSE)
			}
		}else{
			
			## Opens the main plot window if not currently opened
			if (is.na(match(2, dev.list())))
				refresh(multi.plot=FALSE, sub.plot=FALSE)
			cw(dev=2)
			
			##gives the user instructions
			hideGui()
			cat(paste('In the main plot window:\n',  
							' Left-click a point inside the plot to designate position\n'))
			flush.console()
			op <- par('font')
			par( font = 2 )
			legend("topleft", c('LEFT CLICK TO DESIGNATE POSITION', 
							'RIGHT CLICK TO EXIT'),	pch=NULL, bty='n', 
					text.col=fileFolder[[wc()]]$graphics.par$fg)
			par(font = op)
			
			##get the chemical shift at designated postion
			tryCatch(shift <- locator(1), error=function(er){
						showGui()
						refresh(multi.plot=FALSE, sub.plot=FALSE)
						stop('Shift not defined', call.=FALSE)})
			if (is.null(shift)){
				showGui()
				refresh(multi.plot=FALSE, sub.plot=FALSE)
				stop('Shift not defined', call.=FALSE)
			}
			refresh(multi.plot=FALSE, sub.plot=FALSE)
			abline(v=shift$x, lty=2, col=fileFolder[[wc()]]$graphics.par$fg)
			shift <- shift$x
		}
		if (is.na(shift[1])){
			showGui()
			err('Specified region does not contain peaks above the noise level')
		}
		tclObj(onedRefVal) <<- round(unlist(shift), 4)
		showGui()
		tkfocus(onedFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onedLocButton <- ttkbutton(onedRefValFrame, text='Get Shift', command=onedLoc)
	
	##creates point reference button
	onedDefRefFrame <- ttklabelframe(onedOptionFrame, text='Define reference', 
			padding=3)
	onedPoint <- function(){
		
		##checks for correct input
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		usrFiles <- onedFileNames[usrSel]
		if (length(usrSel) == 0)
			err(paste('You must select a spectrum from the list before designating',
							' a position'), parent=dlg)
		newShift <- suppressWarnings(as.numeric(tclvalue(onedRefVal)))
		if (is.na(newShift))
			err('You must provide a numeric value for the chemical shift reference', 
					parent=dlg)
		
		##make sure input files are similar to each other and the current spectrum
		lineCol <- fileFolder[[wc()]]$graphics.par$fg
		for (i in usrFiles){
			if (!identical(fileFolder[[wc()]]$file.par$number_dimensions, 
					fileFolder[[i]]$file.par$number_dimensions))
				err(paste('All files must have the same number of dimensions as the', 
								'current spectrum'), parent=dlg)
			if (!identical(fileFolder[[wc()]]$file.par$nucleus, 
					fileFolder[[i]]$file.par$nucleus))
				err('All files must have the same nuclei as the current spectrum', 
						parent=dlg)
			if (!identical(fileFolder[[wc()]]$file.par$matrix_size, 
					fileFolder[[i]]$file.par$matrix_size))
				err(paste('All files must have the same number of points in all', 
								'dimensions as the current spectrum'), parent=dlg)
		}
		
		##makes sure the current spectrum is included in the user's selection
		if (!currentSpectrum %in% usrFiles){
			usrSel <- myMsg(paste('The current spectrum was not included in your', 
							' selection and will be added automatically.\nDo you wish to', 
							' proceed?', sep=''), 'yesno', parent=dlg)
			if (usrSel == 'no'){
				return(invisible())
			}else{
				usrFiles <- c(currentSpectrum, usrFiles)
				tkselection.set(onedFileBox, match(currentSpectrum, 
								onedFileNames) - 1)
			}
		}
		
		## Opens the main plot window if not currently opened
		if (is.na(match(2, dev.list())))
			refresh(multi.plot=FALSE, sub.plot=FALSE)
		cw(dev=2)
		
		##gives the user instructions
		hideGui()
		cat(paste('In the main plot window:\n',  
						' Left-click a point inside the plot to define the reference\n'))
		flush.console()
		op <- par('font')
		par( font = 2 )
		legend("topleft", c('LEFT CLICK TO DEFINE REFERENCE', 
						'RIGHT CLICK TO EXIT'),	pch=NULL, bty='n', text.col=lineCol)
		par(font = op)
		tryCatch(pointVal <- locator(1)[[1]], error=function(er){
					showGui()
					stop('Point not defined', call.=FALSE)})
		if (length(pointVal) == 0 || is.null(pointVal)){
			showGui()
			refresh(multi.plot=FALSE, sub.plot=FALSE)
			stop('Point not defined', call.=FALSE)
		}
		showGui()
		pointVal <- pointVal - newShift
		
		##sets up and downfield shifts to the current spectrum's
		currUp <- fileFolder[[wc()]]$file.par$upfield_ppm
		currDown <- fileFolder[[wc()]]$file.par$downfield_ppm
		keepFolder <- fileFolder
		for (i in usrFiles){
			fileFolder[[i]]$file.par$upfield_ppm <- currUp
			fileFolder[[i]]$file.par$downfield_ppm <- currDown
		}
		myAssign('fileFolder', fileFolder, save.backup=FALSE)
		
		##references selected spectra
		for (i in usrFiles){
			fileFolder[[i]]$file.par$upfield_ppm <- currUp - pointVal
			fileFolder[[i]]$file.par$downfield_ppm <- currDown - pointVal
			totShiftChange <- keepFolder[[i]]$file.par$upfield_ppm - 
					fileFolder[[i]]$file.par$upfield_ppm
			newUsr <- c(fileFolder[[i]]$graphics.par$usr[1:2] - totShiftChange, 
					fileFolder[[i]]$graphics.par$usr[3:4])
			fileFolder[[i]]$graphics.par$usr <- newUsr
			if (!is.null(fileFolder[[i]]$peak.list)){
				fileFolder[[i]]$peak.list$w2 <- fileFolder[[i]]$peak.list$w2 - 
						totShiftChange
			}
		}
		myAssign('fileFolder', fileFolder)
		refresh()
		abline(v=newShift, lty=2, col=lineCol)
		tkfocus(onedFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onedPointButton <- ttkbutton(onedDefRefFrame, text='Point', width=8, 
			command=onedPoint)
	
	##creates region reference button
	onedRegion <- function(){
		
		##checks for correct input
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		usrFiles <- onedFileNames[usrSel]
		if (length(usrSel) == 0)
			err('You must select a spectrum from the list before defining a region', 
					parent=dlg)
		newShift <- suppressWarnings(as.numeric(tclvalue(onedRefVal)))
		if (is.na(newShift))
			err('You must provide a numeric value for the chemical shift reference', 
					parent=dlg)
		
		##make sure input files are similar to each other and the current spectrum
		for (i in usrFiles){
			if (!identical(fileFolder[[wc()]]$file.par$number_dimensions, 
					fileFolder[[i]]$file.par$number_dimensions))
				err(paste('All files must have the same number of dimensions as the', 
								'current spectrum'), parent=dlg)
			if (!identical(fileFolder[[wc()]]$file.par$nucleus, 
					fileFolder[[i]]$file.par$nucleus))
				err('All files must have the same nuclei as the current spectrum', 
						parent=dlg)
			if (!identical(fileFolder[[wc()]]$file.par$matrix_size, 
					fileFolder[[i]]$file.par$matrix_size))
				err(paste('All files must have the same number of points in all', 
								'dimensions as the current spectrum'), parent=dlg)
		}
		
		##makes sure the current spectrum is included in the user's selection
		if (!currentSpectrum %in% usrFiles){
			usrSel <- myMsg(paste('The current spectrum was not included in your', 
							' selection and will be added automatically.\nDo you wish to', 
							' proceed?', sep=''), 'yesno', parent=dlg)
			if (usrSel == 'no'){
				return(invisible())
			}else{
				usrFiles <- c(currentSpectrum, usrFiles)
				tkselection.set(onedFileBox, match(currentSpectrum, onedFileNames) - 1)
			}
		}
		
		##sets up and downfield shifts to the current spectrum's
		currUp <- fileFolder[[wc()]]$file.par$upfield_ppm
		currDown <- fileFolder[[wc()]]$file.par$downfield_ppm
		keepFolder <- fileFolder
		for (i in usrFiles){
			fileFolder[[i]]$file.par$upfield_ppm <- currUp
			fileFolder[[i]]$file.par$downfield_ppm <- currDown
		}
		myAssign('fileFolder', fileFolder, save.backup=FALSE)
		
		##references selected spectra
		tryCatch(ms <- regionMax(usrFiles, redraw=FALSE), error=function(er){
					myAssign('fileFolder', keepFolder, save.backup=FALSE)
					showGui()
					stop('Region not defined', call.=FALSE)})
		if (is.null(ms)){
			myAssign('fileFolder', keepFolder, save.backup=FALSE)
			showGui()
			stop('Region not defined', call.=FALSE)
		}
		for (i in usrFiles){
			if (is.na(ms[i, 'w2']))
				next
			regionVal <- ms[i, 'w2'] - newShift
			fileFolder[[i]]$file.par$upfield_ppm <- currUp - regionVal
			fileFolder[[i]]$file.par$downfield_ppm <- currDown - regionVal
			totShiftChange <- keepFolder[[i]]$file.par$upfield_ppm - 
					fileFolder[[i]]$file.par$upfield_ppm
			newUsr <- c(fileFolder[[i]]$graphics.par$usr[1:2] - totShiftChange, 
					fileFolder[[i]]$graphics.par$usr[3:4])
			fileFolder[[i]]$graphics.par$usr <- newUsr
			if (!is.null(fileFolder[[i]]$peak.list)){
				fileFolder[[i]]$peak.list$w2 <-	fileFolder[[i]]$peak.list$w2 - 
						totShiftChange
			}
		}
		myAssign('fileFolder', fileFolder)
		refresh()
		
		##draw lines to indicate region maximum
		lineCol <- fileFolder[[wc()]]$graphics.par$fg
		abline(v=newShift, lty=2, col=lineCol)		
		tkfocus(onedFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onedRegionButton <- ttkbutton(onedDefRefFrame, text='Region', width=8, 
			command=onedRegion)
	
	##manual shift adjustment functions
	onedAdjFrame <- ttklabelframe(onedOptionFrame, text='Man. adjustment (ppm)', 
			padding=3)
	onedAmountVal <- tclVar(1)
	onedArrow <- function(direct, n){
		
		##checks for correct inputs
		tryCatch({n <- as.numeric(tclvalue((onedAmountVal)))
					if (n < 0)
						warning()
				}, warning = function(w){
					err('Increment value must be a positive number', parent=dlg)
				})
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		usrFiles <- onedFileNames[usrSel]
		fileIndices <- match(usrFiles, names(fileFolder))
		if (length(usrSel) == 0)
			err('You must select a spectrum from the list before adjusting shifts', 
					parent=dlg)
		
		##adjust shifts to the left
		if (direct == 'left'){
			for (i in fileIndices){
				fileFolder[[i]]$file.par$upfield_ppm <- 
						fileFolder[[i]]$file.par$upfield_ppm + n
				fileFolder[[i]]$file.par$downfield_ppm <- 
						fileFolder[[i]]$file.par$downfield_ppm + n
				fileFolder[[i]]$graphics.par$usr[1:2] <- 
						fileFolder[[i]]$graphics.par$usr[1:2] + n
				if (!is.null(fileFolder[[i]]$peak.list))
					fileFolder[[i]]$peak.list$w2 <- 
							fileFolder[[i]]$peak.list$w2 + n
			}
			
			##adjust shifts to the right
		}else{
			for (i in fileIndices){
				fileFolder[[i]]$file.par$upfield_ppm <- 
						fileFolder[[i]]$file.par$upfield_ppm - n
				fileFolder[[i]]$file.par$downfield_ppm <- 
						fileFolder[[i]]$file.par$downfield_ppm - n
				fileFolder[[i]]$graphics.par$usr[1:2] <- 
						fileFolder[[i]]$graphics.par$usr[1:2] - n
				if (!is.null(fileFolder[[i]]$peak.list))
					fileFolder[[i]]$peak.list$w2 <- 
							fileFolder[[i]]$peak.list$w2 - n
			}
		}
		myAssign('fileFolder', fileFolder)
		refresh()	
		tkfocus(onedFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	
	##creates manual shift adjustment arrows
	onedLeftButton <- ttkbutton(onedAdjFrame, text='<', width=4, 
			command=function(...) onedArrow('left', onedAmountVal))
	onedAmountEntry <- ttkentry(onedAdjFrame, textvariable=onedAmountVal, width=5, 
			justify='center')
	onedRightButton <- ttkbutton(onedAdjFrame, text='>', width=4, 
			command=function(...) onedArrow('right', onedAmountVal))
	
	##creates auto referencing button
	onedAuto <- function(){
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		usrFiles <- onedFileNames[usrSel]
		if (length(usrSel) == 0)
			err('You must select a spectrum from the list before referencing shifts.', 
					parent=dlg)
		autoRef(usrFiles)
		tclObj(onedRefVal) <<- 0
		tkfocus(onedFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onedAutoButton <- ttkbutton(onedOptionFrame, text='Auto Ref', width=10, 
			command=onedAuto)
	
	##creates default button
	onedDefault <- function(){
		
		##checks for correct input
		usrSel <- 1 + as.integer(tkcurselection(onedFileBox))
		usrFiles <- onedFileNames[usrSel]
		if (length(usrSel) == 0)
			err(paste('You must select a spectrum from the list before restoring',
							'defaults'), parent=dlg)
		
		##restores defaults
		for (i in usrFiles){
			filePar <- ucsfHead(i, print.info=FALSE)
			filePar <- filePar[[1]]
			prevFullUsr <- c(fileFolder[[i]]$file.par$downfield_ppm, 
					fileFolder[[i]]$file.par$upfield_ppm, 
					fileFolder[[i]]$file.par$zero_offset - 
							(fileFolder[[i]]$file.par$max_intensity - 
								fileFolder[[i]]$file.par$zero_offset) * 
							globalSettings$position.1D, 
					fileFolder[[i]]$file.par$max_intensity)
			defUsr <- c(filePar$downfield_ppm, filePar$upfield_ppm, 
					filePar$zero_offset - (filePar$max_intensity - filePar$zero_offset) * 
							globalSettings$position.1D, filePar$max_intensity)
			usrDiff <- prevFullUsr - defUsr
			fileFolder[[i]]$graphics.par$usr <- 
					fileFolder[[i]]$graphics.par$usr - usrDiff
			fileFolder[[i]]$file.par$upfield_ppm <- filePar$upfield_ppm
			fileFolder[[i]]$file.par$downfield_ppm <- filePar$downfield_ppm
			if (!is.null(fileFolder[[i]]$peak.list))
				fileFolder[[i]]$peak.list$w2 <- 
						fileFolder[[i]]$peak.list$w2 - usrDiff[1]
		}
		myAssign('fileFolder', fileFolder)
		refresh()
		tkfocus(onedFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onedDefaultButton <- ttkbutton(onedOptionFrame, text='Default', width=10, 
			command=onedDefault)
	
	##creates undo button
	onedUndo<- function(){
		ud()
		tkfocus(onedFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onedUndoButton <- ttkbutton(onedOptionFrame, text='Undo', width=10, 
			command=onedUndo)
	
	##creates redo button
	onedRedo<- function(){
		rd()
		tkfocus(onedFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onedRedoButton <- ttkbutton(onedOptionFrame, text='Redo', width=10, 
			command=onedRedo)
	
	##add widgets to fileFrame
	tkgrid(onedFileFrame, column=1, row=1, sticky='nswe', pady=c(6, 0),	padx=8)
	tkgrid(onedFileBox, column=1, row=1, sticky='nswe')
	tkgrid(onedYscr, column=2, row=1, sticky='ns')
	tkgrid(onedXscr, column=1, row=2, sticky='we')
	
	##make fileFrame stretch when window is resized
	tkgrid.columnconfigure(onedFrame, 1, weight=1)
	tkgrid.rowconfigure(onedFrame, 1, weight=10)
	tkgrid.columnconfigure(onedFileFrame, 1, weight=1)
	tkgrid.rowconfigure(onedFileFrame, 1, weight=1)
	
	##add widgets to optionFrame
	tkgrid(onedOptionFrame, column=2, row=1, sticky='nswe', pady=c(10, 2), 
			padx=c(4, 0))
	tkgrid(onedRefValFrame, column=1, columnspan=2, row=2, sticky='we', pady=4)
	tkgrid(onedRefEntry, column=1, row=1, padx=4)
	tkgrid(onedLocButton, column=2, row=1)
	
	tkgrid(onedDefRefFrame, column=1, columnspan=2, row=3, sticky='we', pady=4)
	tkgrid(onedPointButton, column=1, row=1, padx=4)
	tkgrid(onedRegionButton, column=2, row=1)
	
	tkgrid(onedAdjFrame, column=1, columnspan=2, row=4, sticky='we', pady=c(0, 6))
	tkgrid(onedLeftButton, column=1, row=1, padx=c(12, 0))
	tkgrid(onedAmountEntry, column=2, row=1)
	tkgrid(onedRightButton, column=3, row=1)
	
	tkgrid(onedAutoButton, column=1, row=5, pady=c(6, 2))
	tkgrid(onedDefaultButton, column=2, row=5, pady=c(6, 2))
	tkgrid(onedUndoButton, column=1, row=6)
	tkgrid(onedRedoButton, column=2, row=6)
	
	##make optionFrame stretch when window is resized
	tkgrid.rowconfigure(onedOptionFrame, 0, weight=1)
	tkgrid.rowconfigure(onedOptionFrame, 7, weight=1)
	
	##resets file list whenever the mouse enters the GUI
	onedMouse <- function(){
		reset(onedFileList, onedFileBox, onedFileNames, dims='1D')
		onedFileNames <<- names(fileFolder)[which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) == 1)]
	}
	tkbind(onedFrame, '<Enter>', onedMouse)
	tkbind(onedFrame, '<FocusIn>', onedMouse)
	
	####create widgets for twodFrame
	##create file list box
	twodFileFrame <- ttklabelframe(twodFrame, text='Files')
	twodFileList <- tclVar()
	twodFileNames <- names(fileFolder)[which(sapply(fileFolder, 
							function(x){x$file.par$number_dimensions}) > 1)]
	tclObj(twodFileList) <- getTitles(twodFileNames)
	twodFileBox <- tklistbox(twodFileFrame, height=12, width=30, bg='white', 
			listvariable=twodFileList, selectmode='extended', active='dotbox',	
			exportselection=FALSE, xscrollcommand=function(...) tkset(twodXscr, ...), 
			yscrollcommand=function(...) tkset(twodYscr, ...))
	twodXscr <- ttkscrollbar(twodFileFrame, orient='horizontal', 
			command=function(...) tkxview(twodFileBox, ...))
	twodYscr <- ttkscrollbar(twodFileFrame, orient='vertical', 
			command=function(...) tkyview(twodFileBox, ...))
	if (length(twodFileNames) > 2){
		for (i in seq(0, length(twodFileNames) - 1, 2))
			tkitemconfigure(twodFileBox, i, background='#ececff')
	}
	if (fileFolder[[current]]$file.par$number_dimensions > 1){
		tkselection.set(twodFileBox, match(currentSpectrum, twodFileNames) - 1)
		tcl(twodFileBox, 'see', match(currentSpectrum, twodFileNames) - 1)
	}
	
	##export fileBox selections to other tabs
	twodSelect <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		usrFile <- twodFileNames[usrSel]
		selIndices <- match(twodFileNames[usrSel], names(fileFolder))
		tkselection.clear(olFileBox, 0, 'end')
		for (i in selIndices)
			tkselection.set(olFileBox, i - 1)
	}
	tkbind(twodFileBox, '<<ListboxSelect>>', twodSelect)
	
	##switches spectra on left-mouse double-click
	twodDouble <- function(){
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		if (length(usrSel))
			usrFile <- twodFileNames[usrSel]
		else
			usrFile <- NULL
		if (!is.null(usrFile) && currentSpectrum != usrFile){
			currentSpectrum <- usrFile
			myAssign('currentSpectrum', currentSpectrum)
			refresh(multi.plot = FALSE)
			tkwm.deiconify(dlg)
			tkfocus(twodFileBox)
		}
	}
	tkbind(twodFileBox, '<Double-Button-1>', twodDouble)
	
	##creates reference value textboxes
	twodOptionFrame <- ttkframe(twodFrame)
	twodRefValFrame <- ttklabelframe(twodOptionFrame, text='Reference value (ppm)', 
			padding=3)
	w1RefVal <- tclVar(0)
	w1Entry <- ttkentry(twodRefValFrame, width=6, justify='center', 
			textvariable=w1RefVal)
	w2RefVal <- tclVar(0)
	w2Entry <- ttkentry(twodRefValFrame, width=6, justify='center', 
			textvariable=w2RefVal)
	
	##creates get shift button
	twodLoc <- function(){
		reset(twodFileList, twodFileBox, twodFileNames, dims='2D')
		twodFileNames <<- names(fileFolder)[which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) > 1)]
		
		##prompt user for type of shift selection
		usr <- mySelect(c('Designated point', 'Region maximum'), multiple=FALSE, 
				title='Get shifts at:',	preselect='Designated point', parent=dlg)
		if (length(usr) == 0 || !nzchar(usr))
			return(invisible())
		else if (usr == 'Region maximum'){
			tryCatch(shift <- regionMax(currentSpectrum)[c('w2', 
									'w1')], error=function(er){
						showGui()
						refresh(multi.plot=FALSE, sub.plot=FALSE)
						stop('Shift not defined', call.=FALSE)})
			if (is.null(shift)){
				showGui()
				refresh(multi.plot=FALSE, sub.plot=FALSE)
				stop('Shift not defined', call.=FALSE)
			}
		}else{
			
			## Opens the main plot window if not currently opened
			if (is.na(match(2, dev.list())))
				refresh(multi.plot=FALSE, sub.plot=FALSE)
			cw(dev=2)
			
			##gives the user instructions
			hideGui()
			cat(paste('In the main plot window:\n',  
							' Left-click a point inside the plot to designate position\n'))
			flush.console()
			op <- par('font')
			par(font=2)
			legend("topleft", c('LEFT CLICK TO DESIGNATE POSITION', 
							'RIGHT CLICK TO EXIT'),	pch=NULL, bty='n', 
					text.col=fileFolder[[wc()]]$graphics.par$fg)
			par(font=op)
			
			##get the chemical shift at designated postion
			tryCatch(shift <- locator(1), error=function(er){
						showGui()
						refresh(multi.plot=FALSE, sub.plot=FALSE)
						stop('Shift not defined', call.=FALSE)})
			if (is.null(shift)){
				showGui()
				refresh(multi.plot=FALSE, sub.plot=FALSE)
				stop('Shift not defined', call.=FALSE)
			}
		}
		refresh(multi.plot=FALSE, sub.plot=FALSE)
		if (is.na(shift[2])){
			showGui()
			err('Specified region does not contain peaks above the noise level')
		}
		points(shift[1], shift[2], pch='*', cex=1.5, 
				col=fileFolder[[wc()]]$graphics.par$fg)
		tclObj(w1RefVal) <<- round(unlist(shift[2]), 4)
		tclObj(w2RefVal) <<- round(unlist(shift[1]), 4)
		showGui()
		tkfocus(twodFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	twodLocButton <- ttkbutton(twodRefValFrame, text='Get Shifts', width=14, 
			command=twodLoc)
	
	##creates point reference button
	twodDefRefFrame <- ttklabelframe(twodOptionFrame, text='Define reference', 
			padding=3)
	twodPoint <- function(){
		
		##checks for correct input
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		usrFiles <- twodFileNames[usrSel]
		if (length(usrSel) == 0)
			err(paste('You must select a spectrum from the list before designating a',
							'position'), parent=dlg)
		w1RefVal <- suppressWarnings(as.numeric(tclvalue(w1RefVal)))
		w2RefVal <- suppressWarnings(as.numeric(tclvalue(w2RefVal)))
		if (is.na(w1RefVal) || is.na(w2RefVal))
			err('You must provide numeric values for the chemical shift reference', 
					parent=dlg)
		
		##make sure input files are similar to each other and the current spectrum
		for (i in usrFiles){
			if (!identical(fileFolder[[wc()]]$file.par$number_dimensions, 
					fileFolder[[i]]$file.par$number_dimensions))
				err(paste('All files must have the same number of dimensions as the', 
								'current spectrum'), parent=dlg)
			if (!identical(fileFolder[[wc()]]$file.par$nucleus, 
					fileFolder[[i]]$file.par$nucleus))
				err('All files must have the same nuclei as the current spectrum', 
						parent=dlg)
			if (!identical(fileFolder[[wc()]]$file.par$matrix_size, 
					fileFolder[[i]]$file.par$matrix_size))
				err(paste('All files must have the same number of points in all', 
								'dimensions as the current spectrum'), parent=dlg)
		}
		
		##makes sure the current spectrum is included in the user's selection
		if (!currentSpectrum %in% usrFiles){
			usrSel <- myMsg(paste('The current spectrum was not included in your', 
							' selection and will be added automatically.\nDo you wish to', 
							' proceed?', sep=''), 'yesno', parent=dlg)
			if (usrSel == 'no'){
				return(invisible())
			}else{
				usrFiles <- c(currentSpectrum, usrFiles)
				tkselection.set(twodFileBox, match(currentSpectrum, twodFileNames) - 1)
			}
		}
		
		## Opens the main plot window if not currently opened
		if (is.na(match(2, dev.list())))
			refresh(multi.plot=FALSE, sub.plot=FALSE)
		cw(dev=2)
		
		##gives the user instructions
		hideGui()
		cat(paste('In the main plot window:\n',  
						' Left-click a point inside the plot to define the reference\n'))
		flush.console()
		op <- par('font')
		par(font=2)
		legend("topleft", c('LEFT CLICK TO DEFINE REFERENCE', 
						'RIGHT CLICK TO EXIT'), pch=NULL, bty='n', 
				text.col=fileFolder[[wc()]]$graphics.par$fg)
		par(font = op)
		tryCatch(pointVal <- locator(1), error=function(er){
					showGui()
					stop('Point not defined', call.=FALSE)})
		if (length(pointVal) == 0 || is.null(pointVal)){
			showGui()
			refresh(multi.plot=FALSE, sub.plot=FALSE)
			stop('Point not defined', call.=FALSE)
		}
		showGui()
		pointVal <- c(pointVal[[2]] - w1RefVal, pointVal[[1]] - w2RefVal)
		
		##sets up and downfield shifts to the current spectrum's
		currUp <- fileFolder[[wc()]]$file.par$upfield_ppm
		currDown <- fileFolder[[wc()]]$file.par$downfield_ppm
		keepFolder <- fileFolder
		for (i in usrFiles){
			fileFolder[[i]]$file.par$upfield_ppm <- currUp
			fileFolder[[i]]$file.par$downfield_ppm <- currDown
		}
		myAssign('fileFolder', fileFolder, save.backup=FALSE)
		
		##references selected spectra
		for (i in usrFiles){
			fileFolder[[i]]$file.par$upfield_ppm <- currUp - pointVal
			fileFolder[[i]]$file.par$downfield_ppm <- currDown - pointVal
			totShiftChange <- keepFolder[[i]]$file.par$upfield_ppm - 
					fileFolder[[i]]$file.par$upfield_ppm
			newUsr <- c(fileFolder[[i]]$graphics.par$usr[1:2] - totShiftChange[2], 
					fileFolder[[i]]$graphics.par$usr[3:4] - totShiftChange[1])
			fileFolder[[i]]$graphics.par$usr <- newUsr
			if (!is.null(fileFolder[[i]]$peak.list)){
				fileFolder[[i]]$peak.list$w1 <- fileFolder[[i]]$peak.list$w1 - 
						totShiftChange[1]
				fileFolder[[i]]$peak.list$w2 <- fileFolder[[i]]$peak.list$w2 - 
						totShiftChange[2]
			}
		}
		myAssign('fileFolder', fileFolder)
		refresh()
		points(w2RefVal, w1RefVal, pch='*', cex=1.5, 
				col=fileFolder[[wc()]]$graphics.par$fg)
		showGui()
		tkfocus(twodFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	twodPointButton <- ttkbutton(twodDefRefFrame, text='Point', width=8, 
			command=twodPoint)
	
	##creates region reference button
	twodRegion <- function(){
		
		##checks for correct input
		reset(twodFileList, twodFileBox, twodFileNames, dims='2D')
		twodFileNames <<- names(fileFolder)[which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) > 1)]
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		usrFiles <- twodFileNames[usrSel]
		if (length(usrSel) == 0)
			err('You must select a spectrum from the list before defining a region', 
					parent=twodFrame)
		w1RefVal <- suppressWarnings(as.numeric(tclvalue(w1RefVal)))
		w2RefVal <- suppressWarnings(as.numeric(tclvalue(w2RefVal)))
		if (is.na(w1RefVal) || is.na(w2RefVal))
			err('You must provide numeric values for the chemical shift reference', 
					parent=dlg)
		
		##make sure input files are similar to each other and the current spectrum
		for (i in usrFiles){
			if (!identical(fileFolder[[wc()]]$file.par$number_dimensions, 
					fileFolder[[i]]$file.par$number_dimensions))
				err(paste('All files must have the same number of dimensions as the', 
								'current spectrum'), parent=dlg)
			if (!identical(fileFolder[[wc()]]$file.par$nucleus, 
					fileFolder[[i]]$file.par$nucleus))
				err('All files must have the same nuclei as the current spectrum',
						parent=dlg)
			if (!identical(fileFolder[[wc()]]$file.par$matrix_size, 
					fileFolder[[i]]$file.par$matrix_size))
				err(paste('All files must have the same number of points in all', 
								'dimensions as the current spectrum'), parent=dlg)
		}
		
		##makes sure the current spectrum is included in the user's selection
		if (!currentSpectrum %in% usrFiles){
			usrSel <- myMsg(paste('The current spectrum was not included in your', 
							' selection and will be added automatically.\nDo you wish to', 
							' proceed?', sep=''), 'yesno', parent=dlg)
			if (usrSel == 'no'){
				return(invisible())
			}else{
				usrFiles <- c(currentSpectrum, usrFiles)
				tkselection.set(twodFileBox, match(currentSpectrum, twodFileNames) - 1)
			}
		}
		
		##sets up and downfield shifts to the current spectrum's
		currUp <- fileFolder[[wc()]]$file.par$upfield_ppm
		currDown <- fileFolder[[wc()]]$file.par$downfield_ppm
		keepFolder <- fileFolder
		for (i in usrFiles){
			fileFolder[[i]]$file.par$upfield_ppm <- currUp
			fileFolder[[i]]$file.par$downfield_ppm <- currDown
		}
		myAssign('fileFolder', fileFolder, save.backup=FALSE)
		
		##references selected spectra
		tryCatch(ms <- regionMax(usrFiles, redraw=FALSE), error=function(er){
					myAssign('fileFolder', keepFolder, save.backup=FALSE)
					showGui()
					stop('Region not defined', call.=FALSE)})
		if (is.null(ms)){
			myAssign('fileFolder', keepFolder, save.backup=FALSE)
			showGui()
			stop('Region not defined', call.=FALSE)
		}
		for (i in usrFiles){
			if (is.na(ms[i, 'w1']) || is.na(ms[i, 'w2']))
				next
			regionVal <- c(ms[i, 'w1'] - w1RefVal,	ms[i, 'w2'] - w2RefVal)
			fileFolder[[i]]$file.par$upfield_ppm <- currUp - regionVal
			fileFolder[[i]]$file.par$downfield_ppm <- currDown - regionVal
			totShiftChange <- keepFolder[[i]]$file.par$upfield_ppm - 
					fileFolder[[i]]$file.par$upfield_ppm
			newUsr <- c(fileFolder[[i]]$graphics.par$usr[1:2] - totShiftChange[2], 
					fileFolder[[i]]$graphics.par$usr[3:4] - totShiftChange[1])
			fileFolder[[i]]$graphics.par$usr <- newUsr
			if (!is.null(fileFolder[[i]]$peak.list)){
				fileFolder[[i]]$peak.list$w1 <- fileFolder[[i]]$peak.list$w1 - 
						totShiftChange[1]
				fileFolder[[i]]$peak.list$w2 <-	fileFolder[[i]]$peak.list$w2 - 
						totShiftChange[2]
			}
		}
		myAssign('fileFolder', fileFolder)
		refresh()
		
		##draw lines to indicate region maximum
		lineCol <- fileFolder[[wc()]]$graphics.par$fg
		abline(h=w1RefVal,	v=w2RefVal, lty=2,	col=lineCol)
		tkfocus(twodFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}	
	twodRegionButton <- ttkbutton(twodDefRefFrame, text='Region', width=8, 
			command=twodRegion)
	
	##create manual shift adjustment arrows
	twodAdjFrame <- ttklabelframe(twodOptionFrame, text='Man. adjustment (ppm)', 
			padding=3)
	twodAmountVal <- tclVar(1)
	twodArrow <- function(direct, n){
		reset(twodFileList, twodFileBox, twodFileNames, dims='2D')
		twodFileNames <<- names(fileFolder)[which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) > 1)]
		
		##checks for valid inputs
		tryCatch({n <- as.numeric(tclvalue((twodAmountVal)))
					if (n < 0)
						warning()
				}, warning = function(w){
					err('Increment value must be a positive number', parent=dlg)
				})
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		usrFiles <- twodFileNames[usrSel]
		if (length(usrSel) == 0)
			err('You must select a spectrum from the list before adjusting shifts', 
					parent=dlg)
		
		##adjust shifts to the left
		if (direct == 'left'){
			ppmInc <- c(0, n)
			usrInc <- c(n, n, 0, 0)
			peakInc <- c('w2', n)
			
			##adjust shifts to the right
		}else if (direct == 'right'){
			ppmInc <- c(0, -n, 0, -n)
			usrInc <- c(-n, -n, 0, 0)
			peakInc <- c('w2', -n)
			
			##adjust shifts downward
		}else if (direct == 'down'){
			ppmInc <- c(n, 0)
			usrInc <- c(0, 0, n, n)
			peakInc <- c('w1', n)
			
			##adjust shifts upward
		}else if (direct == 'up'){
			ppmInc <- c(-n, 0)
			usrInc <- c(0, 0, -n, -n)
			peakInc <- c('w1', -n)
		}
		
		##set new shifts
		for (i in usrFiles){
			fileFolder[[i]]$file.par$upfield_ppm <- 
					fileFolder[[i]]$file.par$upfield_ppm + ppmInc
			fileFolder[[i]]$file.par$downfield_ppm <- 
					fileFolder[[i]]$file.par$downfield_ppm + ppmInc
			fileFolder[[i]]$graphics.par$usr <- 
					fileFolder[[i]]$graphics.par$usr + usrInc
			if (!is.null(fileFolder[[i]]$peak.list))
				fileFolder[[i]]$peak.list[, peakInc[1]] <- 
						fileFolder[[i]]$peak.list[, peakInc[1]] + as.numeric(peakInc[2])
		}
		
		myAssign('fileFolder', fileFolder)
		refresh()	
		tkfocus(twodFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}	
	twodUpButton <- ttkbutton(twodAdjFrame, text='^', width=5, 
			command=function(...) twodArrow('up', twodAmountVal))
	twodDownButton <- ttkbutton(twodAdjFrame, text='v', width=5, 
			command=function(...) twodArrow('down', twodAmountVal))
	twodLeftButton <- ttkbutton(twodAdjFrame, text='<', width=4, 
			command=function(...) twodArrow('left', twodAmountVal))
	twodRightButton <- ttkbutton(twodAdjFrame, text='>', width=4, 
			command=function(...) twodArrow('right', twodAmountVal))
	twodAmountEntry <- ttkentry(twodAdjFrame, textvariable=twodAmountVal, width=5, 
			justify='center')
	
	##creates default button
	twodDefault <- function(){
		
		##checks for correct input
		reset(twodFileList, twodFileBox, twodFileNames, dims='2D')
		twodFileNames <<- names(fileFolder)[which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) > 1)]
		usrSel <- 1 + as.integer(tkcurselection(twodFileBox))
		usrFiles <- twodFileNames[usrSel]
		if (length(usrSel) == 0)
			err(paste('You must select a spectrum from the list before restoring', 
							'defaults'), parent=dlg)
		
		##restores defaults
		for (i in usrFiles){
			filePar <- ucsfHead(i, print.info=FALSE)[[1]]
			prevFullUsr <- c(fileFolder[[i]]$file.par$downfield_ppm[2],	
					fileFolder[[i]]$file.par$upfield_ppm[2], 
					fileFolder[[i]]$file.par$downfield_ppm[1], 
					fileFolder[[i]]$file.par$upfield_ppm[1])
			defUsr <- c(filePar$downfield_ppm[2],	filePar$upfield_ppm[2], 
					filePar$downfield_ppm[1], filePar$upfield_ppm[1])
			usrDiff <- prevFullUsr - defUsr
			fileFolder[[i]]$graphics.par$usr <- 
					fileFolder[[i]]$graphics.par$usr - usrDiff
			fileFolder[[i]]$file.par$upfield_ppm <- filePar$upfield_ppm
			fileFolder[[i]]$file.par$downfield_ppm <- filePar$downfield_ppm
			if (!is.null(fileFolder[[i]]$peak.list)){
				fileFolder[[i]]$peak.list$w1 <- 
						fileFolder[[i]]$peak.list$w1 - usrDiff[3]
				fileFolder[[i]]$peak.list$w2 <- 
						fileFolder[[i]]$peak.list$w2 - usrDiff[1]
			}
		}
		myAssign('fileFolder', fileFolder)
		refresh()
		tkfocus(twodFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	twodDefaultButton <- ttkbutton(twodOptionFrame, text='Default', width=18,
			command=twodDefault)
	
	##creates undo button
	twodUndo<- function(){
		ud()
		tkfocus(twodFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	twodUndoButton <- ttkbutton(twodOptionFrame, text='Undo', width=10, 
			command=twodUndo)
	
	##creates redo button
	twodRedo<- function(){
		rd()
		tkfocus(twodFrame)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	twodRedoButton <- ttkbutton(twodOptionFrame, text='Redo', width=10, 
			command=twodRedo)
	
	##add widgets to fileFrame
	tkgrid(twodFileFrame, column=1, row=1, sticky='nswe', pady=c(6, 0),	padx=8)
	tkgrid(twodFileBox, column=1, row=1, sticky='nswe')
	tkgrid(twodYscr, column=2, row=1, sticky='ns')
	tkgrid(twodXscr, column=1, row=2, sticky='we')
	
	##make fileFrame stretch when window is resized
	tkgrid.columnconfigure(twodFrame, 1, weight=1)
	tkgrid.rowconfigure(twodFrame, 1, weight=10)
	tkgrid.columnconfigure(twodFileFrame, 1, weight=1)
	tkgrid.rowconfigure(twodFileFrame, 1, weight=1)
	
	##add widgets to optionFrame
	tkgrid(twodOptionFrame, column=2, row=1, sticky='nswe', pady=c(10, 2), 
			padx=c(4, 0))
	tkgrid(twodRefValFrame, column=1, columnspan=2, row=2, sticky='we', pady=4)
	tkgrid(ttklabel(twodRefValFrame, text='w1:'), column=1, row=1)
	tkgrid(w1Entry, column=2, row=1, padx=1)
	tkgrid(ttklabel(twodRefValFrame, text='w2:'), column=3, row=1)
	tkgrid(w2Entry, column=4, row=1, padx=c(1, 3))
	tkgrid(twodLocButton, column=1, columnspan=4, row=3, pady=c(3, 0))
	
	tkgrid(twodDefRefFrame, column=1, columnspan=2, row=3, sticky='we', pady=4)
	tkgrid(twodPointButton, column=1, row=1, padx=c(6, 4))
	tkgrid(twodRegionButton, column=2, row=1)
	
	tkgrid(twodAdjFrame, column=1, columnspan=2, row=4, sticky='we', pady=c(0, 6))
	tkgrid(twodUpButton, column=2, row=1, sticky='s', pady=c(2, 0))
	tkgrid(twodLeftButton, column=1, row=2, sticky='e', padx=c(11, 0))
	tkgrid(twodAmountEntry, column=2, row=2)
	tkgrid(twodRightButton, column=3, row=2, sticky='w')
	tkgrid(twodDownButton, column=2, row=3, sticky='n', pady=c(0, 4))
	
	tkgrid(twodDefaultButton, column=1, columnspan=2, row=5, pady=c(0, 2))
	tkgrid(twodUndoButton, column=1, row=6)
	tkgrid(twodRedoButton, column=2, row=6)
	
	##make optionFrame stretch when window is resized
	tkgrid.rowconfigure(twodOptionFrame, 0, weight=1)
	tkgrid.rowconfigure(twodOptionFrame, 7, weight=1)
	
	##resets file list whenever the mouse enters the GUI
	twodMouse <- function(){
		reset(twodFileList, twodFileBox, twodFileNames, dims='2D')
		twodFileNames <<- names(fileFolder)[which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) > 1)]
	}
	tkbind(twodFrame, '<Enter>', twodMouse)
	tkbind(twodFrame, '<FocusIn>', twodMouse)
	
	##Allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (length(grep('.1.1.1.1$', focus)))
			olDouble(olFileBox)
		else if (length(grep('.1.1.3.1$', focus)))
			olDouble(overlayBox)
		else if (length(grep('.1.2.1.1$', focus)))
			onedDouble()
		else if (length(grep('.1.3.1.1$', focus)))
			twodDouble()
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter) 
	
	##Change the window title depending on which pane is displayed
	onSwitch <- function(){
		if (length(grep('.1.1', as.character(tkselect(osBook)))))
			tkwm.title(dlg, 'Overlays')
		else
			tkwm.title(dlg, 'Referencing')
	}
	
	##enable\disable panes depending on which files are open
	onMouse <- function(){
		if (length(names(fileFolder)) && any(which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) == 1)))
			tcl(osBook, 'tab', 1, state='normal')
		else
			tcl(osBook, 'tab', 1, state='disabled')
		if (length(names(fileFolder)) && any(which(sapply(fileFolder, 
								function(x){x$file.par$number_dimensions}) > 1)))
			tcl(osBook, 'tab', 2, state='normal')
		else
			tcl(osBook, 'tab', 2, state='disabled')
	}
	tkbind(dlg, '<Enter>', onMouse)
	tkbind(dlg, '<FocusIn>', onMouse)
	tkbind(dlg, '<<NotebookTabChanged>>', onSwitch)
	
	invisible()
}

## Wrapper function, displays the shift referencing panes in os()
sr <- function(){
	current <- wc()
	if (fileFolder[[current]]$file.par$number_dimensions == 1)
		os('sr1D')
	else
		os('sr2D')
}

## Interactive GUI for manipulating 1D projections and slices
pj <- function(){
	
	##checks that the current spectrum is 2D
	current <- wc()
	if (fileFolder[[current]]$file.par$number_dimensions == 1)
		err('1D projections can only be applied to 2D spectra')
	
	##create main window
	tclCheck()
	dlg <- myToplevel('pj', pady=4, padx=4)
	if (is.null(dlg))
		return(invisible())
	tkwm.title(dlg, 'Slice')
	tkwm.resizable(dlg, FALSE, FALSE)
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##applies changes to projection settings
	onApply <- function(){
		filt=NULL
		if (nzchar(tclvalue(projType))){
			if (tclvalue(projType) == 'absolute max')
				filt <- function(x){max(abs(x))}
			else if (tclvalue(projType) == 'pseudo1D')
				filt <- pseudo1D
			else if (tclvalue(projType) == 'max')
				filt <- function(x){max(x)}
			else if (tclvalue(projType) == 'min')
				filt <- function(x){min(x)}
		}
		dType <- switch(tclvalue(dispType), 'line'='l', 'points'='p', 'both'='b')
		setGraphics(all.files=TRUE, proj.mode=as.logical(tclObj(projVal)), 
				filter=filt, proj.direct=as.integer(tclvalue(dimVal)), proj.type=dType)
		refresh(sub.plot=FALSE, multi.plot=FALSE)
		configGui()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	
	##creates view slice buttons
	sliceFrame <- ttklabelframe(dlg, text='1D slice', padding=2)
	directButton <- ttkbutton(sliceFrame, text='Direct', width=10, 
			command=function(...) vs(1))
	indirectButton <- ttkbutton(sliceFrame, text='Indirect', width=10, 
			command=function(...) vs(2))
	
	##creates 1D projection radio buttons
	projFrame <- ttklabelframe(dlg, text='1D projection', padding=2)
	projVal <- tclVar(globalSettings$proj.mode)
	onON <- function(){
		onApply()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onRb <- ttkradiobutton(projFrame, variable=projVal, value=TRUE, text='On', 
			command=onON)
	onOFF <- function(){
		onApply()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	offRb <- ttkradiobutton(projFrame, variable=projVal, value=FALSE, text='Off', 
			command=onOFF)
	
	##creates projection type combobox/radio buttons
	typeFrame <- ttkframe(projFrame)
	typeLabel <- ttklabel(typeFrame, text='Type:')
	if (isTRUE(all.equal(globalSettings$filter, function(x){max(abs(x))})))
		projType <- tclVar('absolute max')
	else if (isTRUE(all.equal(globalSettings$filter, pseudo1D)))
		projType <- tclVar('pseudo1D')
	else if (isTRUE(all.equal(globalSettings$filter, function(x){max(x)})))
		projType <- tclVar('max')
	else if (isTRUE(all.equal(globalSettings$filter,  function(x){min(x)})))
		projType <- tclVar('min')
	else
		projType <- tclVar('')	
	
	typeBox <- ttkcombobox(typeFrame, textvariable=projType, height=4, width=12,  
			values=c('pseudo1D', 'max', 'min', 'absolute max'), exportselection=FALSE)
	tkbind(typeBox, '<<ComboboxSelected>>', onApply) 
	
	##creates projection direction radio buttons
	dimFrame <- ttkframe(projFrame)
	dimLabel <- ttklabel(dimFrame, text='Dimension:')
	dimVal <- tclVar(globalSettings$proj.direct)
	dirRb <- ttkradiobutton(dimFrame, variable=dimVal, value=1, text='Direct', 
			command=onApply)
	indirRb <- ttkradiobutton(dimFrame, variable=dimVal, value=2, text='Indirect', 
			command=onApply)
	
	##creates display type combobox/radio buttons
	genFrame <- ttklabelframe(dlg, text='Settings', padding=2)
	dispFrame <- ttkframe(genFrame)
	dispLabel <- ttklabel(dispFrame, text='Display:')
	dispType <- tclVar(switch(globalSettings$proj.type, 'l'='line', 'p'='points', 
					'b'='both'))
	dispBox <- ttkcombobox(dispFrame, textvariable=dispType, height=4, width=12,  
			values=c('line', 'points', 'both'), exportselection=FALSE, 
			state='readonly')
	tkbind(dispBox, '<<ComboboxSelected>>', onApply) 
	
	##create set 1D color button 
	projColButton <- ttkbutton(genFrame, text='Color', width=10, 
			command=function(...) changeColor(dlg, '1D', currentSpectrum))
	
	##create defaults button
	onDefault <- function(){
		if (isTRUE(all.equal(defaultSettings$filter, function(x){max(abs(x))})))
			filter <- 'absolute max'
		else if (isTRUE(all.equal(defaultSettings$filter, pseudo1D)))
			filter <- 'pseudo1D'
		else if (isTRUE(all.equal(defaultSettings$filter,  function(x){max(x)})))
			filter <- 'max'
		else if (isTRUE(all.equal(defaultSettings$filter,  function(x){min(x)})))
			filter <- 'min'
		else
			filter <- ''	
		tclObj(projType) <- filter
		tclObj(dispType) <- switch(defaultSettings$proj.type, 'l'='line', 
				'p'='points', 'b'='both')
		tclObj(dimVal) <- defaultSettings$proj.direct
		setGraphics(proj.color=defaultSettings$proj.color, save.backup=FALSE)
		onOFF()
	}
	defaultsButton <- ttkbutton(genFrame, text='Defaults', width=10, 
			command=onDefault)
	
	##add widgets to sliceFrame
	tkgrid(sliceFrame, column=1, columnspan=2, row=1, sticky='we', pady=4, padx=4)
	tkgrid(directButton, column=1, row=1, pady=4, padx=2)
	tkgrid(indirectButton, column=2, row=1, pady=4, padx=2)
	
	##add widgets to projFrame
	tkgrid(projFrame, column=1, columnspan=2, row=2, sticky='we', pady=4, padx=4)
	tkgrid(onRb, column=1, row=1, sticky='w', padx=c(6, 0), pady=3)
	tkgrid(offRb, column=2, row=1, sticky='w', pady=3)	
	tkgrid(typeFrame, column=1, columnspan=2, row=2, sticky='we', pady=2, padx=3)
	tkgrid(typeLabel, row=1, column=1, sticky='w', padx=c(0, 16))
	tkgrid(typeBox, row=1, column=2, sticky='e')
	tkgrid(dimFrame, column=1, columnspan=2, row=3, sticky='we', pady=2, padx=3)
	tkgrid(dimLabel, column=1, row=1, pady=2, sticky='w')
	tkgrid(dirRb, column=1, row=2, padx=c(6, 12))
	tkgrid(indirRb, column=2, row=2)
	
	tkgrid(genFrame, column=1, columnspan=2, row=3, sticky='we', pady=c(4, 8), 
			padx=4)
	tkgrid(dispFrame, column=1, columnspan=2, row=1, sticky='we', pady=3, padx=3)
	tkgrid(dispLabel, row=1, column=1, sticky='w', padx=c(2, 4))
	tkgrid(dispBox, row=1, column=2, sticky='e', padx=2)
	tkgrid(projColButton, column=1, row=2, sticky='e', pady=5, padx=3)
	tkgrid(defaultsButton, column=2, row=2, sticky='w', pady=5, padx=2)
	
	##reconfigures widgets in GUI to match current settings
	configGui <- function(){
		configList <- list(dirRb, indirRb, typeLabel, dimLabel)
		if (globalSettings$proj.mode){
			for (i in configList)
				tkconfigure(i, state='normal')
			tkconfigure(typeBox, state='readonly', foreground='black')
		}else{
			for (i in configList)
				tkconfigure(i, state='disabled')
			tkconfigure(typeBox, state='disabled', foreground='grey')
		}
		tclObj(projVal) <- globalSettings$proj.mode
		if (isTRUE(all.equal(globalSettings$filter, function(x){max(abs(x))})))
			tclvalue(projType) <- 'absolute max'
		else if (isTRUE(all.equal(globalSettings$filter, pseudo1D)))
			tclObj(projType) <- 'pseudo1D'
		else if (isTRUE(all.equal(globalSettings$filter,  function(x){max(x)})))
			tclObj(projType) <- 'max'
		else if (isTRUE(all.equal(globalSettings$filter,  function(x){min(x)})))
			tclObj(projType) <- 'min'
		else
			tclObj(projType) <- ''	
		tclObj(dispType) <- switch(globalSettings$proj.type, 'l'='line', 
				'p'='points', 'b'='both')
		tclObj(dimVal) <- globalSettings$proj.direct
	}
	configGui()	
	tkbind(dlg, '<Enter>', configGui)
	tkbind(dlg, '<FocusIn>', configGui)
	tkbind(dlg, '<Return>', function(...) tryCatch(tkinvoke(tkfocus()), 
						error=function(er){}))
	
	invisible()
}

## Interactive ROI GUI
roi <- function(){
	
	##create main window
	current <- wc()
	tclCheck()
	dlg <- myToplevel('roi')
	if (is.null(dlg))
		return(invisible())
	tkwm.title(dlg, 'ROI')
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##create paned notebook
	roiBook <- ttknotebook(dlg, padding=3)
	tkgrid(roiBook, column=1, row=1, sticky='nswe')
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=1)
	
	##create roi notebook panes
	editFrame <- ttkframe(roiBook, padding=3) 
	tkadd(roiBook, editFrame, text='     Edit     ')
	selectFrame <- ttkframe(roiBook, padding=3)
	tkadd(roiBook, selectFrame, text='   Select   ')
	dispFrame <- ttkframe(roiBook, padding=3)
	tkadd(roiBook, dispFrame, text='   Display   ')
	autoFrame <- ttkframe(roiBook, padding=3)
	tkadd(roiBook, autoFrame, text='    Auto    ')
	sumFrame <- ttkframe(roiBook, padding=3) 
	tkadd(roiBook, sumFrame, text='  Summary   ')
	
	#####create widgets for editFrame
	##create new button
	editButFrame <- ttkframe(editFrame)
	onNew <- function(){
		rn()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	newButton <- ttkbutton(editButFrame, text='New', width=9, command=onNew)
	
	##create delete button
	onDel <- function(){
		rDel()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	delButton <- ttkbutton(editButFrame, text='Delete', width=9, command=onDel)
	
	##create peak center button
	onCenter <- function(){
		rc()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	centerButton <- ttkbutton(editButFrame, text='Center Active', width=16, 
			command=onCenter)
	
	##create rename button
	onRename <- function(){
		rr()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	editRenameButton <- ttkbutton(editButFrame, text='Rename Active', width=16, 
			command=onRename)
	
	##create edit table button
	editTableButton <- ttkbutton(editButFrame, text='Edit ROI Table', width=16, 
			command=function() re())
	
	##create ROI edit radiobuttons
	adjustFrame <- ttklabelframe(editFrame, text='Adjust', padding=3)
	adjTypeFrame <- ttkframe(adjustFrame)
	adjRbVal <- tclVar('move')
	moveButton <- ttkradiobutton(adjTypeFrame, variable=adjRbVal, value='move', 
			text='move')
	expandButton <- ttkradiobutton(adjTypeFrame, variable=adjRbVal, 
			value='expand', text='expand')
	contractButton <- ttkradiobutton(adjTypeFrame, variable=adjRbVal, 
			value='contract', text='contract')
	
	##create ROI arrow buttons
	arrowFrame <- ttkframe(adjustFrame)
	amount <- tclVar(20)
	onArrow <- function(type, direct, n){
		if (tclvalue(incRbVal) == 'percent')
			ppmInc <- FALSE
		else
			ppmInc <- TRUE
		type <- tclvalue(type)
		tryCatch({n <- as.numeric(tclvalue((amount)))
					if (n < 0)
						warning()}, warning = function(w){
					err('Increment value must be a positive number', parent=dlg)
				})
		if (type == 'move'){
			switch(direct, 'up'=changeRoi(ppmInc, w1Inc=c(-n, -n), checkF=FALSE), 
					'down'=changeRoi(ppmInc, w1Inc=c(n, n), checkF=FALSE), 
					'left'=changeRoi(ppmInc, w2Inc=c(n, n), checkF=FALSE), 
					'right'=changeRoi(ppmInc, w2Inc=c(-n, -n), checkF=FALSE))
		}else if (type == 'expand'){
			switch(direct, 'up'=changeRoi(ppmInc, w1Inc=c(0, -n)), 
					'down'=changeRoi(ppmInc, w1Inc=c(n, 0)), 
					'left'=changeRoi(ppmInc, w2Inc=c(n, 0)), 
					'right'=changeRoi(ppmInc, w2Inc=c(0, -n)))
		}else{
			switch(direct, 'up'=changeRoi(ppmInc, w1Inc=c(-n, 0)), 
					'down'=changeRoi(ppmInc, w1Inc=c(0, n)), 
					'left'=changeRoi(ppmInc, w2Inc=c(0, n)), 
					'right'=changeRoi(ppmInc, w2Inc=c(-n, 0)))
		}
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	upButton <- ttkbutton(arrowFrame, text='^', width=5, command=function(...) 
				onArrow(adjRbVal, 'up', amount))
	downButton <- ttkbutton(arrowFrame, text='v', width=5, command=function(...) 
				onArrow(adjRbVal, 'down', amount))
	leftButton <- ttkbutton(arrowFrame, text='<', width=4, command=function(...) 
				onArrow(adjRbVal, 'left', amount))
	rightButton <- ttkbutton(arrowFrame, text='>', width=4, command=function(...) 
				onArrow(adjRbVal, 'right', amount))
	arrowEntry <- ttkentry(arrowFrame, textvariable=amount, width=5, 
			justify='center')
	
	##create adjustment increment radiobuttons
	incFrame <- ttkframe(adjustFrame)
	incRbVal <- tclVar('percent')
	incLabel <- ttklabel(incFrame, text='Increment:')
	percentButton <- ttkradiobutton(incFrame, variable=incRbVal, value='percent', 
			text='percent')
	ppmButton <- ttkradiobutton(incFrame, variable=incRbVal, value='ppm', 
			text='ppm')
	
	##add widgets to editFrame
	tkgrid(editButFrame, column=1, row=1, padx=15, pady=c(10, 0))
	tkgrid(newButton, row=1, column=1, pady=3, padx=4)
	tkgrid(delButton, row=1, column=2, pady=3, padx=4)
	tkgrid(centerButton, row=2, column=1, columnspan=2, pady=3, padx=4)
	tkgrid(editRenameButton, row=3, column=1, columnspan=2, pady=3, padx=4)
	tkgrid(editTableButton, row=4, column=1, columnspan=2, pady=3, padx=4)
	
	tkgrid(adjustFrame, column=2, row=1, pady=c(5, 0))
	tkgrid(adjTypeFrame, column=1, row=1)
	tkgrid(moveButton, column=1, row=1, padx=5)
	tkgrid(expandButton, column=2, row=1, padx=7)
	tkgrid(contractButton, column=3, row=1, padx=5)
	
	tkgrid(arrowFrame, column=1, row=2, padx=c(0, 15))
	tkgrid(upButton, column=2, row=1, sticky='s', pady=c(3, 0))
	tkgrid(leftButton, column=1, row=2, sticky='e')
	tkgrid(arrowEntry, column=2, row=2)
	tkgrid(rightButton, column=3, row=2, sticky='w')
	tkgrid(downButton, column=2, row=3, sticky='n', pady=c(0, 4))
	
	tkgrid(incFrame, column=1, row=3, pady=c(0, 4))
	tkgrid(incLabel, column=1, row=1, padx=c(0, 3))
	tkgrid(percentButton, column=2, row=1, padx=3)
	tkgrid(ppmButton, column=3, row=1, padx=c(8, 3))
	
	#####create widgets for selectFrame
	##create all button
	selButFrame <- ttklabelframe(selectFrame, text='ROIs', padding=6)
	onAll <- function(){
		newTable <- roiTable
		newTable$ACTIVE <- TRUE
		myAssign('roiTable', newTable)
		refresh()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	allButton <- ttkbutton(selButFrame, text='All', width=9, command=onAll)
	
	##create none button
	onNone <- function(){
		newTable <- roiTable
		newTable$ACTIVE <- FALSE
		myAssign('roiTable', newTable)
		refresh()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	noneButton <- ttkbutton(selButFrame, text='None', width=9, command=onNone)
	
	##create list button
	onList <- function(){
		rs(1)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	listButton <- ttkbutton(selButFrame, text='From List', width=15, 
			command=onList)
	
	##create single button
	mainFrame <- ttklabelframe(selectFrame, text='ROIs in main plot', padding=6)
	onSingle <- function(){
		rs(2)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	singleButton <- ttkbutton(mainFrame, text='Single', width=9, command=onSingle)
	
	##create region button
	onReg <- function(){
		rs(5)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	regionButton <- ttkbutton(mainFrame, text='Region', width=9, command=onReg)
	
	##create ROIs button
	multiFrame <- ttklabelframe(selectFrame, text='Multiple file window', 
			padding=6)
	onRois <- function(){
		rs(4)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	multiRoiButton <- ttkbutton(multiFrame, text='ROIs', width=8, command=onRois)
	multiRoiLabel <- ttklabel(multiFrame, text='Zoom to selected ROI')
	
	##create files button
	onFiles <- function(){
		rsf()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	filesButton <- ttkbutton(multiFrame, text='Files', width=8, command=onFiles)
	multiFileLabel <- ttklabel(multiFrame, text='Display selected files')
	
	##create subplot ROIs button
	subFrame <- ttklabelframe(selectFrame, text='Subplot Window', 
			padding=6)
	onSub <- function(){
		rs(3)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	subRoiButton <- ttkbutton(subFrame, text='ROIs', width=8, command=onSub)
	subRoiLabel <- ttklabel(subFrame, text='Activate/Deactivate ROI')
	
	##add widgets to selectFrame
	tkgrid(selButFrame, row=1, column=1, padx=20, pady=c(5, 0), sticky='nwe')
	tkgrid(allButton, row=2, column=1, padx=2)
	tkgrid(noneButton, row=2, column=2, padx=2)
	tkgrid(listButton, row=3, column=1, columnspan=2, pady=2, padx=2)
	
	tkgrid(mainFrame, row=2, column=1, padx=20, pady=c(5, 0), sticky='we')
	tkgrid(singleButton, row=1, column=1, padx=2, pady=c(0, 2))
	tkgrid(regionButton, row=1, column=2, padx=2, pady=c(0, 2))
	
	tkgrid(multiFrame, row=1, column=2, padx=c(0, 20), pady=c(5, 0), sticky='nwe')
	tkgrid(multiRoiButton, row=1, column=1, padx=2)
	tkgrid(multiRoiLabel, row=1, column=2, padx=4, sticky='w')
	tkgrid(filesButton, row=2, column=1, pady=2, padx=2)
	tkgrid(multiFileLabel, row=2, column=2, pady=2, padx=4, sticky='w')
	
	tkgrid(subFrame, row=2, column=2, padx=c(0, 20), pady=c(5, 0), sticky='we')
	tkgrid(subRoiButton, row=1, column=1, pady=c(0, 2), padx=2)
	tkgrid(subRoiLabel, row=1, column=2, pady=c(0, 2), padx=4, sticky='w')
	
	##make widgets a bit smaller on non-windows systems
	if (.Platform$OS.type != 'windows'){
		tkconfigure(multiRoiButton, width=6)
		tkconfigure(filesButton, width=6)
		tkconfigure(subRoiButton, width=6)
	}
	
	#####create widgets for dispFrame
	##create main plot display checkbox
	winFrame <- ttklabelframe(dispFrame, text='Windows', padding=3)
	mainVal <- tclVar(ifelse(globalSettings$roiMain, 1, 0))
	onMain <- function(){
		if (as.logical(as.integer(tclvalue(mainVal)))){
			setGraphics(roiMain=TRUE, save.backup=TRUE)
			refresh(sub.plot=FALSE, multi.plot=FALSE)
		}else{
			setGraphics(roiMain=FALSE, save.backup=TRUE)
			refresh(sub.plot = FALSE, multi.plot=FALSE)
		}
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	mainButton <- ttkcheckbutton(winFrame, variable=mainVal, command=onMain, 
			text='Main plot')
	
	##create subplot display checkbox
	subVal <- tclVar(ifelse(3 %in% dev.list(), 1, 0))
	onSub <- function(){
		if (as.logical(as.integer(tclvalue(subVal)))){
			rvs()
		}else{
			dev.off(3)
		}
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	subRoisButton <- ttkcheckbutton(winFrame, variable=subVal, command=onSub,
			text='Subplot')
	
	##create multiple file display checkbox
	multiVal <- tclVar(ifelse(4 %in% dev.list(), 1, 0))
	onMulti <- function(){
		if (as.logical(as.integer(tclvalue(multiVal)))){
			rvm()
		}else{
			dev.off(4)
		}
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	multiButton <- ttkcheckbutton(winFrame, variable=multiVal, command=onMulti,
			text='Multiple file')
	
	##create max intensity display checkbox
	maxVal <- tclVar(ifelse(globalSettings$roiMax, 1, 0))
	onMax<- function(){
		if (as.logical(as.integer(tclvalue(maxVal)))){
			setGraphics(roiMax=TRUE)
			refresh(main.plot=FALSE, overlay=FALSE)
		}else{
			setGraphics(roiMax=FALSE)
			refresh(main.plot=FALSE, overlay=FALSE)
		}
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	maxButton <- ttkcheckbutton(winFrame, variable=maxVal, command=onMax,
			text='ROI Maxima')
	
	##create appearance frame
	appFrame <- ttklabelframe(dispFrame, text='Appearance', padding=2)
	activeLabel <- ttklabel(appFrame, text='Active')
	inactiveLabel <- ttklabel(appFrame, text='Inactive')
	
	##create box type combo boxes
	ltyLabel <- ttklabel(appFrame, text='Box type:')
	altyVar <- tclVar(globalSettings$roi.lty[1])
	altyBox <- ttkcombobox(appFrame, textvariable=altyVar, width=8, 
			values=c('solid', 'dashed', 'dotted', 'dotdash', 'longdash', 'twodash', 
					'blank'), justify='center', exportselection=FALSE, state='readonly')
	iltyVar <- tclVar(globalSettings$roi.lty[2])
	iltyBox <- ttkcombobox(appFrame, textvariable=iltyVar, width=8, 
			values=c('solid', 'dashed', 'dotted', 'dotdash', 'longdash', 'twodash', 
					'blank'), justify='center', exportselection=FALSE, state='readonly')
	
	##create line width entry boxes
	boxColLabel <- ttklabel(appFrame, text='Box color:')
	aboxColVar <- tclVar(globalSettings$roi.bcolor[1])
	onActiveColor <- function(){
		usrColor <- tclvalue(tcl("tk_chooseColor", parent=dlg, 
						initialcolor=defaultSettings$roi.bcolor[1]))
		if (nzchar(usrColor)){
			tclvalue(aboxColVar) <- usrColor
			tkconfigure(aboxButton, bg=usrColor)
		}
	}
	aboxButton <- tkbutton(appFrame, width=10, text='', relief='raised', 
			borderwidth=2, bg=globalSettings$roi.bcolor[1], command=onActiveColor)
	iboxColVar <- tclVar(globalSettings$roi.bcolor[2])
	onInactiveColor <- function(){
		usrColor <- tclvalue(tcl("tk_chooseColor", parent=dlg, 
						initialcolor=defaultSettings$roi.bcolor[2]))
		if (nzchar(usrColor)){
			tclvalue(iboxColVar) <- usrColor
			tkconfigure(iboxButton, bg=usrColor)
		}
	}
	iboxButton <- tkbutton(appFrame, width=10, text='', relief='raised', 
			borderwidth=2, bg=globalSettings$roi.bcolor[2], command=onInactiveColor)
	
	##create text magnification entry boxes
	roiCexLabel <- ttklabel(appFrame, text='Magnification:')
	acexVar <- tclVar(globalSettings$roi.cex[1])
	acexEntry <- ttkentry(appFrame, textvariable=acexVar, width=11, 
			justify='center')
	icexVar <- tclVar(globalSettings$roi.cex[2])
	icexEntry <- ttkentry(appFrame, textvariable=icexVar, width=11, 
			justify='center')
	
	##create label horizontal adjustment entry box
	roiPosLabel <- ttklabel(appFrame, text='Label position:')
	roiPosVar <- tclVar(globalSettings$roi.labelPos[1])
	roiPosBox <- ttkcombobox(appFrame, textvariable=roiPosVar, width=8, 
			values=c('top', 'bottom', 'left', 'right', 'center'), 
			exportselection=FALSE, state='readonly')
	
	##create apply button
	onDispApply <- function(){
		setGraphics(roi.lty=c(tclvalue(altyVar), tclvalue(iltyVar)), 
				roi.bcolor=c(tclvalue(aboxColVar), tclvalue(iboxColVar)), 
				roi.cex=c(as.numeric(tclvalue(acexVar)), as.numeric(tclvalue(icexVar))),
				roi.labelPos=tclvalue(roiPosVar), refresh.graphics=TRUE)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	dispApplyButton <- ttkbutton(appFrame, text='Apply', width=11, 
			command=onDispApply)
	
	##add widgets to dispFrame
	tkgrid(winFrame, column=1, row=1, padx=c(20, 15), pady=c(3, 0), sticky='ns')
	tkgrid(mainButton, row=1, sticky='w', pady=6, padx=c(6, 4))
	tkgrid(subRoisButton, row=2, sticky='w', pady=6, padx=c(6, 4))
	tkgrid(multiButton, row=3, sticky='w', pady=6, padx=c(6, 4))
	tkgrid(maxButton, row=4, sticky='w', pady=6, padx=c(6, 4))
	
	tkgrid(appFrame, column=2, row=1, padx=c(0, 18), pady=c(3, 0), sticky='ns')
	tkgrid(activeLabel, column=2, row=1, pady=c(0, 1))
	tkgrid(inactiveLabel, column=3, row=1, pady=c(0, 1))
	
	tkgrid(ltyLabel, column=1, row=2, padx=3, pady=2, sticky='e')
	tkgrid(altyBox, column=2, row=2, padx=4, pady=2)
	tkgrid(iltyBox, column=3, row=2, padx=4, pady=2)
	
	tkgrid(boxColLabel, column=1, row=3, padx=3, pady=2, sticky='e')
	tkgrid(aboxButton, column=2, row=3, padx=4, pady=2)
	tkgrid(iboxButton, column=3, row=3, padx=4, pady=2)
	
	tkgrid(roiCexLabel, column=1, row=4, padx=3, pady=2, sticky='e')
	tkgrid(acexEntry, column=2, row=4, padx=4, pady=2)
	tkgrid(icexEntry, column=3, row=4, padx=4, pady=2)
	
	tkgrid(roiPosLabel, column=1, row=5, padx=3, pady=2, sticky='e')
	tkgrid(roiPosBox, column=2, row=5, padx=4, pady=c(2, 4))
	tkgrid(dispApplyButton, column=3, row=5, padx=c(4, 6), pady=c(8, 4))
	
	##make buttons a bit smaller on non-windows systems
	if (.Platform$OS.type != 'windows'){
		tkconfigure(aboxButton, width=5)
		tkconfigure(aboxButton, borderwidth=1)
		tkconfigure(iboxButton, width=5)
		tkconfigure(iboxButton, borderwidth=1)
		tkconfigure(acexEntry, width=10)
		tkconfigure(icexEntry, width=10)
		tkconfigure(dispApplyButton, width=9)
	}
	
	#####create widgets for autoFrame
	##configure roi size widgets
	onSize <- function(){
		
		##configure padding widgets
		if (tclvalue(fixedW1) != '0' && tclvalue(fixedW2) != '0')
			padState <- 'disabled'
		else
			padState <- 'normal'
		tkconfigure(roiPadLabel, state=padState)
		tkconfigure(roiPadEntry, state=padState)
		
		##configure w1 size widgets
		if (tclvalue(fixedW1) == '0'){
			w1State <- 'disabled'
			tclObj(roiW1Var) <- 0
		}else
			w1State <- 'normal'
		tkconfigure(roiW1Entry, state=w1State)
		
		##configure w2 size widgets
		if (tclvalue(fixedW2) == '0'){
			w2State <- 'disabled'
			tclObj(roiW2Var) <- 0
		}else
			w2State <- 'normal'
		tkconfigure(roiW2Entry, state=w2State)
	}
	
	##create ROI fixed w1 size checkbutton
	sizeFrame <- ttklabelframe(autoFrame, text='ROI size', padding=4)
	if (globalSettings$roi.w1 == 0){
		fixedW1 <- tclVar(0)
		w1State <- 'disabled'
	}else{
		fixedW1 <- tclVar(1)
		w1State <- 'normal'
	}
	roiW1Button <- ttkcheckbutton(sizeFrame, variable=fixedW1, text='Fixed w1:', 
			command=onSize)	
	
	##create ROI fixed w2 size checkbutton
	if (globalSettings$roi.w2 == 0){
		fixedW2 <- tclVar(0)
		w2State <- 'disabled'
	}else{
		fixedW2 <- tclVar(1)
		w2State <- 'normal'
	}
	roiW2Button <- ttkcheckbutton(sizeFrame, variable=fixedW2, text='Fixed w2:', 
			command=onSize)	
	
	##create w1 size entry box
	roiW1Var <- tclVar(globalSettings$roi.w1)
	roiW1Entry <- ttkentry(sizeFrame, textvariable=roiW1Var, width=9, 
			justify='center', state=w1State)
	
	##create w2 size entry box
	roiW2Var <- tclVar(globalSettings$roi.w2)
	roiW2Entry <- ttkentry(sizeFrame, textvariable=roiW2Var, width=9, 
			justify='center', state=w2State)
	
	##create w2 size entry box
	if (globalSettings$roi.w1 && globalSettings$roi.w2)
		padState <- 'disabled'
	else
		padState <- 'normal'
	roiPadLabel <- ttklabel(sizeFrame, text='Padding (%):', state=padState)
	roiPadVar <- tclVar(globalSettings$roi.pad)
	roiPadEntry <- ttkentry(sizeFrame, textvariable=roiPadVar, width=9, 
			justify='center', state=padState)
	
	##creates noise filter radio buttons
	filtFrame <- ttklabelframe(autoFrame, text='Noise filter', padding=4)
	roiFiltVar <- tclVar(globalSettings$roi.noiseFilt)
	strongButton <- ttkradiobutton(filtFrame, variable=roiFiltVar, value=2, 
			text='Strong (default)', command=function(...) 
				setGraphics(roi.noiseFilt=2, save.backup=FALSE))
	mildButton <- ttkradiobutton(filtFrame, variable=roiFiltVar, value=1, 
			text='Mild', command=function(...) 
				setGraphics(roi.noiseFilt=1, save.backup=FALSE))
	offButton <- ttkradiobutton(filtFrame, variable=roiFiltVar, value=0, 
			text='Off (not recommended)', command=function(...) 
				setGraphics(roi.noiseFilt=0, save.backup=FALSE))
	
	##create apply button
	onAutoApply <- function(){
		setGraphics(roi.w1=as.numeric(tclvalue(roiW1Var)), 
				roi.w2=as.numeric(tclvalue(roiW2Var)),
				roi.pad=as.numeric(tclvalue(roiPadVar)), refresh.graphics=TRUE)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	autoApplyButton <- ttkbutton(sizeFrame, text='Apply', width=13,
			command=onAutoApply)
	
	##create auto button
	onAuto <- function(){
		ra()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	autoButton <- ttkbutton(autoFrame, text='Auto ROI', width=13, command=onAuto)
	
	##add widgets to autoFrame
	tkgrid(sizeFrame, column=1, row=1, rowspan=2, padx=c(35, 15), pady=c(5, 0), 
			sticky='ns')
	tkgrid(roiW1Button, column=1, row=1, padx=4, pady=4)
	tkgrid(roiW1Entry, column=2, row=1, padx=4, pady=4)
	
	tkgrid(roiW2Button, column=1, row=2, padx=4, pady=4)
	tkgrid(roiW2Entry, column=2, row=2, padx=4, pady=4)
	
	tkgrid(roiPadLabel, column=1, row=3, padx=4, pady=4)
	tkgrid(roiPadEntry, column=2, row=3, padx=4, pady=4)
	
	tkgrid(autoApplyButton, column=1, columnspan=2, row=4, pady=4)
	
	tkgrid(filtFrame, column=2, row=1, padx=c(0, 35), pady=c(5, 0), sticky='n')
	tkgrid(strongButton, column=1, row=1, padx=4, pady=4, sticky='w')
	tkgrid(mildButton, column=1, row=2, padx=4, pady=4, sticky='w')
	tkgrid(offButton, column=1, row=3, padx=4, pady=4, sticky='w')
	
	tkgrid(autoButton, column=2, row=2, padx=c(0, 35), pady=c(10, 0))
	
	#####create widgets for sumFrame
	##create file selection radiobuttons
	sumSelFrame <- ttkframe(sumFrame)
	sumFilesFrame <- ttklabelframe(sumSelFrame, text='Files')
	filesRbVal <- tclVar('Active')
	allFilesButton <- ttkradiobutton(sumFilesFrame, variable=filesRbVal, 
			value='All', text='All', command=function(...) tclvalue(normList) <- '')
	noneFilesButton <- ttkradiobutton(sumFilesFrame, variable=filesRbVal, 
			value='Active', text='Active', command=function(...) 
				tclvalue(normList) <- '')
	customFiles <- tclVar('')
	onCustomFiles <- function(){
		if (!is.null(roiSummary))
			prevFiles <- roiSummary$data$File
		else
			prevFiles <- ''
		usrSel <- mySelect(getTitles(names(fileFolder), FALSE), preselect=prevFiles, 
				multiple=TRUE, index=TRUE, title='Select summary files:')
		if (nzchar(usrSel[1]))
			tclvalue(customFiles) <- names(fileFolder)[usrSel]
		else
			tclvalue(filesRbVal) <- 'Active'
		tclvalue(normList) <- ''
	}
	customFilesButton <- ttkradiobutton(sumFilesFrame, variable=filesRbVal, 
			value='Custom', text='Custom', command=onCustomFiles)
	
	##create ROI selection radiobuttons
	sumRoisFrame <- ttklabelframe(sumSelFrame, text='ROIs')
	roisRbVal <- tclVar('Active')
	allRoisButton <- ttkradiobutton(sumRoisFrame, variable=roisRbVal, 
			value='All', text='All', command=function(...) tclvalue(normList) <- '')
	noneRoisButton <- ttkradiobutton(sumRoisFrame, variable=roisRbVal, 
			value='Active', text='Active', command=function(...) 
				tclvalue(normList) <- '')
	customRois <- tclVar('')
	onCustomRois <- function(){
		if (!is.null(roiSummary))
			prevRois <- names(roiSummary$data)[-1]
		else
			prevRois <- ''
		usrSel <- mySelect(roiTable$Name, title='Select summary ROIs:', 
				multiple=TRUE, preselect=prevRois)
		if (nzchar(usrSel[1]))
			tclvalue(customRois) <- usrSel
		else
			tclvalue(roisRbVal) <- 'Active'
		tclvalue(normList) <- ''
	}
	customRoisButton <- ttkradiobutton(sumRoisFrame, variable=roisRbVal, 
			value='Custom', text='Custom', command=onCustomRois)
	
	##create generate summary button
	onGen <- function(){
		
		##get summary files
		if (tclvalue(filesRbVal) == 'All')
			sumFiles <- names(fileFolder)
		else if (tclvalue(filesRbVal) == 'Active')
			sumFiles <- names(fileFolder)[sapply(fileFolder, function(x) 
								x$graphics.par$roi.multi)]
		else
			sumFiles <- as.character(tclObj(customFiles))
		if (!length(sumFiles) || !nzchar(sumFiles[1]))
			err('One or more files must be included in the summary')
		
		##get summary ROIs
		if (tclvalue(roisRbVal) == 'All')
			sumRois <- roiTable$Name
		else if (tclvalue(roisRbVal) == 'Active')
			sumRois <- roiTable$Name[roiTable$ACTIVE]
		else
			sumRois <- as.character(tclObj(customRois))
		if (!length(sumRois) || !nzchar(sumRois[1]))
			err('One or more ROIs must be included in the summary')
		
		##get summary type
		sumType <- tclvalue(sumTypeVar)
		sumType <- switch(sumType, 'maximum'='maximum', 'absolute max'='absMax', 
				'minimum'='minimum', 'area'='area', 'absolute area'='absArea', 
				'w1 shift'='w1', 'w2 shift'='w2', 'custom'='custom')
		
		##get normalization type and source
		normType <- tclvalue(normTypeVar)
		normType <- switch(normType, 'none'='none', 'internal'='internal', 
				'across spectra'='crossSpec', 'signal to noise'='signal/noise', 
				'constant sum'='sum')
		normList <- as.character(tclObj(normList))
		if (!length(normList) || !nzchar(normList[1]))
			normList <- NA
		if (normType == 'internal' && is.na(normList))
			err('One or more ROIs must be added to the normalization list')
		if (normType == 'crossSpec'){
			if (is.na(normList[1]))
				err('One or more files must be added to the normalization list')
			normList <- names(fileFolder)[match(normList, getTitles(names(fileFolder), 
									FALSE))]
		}
		
		##generate summary
		rSum(FALSE, sumFiles, sumRois, sumType, normType, normList)
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	genButton <- ttkbutton(sumSelFrame, text='Generate Summary', width=17, 
			command=onGen)
	
	##create summary type combobox
	middleFrame <- ttkframe(sumFrame)
	sumTypeLabel <- ttklabel(middleFrame, text='Type:')
	if (is.null(roiSummary))
		sumType <- 'maximum'
	else
		sumType <- switch(roiSummary$summary.par$summary.type, 'maximum'='maximum', 
				'absMax'='absolute max', 'minimum'='minimum', 'area'='area', 
				'absArea'='absolute area', 'w1'='w1 shift', 'w2'='w2 shift', 
				'custom'='custom')
	sumTypeVar <- tclVar(sumType)
	sumTypeBox <- ttkcombobox(middleFrame, textvariable=sumTypeVar, width=13, 
			values=c('maximum', 'absolute max', 'minimum', 'area', 'absolute area', 
					'w1 shift', 'w2 shift', 'custom'), exportselection=FALSE, 
			state='readonly')
	onSumType <- function(){
		sumType <- tclvalue(sumTypeVar)
		if (sumType == 'w1 shift' || sumType == 'w2 shift'){
			tclObj(normTypeVar) <- 'none'
			tkconfigure(normTypeBox, state='disabled')
			tclObj(normList) <- ''
		}else
			tkconfigure(normTypeBox, state='readonly')
		configNorm()
	}
	tkbind(sumTypeBox, '<<ComboboxSelected>>', onSumType) 
	
	##create nomalization type combobox
	normTypeLabel <- ttklabel(middleFrame, text='Normalization:')
	if (is.null(roiSummary))
		normType <- 'none'
	else{
		normType <- roiSummary$summary.par$normalization
		normType <- switch(normType, 'none'='none', 'internal'='internal', 
				'crossSpec'='across spectra', 'signal/noise'='signal to noise', 
				'sum'='constant sum')
	}
	normTypeVar <- tclVar(normType)
	normTypeBox <- ttkcombobox(middleFrame, textvariable=normTypeVar, width=13, 
			values=c('none', 'internal', 'across spectra', 'signal to noise', 
					'constant sum'), exportselection=FALSE, state='readonly')
	configNorm <- function(){
		normType <- tclvalue(normTypeVar)
		if (normType == 'internal' || normType == 'across spectra')
			state <- 'normal'
		else
			state <- 'disabled'
		configList <- list(normBox, normAddBut, normRmBut)
		for (i in configList)
			tkconfigure(i, state=state)
	}
	onNormType <- function(){
		configNorm()
		tclObj(normList) <- ''
	}
	tkbind(normTypeBox, '<<ComboboxSelected>>', onNormType) 
	
	##create edit summary button
	onEditSum <- function(){
		se()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	editSumButton <- ttkbutton(middleFrame, text='Edit Summary', width=14, 
			command=onEditSum)
	
	##create normalization list box
	normFrame <- ttklabelframe(sumFrame, text='Normalization ROI/Files')
	normList <- tclVar()
	if (is.null(roiSummary))
		normNames <- ''
	else{
		if (is.na(roiSummary$summary.par$norm.data.source[1]))
			normNames <- ''
		else
			normNames <- roiSummary$summary.par$norm.data.source
	}
	tclObj(normList) <- normNames
	normBox <- tklistbox(normFrame, height=6, width=15, listvariable=normList, 
			selectmode='extended', active='dotbox',	exportselection=FALSE, bg='white', 
			xscrollcommand=function(...) tkset(normXscr, ...), 
			yscrollcommand=function(...) tkset(normYscr, ...))
	normXscr <- ttkscrollbar(normFrame, orient='horizontal',
			command=function(...) tkxview(normBox, ...))
	normYscr <- ttkscrollbar(normFrame, orient='vertical', 
			command=function(...) tkyview(normBox, ...))
	
	##create normalization file/ROI add button
	normButFrame <- ttkframe(normFrame)
	onNormAdd <- function(){
		
		##find ROIs/files that are not already being used for normalization
		if (is.null(roiTable))
			err(paste('One or more ROIs must be created before a summary can be',
							'generated'))
		currNorms <- as.character(tclObj(normList))
		if (any(!nzchar(currNorms)))
			currNorms <- currNorms[-which(!nzchar(currNorms))]
		if (tclvalue(normTypeVar) == 'internal'){
			if (length(currNorms) == nrow(roiTable))
				err('All available ROIs have already been selected')
			if (tclvalue(roisRbVal) == 'All')
				nonSumNorms <- roiTable$Name
			else if (tclvalue(roisRbVal) == 'Active')
				nonSumNorms <- roiTable$Name[roiTable$ACTIVE]
			else
				nonSumNorms <- as.character(tclObj(customRois))
		}else{
			if (length(currNorms) == length(names(fileFolder)))
				err('All currently opened files have already been selected')
			if (tclvalue(filesRbVal) == 'All')
				nonSumNorms <- getTitles(names(fileFolder), FALSE)
			else if (tclvalue(filesRbVal) == 'Active')
				nonSumNorms <- getTitles(names(fileFolder), FALSE)[sapply(fileFolder, 
								function(x) x$graphics.par$roi.multi)]
			else
				nonSumNorms <- getTitles(names(fileFolder), 
						FALSE)[match(as.character(tclObj(customFiles)), names(fileFolder))]
		}
		if (!length(currNorms) || !nzchar(currNorms))
			currNorms <- NULL
		if (!is.null(currNorms)){
			normMatches <- match(currNorms, nonSumNorms)
			if (!is.na(normMatches)[1])
				nonSumNorms <- nonSumNorms[-normMatches]
		}
		
		##ask user which ROIs/files to add
		newNorms <- mySelect(nonSumNorms, title='Normalization', multiple=TRUE)	
		if (!nzchar(newNorms[1]))
			return(invisible())
		tclObj(normList) <- sort(c(currNorms, newNorms))
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	normAddBut <- ttkbutton(normButFrame, text='Add', width=9, command=onNormAdd)
	
	##create normalization file/ROI remove button
	onNormRemove <- function(){
		usrSel <- 1 + as.integer(tkcurselection(normBox))
		if (length(usrSel))
			tclObj(normList) <- as.character(tclObj(normList))[-usrSel]
	}
	normRmBut <- ttkbutton(normButFrame, text='Remove', width=9, 
			command=onNormRemove)
	configNorm()
	
	##add widgets to sumFrame
	tkgrid(sumSelFrame, column=1, row=1, sticky='nswe', padx=6)
	tkgrid(sumFilesFrame, column=1, row=1, padx=c(0, 6), pady=5)
	tkgrid(allFilesButton, column=1, row=1, pady=4, sticky='w')
	tkgrid(noneFilesButton, column=1, row=2, pady=8, sticky='w')
	tkgrid(customFilesButton, column=1, row=3, pady=4, sticky='w')
	
	tkgrid(sumRoisFrame, column=2, row=1, pady=5)
	tkgrid(allRoisButton, column=1, row=1, pady=4, sticky='w')
	tkgrid(noneRoisButton, column=1, row=2, pady=8, sticky='w')
	tkgrid(customRoisButton, column=1, row=3, pady=4, sticky='w')
	tkgrid(genButton, column=1, columnspan=2, row=2, pady=c(8, 0))
	
	tkgrid(middleFrame, column=2, row=1, sticky='we', padx=4)
	tkgrid(sumTypeLabel, column=1, row=1, sticky='w', pady=c(8, 0))
	tkgrid(sumTypeBox, column=1, row=2, pady=c(0, 8))
	tkgrid(normTypeLabel, column=1, row=3, sticky='w')
	tkgrid(normTypeBox, column=1, row=4)
	tkgrid(editSumButton, column=1, row=5, pady=c(25, 0))
	
	tkgrid(normFrame, column=3, row=1, sticky='nswe', padx=6)
	tkgrid(normBox, column=1, row=1, sticky='nswe', padx=c(2, 0))
	tkgrid(normYscr, column=2, row=1, sticky='ns', padx=c(0, 2))
	tkgrid(normXscr, column=1, row=2, sticky='we')
	tkgrid(normButFrame, column=1, columnspan=2, row=3, pady=5)
	tkgrid(normAddBut, column=1, row=1, padx=2)
	tkgrid(normRmBut, column=3, row=1, padx=2)
	
	##make listboxes stretch when window is resized
	tkgrid.columnconfigure(sumFrame, 3, weight=1)
	tkgrid.rowconfigure(sumFrame, 1, weight=1)
	tkgrid.columnconfigure(normFrame, 1, weight=1)
	tkgrid.rowconfigure(normFrame, 1, weight=1)
	
	##make widgets a bit smaller on non-windows systems
	if (.Platform$OS.type != 'windows'){
		tkconfigure(sumTypeBox, width=11)
		tkconfigure(normTypeBox, width=11)
		tkconfigure(genButton, width=15)
		tkconfigure(editSumButton, width=12)
		tkconfigure(normBox, width=9)
		tkconfigure(normAddBut, width=9)
		tkconfigure(normRmBut, width=9)
	}
	
	##updates display options whenever the mouse enters the GUI
	onMouse <- function(){
		tclObj(mainVal) <- ifelse(globalSettings$roiMain, 1, 0)
		tclObj(subVal) <- ifelse(3 %in% dev.list(), 1, 0)
		tclObj(multiVal) <- ifelse(4 %in% dev.list(), 1, 0)
		tclObj(maxVal) <- ifelse(globalSettings$roiMax, 1, 0)
	}
	tkbind(dlg, '<Enter>', onMouse)
	tkbind(dlg, '<FocusIn>', onMouse)
	
	##allows user to press the "Enter" key to make selections
	tkbind(dlg, '<Return>', function(...) tryCatch(tkinvoke(tkfocus()), 
						error=function(er){}))
	
	return(invisible())
}

## Interactive GUI for zooming and scrolling
zm <- function(){
	
	##Checks for open files
	wc()
	
	##creates main window
	tclCheck()
	dlg <- myToplevel('zm', pady=2, padx=4)
	if (is.null(dlg))
		return(invisible())
	tkwm.title(dlg, 'Zoom')
	tkwm.resizable(dlg, FALSE, FALSE)
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##create radiobuttons
	leftFrame <- ttkframe(dlg)
	radioFrame <- ttkframe(leftFrame)
	rbVal <- tclVar('zoom')
	onZoom <- function(){
		tkconfigure(upButton, text='In')
		tkconfigure(downButton, text='Out')
		tkconfigure(leftButton, state='disabled')
		tkconfigure(rightButton, state='disabled')
		tkfocus(arrowFrame)
	}
	zoomButton <- ttkradiobutton(radioFrame, variable=rbVal, value='zoom', 
			text='zoom', command=onZoom)
	
	onScroll <- function(){
		tkconfigure(upButton, text='^')
		tkconfigure(downButton, text='v')
		tkconfigure(leftButton, text='<', state='normal')
		tkconfigure(rightButton, text='>', state='normal')
		tkfocus(arrowFrame)
	}
	scrollButton <- ttkradiobutton(radioFrame, variable=rbVal, value='scroll', 
			text='scroll', command=onScroll)
	
	##create arrow buttons
	arrowFrame <- ttkframe(leftFrame)
	inc <- tclVar(20)
	onArrow <- function(type, direct, n){
		type=tclvalue(type)
		tryCatch({n <- as.numeric(tclvalue((inc)))
					if (n < 0)
						warning()
				}, warning = function(w){
					err('Increment value must be a positive number', parent=dlg)
				})
		if (type == 'scroll'){
			switch(direct, 'up'=pu(n), 
					'down'=pd(n), 
					'left'=pl(n), 
					'right'=pr(n))
		}else{
			switch(direct, 'up'=zi(n), 'down'=zo(n)) 
		}	
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	upButton <- ttkbutton(arrowFrame, text='In', width=5, command=function(...) 
				onArrow(rbVal, 'up', inc))
	downButton <- ttkbutton(arrowFrame, text='Out', width=5, command=function(...)
				onArrow(rbVal, 'down', inc))
	leftButton <- ttkbutton(arrowFrame, text='<', width=4, state='disabled', 
			command=function(...) onArrow(rbVal, 'left', inc))
	rightButton <- ttkbutton(arrowFrame, text='>', width=4, state='disabled', 
			command=function(...) onArrow(rbVal, 'right', inc))
	editEntry <- ttkentry(arrowFrame, textvariable=inc, width=5, justify='center')
	
	##create other zoom buttons
	rightFrame <- ttkframe(dlg)
	onFf <- function(){
		ff()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	ffButton <- ttkbutton(rightFrame, text='Full', width=8, command=onFf)
	
	onZc <- function(){
		zc()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	zcButton <- ttkbutton(rightFrame, text='Center', width=8, command=onZc)
	
	onZz <- function(){
		zz()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	zzButton <- ttkbutton(rightFrame, text='Hand', width=8, command=onZz)
	
	onPz <- function(){
		pz()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	pzButton <- ttkbutton(rightFrame, text='Point', width=8, command=onPz)
	
	onZp <- function(){
		zp()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	zpButton <- ttkbutton(rightFrame, text='Prev', width=8, command=onZp)
	
	onLoc <- function(){
		hideGui()
		usrLoc <- mySelect(c('Chemical Shift', 'Region Maximum', 'Delta in PPM/Hz'), 
				title = 'Measure:', parent=dlg)
		if (!nzchar(usrLoc)){
			showGui()
			return(invisible())
		}
		if (usrLoc == 'Chemical Shift')
			loc()
		else if (usrLoc == 'Region Maximum'){
			tryCatch(shift <- regionMax(currentSpectrum), 
					error=function(er){
						showGui()
						refresh(multi.plot=FALSE, sub.plot=FALSE)
						stop('Shift not defined', call.=FALSE)})
			showGui()
			if (is.null(shift)){
				refresh(multi.plot=FALSE, sub.plot=FALSE)
				stop('Shift not defined', call.=FALSE)
			}
			rownames(shift) <- NULL
			print(shift)
		}else
			delta()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	locButton <- ttkbutton(rightFrame, text='Get shifts', width=8, command=onLoc)
	
	##add widgets to leftFrame
	tkgrid(leftFrame, column=1, row=1, padx=c(0, 4))
	tkgrid(radioFrame, column=1, columnspan=3, row=1)
	tkgrid(zoomButton, column=1, row=1, padx=3)
	tkgrid(scrollButton, column=2, row=1)
	
	tkgrid(arrowFrame, column=1, columnspan=3, row=2)
	tkgrid(upButton, column=2, row=1, sticky='s', pady=c(2, 0))
	tkgrid(leftButton, column=1, row=2, sticky='e')
	tkgrid(editEntry, column=2, row=2)
	tkgrid(rightButton, column=3, row=2, sticky='w')
	tkgrid(downButton, column=2, row=3, sticky='n', pady=c(0, 4))
	
	##add widgets to rightFrame
	tkgrid(rightFrame, column=2, row=1)
	tkgrid(ffButton, column=1, row=1, pady=c(4, 2), padx=2)
	tkgrid(pzButton, column=2, row=1, pady=c(4, 2))
	tkgrid(zcButton, column=1, row=2, pady=2, padx=2)
	tkgrid(zpButton, column=2, row=2, pady=2)
	tkgrid(zzButton, column=1, row=3, pady=2, padx=2)
	tkgrid(locButton, column=2, row=3, pady=2)
	tkbind(dlg, '<Return>', function(...) tryCatch(tkinvoke(tkfocus()), 
						error=function(er){}))
	
	invisible()
}

##Interactive GUI for peak picking multiple files
pp <- function(){
	
	current <- wc()
	
	##creates main window
	tclCheck()
	dlg <- myToplevel('pp')
	if (is.null(dlg))
		return(invisible())
	pdisp()
	tkwm.title(dlg, 'Peaks')
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	setGraphics(peak.disp=TRUE, save.backup=FALSE)
	
	##create file list box
	fileFrame <- ttklabelframe(dlg, text='Files')
	fileList <- tclVar()
	fileNames <- names(fileFolder)
	tclObj(fileList) <- getTitles(fileNames)
	fileBox <- tklistbox(fileFrame, height=10, width=34, listvariable=fileList, 
			selectmode='extended', active='dotbox',	exportselection=FALSE, bg='white', 
			xscrollcommand=function(...) tkset(xscr, ...), 
			yscrollcommand=function(...) tkset(yscr, ...))
	xscr <- ttkscrollbar(fileFrame, orient='horizontal',
			command=function(...) tkxview(fileBox, ...))
	yscr <- ttkscrollbar(fileFrame, orient='vertical', 
			command=function(...) tkyview(fileBox, ...))
	if (length(fileNames) > 2){
		for (i in seq(0, length(fileNames) - 1, 2))
			tkitemconfigure(fileBox, i, background='#ececff')
	}
	tkselection.set(fileBox, current - 1)
	tcl(fileBox, 'see', current - 1)
	
	##switches spectra on left-mouse double-click
	onDouble <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		if (length(usrSel))
			usrFile <- fileNames[usrSel]
		else
			usrFile <- NULL
		if (!is.null(usrFile) && currentSpectrum != usrFile){
			currentSpectrum <- usrFile
			myAssign('currentSpectrum', currentSpectrum)
			refresh(multi.plot=FALSE)
			configGui()
			tkwm.deiconify(dlg)
			tkfocus(fileBox)
		}
	}
	tkbind(fileBox, '<Double-Button-1>', onDouble)
	
	##creates peak display radio buttons
	optionFrame <- ttkframe(dlg)
	dispFrame <- ttklabelframe(optionFrame, text='Peak display', padding=2)
	dispVal <- tclVar(TRUE)
	onOn <- function(save=FALSE){
		setGraphics(peak.disp=TRUE, save.backup=save)
		pdisp()
		configGui()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	onButton <- ttkradiobutton(dispFrame, variable=dispVal, value=TRUE, 
			text='On', command=function(...) onOn(TRUE))
	
	onOff <- function(){
		setGraphics(peak.disp=FALSE)
		refresh(sub.plot=FALSE, multi.plot=FALSE)
		configGui()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	offButton <- ttkradiobutton(dispFrame, variable=dispVal, value=FALSE, 
			text='Off', command=onOff)
	
	##create peak color button
	onPeakCol <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		if (length(usrSel))
			usrFiles <- fileNames[usrSel]	
		else
			usrFiles <- currentSpectrum
		changeColor(dlg, 'peak', usrFiles)
	}
	peakColButton <- ttkbutton(dispFrame, text='Color', width=8, 
			command=onPeakCol)
	
	##creates noise filter radio buttons
	filtFrame <- ttklabelframe(optionFrame, text='Noise filter', padding=2)
	filtVal <- tclVar(globalSettings$peak.noiseFilt)
	onFiltOff <- function(){
		nf(0)
		onOn()
	}
	filtOffButton <- ttkradiobutton(filtFrame, variable=filtVal, value=0, 
			text='Off', command=onFiltOff)
	
	onMild <- function(){
		nf(1)
		onOn()
	}
	mildButton <- ttkradiobutton(filtFrame, variable=filtVal, value=1, 
			text='Mild', command=onMild)
	
	onStrong <- function(){
		nf(2)
		onOn()
	}
	strongButton <- ttkradiobutton(filtFrame, variable=filtVal, value=2, 
			text='Strong', command=onStrong)
	
	##create minimum threshold text box
	threshFrame <- ttklabelframe(optionFrame, text='1D threshold', padding=2)
	entryFrame <- ttkframe(threshFrame)
	threshVal <- tclVar(globalSettings$thresh.1D)
	threshEntry <- ttkentry(entryFrame, width=6, textvariable=threshVal)
	entryLab <- ttklabel(entryFrame, text='standard deviations')
	
	##create apply button
	onApply <- function(){
		threshVal <- suppressWarnings(as.numeric(tclObj(threshVal)))
		setGraphics(thresh.1D=threshVal)
		refresh(sub.plot=FALSE, multi.plot=FALSE)
		tkinvoke(onButton)
	}
	apply <- ttkbutton(threshFrame, text='Apply', width=10, command=onApply)
	
	##create default button
	onDefault <- function(){
		tclObj(threshVal) <- defaultSettings$thresh.1D
		onApply()
	}
	default <- ttkbutton(threshFrame, text='Default', width=10, command=onDefault)
	
	##creates peak pick full spectrum button
	pickFrame <- ttklabelframe(optionFrame, text='Peak pick', padding=2)
	onFull <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		if (!length(usrSel))
			usrFiles <- currentSpectrum
		else
			usrFiles <- names(fileFolder)[usrSel]
		pa(fileName=usrFiles)
		onOn()
	}
	fullButton <- ttkbutton(pickFrame, text='Full', width=10, command=onFull)
	
	##creates peak pick window button
	onReg <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		if (!length(usrSel))
			usrFiles <- currentSpectrum
		else
			usrFiles <- names(fileFolder)[usrSel]
		usr <- mySelect(c('Entire region', 'Maximum'), multiple=FALSE, 
				title='Peak pick:',	preselect='Entire region', parent=dlg)
		if (length(usr) == 0 || !nzchar(usr))
			return(invisible())
		else if (usr == 'Entire region')
			pReg(fileName=usrFiles)
		else
			pm(fileName=usrFiles)
		onOn()
	}
	regButton <- ttkbutton(pickFrame, text='Region', width=10, command=onReg)
	
	##creates peak pick ROI button
	onRoi<- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		if (!length(usrSel))
			usrFiles <- currentSpectrum
		else
			usrFiles <- names(fileFolder)[usrSel]
		rp(fileName=usrFiles, parent=dlg)
		onOn()
	}
	roiButton <- ttkbutton(pickFrame, text='ROI', width=10, command=onRoi)
	
	##creates manual pick button
	onHand <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		usrFiles <- names(fileFolder)[usrSel]
		if (length(usrSel) > 1 || usrFiles != currentSpectrum){
			myMsg('Manual peak picking is applied to the current spectrum only', 
					icon='info', parent=dlg)
			tkselection.clear(fileBox, 0, 'end')
			tkselection.set(fileBox, match(currentSpectrum, names(fileFolder)) - 1)
		}
		ph()
		onOn()
	}
	handButton <- ttkbutton(pickFrame, text='Hand', width=10, command=onHand)
	
	##creates list edit button
	listFrame <- ttklabelframe(optionFrame, text='Peak list', padding=2)
	onEdit<- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		usrFiles <- names(fileFolder)[usrSel]
		if (length(usrFiles) > 1 || usrFiles != currentSpectrum){
			myMsg('Changes will be applied to the current spectrum only', icon='info', 
					parent=dlg)
			tkselection.clear(fileBox, 0, 'end')
			tkselection.set(fileBox, match(currentSpectrum, names(fileFolder)) - 1)
		}
		pe()
		onOn()
	}
	listButton <- ttkbutton(listFrame, text='Edit', width=10, command=onEdit)
	
	##creates clear button
	onClear <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		if (!length(usrSel))
			usrFiles <- currentSpectrum
		else
			usrFiles <- names(fileFolder)[usrSel]
		peakDel(fileName=usrFiles)
		onOn()
	}
	clearButton <- ttkbutton(listFrame, text='Clear', width=10, command=onClear)
	
	##creates import button
	onImport <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		if (length(usrSel) > 1 || names(fileFolder)[usrSel] != currentSpectrum)
			myMsg('List will only be imported to the current spectrum', icon='info',
					parent=dlg)
		import('Peak list')
		onOn()
	}
	importButton <- ttkbutton(listFrame, text='Import', width=10, command=onImport)
	
	##creates export button
	onExport <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		if (is.null(fileFolder[[wc()]]$peak.list))
			err('A peak list does not exist for the current spectrum.')
		if (length(usrSel) > 1 || names(fileFolder)[usrSel] != currentSpectrum)
			myMsg('Only the peak list for the current spectrum will be exported', 
					icon='info', parent=dlg)
		export('Peak list')
		onOn()
	}
	exportButton <- ttkbutton(listFrame, text='Export', width=10, command=onExport)
	mmcdButton <- ttkbutton(listFrame, text='MMCD homepage', width=17, 
			command=function() mmcd())
	
	##creates undo button
	onUndo<- function(){
		ud()
		onMouse()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	undoButton <- ttkbutton(optionFrame, text='Undo', width=11, command=onUndo)
	
	##creates redo button
	onRedo<- function(){
		rd()
		onMouse()
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		bringFocus()
	}
	redoButton <- ttkbutton(optionFrame, text='Redo', width=11, command=onRedo)
	
	##add widgets to fileFrame
	tkgrid(fileFrame, column=1, row=1, sticky='nswe', pady=c(6, 0),	padx=8)
	tkgrid(fileBox, column=1, row=1, sticky='nswe')
	tkgrid(yscr, column=2, row=1, sticky='ns')
	tkgrid(xscr, column=1, row=2, sticky='we')
	
	##make fileFrame stretch when window is resized
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=10)
	tkgrid.columnconfigure(fileFrame, 1, weight=1)
	tkgrid.rowconfigure(fileFrame, 1, weight=1)
	
	##add widgets to optionFrame
	tkgrid(optionFrame, column=2, row=1, sticky='nswe', pady=c(9, 5), 
			padx=c(3, 8))
	tkgrid(dispFrame, column=1, columnspan=3, row=1, sticky='we', pady=c(0, 2))
	tkgrid(onButton, column=1, row=1)
	tkgrid(offButton, column=2, row=1, padx=c(3, 8))
	tkgrid(peakColButton, column=3, row=1)
	
	tkgrid(filtFrame, column=1, columnspan=2, row=2, sticky='we', pady=2)
	tkgrid(filtOffButton, column=1, row=1, sticky='w')
	tkgrid(mildButton, column=2, row=1, padx=4, sticky='w')
	tkgrid(strongButton, column=3, row=1, sticky='w')
	
	tkgrid(threshFrame, column=1, columnspan=2, row=3, sticky='we', pady=2)
	tkgrid(entryFrame, column=1, columnspan=2, row=1, pady=c(0, 2))
	tkgrid(threshEntry, column=1, row=1)
	tkgrid(entryLab, column=2, row=1, sticky='w')
	tkgrid(apply, column=1, row=2, sticky='w')
	tkgrid(default, column=2, row=2, padx=4)
	
	tkgrid(pickFrame, column=1, columnspan=2, row=4, sticky='we', pady=2)
	tkgrid(fullButton, column=1, row=1)
	tkgrid(regButton, column=2, row=1, padx=c(3, 0))
	tkgrid(roiButton, column=1, row=2, pady=2)
	tkgrid(handButton, column=2, row=2, padx=c(3, 0), pady=2)
	
	tkgrid(listFrame, column=1, columnspan=2, row=5, sticky='we', pady=2)
	tkgrid(listButton, column=1, row=1)
	tkgrid(clearButton, column=2, row=1, padx=c(3, 0))
	tkgrid(importButton, column=1, row=2, pady=2)
	tkgrid(exportButton, column=2, row=2, padx=c(3, 0), pady=2)
	tkgrid(mmcdButton, column=1, columnspan=2, row=3, pady=2)
	
	tkgrid(undoButton, column=1, row=6, pady=c(6, 0))
	tkgrid(redoButton, column=2, row=6, padx=c(3, 0), pady=c(6, 0))
	
	##make optionFrame stretch when window is resized
	tkgrid.rowconfigure(optionFrame, 0, weight=1)
	tkgrid.rowconfigure(optionFrame, 7, weight=1)
	tkgrid(ttksizegrip(dlg), column=2, row=2, sticky='se')
	
	##reconfigures widgets in GUI according to which spectra are open
	configGui <- function(){
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		usrFiles <- names(fileFolder)[usrSel]
		configList <- list(threshEntry, entryLab, default, apply)
		if (!length(usrSel)){
			for (i in configList)
				tkconfigure(i, state='disabled')
		}else{
			oneD <- FALSE
			for (i in usrFiles){
				if (fileFolder[[i]]$file.par$number_dimensions == 1){
					oneD <- TRUE
					break
				}
			}
			if (oneD){
				for (i in configList)
					tkconfigure(i, state='normal')
			}else{
				for (i in configList)
					tkconfigure(i, state='disabled')
			}
		}
		tclObj(dispVal) <- globalSettings$peak.disp
		tclObj(filtVal) <- globalSettings$peak.noiseFilt
		tclObj(threshVal) <- globalSettings$thresh.1D
	}
	configGui()	
	tkbind(fileBox, '<<ListboxSelect>>', configGui)
	
	##Allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (focus == '.pp.1.1')
			onDouble()
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter)
	
	##updates widgets whenever the mouse enters the GUI
	onMouse <- function(){
		reset(fileList, fileBox, fileNames)
		fileNames <<- names(fileFolder)
		usrSel <- 1 + as.integer(tkcurselection(fileBox))
		usrFiles <- names(fileFolder)[usrSel]
		configList <- list(threshEntry, entryLab, default, apply)
		if (!length(usrSel)){
			for (i in configList)
				tkconfigure(i, state='disabled')
		}else{
			oneD <- FALSE
			for (i in usrFiles){
				if (fileFolder[[i]]$file.par$number_dimensions == 1){
					oneD <- TRUE
					break
				}
			}
			if (oneD){
				for (i in configList)
					tkconfigure(i, state='normal')
			}else{
				for (i in configList)
					tkconfigure(i, state='disabled')
			}
		}
		tclObj(dispVal) <- globalSettings$peak.disp
		tclObj(filtVal) <- globalSettings$peak.noiseFilt
	}
	tkbind(dlg, '<Enter>', onMouse)
	tkbind(dlg, '<FocusIn>', onMouse)
	
	invisible()
}

## Internal function openStored
## Add an entry to fileFolder for a spectrum stored in the global environment
## inFolder - list; data and file parameters for input spectrum.  This should 
##	match the	output format of ucsf2D()
## fileName - character string; name for the new entry in fileFolder
openStored <- function(inFolder, fileName='storedSpec'){
	
	## Check input folder format
	if (is.null(inFolder$file.par))
		inFolder <- inFolder[[1]]
	if (is.null(inFolder$file.par) || is.null(inFolder$w2) || 
			is.null(inFolder$data))
		err('Object must contain a spectrum matching the format returned by ed().')
	if (inFolder$file.par$number_dimensions == 2 && is.null(inFolder$w1))
		err('Object must contain a spectrum matching the format returned by ed().')
	
	## Look for fileName in fileFolder
	while(fileName %in% names(fileFolder)){
		fileName <- myDialog(paste('Name already exists in the file folder.', 
						'Please provide a unique name:', sep='\n'), fileName)
		if (!length(fileName) || !nzchar(fileName))
			return(invisible())
	}
	
	## Modify file parameters
	inFolder$file.par$user_title <- fileName
	inFolder$file.par$file.name <- fileName
	if (is.null(inFolder$graphics.par))
		inFolder$graphics.par <- defaultSettings
	
	## Add entry to fileFolder
	n <- length(fileFolder) + 1
	fileFolder[[n]] <- inFolder
	names(fileFolder)[n] <- fileName
	
	## Save changes and plot spectrum
	currentSpectrum <- fileName
	myAssign('fileFolder', fileFolder, FALSE)
	myAssign('currentSpectrum', currentSpectrum, FALSE)
	zf()
	
	return(fileName)
}

## Displays an interactive GUI for sorting files
fs <- function(){
	
	##call fo() if there are no open files
	if (!exists("fileFolder") || is.null(fileFolder) || !exists("currentSpectrum") 
			|| is.null(currentSpectrum)){
		usrSel <- fo()
		if (is.null(usrSel))
			return(invisible())
	}
	
	##creates main window
	tclCheck()
	dlg <- myToplevel('fs')
	if (is.null(dlg))
		return(invisible())
	tkwm.title(dlg, 'Files')
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	
	##create tablelist widget
	tableFrame <- ttklabelframe(dlg, 
			text='Double-click on a file path to switch spectra:')
	xscr <- ttkscrollbar(tableFrame, orient='horizontal', command=function(...) 
				tkxview(tableList, ...))
	yscr <- ttkscrollbar(tableFrame, orient='vertical', command=function(...) 
				tkyview(tableList, ...))
	tableList <- tkwidget(tableFrame, 'tablelist::tablelist', bg='white',  
			columns=c('0', 'Spectrum', '0', '# Dim', '0', 'File Path', '0', 'Size', 
					'right', '0', 'Date Modified', 'center'), height=11, width=110, 
			labelcommand=function(...) onSort(...), selectmode='extended', spacing=3, 
			stretch='all', activestyle='underline', exportselection=FALSE,
			editselectedonly=TRUE, xscrollcommand=function(...) tkset(xscr, ...),
			yscrollcommand=function(...) tkset(yscr, ...))
	for (i in 0:4)
		tcl(tableList, 'columnconfigure', i, sortmode='dictionary')
	tcl(tableList, 'columnconfigure', 0, editable=TRUE)
	
	##format the size column
	formatSize <- function(size){
		if (length(grep('KB', size)))
			return(tclVar(size))
		size <- as.numeric(size)
		if (size < 2^20)
			return(tclVar(paste(signif(size / 2^10, 3), 'KB')))
		else
			return(tclVar(paste(signif(size / 2^20, 3), 'MB')))
	}
	tcl(tableList, 'columnconfigure', 3, formatcommand=function(...) 
				formatSize(...))
	
	##selects all rows Ctrl+A is pressed
	tkbind(dlg, '<Control-a>', function(...) 
				tkselection.set(tableList, 0, 'end'))
	
	##get file information and add to tablelist
	getFileInfo <- function(fileNames){
		if (!length(fileNames) || !nzchar(fileNames))
			return(invisible())
		tmpFolder <- fileFolder[fileNames]
		userTitles <- sapply(tmpFolder, function(x) x$file.par$user_title)
		dims <- as.character(sapply(tmpFolder, function(x) 
							x$file.par$number_dimensions))
		sizes <- as.character(sapply(tmpFolder, function(x) 
							x$file.par$file.size))
		mods <- sapply(tmpFolder, function(x) 
					as.character(x$file.par$date.modified))
		paths <- sapply(tmpFolder, function(x) x$file.par$file.name)
		fileData <- cbind(userTitles, dims, paths, sizes, mods, 
				deparse.level=0)
		for (i in 1:nrow(fileData))
			tkinsert(tableList, 'end', fileData[i, ])
	}
	getFileInfo(names(fileFolder))
	if (!is.null(currentSpectrum)){
		tkselection.set(tableList, wc() - 1)
		tcl(tableList, 'see', wc() - 1)
	}
	
	##switches spectra on left-mouse double-click
	onDouble <- function(W){
		if (W != '.fs.1.3.body')
			return(invisible())
		usrSel <- as.numeric(tcl(tableList, 'curselection')) + 1
		usrFile <- names(fileFolder)[usrSel]
		if (!is.null(usrFile) && !is.na(usrFile) && currentSpectrum != usrFile){
			currentSpectrum <- usrFile
			myAssign('currentSpectrum', currentSpectrum)
			refresh(multi.plot=FALSE)
			tkwm.deiconify(dlg)
			tkfocus(tableList)
		}
	}
	tkbind(dlg, '<Double-Button-1>', onDouble)
	
	##updates fileFolder
	updateFileFolder <- function(newOrder){
		newFolder <- fileFolder[newOrder]
		myAssign('fileFolder', newFolder)
	}
	
	##sort files when user clicks on column headers 
	onSort <- function(tbl, col){
		prevOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		tcl('tablelist::sortByColumn', tbl, col)
		newOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		updateFileFolder(match(newOrder, prevOrder))
	}
	
	##allow spectrum names to be edited
	onEdit <- function(widget, rowNum, colNum, newVal){
		rowNum <- as.numeric(rowNum) + 1
		userTitles <- sapply(fileFolder, function(x) x$file.par$user_title)
		if (newVal %in% userTitles){
			myMsg(paste('A spectrum with that name is currently open.', 
							'Please enter a unique name.', sep='\n'), icon='error', 
					parent=dlg)
			tcl(tableList, 'cancelediting')
		}else{
			fileFolder[[rowNum]]$file.par$user_title <- newVal
			myAssign('fileFolder', fileFolder)
			refresh()
		}
		
		return(tclVar(as.character(newVal)))
	}
	tkconfigure(tableList, editendcommand=function(...) onEdit(...))
	
	##create top button
	optionFrame <- ttkframe(dlg)
	onTop <- function(){
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel) || usrSel == 0)
			return(invisible())
		prevOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		for (i in seq_along(usrSel))
			tkmove(tableList, usrSel[i], i - 1)
		tcl(tableList, 'see', 0)
		newOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		updateFileFolder(match(newOrder, prevOrder))
	}
	topButton <- ttkbutton(optionFrame, text='Top', width=8, command=onTop)
	
	##create up button
	onUp <- function(){
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel) || usrSel == 0)
			return(invisible())
		prevOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		for (selItem in usrSel)
			tkmove(tableList, selItem, selItem - 1)
		tcl(tableList, 'see', min(usrSel) - 1)
		newOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		updateFileFolder(match(newOrder, prevOrder))
	}
	upButton <- ttkbutton(optionFrame, text='^', width=8, command=onUp)
	
	##create down button
	onDown <- function(){
		usrSel <- rev(as.numeric(tcl(tableList, 'curselection')))
		if (!length(usrSel) || usrSel == length(fileFolder) - 1)
			return(invisible())
		prevOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		for (selItem in usrSel)
			tkmove(tableList, selItem, selItem + 2)
		tcl(tableList, 'see', max(usrSel) + 1)
		newOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		updateFileFolder(match(newOrder, prevOrder))
	}
	downButton <- ttkbutton(optionFrame, text='v', width=8, command=onDown)
	
	##create bottom button
	onBottom <- function(){
		usrSel <- rev(as.numeric(tcl(tableList, 'curselection')))
		if (!length(usrSel) || usrSel == length(fileFolder) - 1)
			return(invisible())
		prevOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		for (i in seq_along(usrSel))
			tkmove(tableList, usrSel[i], length(fileFolder) - i + 1)
		tcl(tableList, 'see', length(fileFolder) - 1)
		newOrder <- as.character(tcl(tableList, 'getcolumns', 0))
		updateFileFolder(match(newOrder, prevOrder))
	}
	bottomButton <- ttkbutton(optionFrame, text='Bottom', width=8, 
			command=onBottom)
	
	##create file open button
	onOpen <- function(){
		
		##open files
		prevFiles <- NULL
		if (length(fileFolder))
			prevFiles <- names(fileFolder)
		newFiles <- fo()
		if (is.null(newFiles))
			return(invisible())
		fileMatches <- as.vector(na.omit(match(prevFiles, newFiles)))
		if (length(fileMatches))
			newFiles <- newFiles[-fileMatches]
		if (!length(newFiles))
			return(invisible())
		
		##get file information for newly opened files
		getFileInfo(newFiles)
		
		##select newly opened files
		tkselection.clear(tableList, 0, 'end')
		tkselection.set(tableList, length(fileFolder) - length(newFiles), 'end')
		tkyview.moveto(tableList, 1)
	}
	openButton <- ttkbutton(optionFrame, text='Open file', width=11, 
			command=onOpen)
	
	##create open stored spectrum button
	onOpenStored <- function(){
		
		##prompt user for a object in the global environment
		obs <- ls(envir=.GlobalEnv)
		usrSel <- mySelect(obs, title='Select an object:', parent=dlg, 
				multiple=FALSE)
		if (!length(usrSel) || !nzchar(usrSel))
			return(invisible())
		
		##get name for new fileFolder entry
		usrName <- myDialog(paste('Provide a name for the spectrum:'), usrSel)
		if (!length(usrName) || !nzchar(usrName))
			return(invisible())
		
		##insert selected object into fileFolder
		openStored(get(usrSel), usrName)
		
		##get file information for newly opened files
		getFileInfo(usrName)
		
		##select newly opened file
		tkselection.clear(tableList, 0, 'end')
		tkselection.set(tableList, length(fileFolder) - 1, 'end')
		tkyview.moveto(tableList, 1)
	}
	openStoredButton <- ttkbutton(optionFrame, text='Open stored*', width=13, 
			command=onOpenStored)
	
	##create file close button
	onClose <- function(){
		
		##get user selection
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel))
			return(invisible())
		usrFiles <- names(fileFolder)[usrSel + 1]
		
		##close selected files
		fc(usrFiles)
		tkdelete(tableList, usrSel)
		tkselection.set(tableList, usrSel[1])
	}
	closeButton <- ttkbutton(optionFrame, text='Close file', width=11, 
			command=onClose)
	
	##create openStored label
	openStoredLabel <- ttklabel(dlg, text=paste('*Please type "?fs" in', 
					'the R console for more details on this feature.'))
	
	##add widgets to tableFrame
	tkgrid(tableFrame, column=1, row=1, sticky='nswe', pady=6, padx=6)
	tkgrid(tableList, column=1, row=1, sticky='nswe')
	tkgrid(xscr, column=1, row=2, sticky='we')
	tkgrid(yscr, column=2, row=1, sticky='ns')
	
	##make tableFrame stretch when window is resized
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=1)
	tkgrid.columnconfigure(tableFrame, 1, weight=1)
	tkgrid.rowconfigure(tableFrame, 1, weight=1)
	
	##add widgets to optionFrame
	tkgrid(optionFrame, column=1, row=2, pady=c(6, 0))
	tkgrid(topButton, column=1, row=1, padx=c(0, 4), pady=2)
	tkgrid(upButton, column=2, row=1, pady=2)
	tkgrid(downButton, column=3, row=1, padx=c(0, 4), pady=2)
	tkgrid(bottomButton, column=4, row=1, pady=2)
	tkgrid(openButton, column=5, row=1, padx=c(30, 4), pady=2)
	tkgrid(openStoredButton, column=6, row=1, padx=4, pady=2)
	tkgrid(closeButton, column=7, row=1, pady=2)
	tkgrid(openStoredLabel, column=1, row=3, padx=c(10, 0), pady=c(10, 0), sticky='w')
	tkgrid(ttksizegrip(dlg), column=2, row=3, sticky='se')
	
	##allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (focus == '.fs.1.3.body')
			onDouble('.fs.1.3.body')
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter)
	
	##updates widgets whenever the mouse enters the GUI
	onMouse <- function(){
		if (!length(fileFolder)){
			tkdelete(tableList, '0', 'end')
			return(invisible())
		}
		filePaths <- as.character(tcl(tableList, 'getcolumns', 2))
		folderPaths <- as.vector(sapply(fileFolder, function(x) 
							x$file.par$file.name))
		userTitles <- as.character(tcl(tableList, 'getcolumns', 0))
		folderTitles <- getTitles(names(fileFolder), FALSE)		
		if (identical(folderPaths, filePaths) && 
				identical(folderTitles, userTitles))
			return(invisible())
		tkdelete(tableList, '0', 'end')
		getFileInfo(names(fileFolder))
	}
	tkbind(dlg, '<Enter>', onMouse)
	tkbind(dlg, '<FocusIn>', onMouse)
	
	invisible()
}

## Interactive GUI for editing tables
## data - data.frame; the table to edit
## editable - logical vector; indicates whether entries in each column in the 
##	table should be editable, should be the same length as the number of columns
## title - character string; title for the GUI
## colVer - function list; functions, one for each column, used to verify the 
##	entries in each column.  Functions should return TRUE or FALSE.
## errMsgs - character vector; error messages to display if a function in colVer
##	returns FALSE, should be the same length as as the number of columns.  If 
##	NULL, no error messages are displayed
tableEdit <- function(data, editable=rep(TRUE, ncol(data)),	title='rNMR', 
		colVer=NULL, errMsgs=rep(paste('Data type for new entry must',  
						'match the data type for a given column.'), ncol(data))){
	
	##check colVer argument
	if (is.null(colVer)){
		verFun <- function(x) return(TRUE)
		colVer <- rep(list(verFun), ncol(data))
	}
	if (length(colVer) != ncol(data))
		stop('length of colVer argument must equal the number of columns in data')
	
	##check errMsgs argument
	if (!is.null(errMsgs) && length(errMsgs) != ncol(data))
		stop('length of errMsgs argument must equal the number of columns in data')
	
	##creates main window
	dlg <- tktoplevel()
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	returnVal <- NULL
	tkwm.title(dlg, title)
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	colNames <- colnames(data)
	
	##create tablelist widget
	tableFrame <- ttklabelframe(dlg, text='Data Table:')
	xscr <- ttkscrollbar(tableFrame, orient='horizontal', command=function(...) 
				tkxview(tableList, ...))
	yscr <- ttkscrollbar(tableFrame, orient='vertical', command=function(...) 
				tkyview(tableList, ...))
	colVals <- NULL
	for (i in colNames)
		colVals <- c(colVals, '0', i, 'center')
	tableList <- tkwidget(tableFrame, 'tablelist::tablelist', columns=colVals, 
			activestyle='underline', height=11, width=110, exportselection=FALSE,
			labelcommand='tablelist::sortByColumn', selectmode='extended', bg='white', 
			spacing=3, stretch='all', editselectedonly=TRUE, selecttype='cell',
			xscrollcommand=function(...) tkset(xscr, ...),
			yscrollcommand=function(...) tkset(yscr, ...))
	
	##add data to tablelist widget
	for (i in 1:nrow(data))
		tkinsert(tableList, 'end', unlist(data[i, ]))
	for (i in 1:ncol(data))
		tcl(tableList, 'columnconfigure', i - 1, sortmode='dictionary', 
				editable=editable[i], width=0, align='left')
	
	##get the data types for each column
	colTypes <- NULL
	for (i in 1:ncol(data))
		colTypes <- c(colTypes, storage.mode(data[, i]))
	
	##selects all rows Ctrl+A is pressed
	tkbind(tableList, '<Control-a>', function(...) 
				tkselect(tableList, 'set', 0, 'end'))
	
	##rewrites data after GUI is updated
	writeData <- function(){
		
		##get the data from the GUI
		newData <- NULL
		numRows <- as.numeric(tcl(tableList, 'index', 'end'))
		if (numRows == 0){
			data <<- newData
			return(invisible())
		}
		for (i in 0:numRows)
			newData <- rbind(newData, as.character(tcl(tableList, 'get', i)))
		
		##format data
		colnames(newData) <- colNames
		newData <- as.data.frame(newData, stringsAsFactors=FALSE)
		for (i in 1:ncol(newData))
			suppressWarnings(storage.mode(newData[, i]) <- colTypes[i])
		data <<- newData
	}
	
	##save tableList data after table is sorted
	tkbind(dlg, '<<TablelistColumnSorted>>', writeData)
	
	##create top button
	optionFrame <- ttkframe(tableFrame)
	moveFrame <- ttklabelframe(optionFrame, text='Move selected rows', padding=6)
	onTop <- function(){
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel) || usrSel == 0)
			return(invisible())
		tkselection.set(tableList, usrSel)
		for (i in seq_along(usrSel))
			tkmove(tableList, usrSel[i], 0 + i - 1)
		tcl(tableList, 'see', 0)
		writeData()
	}
	topButton <- ttkbutton(moveFrame, text='Top', width=11, command=onTop)
	
	##create up button
	onUp <- function(){
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(usrSel) || usrSel == 0)
			return(invisible())
		tkselection.set(tableList, usrSel)
		for (selItem in usrSel)
			tkmove(tableList, selItem, selItem - 1)
		tcl(tableList, 'see', min(usrSel) - 1)
		writeData()
	}
	upButton <- ttkbutton(moveFrame, text='^', width=9, command=onUp)
	
	##create down button
	onDown <- function(){
		usrSel <- rev(as.numeric(tcl(tableList, 'curselection')))
		if (!length(usrSel) || usrSel == nrow(data) - 1)
			return(invisible())
		tkselection.set(tableList, usrSel)
		for (selItem in usrSel)
			tkmove(tableList, selItem, selItem + 2)
		tcl(tableList, 'see', max(usrSel) + 1)
		writeData()
	}
	downButton <- ttkbutton(moveFrame, text='v', width=9, command=onDown)
	
	##create bottom button
	onBottom <- function(){
		usrSel <- rev(as.numeric(tcl(tableList, 'curselection')))
		if (!length(usrSel) || usrSel == nrow(data) - 1)
			return(invisible())
		tkselection.set(tableList, usrSel)
		for (i in seq_along(usrSel))
			tkmove(tableList, usrSel[i], nrow(data) - i + 1)
		tcl(tableList, 'see', nrow(data) - 1)
		writeData()
	}
	bottomButton <- ttkbutton(moveFrame, text='Bottom', width=11, 
			command=onBottom)
	
	##create sig. fig. spinbox
	sigFigFrame <- ttklabelframe(optionFrame, text='Display', padding=6)
	onSigFig <- function(){
		if (tclvalue(sigFigVal) == 'max'){
			for (i in 1:nrow(data))
				tcl(tableList, 'rowconfigure', i - 1, text=unlist(data[i, ]))
			return(invisible())
		}
		sigFig <- as.numeric(tclvalue(sigFigVal))
		for (i in seq_along(data[1, ])){
			if (any(is.logical(data[, i])))
				next
			newData <- tryCatch(signif(data[, i], sigFig), 
					error=function(er) return(data[, i]))
			newData[is.na(newData)] <- 'NA'
			tcl(tableList, 'columnconfigure', i - 1, text=newData)
		}
	}
	sigFigVal <- tclVar('max')
	sigFigBox <- tkwidget(sigFigFrame, 'spinbox', width=6, wrap=TRUE,
			textvariable=sigFigVal, values=c('max', 1:9), command=onSigFig)
	sigFigLabel <- ttklabel(sigFigFrame, text='significant figures')
	
	##create table edit widgets
	if (any(editable)){
		
		##check interactively edited cells using functions provided in colVer
		onEdit <- function(widget, rowNum, colNum, newVal, tclReturn=TRUE){
			rowNum <- as.numeric(rowNum) + 1
			colNum <- as.numeric(colNum) + 1
			if (newVal == 'NA'){
				if (tclReturn)
					return(tclVar(as.character(newVal)))
				else
					return(TRUE)
			}
			suppressWarnings(storage.mode(newVal) <- colTypes[colNum])
			if (!colVer[[colNum]](newVal)){
				if (!is.null(errMsgs))
					myMsg(errMsgs[colNum], icon='error', parent=dlg)
				if (tclReturn)
					tcl(tableList, 'cancelediting')
				else
					return(FALSE)
			}else
				data[rowNum, colNum] <<- newVal
			if (tclReturn)
				return(tclVar(as.character(newVal)))
			else
				return(TRUE)
		}
		tkconfigure(tableList, editendcommand=function(...) onEdit(...))
		
		##create cell editing textbox
		ceditFrame <- ttklabelframe(optionFrame, text='Edit selected cells', 
				padding=6)
		usrEntry <- tclVar(character(0))
		textEntry <- ttkentry(ceditFrame, width=13, justify='center', 
				textvariable=usrEntry)
		
		##update cell editing textbox with current cell selection value
		onCellSel <- function(){
			usrSel <- as.character(tcl(tableList, 'curcellselection'))
			if (!length(usrSel))
				tclObj(usrEntry) <- character(0)
			selVals <- as.character(tcl(tableList, 'getcells', usrSel))
			if (length(grep(selVals[1], selVals, fixed=TRUE)) == length(selVals))
				tclObj(usrEntry) <- selVals[1]
			else
				tclObj(usrEntry) <- character(0)
		}
		tkbind(tableList, '<<TablelistSelect>>', onCellSel)
		
		##create apply button
		onApply <- function(){
			tcl(tableList, 'finishediting')
			newVal <- tclvalue(usrEntry)
			usrSel <- as.character(tcl(tableList, 'curcellselection'))
			for (i in usrSel){
				rowNum <- unlist(strsplit(i, ','))[1]
				colNum <- unlist(strsplit(i, ','))[2]
				isValid <- onEdit(rowNum=rowNum, colNum=colNum, newVal=newVal, 
						tclReturn=FALSE)
				if (isValid)
					tcl(tableList, 'cellconfigure', i, text=newVal)
				else
					return(invisible())
			}
			writeData()
		}
		applyButton <- ttkbutton(ceditFrame, text='Apply', width=8, command=onApply)
		
		##create copy button
		reditFrame <- ttklabelframe(optionFrame, text='Edit rows', padding=6)
		clipboard <- NULL
		onCopy <- function(){
			usrSel <- as.numeric(tcl(tableList, 'curselection'))
			if (!length(usrSel) || usrSel == 0)
				return(invisible())
			tkselection.set(tableList, usrSel)
			selVals <- NULL
			for (i in usrSel)
				selVals <- rbind(selVals, as.character(tcl(tableList, 'get', i)))
			clipboard <<- selVals
		}
		copyButton <- ttkbutton(reditFrame, text='Copy', width=10, command=onCopy)
		
		##create paste button
		onPaste <- function(){
			if (is.null(clipboard))
				return(invisible())
			for (i in 1:nrow(clipboard))
				tkinsert(tableList, 'end', unlist(clipboard[i, ]))
			writeData()
			tcl(tableList, 'see', nrow(data) - 1)
		}
		pasteButton <- ttkbutton(reditFrame, text='Paste', width=10, 
				command=onPaste)
		
		##create insert button
		onInsert <- function(){
			tkinsert(tableList, 'end', as.character(rep(NA, ncol(data))))
			writeData()
			tcl(tableList, 'see', nrow(data) - 1)
		}
		insertButton <- ttkbutton(reditFrame, text='Insert', width=10, 
				command=onInsert)
		
		##create delete button
		onDelete <- function(){
			usrSel <- as.numeric(tcl(tableList, 'curselection'))
			if (!length(usrSel))
				return(invisible())
			tkselection.set(tableList, usrSel - 1)
			tkdelete(tableList, usrSel)
			writeData()
		}
		deleteButton <- ttkbutton(reditFrame, text='Delete', width=10, 
				command=onDelete)
	}
	
	##create ok button
	bottomFrame <- ttkframe(dlg)
	onOk <- function(){
		
		##verify data
		tcl(tableList, 'finishediting')
		if (!is.null(data)){
			for (i in 1:ncol(data)){
				suppressWarnings(storage.mode(data[, i]) <- colTypes[i])
				if (!colVer[[i]](data[, i])){
					if (!is.null(errMsgs))
						myMsg(errMsgs[i], icon='error', parent=dlg)
					return(invisible())
				}
			}
		}
		
		##return the data and close the GUI
		returnVal <<- data
		tkgrab.release(dlg)
		tkdestroy(dlg)
		return(returnVal)
	}
	okButton <- ttkbutton(bottomFrame, text='OK', width=10, command=onOk)
	
	##create cancel button
	onCancel <- function(){
		tkgrab.release(dlg)
		tkdestroy(dlg)
		return(returnVal)
	}
	cancelButton <- ttkbutton(bottomFrame, text='Cancel', width=10, 
			command=onCancel)
	
	##create export button
	onExport <- function(){
		tkwm.iconify(dlg)
		if ('ACTIVE' %in% names(data))
			initFile <- 'roiTable'
		else if ('Index' %in% names(data))
			initFile <- 'peakList'
		else
			initFile <- 'roiSummary'
		fileName <- mySave(initialfile=initFile, defaultextension='txt', 
				title='Export', filetypes=list('xls'='Excel Files', 'txt'='Text Files'))
		if (length(fileName) == 0 || !nzchar(fileName)){
			tkwm.deiconify(dlg)
			return(invisible())
		}
		write.table(data, file=fileName, quote=FALSE, sep='\t', row.names=FALSE, 
				col.names=TRUE)
		tkwm.deiconify(dlg)
	}
	exportButton <- ttkbutton(bottomFrame, text='Export', width=10, 
			command=onExport)
	
	##add widgets to treeFrame
	tkgrid(tableFrame, column=1, row=1, sticky='nswe', pady=6, padx=6)
	tkgrid(tableList, column=1, row=1, sticky='nswe')
	tkgrid(xscr, column=1, row=2, sticky='we')
	tkgrid(yscr, column=2, row=1, sticky='ns')
	
	##make treeFrame stretch when window is resized
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 1, weight=1)
	tkgrid.columnconfigure(tableFrame, 1, weight=1)
	tkgrid.rowconfigure(tableFrame, 1, weight=1)
	
	##add widgets to moveFrame
	tkgrid(optionFrame, column=1, columnspan=2, row=3, pady=8)
	tkgrid(moveFrame, column=1, row=1, padx=8)
	tkgrid(topButton, column=1, row=1, pady=2, padx=c(0, 4))
	tkgrid(upButton, column=2, row=1, pady=2, padx=1)
	tkgrid(downButton, column=3, row=1, padx=1, pady=2)
	tkgrid(bottomButton, column=4, row=1, pady=2, padx=c(4, 0))
	
	##add widgets to sigFigFrame
	tkgrid(sigFigFrame, column=2, row=1, padx=8)
	tkgrid(sigFigBox, column=1, row=1, padx=c(4, 2), pady=c(2, 4))
	tkgrid(sigFigLabel, column=2, row=1, padx=c(0, 4), pady=c(2, 4))
	
	##add editing widgets
	if (any(editable)){
		
		##add widgets to rowFrame
		tkgrid(reditFrame, column=1, row=2, pady=4, padx=8)
		tkgrid(copyButton, column=1, row=1, padx=c(0, 2))
		tkgrid(pasteButton, column=2, row=1, padx=c(0, 8))
		tkgrid(insertButton, column=3, row=1, padx=c(0, 2))
		tkgrid(deleteButton, column=4, row=1, padx=c(0, 0))
		
		##add widgets to ceditFrame
		tkgrid(ceditFrame, column=2, row=2, pady=4, padx=8)
		tkgrid(textEntry, column=1, row=1, padx=2)
		tkgrid(applyButton, column=3, row=1, padx=2)
	}
	
	##add widgets to bottomFrame
	tkgrid(bottomFrame, column=1, row=2, pady=c(6, 0))
	tkgrid(okButton, column=1, row=1, padx=4)
	tkgrid(cancelButton, column=2, row=1, padx=4)
	tkgrid(exportButton, column=3, row=1, padx=c(20, 4))
	tkgrid(ttksizegrip(dlg), column=1, row=3, sticky='se')
	
	##Allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		focus <- as.character(tkfocus())
		if (length(grep('.2.2.3.1$', focus)))
			onApply()
		else
			tryCatch(tkinvoke(focus), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter)
	
	## configure the toplevel
	tkfocus(tableList)
	if (as.logical(tkwinfo('viewable', dlg)))
		tkgrab.set(dlg)
	tkwait.window(dlg)
	return(returnVal)
	
	invisible()
}

## User preferences GUI
ep <- function(dispPane=0){
	
	##create main window
	tclCheck()
	dlg <- myToplevel('ep')
	if (is.null(dlg))
		return(invisible())
	tkwm.title(dlg, 'Preferences')
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	newDef <- defaultSettings
	
	##create paned notebook
	epBook <- ttknotebook(dlg, padding=3)
	tkgrid(epBook, column=1, row=1, sticky='nsew', padx=6, pady=6)
	
	##create individual panes
	genFrame <- ttkframe(epBook, padding=6) 
	tkadd(epBook, genFrame, text=' General ')	
	grFrame <- ttkframe(epBook, padding=6)
	tkadd(epBook, grFrame, text=' Graphics ')
	coFrame <- ttkframe(epBook, padding=6)
	tkadd(epBook, coFrame, text=' Colors ')
	psFrame <- ttkframe(epBook, padding=6)
	tkadd(epBook, psFrame, text=' Plotting ')
	ppFrame <- ttkframe(epBook, padding=6)
	tkadd(epBook, ppFrame, text=' Peak Picking ')
	roiFrame <- ttkframe(epBook, padding=6)
	tkadd(epBook, roiFrame, text=' ROIs ')
	tkselect(epBook, dispPane)
	
	#####create widgets for genFrame
	##create a label with instructions
	genLabel <- ttklabel(genFrame, wraplength=350, text=paste('The following', 
					'settings will be applied when the rNMR package is loaded.  Press', 
					'the "?" button for more information on each setting.'))
	
	##create window dimension settings frame
	sizeFrame <- ttklabelframe(genFrame, text='Window dimensions', padding=6)
	widthLabel <- ttklabel(sizeFrame, text='width:')
	heightLabel <- ttklabel(sizeFrame, text='height:')
	
	##create main plot window widgets
	mainFrame <- ttkframe(sizeFrame)
	mainLabel <- ttklabel(mainFrame, text='Main plot')
	mainWdVar <- tclVar(newDef$size.main[1])
	mainWdEntry <- ttkentry(mainFrame, textvariable=mainWdVar, width=6,
			justify='center')
	mainHtVar <- tclVar(newDef$size.main[2])
	mainHtEntry <- ttkentry(mainFrame, textvariable=mainHtVar, width=6,
			justify='center')
	
	##create subplot window widgets
	subFrame <- ttkframe(sizeFrame)
	subLabel <- ttklabel(subFrame, text='Subplot')
	subWdVar <- tclVar(newDef$size.sub[1])
	subWdEntry <- ttkentry(subFrame, textvariable=subWdVar, width=6,
			justify='center')
	subHtVar <- tclVar(newDef$size.sub[2])
	subHtEntry <- ttkentry(subFrame, textvariable=subHtVar, width=6,
			justify='center')
	
	##create multiple file window widgets
	multiFrame <- ttkframe(sizeFrame)
	multiLabel <- ttklabel(multiFrame, text='Multi file')
	multiWdVar <- tclVar(newDef$size.multi[1])
	multiWdEntry <- ttkentry(multiFrame, textvariable=multiWdVar, width=6,
			justify='center')
	multiHtVar <- tclVar(newDef$size.multi[2])
	multiHtEntry <- ttkentry(multiFrame, textvariable=multiHtVar, width=6,
			justify='center')
	
	##create SDI checkbox
	checkFrame <- ttkframe(genFrame)
	sdiVar <- tclVar(as.character(newDef$sdi))
	sdiButton <- ttkcheckbutton(checkFrame, onvalue='TRUE', offvalue='FALSE', 
			variable=sdiVar, text=paste(' Run rNMR using\n separate windows'))
	
	##create update checkbox
	updateVar <- tclVar(as.character(newDef$update))
	updateButton <- ttkcheckbutton(checkFrame, onvalue='TRUE', offvalue='FALSE', 
			variable=updateVar, text=' Check for updates\n when rNMR loads')
	
	##create auto backup checkbox
	backupVar <- tclVar(as.character(newDef$autoBackup))
	backupButton <- ttkcheckbutton(checkFrame, onvalue='TRUE', offvalue='FALSE', 
			variable=backupVar, text=paste(' Enable automatic\n backup'))
	
	##create working directory selection widgets
	dirFrame <- ttkframe(genFrame)
	dirLabel <- ttklabel(dirFrame, text='Default directory:')
	dirVar <- tclVar(newDef$wd)
	dirEntry <- ttkentry(dirFrame, textvariable=dirVar, justify='left', width=38, 
			state='readonly')
	onAddLib <- function(){
		newWd <- myDir(parent=dlg)
		if (nzchar(newWd))
			tclvalue(dirVar) <- newWd
	}
	browseButton <- ttkbutton(dirFrame, text='Browse', width=10, command=onAddLib)
	
	##add widgets to genFrame
	tkgrid(genLabel, column=1, columnspan=2, row=1, padx=c(6, 10), pady=c(10, 0), 
			sticky='w')
	
	tkgrid(sizeFrame, column=1, row=2, padx=4, pady=8, sticky='nsw')
	tkgrid(widthLabel, column=1, row=2, pady=4, sticky='sw')
	tkgrid(heightLabel, column=1, row=3, pady=4, sticky='sw')
	
	tkgrid(mainFrame, column=2, row=1, rowspan=3, padx=6)
	tkgrid(mainLabel, column=1, row=1, pady=c(0, 2), sticky='w')
	tkgrid(mainWdEntry, column=1, row=2, pady=4, sticky='e')
	tkgrid(mainHtEntry, column=1, row=3, pady=4, sticky='e')
	
	tkgrid(subFrame, column=3, row=1, rowspan=3, padx=6)
	tkgrid(subLabel, column=1, row=1, pady=c(0, 2), sticky='w')
	tkgrid(subWdEntry, column=1, row=2, pady=4, sticky='e')
	tkgrid(subHtEntry, column=1, row=3, pady=4, sticky='e')
	
	tkgrid(multiFrame, column=4, row=1, rowspan=3, padx=6)
	tkgrid(multiLabel, column=1, row=1, pady=c(0, 2), sticky='w')
	tkgrid(multiWdEntry, column=1, row=2, pady=4, sticky='e')
	tkgrid(multiHtEntry, column=1, row=3, pady=4, sticky='e')
	
	tkgrid(checkFrame, column=2, row=2, padx=4, pady=8, sticky='ns')
	tkgrid(sdiButton, column=1, row=1, pady=c(3, 0), sticky='w')
	tkgrid(updateButton, column=1, row=2, pady=6, sticky='w')
	tkgrid(backupButton, column=1, row=3, sticky='w')
	
	tkgrid(dirFrame, column=1, columnspan=2, row=3, padx=4, pady=4, sticky='w')
	tkgrid(dirLabel, column=1, row=1, pady=c(0, 3), sticky='w')
	tkgrid(dirEntry, column=1, row=2, padx=c(12, 4), pady=2)
	tkgrid(browseButton, column=2, row=2, pady=2, sticky='e')
	
	#####create widgets for grFrame
	##create plot margin options
	marFrame <- ttklabelframe(grFrame, text='Plot margins', padding=4)
	topLabel <- ttklabel(marFrame, text='top:')
	bottomLabel <- ttklabel(marFrame, text='bottom:')
	leftLabel <- ttklabel(marFrame, text='left:')
	rightLabel <- ttklabel(marFrame, text='right:')
	
	marMainLabel <- ttklabel(marFrame, text='Main plot')
	topMarVar <- tclVar(newDef$mar[3])
	topMarEntry <- ttkentry(marFrame, textvariable=topMarVar, width=8,
			justify='center')
	botMarVar <- tclVar(newDef$mar[1])
	botMarEntry <- ttkentry(marFrame, textvariable=botMarVar, width=8,
			justify='center')
	leftMarVar <- tclVar(newDef$mar[2])
	leftMarEntry <-	ttkentry(marFrame, textvariable=leftMarVar, width=8,
			justify='center')
	rightMarVar <- tclVar(newDef$mar[4])
	rightMarEntry <- ttkentry(marFrame, textvariable=rightMarVar, width=8,
			justify='center')
	
	marSubLabel <- ttklabel(marFrame, text='Subplot')
	topSubMarVar <- tclVar(newDef$mar.sub[3])
	topSubMarEntry <-	ttkentry(marFrame, textvariable=topSubMarVar, width=8,
			justify='center')
	botSubMarVar <- tclVar(newDef$mar.sub[1])
	botSubMarEntry <-	ttkentry(marFrame, textvariable=botSubMarVar, width=8,
			justify='center')
	leftSubMarVar <- tclVar(newDef$mar.sub[2])
	leftSubMarEntry <-	ttkentry(marFrame, textvariable=leftSubMarVar, width=8,
			justify='center')
	rightSubMarVar <- tclVar(newDef$mar.sub[4])
	rightSubMarEntry <-	ttkentry(marFrame, textvariable=rightSubMarVar, width=8,
			justify='center')
	
	marMultiLabel <- ttklabel(marFrame, text='Multi file')
	topMultiMarVar <- tclVar(newDef$mar.multi[3])
	topMultiMarEntry <-	ttkentry(marFrame, textvariable=topMultiMarVar, width=8,
			justify='center')
	botMultiMarVar <- tclVar(newDef$mar.multi[1])
	botMultiMarEntry <-	ttkentry(marFrame, textvariable=botMultiMarVar, width=8,
			justify='center')
	leftMultiMarVar <- tclVar(newDef$mar.multi[2])
	leftMultiMarEntry <-	ttkentry(marFrame, textvariable=leftMultiMarVar, 
			width=8, justify='center')
	rightMultiMarVar <- tclVar(newDef$mar.multi[4])
	rightMultiMarEntry <-	ttkentry(marFrame, textvariable=rightMultiMarVar, 
			width=8, justify='center')
	
	##create x-axis gridlines checkbox
	gridFrame <- ttklabelframe(grFrame, text='Gridlines', padding=2)
	if (is.na(newDef$xtck))
		xtckVar <- tclVar(0)
	else
		xtckVar <- tclVar(1)
	xgridButton <- ttkcheckbutton(gridFrame, variable=xtckVar, text='x-axis')
	
	##create y-axis gridlines checkbox
	if (is.na(newDef$ytck))
		ytckVar <- tclVar(0)
	else
		ytckVar <- tclVar(1)
	ygridButton <- ttkcheckbutton(gridFrame, variable=ytckVar, text='y-axis')
	
	##create text magnification options
	cexFrame <- ttklabelframe(grFrame, text='Text magnification', padding=4)
	cexMainLabel <- ttklabel(cexFrame, text='Main plot')
	titleLabel <- ttklabel(cexFrame, text='title:')
	cexMainVar <- tclVar(newDef$cex.main)
	titleEntry <-	ttkentry(cexFrame, textvariable=cexMainVar, width=8,
			justify='center')
	axesLabel <- ttklabel(cexFrame, text='axes:')
	cexAxesVar <- tclVar(newDef$cex.axis)
	axesEntry <-	ttkentry(cexFrame, textvariable=cexAxesVar, width=8,
			justify='center')
	
	cexMultiLabel <- ttklabel(cexFrame, text='Multi file')
	roiMultiLabel <- ttklabel(cexFrame, text='ROI names:')
	cexRoiMultiVar <- tclVar(newDef$cex.roi.multi)
	roiMultiEntry <-	ttkentry(cexFrame, textvariable=cexRoiMultiVar, width=8,
			justify='center')
	fileLabel <- ttklabel(cexFrame, text='file names:')
	cexFilesMultiVar <- tclVar(newDef$cex.files.multi)
	fileEntry <-	ttkentry(cexFrame, textvariable=cexFilesMultiVar, width=8,
			justify='center')
	
	cexSubLabel <- ttklabel(cexFrame, text='Subplot')
	cexRoiSubVar <- tclVar(newDef$cex.roi.sub)
	roiSubEntry <-	ttkentry(cexFrame, textvariable=cexRoiSubVar, width=8,
			justify='center')
	
	##add widgets to grFrame	
	tkgrid(marFrame, row=1, column=1, padx=5, pady=3, sticky='we')
	tkgrid(topLabel, row=2, column=1, padx=3, pady=3, sticky='e')
	tkgrid(bottomLabel, row=3, column=1, padx=3, pady=3, sticky='e')
	tkgrid(leftLabel, row=4, column=1, padx=3, pady=3, sticky='e')
	tkgrid(rightLabel, row=5, column=1, padx=3, pady=3, sticky='e')
	
	tkgrid(marMainLabel, row=1, column=2, padx=4, pady=c(0, 1))
	tkgrid(topMarEntry, row=2, column=2, padx=4, pady=1)
	tkgrid(botMarEntry, row=3, column=2, padx=4, pady=1)
	tkgrid(leftMarEntry, row=4, column=2, padx=4, pady=1)
	tkgrid(rightMarEntry, row=5, column=2, padx=4, pady=1)
	
	tkgrid(marSubLabel, row=1, column=3, padx=4, pady=c(0, 1))
	tkgrid(topSubMarEntry, row=2, column=3, padx=4, pady=1)
	tkgrid(botSubMarEntry, row=3, column=3, padx=4, pady=1)
	tkgrid(leftSubMarEntry, row=4, column=3, padx=4, pady=1)
	tkgrid(rightSubMarEntry, row=5, column=3, padx=4, pady=1)
	
	tkgrid(marMultiLabel, row=1, column=4, padx=c(4, 7), pady=c(0, 1))
	tkgrid(topMultiMarEntry, row=2, column=4, padx=c(4, 7), pady=1)
	tkgrid(botMultiMarEntry, row=3, column=4, padx=c(4, 7), pady=1)
	tkgrid(leftMultiMarEntry, row=4, column=4, padx=c(4, 7), pady=1)
	tkgrid(rightMultiMarEntry, row=5, column=4, padx=c(4, 7), pady=1)
	
	tkgrid(gridFrame, row=1, column=2, padx=5, pady=3, sticky='nwe')
	tkgrid(xgridButton, row=1, column=1, padx=4, pady=5)
	tkgrid(ygridButton, row=2, column=1, padx=4, pady=5)
	
	tkgrid(cexFrame, row=2, column=1, columnspan=2, padx=5, pady=6, sticky='we')
	tkgrid(titleLabel, row=2, column=1, padx=c(8, 2), pady=1, sticky='e')
	tkgrid(axesLabel, row=3, column=1, padx=c(8, 2), pady=1, sticky='e')
	tkgrid(cexMainLabel, row=1, column=2, padx=3, pady=c(0, 1))
	tkgrid(titleEntry, row=2, column=2, padx=3, pady=1, sticky='e')
	tkgrid(axesEntry, row=3, column=2, padx=3, pady=1, sticky='e')
	
	tkgrid(roiMultiLabel, row=2, column=3, padx=c(8, 3), pady=1, sticky='e')
	tkgrid(fileLabel, row=3, column=3, padx=c(8, 3), pady=1, sticky='e')
	tkgrid(cexMultiLabel, row=1, column=4, pady=c(0, 1))
	tkgrid(roiMultiEntry, row=2, column=4, padx=3, pady=1, sticky='e')
	tkgrid(fileEntry, row=3, column=4, padx=3, pady=1, sticky='e')
	
	tkgrid(cexSubLabel, row=1, column=6, padx=c(12, 4), pady=c(0, 1))
	tkgrid(roiSubEntry, row=2, column=6, padx=c(12, 4), pady=1, sticky='e')
	
	#####create widgets for coFrame
	##color change function
	colorChange <- function(colorVars, canvases){
		usrColor <- tclvalue(tcl("tk_chooseColor", parent=dlg, 
						initialcolor=tclvalue(colorVars[[1]])))
		if (nzchar(usrColor)){
			for (i in seq_along(colorVars))
				tclObj(colorVars[[i]]) <- usrColor
			for (i in seq_along(canvases))
				tkconfigure(canvases[[i]], background=usrColor)
		}
	}
	
	##create roi box color buttons
	roiColFrame <- ttklabelframe(coFrame, text='ROI colors')
	boxColLabel <- ttklabel(roiColFrame, text='Boxes:')
	aboxColVar <- tclVar(newDef$roi.bcolor[1])
	aboxColButton <- ttkbutton(roiColFrame, text='Active', width=9, 
			command=function(...) colorChange(list(aboxColVar), list(aboxCanvas)))
	aboxCanvas <- tkcanvas(roiColFrame, width=35, height=20, 
			background=newDef$roi.bcolor[1], relief='sunken', borderwidth=2)
	
	iboxColVar <- tclVar(newDef$roi.bcolor[2])
	iboxColButton <- ttkbutton(roiColFrame, text='Inactive', width=9, 
			command=function(...) colorChange(list(iboxColVar), list(iboxCanvas)))
	iboxCanvas <- tkcanvas(roiColFrame, width=35, height=20, 
			background=newDef$roi.bcolor[2], relief='sunken', borderwidth=2)
	
	##create text color buttons
	textColLabel <- ttklabel(roiColFrame, text='Labels:')
	atextColVar <- tclVar(newDef$roi.tcolor[1])
	atextColButton <- ttkbutton(roiColFrame, text='Active', width=9, 
			command=function(...) colorChange(list(atextColVar), list(atextCanvas)))
	atextCanvas <- tkcanvas(roiColFrame, width=35, height=20, 
			background=newDef$roi.tcolor[1], relief='sunken', borderwidth=2)
	
	itextColVar <- tclVar(newDef$roi.tcolor[2])
	itextColButton <- ttkbutton(roiColFrame, text='Inactive', width=9, 
			command=function(...) colorChange(list(itextColVar), list(itextCanvas)))
	itextCanvas <- tkcanvas(roiColFrame, width=35, height=20, 
			background=newDef$roi.tcolor[2], relief='sunken', borderwidth=2)
	
	##create axis color button
	fgColVar <- labColVar <- mainColVar <- subColVar <- colVar <- axColVar <- 
			tclVar(newDef$col.axis)
	axColButton <- ttkbutton(coFrame, text='Axes', width=11, 
			command=function(...) colorChange(list(axColVar, fgColVar, labColVar,
								mainColVar, subColVar, colVar), list(axCanvas)))
	axCanvas <- tkcanvas(coFrame, width=40, height=20, background=newDef$col.axis,
			relief='sunken', borderwidth=2)
	
	##create peak color button
	peakColVar <- tclVar(newDef$peak.color)
	peakColButton <- ttkbutton(coFrame, text='Peak labels', width=11, 
			command=function(...) colorChange(list(peakColVar), list(peakCanvas)))
	peakCanvas <- tkcanvas(coFrame, width=40, height=20, 
			background=newDef$peak.color, relief='sunken', borderwidth=2)
	
	##create background color button
	bgColVar <- tclVar(newDef$bg)
	bgColButton <- ttkbutton(coFrame, text='BG', width=11, 
			command=function(...) colorChange(list(bgColVar), list(bgCanvas)))
	bgCanvas <- tkcanvas(coFrame, width=40, height=20, background=newDef$bg, 
			relief='sunken', borderwidth=2)
	
	##create projection color button
	projColVar <- tclVar(newDef$proj.color)
	projColButton <- ttkbutton(coFrame, text='1D', width=11, 
			command=function(...) colorChange(list(projColVar), list(projCanvas)))
	projCanvas <- tkcanvas(coFrame, width=40, height=20, 
			background=newDef$proj.color, relief='sunken', borderwidth=2)
	
	##create positive contour color button
	posColVar <- tclVar(newDef$pos.color)
	posColButton <- ttkbutton(coFrame, text='+ Contour', width=11, 
			command=function(...) colorChange(list(posColVar), list(posCanvas)))
	posCanvas <- tkcanvas(coFrame, width=40, height=20, 
			background=newDef$pos.color, relief='sunken', borderwidth=2)
	
	##create negative contour color button
	negColVar <- tclVar(newDef$neg.color)
	negColButton <- ttkbutton(coFrame, text='- Contour', width=11, 
			command=function(...) colorChange(list(negColVar), list(negCanvas)))
	negCanvas <- tkcanvas(coFrame, width=40, height=20, 
			background=newDef$neg.color, relief='sunken', borderwidth=2)
	
	##create high contrast colors button
	onContrast <- function(){
		tclObj(aboxColVar) <- 'red'
		tkconfigure(aboxCanvas, background='red')
		tclObj(iboxColVar) <- 'black'
		tkconfigure(iboxCanvas, background='black')
		tclObj(atextColVar) <- 'red'
		tkconfigure(atextCanvas, background='red')
		tclObj(itextColVar) <- 'black'
		tkconfigure(itextCanvas, background='black')
		tclObj(axColVar) <- 'black'
		tclObj(fgColVar) <- 'black'
		tclObj(labColVar) <- 'black'
		tclObj(mainColVar) <- 'black'
		tclObj(subColVar) <- 'black'
		tclObj(colVar) <- 'black'	
		tkconfigure(axCanvas, background='black')
		tclObj(bgColVar) <- 'white'
		tkconfigure(bgCanvas, background='white')
		tclObj(posColVar) <- 'black'
		tkconfigure(posCanvas, background='black')
		tclObj(peakColVar) <- 'black'
		tkconfigure(peakCanvas, background='black')
		tclObj(projColVar) <- 'black'
		tkconfigure(projCanvas, background='black')
		tclObj(negColVar) <- 'black'
		tkconfigure(negCanvas, background='black')
	}
	hcColButton <- ttkbutton(coFrame, text='Hight Contrast', width=15, 
			command=onContrast)
	
	##create default colors button
	onDefCol <- function(){
		defSet <- createObj('defaultSettings', returnObj=TRUE)
		tclObj(aboxColVar) <- defSet$roi.bcolor[1]
		tkconfigure(aboxCanvas, background=defSet$roi.bcolor[1])
		tclObj(iboxColVar) <- defSet$roi.bcolor[2]
		tkconfigure(iboxCanvas, background=defSet$roi.bcolor[2])
		tclObj(atextColVar) <- defSet$roi.tcolor[1]
		tkconfigure(atextCanvas, background=defSet$roi.tcolor[1])
		tclObj(itextColVar) <- defSet$roi.tcolor[2]
		tkconfigure(itextCanvas, background=defSet$roi.tcolor[2])
		tclObj(axColVar) <- defSet$col.axis
		tclObj(fgColVar) <- defSet$fg
		tclObj(labColVar) <- defSet$col.lab
		tclObj(mainColVar) <- defSet$col.main
		tclObj(subColVar) <- defSet$col.sub
		tclObj(colVar) <- defSet$col
		tkconfigure(axCanvas, background='white')
		tclObj(bgColVar) <- defSet$bg
		tkconfigure(bgCanvas, background=defSet$bg)
		tclObj(posColVar) <- defSet$pos.color
		tkconfigure(posCanvas, background=defSet$pos.color)
		tclObj(peakColVar) <- defSet$peak.color
		tkconfigure(peakCanvas, background=defSet$peak.color)
		tclObj(projColVar) <- defSet$proj.color
		tkconfigure(projCanvas, background=defSet$proj.color)
		tclObj(negColVar) <- defSet$neg.color
		tkconfigure(negCanvas, background=defSet$neg.color)
	}
	defColButton <- ttkbutton(coFrame, text='Default Colors', width=15, 
			command=onDefCol)
	
	##add widgets to coFrame
	tkgrid(roiColFrame, column=1, columnspan=4, row=1, padx=10, pady=10)
	tkgrid(boxColLabel, column=1, row=1, padx=c(15, 3), pady=4)
	tkgrid(aboxColButton, column=2, row=1, padx=2, pady=4)
	tkgrid(aboxCanvas, column=3, row=1, padx=c(2, 20), pady=4)
	tkgrid(iboxColButton, column=4, row=1, padx=2, pady=4)
	tkgrid(iboxCanvas, column=5, row=1, padx=c(2, 15), pady=4)
	
	tkgrid(textColLabel, column=1, row=2, padx=c(15, 3), pady=4)
	tkgrid(atextColButton, column=2, row=2, padx=2, pady=4)
	tkgrid(atextCanvas, column=3, row=2, padx=c(2, 20), pady=4)
	tkgrid(itextColButton, column=4, row=2, padx=2, pady=4)
	tkgrid(itextCanvas, column=5, row=2, padx=c(2, 15), pady=4)
	
	tkgrid(axColButton, column=1, row=2, pady=c(10, 2), padx=c(35, 2))
	tkgrid(axCanvas, column=2, row=2, pady=c(10, 2), padx=c(2, 15))
	
	tkgrid(bgColButton, column=1, row=3, pady=2, padx=c(35, 2))
	tkgrid(bgCanvas, column=2, row=3, pady=2, padx=c(2, 15))
	
	tkgrid(posColButton, column=1, row=4, pady=2, padx=c(35, 2))
	tkgrid(posCanvas, column=2, row=4, pady=2, padx=c(2, 15))
	
	tkgrid(peakColButton, column=3, row=2, pady=c(10, 2), padx=c(15, 2))
	tkgrid(peakCanvas, column=4, row=2, pady=c(10, 2), padx=c(2, 35))
	
	tkgrid(projColButton, column=3, row=3, pady=2, padx=c(15, 2))
	tkgrid(projCanvas, column=4, row=3, pady=2, padx=c(2, 35))
	
	tkgrid(negColButton, column=3, row=4, pady=2, padx=c(15, 2))
	tkgrid(negCanvas, column=4, row=4, pady=2, padx=c(2, 35))
	
	tkgrid(hcColButton, column=1, columnspan=2, row=5, pady=c(15, 5), 
			padx=c(77, 0), sticky='w')
	tkgrid(defColButton, column=3, columnspan=2, row=5, pady=c(15, 5), 
			padx=c(4, 0), sticky='w')
	
	
	
	
	#####create widgets for psFrame
	##create plot type frame
	typeFrame <- ttklabelframe(psFrame, text='Plot type', padding=4)
	typeVar <- tclVar(switch(newDef$type, 'auto'='auto', 'image'='image', 
					'contour'='contour', 'filled'='filled contour', 'l'='line', 
					'p'='points', 'b'='both'))
	typeBox <- ttkcombobox(typeFrame, textvariable=typeVar, values=c('auto', 
					'image', 'contour', 'filled contour', 'line', 'points', 'both'), 
			exportselection=FALSE, width=11, state='readonly')
	
	##create 1D settings frame
	onedFrame <- ttklabelframe(psFrame, text='1D settings', padding=4)
	pos1DLabel <- ttklabel(onedFrame, text='Baseline (0 - 99):')
	pos1DVar <- tclVar(newDef$position.1D)
	pos1DEntry <- ttkentry(onedFrame, textvariable=pos1DVar, width=12,
			justify='center')
	
	offLabel <- ttklabel(onedFrame, text='Offset (-100 - 100):')
	offVar <- tclVar(newDef$offset)
	offEntry <- ttkentry(onedFrame, textvariable=offVar, width=12,
			justify='center')
	
	##create 2D settings frame
	twodFrame <- ttklabelframe(psFrame, text='2D settings', padding=4)
	conLabel <- ttklabel(twodFrame, text='Contour display:')
	if (all(newDef$conDisp))
		conVar <- tclVar('both')
	else if (newDef$conDisp[1])
		conVar <- tclVar('positive')
	else
		conVar <- tclVar('negative')
	conEntry <- ttkcombobox(twodFrame, textvariable=conVar, values=c('positive', 
					'negative', 'both'), width=9, exportselection=FALSE, state='readonly')
	
	clevelLabel <- ttklabel(twodFrame, text='Contour threshold:\n(positive)')
	clevelVar <- tclVar(newDef$clevel)
	clevelEntry <- ttkentry(twodFrame, textvariable=clevelVar, width=12,
			justify='center')
	
	nlevelsLabel <- ttklabel(twodFrame, text='Contour levels:\n(0 - 1000)')
	nlevelsVar <- tclVar(newDef$nlevels)
	nlevelsEntry <- ttkentry(twodFrame, textvariable=nlevelsVar, width=12,
			justify='center')
	
	##create projection settings frame
	projFrame <- ttklabelframe(psFrame, text='Projections', padding=4)
	filterLabel <- ttklabel(projFrame, text='Type:')
	if (isTRUE(all.equal(newDef$filter, function(x){max(abs(x))})))
		filterVar <- tclVar('absolute max')
	else if (isTRUE(all.equal(newDef$filter, pseudo1D)))
		filterVar <- tclVar('pseudo1D')
	else if (isTRUE(all.equal(newDef$filter,  function(x){max(x)})))
		filterVar <- tclVar('max')
	else
		filterVar <- tclVar('min')
	
	filterBox <- ttkcombobox(projFrame, textvariable=filterVar, width=11, 
			values=c('pseudo1D', 'max', 'min', 'absolute max'), exportselection=FALSE, 
			state='readonly')
	
	dispLabel <- ttklabel(projFrame, text='Display:')
	dispVar <- tclVar(switch(newDef$proj.type, 'l'='line', 'p'='points', 
					'b'='both'))
	dispBox <- ttkcombobox(projFrame, textvariable=dispVar, width=11, 
			values=c('line', 'points', 'both'), exportselection=FALSE, 
			state='readonly')
	
	dimLabel <- ttklabel(projFrame, text='Dimension:')
	if (newDef$proj.direct == 1)
		dimVar <- tclVar('direct')
	else
		dimVar <- tclVar('indirect')
	dimBox <- ttkcombobox(projFrame, textvariable=dimVar, width=11,	
			values=c('direct', 'indirect'), exportselection=FALSE, state='readonly')
	
	##add widgets to psFrame
	tkgrid(typeFrame, row=1, column=1, padx=4, pady=c(6, 0), sticky='ns')
	tkgrid(typeBox, pady=2, padx=5)
	
	tkgrid(onedFrame, row=2, column=1, padx=4, pady=c(4, 6), sticky='ns')
	tkgrid(pos1DLabel, row=1, column=1, pady=2, sticky='w')
	tkgrid(pos1DEntry, row=2, column=1, pady=3, padx=c(6, 0))
	tkgrid(offLabel, row=3, column=1, pady=c(6, 2), sticky='w')
	tkgrid(offEntry, row=4, column=1, pady=3, padx=c(6, 0))
	
	tkgrid(twodFrame, row=1, rowspan=2, column=2, padx=4, pady=6, sticky='ns')
	tkgrid(conLabel, row=1, column=1, columnspan=2, pady=c(0, 2), sticky='w')
	tkgrid(conEntry, row=2, column=1, columnspan=2,  pady=2, padx=c(6, 4))
	tkgrid(clevelLabel, row=3, column=1, columnspan=2,  pady=c(4, 2), sticky='w')
	tkgrid(clevelEntry, row=4, column=1, columnspan=2,  pady=2, padx=c(6, 4))
	tkgrid(nlevelsLabel, row=5, column=1, columnspan=2,  pady=c(4, 2), sticky='w')
	tkgrid(nlevelsEntry, row=6, column=1, columnspan=2,  pady=2, padx=c(6, 4))
	
	tkgrid(projFrame, row=1, rowspan=2, column=3, padx=4, pady=6, sticky='ns')
	tkgrid(filterLabel, row=1, column=1, pady=c(4, 6), sticky='w')
	tkgrid(filterBox, row=2, column=1, padx=6)
	tkgrid(dispLabel, row=3, column=1, pady=c(8, 6), sticky='w')
	tkgrid(dispBox, row=4, column=1, padx=6)
	tkgrid(dimLabel, row=5, column=1, pady=c(8, 6), sticky='w')
	tkgrid(dimBox, row=6, column=1, padx=6)
	
	#####create widgets for ppFrame
	##create peak pch entry box
	markerFrame <- ttklabelframe(ppFrame, text='Peak markers', padding=4)
	pchLabel <- ttklabel(markerFrame, text='Symbol:')
	pchVar <- tclVar(newDef$peak.pch)
	pchEntry <- ttkentry(markerFrame, textvariable=pchVar, width=10, 
			justify='center')
	
	##create peak cex entry box
	peakCexLabel <- ttklabel(markerFrame, text='Magnification:')
	peakCexVar <- tclVar(newDef$peak.cex)
	peakCexEntry <- ttkentry(markerFrame, textvariable=peakCexVar, width=10, 
			justify='center')
	
	##create peak label position combo box
	peakPosLabel <- ttklabel(markerFrame, text='Label position:')
	peakPosVar <- tclVar(newDef$peak.labelPos)
	peakPosBox <- ttkcombobox(markerFrame, textvariable=peakPosVar, width=7, 
			values=c('top', 'bottom', 'left', 'right', 'center'), 
			exportselection=FALSE, state='readonly')
	
	##create peak noiseFilt combo box
	pickSetFrame <- ttklabelframe(ppFrame, text='Pick settings', padding=4)
	peakFiltLabel <- ttklabel(pickSetFrame, text='Noise filter:')
	if (newDef$peak.noiseFilt == 2)
		peakFiltVar <- tclVar('strong')
	else if (newDef$peak.noiseFilt == 1)
		peakFiltVar <- tclVar('weak')
	else
		peakFiltVar <- tclVar('none')
	peakFiltBox <- ttkcombobox(pickSetFrame, textvariable=peakFiltVar, width=7, 
			values=c('none', 'weak', 'strong'), exportselection=FALSE, 
			state='readonly')
	
	##create peak threshold entry box
	peakThreshLabel <- ttklabel(pickSetFrame, text='1D threshold:')
	peakThreshVar <- tclVar(newDef$thresh.1D)
	peakThreshEntry <- ttkentry(pickSetFrame, textvariable=peakThreshVar, 
			width=10, justify='center')
	
	##add widgets to ppFrame
	tkgrid(markerFrame, column=1, row=1, padx=10, pady=8)
	tkgrid(pchLabel, column=1, row=1, pady=c(0, 6), sticky='w')
	tkgrid(pchEntry, column=1, row=2, padx=c(15, 5))
	tkgrid(peakCexLabel, column=1, row=3, pady=c(10, 6), sticky='w')
	tkgrid(peakCexEntry, column=1, row=4, padx=c(15, 5), pady=c(0, 4))
	tkgrid(peakPosLabel, column=2, row=1, pady=c(0, 6), sticky='w')
	tkgrid(peakPosBox, column=2, row=2, padx=c(15, 8))
	
	tkgrid(pickSetFrame, column=2, row=1, pady=8)
	tkgrid(peakFiltLabel, column=1, row=1, pady=c(0, 6), sticky='w')
	tkgrid(peakFiltBox, column=1, row=2, padx=c(15, 6))
	tkgrid(peakThreshLabel, column=1, row=3, pady=c(10, 6), sticky='w')
	tkgrid(peakThreshEntry, column=1, row=4, padx=c(15, 5), pady=c(0, 4))
	
	#####create widgets for roiFrame
	##create appearance frame and labels
	appFrame <- ttklabelframe(roiFrame, text='Appearance')
	activeLabel <- ttklabel(appFrame, text='Active')
	inactiveLabel <- ttklabel(appFrame, text='Inactive')
	
	##create box type combo boxes
	ltyLabel <- ttklabel(appFrame, text='Box type:')
	altyVar <- tclVar(newDef$roi.lty[1])
	altyBox <- ttkcombobox(appFrame, textvariable=altyVar, width=8, 
			values=c('solid', 'dashed', 'dotted', 'dotdash', 'longdash', 'twodash', 
					'blank'), justify='center', exportselection=FALSE, state='readonly')
	iltyVar <- tclVar(newDef$roi.lty[2])
	iltyBox <- ttkcombobox(appFrame, textvariable=iltyVar, width=8, 
			values=c('solid', 'dashed', 'dotted', 'dotdash', 'longdash', 'twodash', 
					'blank'), justify='center', exportselection=FALSE, state='readonly')
	
	##create line width entry boxes
	lwdLabel <- ttklabel(appFrame, text='Line width:')
	alwdVar <- tclVar(newDef$roi.lwd[1])
	alwdEntry <- ttkentry(appFrame, textvariable=alwdVar, width=11, 
			justify='center')
	ilwdVar <- tclVar(newDef$roi.lwd[2])
	ilwdEntry <- ttkentry(appFrame, textvariable=ilwdVar, width=11, 
			justify='center')
	
	##create text magnification entry boxes
	roiCexLabel <- ttklabel(appFrame, text='Magnification:')
	acexVar <- tclVar(newDef$roi.cex[1])
	acexEntry <- ttkentry(appFrame, textvariable=acexVar, width=11, 
			justify='center')
	icexVar <- tclVar(newDef$roi.cex[2])
	icexEntry <- ttkentry(appFrame, textvariable=icexVar, width=11, 
			justify='center')
	
	##create label horizontal adjustment entry box
	roiPosLabel <- ttklabel(appFrame, text='Label position:')
	roiPosVar <- tclVar(newDef$roi.labelPos[1])
	roiPosBox <- ttkcombobox(appFrame, textvariable=roiPosVar, width=9, 
			values=c('top', 'bottom', 'left', 'right', 'center'), 
			exportselection=FALSE, state='readonly')
	
	##configure roi size widgets
	onSize <- function(){
		
		##configure padding widgets
		if (tclvalue(fixedW1) != '0' && tclvalue(fixedW2) != '0')
			padState <- 'disabled'
		else
			padState <- 'normal'
		tkconfigure(roiPadLabel, state=padState)
		tkconfigure(roiPadEntry, state=padState)
		
		##configure w1 size widgets
		if (tclvalue(fixedW1) == '0'){
			w1State <- 'disabled'
			tclObj(roiW1Var) <- 0
		}else
			w1State <- 'normal'
		tkconfigure(roiW1Entry, state=w1State)
		
		##configure w2 size widgets
		if (tclvalue(fixedW2) == '0'){
			w2State <- 'disabled'
			tclObj(roiW2Var) <- 0
		}else
			w2State <- 'normal'
		tkconfigure(roiW2Entry, state=w2State)
	}
	
	##create ROI fixed w1 size checkbutton
	autoFrame <- ttklabelframe(roiFrame, text='Auto generation settings', 
			padding=4)
	roiSizeLabel <- ttklabel(autoFrame, text='ROI size:')
	if (newDef$roi.w1 == 0){
		fixedW1 <- tclVar(0)
		w1State <- 'disabled'
	}else{
		fixedW1 <- tclVar(1)
		w1State <- 'normal'
	}
	roiW1Button <- ttkcheckbutton(autoFrame, variable=fixedW1, text='Fixed W1', 
			command=onSize)	
	
	##create ROI fixed w2 size checkbutton
	if (newDef$roi.w2 == 0){
		fixedW2 <- tclVar(0)
		w2State <- 'disabled'
	}else{
		fixedW2 <- tclVar(1)
		w2State <- 'normal'
	}
	roiW2Button <- ttkcheckbutton(autoFrame, variable=fixedW2, text='Fixed W2', 
			command=onSize)	
	
	##create w1 size entry box
	roiW1Var <- tclVar(newDef$roi.w1)
	roiW1Entry <- ttkentry(autoFrame, textvariable=roiW1Var, width=7, 
			justify='center', state=w1State)
	
	##create w2 size entry box
	roiW2Var <- tclVar(newDef$roi.w2)
	roiW2Entry <- ttkentry(autoFrame, textvariable=roiW2Var, width=7, 
			justify='center', state=w2State)
	
	##create w2 size entry box
	if (newDef$roi.w1 && newDef$roi.w2)
		padState <- 'disabled'
	else
		padState <- 'normal'
	roiPadLabel <- ttklabel(autoFrame, text='Padding (%)', state=padState)
	roiPadVar <- tclVar(newDef$roi.pad)
	roiPadEntry <- ttkentry(autoFrame, textvariable=roiPadVar, width=7, 
			justify='center', state=padState)
	
	##create noise filter entry box
	roiFiltLabel <- ttklabel(autoFrame, text='Noise filter:')
	if (newDef$roi.noiseFilt == 2)
		roiFiltVar <- tclVar('strong')
	else if (newDef$roi.noiseFilt == 1)
		roiFiltVar <- tclVar('weak')
	else
		roiFiltVar <- tclVar('none')
	roiFiltBox <- ttkcombobox(autoFrame, textvariable=roiFiltVar, width=7, 
			values=c('none', 'weak', 'strong'), exportselection=FALSE, 
			state='readonly')
	
	##add widgets to roiFrame
	tkgrid(appFrame, column=1, row=1, padx=6, pady=8, sticky='we')
	tkgrid(activeLabel, column=2, row=1, pady=1)
	tkgrid(inactiveLabel, column=3, row=1, pady=1)
	
	tkgrid(ltyLabel, column=1, row=2, padx=3, pady=1, sticky='e')
	tkgrid(altyBox, column=2, row=2, padx=4, pady=1)
	tkgrid(iltyBox, column=3, row=2, padx=4, pady=1)
	
	tkgrid(lwdLabel, column=1, row=3, padx=3, pady=1, sticky='e')
	tkgrid(alwdEntry, column=2, row=3, padx=4, pady=1)
	tkgrid(ilwdEntry, column=3, row=3, padx=4, pady=1)
	
	tkgrid(roiCexLabel, column=1, row=4, padx=3, pady=1, sticky='e')
	tkgrid(acexEntry, column=2, row=4, padx=4, pady=c(1, 4))
	tkgrid(icexEntry, column=3, row=4, padx=4, pady=c(1, 4))
	
	tkgrid(roiPosLabel, column=4, row=1, padx=8, pady=1)
	tkgrid(roiPosBox, column=4, row=2, padx=c(16, 6), pady=3)
	
	tkgrid(autoFrame, column=1, row=2, padx=6, pady=8, sticky='we')
	tkgrid(roiSizeLabel, column=1, row=1, pady=2, padx=4, sticky='w')
	tkgrid(roiW1Button, column=1, row=2, padx=6)
	tkgrid(roiW1Entry, column=1, row=3, padx=6, pady=c(3, 5))
	
	tkgrid(roiW2Button, column=2, row=2, padx=6)
	tkgrid(roiW2Entry, column=2, row=3, padx=6, pady=c(3, 5))
	
	tkgrid(roiPadLabel, column=3, row=2, padx=6)
	tkgrid(roiPadEntry, column=3, row=3, padx=6, pady=c(3, 5))
	
	tkgrid(roiFiltLabel, column=4, row=1, padx=6, pady=3, sticky='w')
	tkgrid(roiFiltBox, column=4, row=2, padx=15, pady=3)
	
	#####create widgets for bottomFrame
	##create help button
	bottomFrame <- ttkframe(dlg)
	onHelp <- function(){
		myHelp('user_manual', TRUE)
	}
	helpButton <- ttkbutton(bottomFrame, text='?', width=3, command=onHelp)
	
	##saves current set of preferences
	savePref <- function(){
		
		##get values for the variables in the GUI
		varList <- list(list(mainWdVar, mainHtVar), list(subWdVar, subHtVar), 
				list(multiWdVar, multiHtVar), sdiVar, updateVar, backupVar, dirVar, 
				list(botMarVar, leftMarVar, topMarVar, rightMarVar), 
				list(botSubMarVar, leftSubMarVar, topSubMarVar, rightSubMarVar), 
				list(botMultiMarVar, leftMultiMarVar, topMultiMarVar, rightMultiMarVar),
				xtckVar, ytckVar, cexMainVar, cexAxesVar, cexFilesMultiVar, 
				cexRoiMultiVar, cexRoiSubVar,  list(aboxColVar, iboxColVar), 
				list(atextColVar, itextColVar), axColVar, fgColVar, labColVar, 
				mainColVar, subColVar, colVar, peakColVar, bgColVar, projColVar, 
				posColVar, negColVar, typeVar, pos1DVar, offVar, conVar, clevelVar, 
				nlevelsVar, filterVar, dispVar, dimVar, pchVar, peakCexVar, peakPosVar, 
				peakFiltVar, peakThreshVar, list(alwdVar, ilwdVar), 
				list(altyVar, iltyVar),	list(acexVar, icexVar), roiPosVar, roiW1Var, 
				roiW2Var, roiPadVar, roiFiltVar)
		valList <- as.list(rep(NA, length(varList)))
		for (i in seq_along(varList)){
			if (length(varList[[i]]) > 1){
				vectorVals <- NULL
				for (j in varList[[i]])
					vectorVals <- c(vectorVals, tclvalue(j))
				valList[[i]] <- vectorVals
			}else
				valList[[i]] <- tclvalue(varList[[i]])
		}
		varNames <- c('size.main', 'size.sub', 'size.multi', 'sdi', 'update', 
				'autoBackup', 'wd', 'mar', 'mar.sub', 'mar.multi', 'xtck', 'ytck', 
				'cex.main', 'cex.axis', 'cex.files.multi', 'cex.roi.multi', 
				'cex.roi.sub', 'roi.bcolor', 'roi.tcolor', 'col.axis', 'fg', 'col.lab', 
				'col.main', 'col.sub', 'col', 'peak.color', 'bg', 'proj.color', 
				'pos.color', 'neg.color', 'type', 'position.1D', 'offset', 'conDisp', 
				'clevel', 'nlevels', 'filter', 'proj.type', 'proj.direct', 'peak.pch', 
				'peak.cex', 'peak.labelPos', 'peak.noiseFilt', 'thresh.1D', 'roi.lwd', 
				'roi.lty', 'roi.cex', 'roi.labelPos', 'roi.w1', 'roi.w2', 'roi.pad', 
				'roi.noiseFilt')
		names(valList) <- varNames
		
		##format values from psFrame
		valList$type <- switch(valList$type, 'auto'='auto', 'image'='image', 
				'contour'='contour', 'filled contour'='filled', 'line'='l', 
				'points'='p', 'both'='b')
		if (valList$conDisp == 'both')
			valList$conDisp <- c(TRUE, TRUE)
		else if (valList$conDisp == 'positive')
			valList$conDisp <- c(TRUE, FALSE)
		else
			valList$conDisp <- c(FALSE, TRUE)
		if (valList$filter == 'absolute max')
			valList$filter <- function(x){max(abs(x))}
		else if (valList$filter == 'pseudo1D')
			valList$filter <- pseudo1D
		else if (valList$filter == 'max')
			valList$filter <- function(x){max(x)}
		else if (valList$filter == 'min')
			valList$filter <- function(x){min(x)}
		else
			valList$filter <- 'custom'
		valList$proj.type <- unlist(strsplit(valList$proj.type, ''))[1]
		if (valList$proj.direct == 'direct')
			valList$proj.direct <- 1
		else
			valList$proj.direct <- 2
		
		##format values from grFrame
		if (valList$xtck == '1')
			valList$xtck <- 1
		else
			valList$xtck <- NA_real_
		if (valList$ytck == '1')
			valList$ytck <- 1
		else
			valList$ytck <- NA_real_
		
		##format values from coFrame
		colorNames <- c('roi.bcolor', 'roi.tcolor', 'col.axis', 'fg', 'col.lab', 
				'col.main', 'col.sub', 'col', 'peak.color', 'bg', 'proj.color', 
				'pos.color', 'neg.color')
		for (i in colorNames){
			colVal <- valList[[i]]
			for (j in seq_along(colVal)){
				if (length(grep('{', colVal[j], fixed=TRUE)))
					valList[[i]][j] <- strsplit(strsplit(colVal[j], '{', 
									fixed=TRUE)[[1]][2], '}', fixed=TRUE)[[1]][1]
			}
		}
		
		##format values from ppFrame
		if (valList$peak.noiseFilt == 'strong')
			valList$peak.noiseFilt <- 2
		else if (valList$peak.noiseFilt == 'weak')
			valList$peak.noiseFilt <- 1
		else
			valList$peak.noiseFilt <- 0
		
		##format values from roiFrame
		if (valList$roi.noiseFilt == 'strong')
			valList$roi.noiseFilt <- 2
		else if (valList$roi.noiseFilt == 'weak')
			valList$roi.noiseFilt <- 1
		else
			valList$roi.noiseFilt <- 0
		
		##check, assign, and write out the new settings
		newDef[varNames] <- valList[varNames]
		newDef <- checkDef(newDef)
		prevSdi <- defaultSettings$sdi
		myAssign('defaultSettings', newDef, save.backup=FALSE)
		writeDef(defSet=newDef)
		
		##apply changes to globalSettings
		newGlobal <- globalSettings
		globalPars <- c('offset', 'position.1D', 'filter', 'proj.direct', 
				'proj.mode', 'proj.type', 'peak.disp', 'peak.noiseFilt', 'thresh.1D', 
				'peak.pch', 'peak.cex', 'peak.labelPos', 'roiMain', 'roiMax', 
				'roi.bcolor', 'roi.tcolor', 'roi.lwd', 'roi.lty', 'roi.cex', 
				'roi.labelPos', 'roi.noiseFilt', 'roi.w1', 'roi.w2', 'roi.pad', 
				'cex.roi.multi', 'cex.files.multi', 'cex.roi.sub', 'size.main', 
				'size.sub', 'size.multi', 'mar', 'mar.sub', 'mar.multi')
		for (i in globalPars)
			newGlobal[i] <- defaultSettings[i]
		myAssign('globalSettings', newGlobal)
		
		##apply SDI/MDI setting
		if (.Platform$OS.type == 'windows'  && .Platform$GUI == 'Rgui' && 
				prevSdi != defaultSettings$sdi){
			
			## Reads in the Rconsole file from the R user directory
			conPath <- file.path(Sys.getenv('R_USER'), 'Rconsole')
			if (file.exists(file.path(Sys.getenv('R_USER'), 'Rconsole'))){
				readCon <- file(conPath)
				conText <- readLines(readCon)
				close(readCon)
				file.remove(conPath)
				
				## Reads in the Rconsole file from the R home directory
			}else if (file.access(file.path(R.home('etc'), 'Rconsole'), 2) == 0){
				conPath <- file.path(R.home('etc'), 'Rconsole')
				readCon <- file(conPath)
				conText <- readLines(readCon)
				close(readCon)
				file.remove(conPath)
				
				## Copies Rconsole file from R home directory to R user directory
			}else{
				conPath <- file.path(R.home('etc'), 'Rconsole')
				readCon <- file(conPath)
				conText <- readLines(readCon)
				close(readCon)
				file.copy(conPath, file.path(Sys.getenv('R_USER'), 'Rconsole'))
			}
			
			## Writes out a new Rconsole file
			outFile <- conText
			file.create(conPath)
			writeCon <- file(conPath, 'w')
			matches <- NULL
			if (prevSdi){
				prevMdi <- 'no'
				newMdi <- 'yes'
			}else{
				prevMdi <- 'yes'
				newMdi <- 'no'
			}
			sdiOptions <- paste(c('MDI = ', 'MDI= ', 'MDI =', 'MDI='), prevMdi, 
					sep='')
			for (i in sdiOptions)
				matches <- c(matches, length(grep(i, outFile)) != 0)
			if (any(matches)){
				for (i in sdiOptions)
					outFile <- gsub(i, paste('MDI =', newMdi), outFile)
				writeLines(outFile, writeCon)
			}else
				writeLines(outFile, writeCon)
			close(writeCon)
		}
	}
	
	##updates current set of preferences to match defaultSettings
	onDefault <- function(tab=NULL, defSet=defaultSettings){
		
		##update general tab
		if (is.null(tab) || tab == 0){
			tclvalue(mainWdVar) <- defSet$size.main[1]
			tclvalue(mainHtVar) <- defSet$size.main[2]
			tclvalue(subWdVar) <- defSet$size.sub[1]
			tclvalue(subHtVar) <- defSet$size.sub[2]
			tclvalue(multiWdVar) <- defSet$size.multi[1]
			tclvalue(multiHtVar) <- defSet$size.multi[2]
			tclvalue(sdiVar) <- as.character(defSet$sdi)
			tclvalue(updateVar) <- as.character(defSet$update)
			tclvalue(backupVar) <- as.character(defSet$autoBackup)
			tclvalue(dirVar) <- defSet$wd
		}
		
		##reset graphics tab
		if (is.null(tab) || tab == 1){
			tclvalue(topMarVar) <- defSet$mar[3]
			tclvalue(botMarVar) <- defSet$mar[1]
			tclvalue(leftMarVar) <- defSet$mar[2]
			tclvalue(rightMarVar) <- defSet$mar[4]
			tclvalue(topSubMarVar) <- defSet$mar.sub[3]
			tclvalue(botSubMarVar) <- defSet$mar.sub[1]
			tclvalue(leftSubMarVar) <- defSet$mar.sub[2]
			tclvalue(rightSubMarVar) <- defSet$mar.sub[4]
			tclvalue(topMultiMarVar) <- defSet$mar.multi[3]
			tclvalue(botMultiMarVar) <- defSet$mar.multi[1]
			tclvalue(leftMultiMarVar) <- defSet$mar.multi[2]
			tclvalue(rightMultiMarVar) <- defSet$mar.multi[4]
			if (is.na(defSet$xtck))
				tclvalue(xtckVar) <- 0
			else
				tclvalue(xtckVar) <- 1
			if (is.na(defSet$ytck))
				tclvalue(ytckVar) <- 0
			else
				tclvalue(ytckVar) <- 1
			tclvalue(cexMainVar) <- defSet$cex.main
			tclvalue(cexAxesVar) <- defSet$cex.axis
			tclvalue(cexRoiMultiVar) <- defSet$cex.roi.multi
			tclvalue(cexFilesMultiVar) <- defSet$cex.files.multi
			tclvalue(cexRoiSubVar) <- defSet$cex.roi.sub
		}
		
		##reset colors tab
		if (is.null(tab) || tab == 2){
			tclvalue(aboxColVar) <- defSet$roi.bcolor[1]
			tkconfigure(aboxCanvas, background=defSet$roi.bcolor[1])
			tclvalue(iboxColVar) <- defSet$roi.bcolor[2]
			tkconfigure(iboxCanvas, background=defSet$roi.bcolor[2])
			tclvalue(atextColVar) <- defSet$roi.tcolor[1]
			tkconfigure(atextCanvas, background=defSet$roi.tcolor[1])
			tclvalue(itextColVar) <- defSet$roi.tcolor[2]
			tkconfigure(itextCanvas, background=defSet$roi.tcolor[2])
			tclvalue(fgColVar) <- tclvalue(labColVar) <- tclvalue(mainColVar) <- 
					tclvalue(subColVar) <- tclvalue(colVar) <- tclvalue(axColVar) <- 
					defSet$col.axis
			tkconfigure(axCanvas, background=defSet$col.axis)
			tclvalue(peakColVar) <- defSet$peak.color
			tkconfigure(peakCanvas, background=defSet$peak.color)
			tclvalue(bgColVar) <- defSet$bg
			tkconfigure(bgCanvas, background=defSet$bg)
			tclvalue(projColVar) <- defSet$proj.color
			tkconfigure(projCanvas, background=defSet$proj.color)
			tclvalue(posColVar) <- defSet$pos.color
			tkconfigure(posCanvas, background=defSet$pos.color)
			tclvalue(negColVar) <- defSet$neg.color
			tkconfigure(negCanvas, background=defSet$neg.color)
		}
		
		##reset plotting tab
		if (is.null(tab) || tab == 3){
			tclvalue(typeVar) <- switch(defSet$type, 'auto'='auto', 'image'='image', 
					'contour'='contour', 'filled'='filled contour', 'l'='line', 
					'p'='points', 'b'='both')
			tclvalue(pos1DVar) <- defSet$position.1D
			tclvalue(offVar) <- defSet$offset
			if (all(defSet$conDisp))
				tclvalue(conVar) <- 'both'
			else if (defSet$conDisp[1])
				tclvalue(conVar) <- 'positive'
			else
				tclvalue(conVar) <- 'negative'
			tclvalue(clevelVar) <- defSet$clevel
			tclvalue(nlevelsVar) <- defSet$nlevels
			if (isTRUE(all.equal(defSet$filter, function(x){max(abs(x))})))
				tclvalue(filterVar) <- 'absolute max'
			else if (isTRUE(all.equal(defSet$filter, pseudo1D)))
				tclvalue(filterVar) <- 'pseudo1D'
			else if (isTRUE(all.equal(defSet$filter,  function(x){max(x)})))
				tclvalue(filterVar) <- 'max'
			else
				tclvalue(filterVar) <- 'min'
			tclvalue(dispVar) <- switch(defSet$proj.type, 'l'='line', 'p'='points', 
					'b'='both')
			if (defSet$proj.direct == 1)
				tclvalue(dimVar) <- 'direct'
			else
				tclvalue(dimVar) <- 'indirect'
		}
		
		##reset peak picking tab
		if (is.null(tab) || tab == 4){
			tclvalue(pchVar) <- defSet$peak.pch
			tclvalue(peakCexVar) <- defSet$peak.cex
			tclvalue(peakPosVar) <- defSet$peak.labelPos
			if (defSet$peak.noiseFilt == 2)
				tclvalue(peakFiltVar) <- 'strong'
			else if (defSet$peak.noiseFilt == 1)
				tclvalue(peakFiltVar) <- 'weak'
			else
				tclvalue(peakFiltVar) <- 'none'
			tclvalue(peakThreshVar) <- defSet$thresh.1D
		}
		
		##reset ROIs tab
		if (is.null(tab) || tab == 5){
			tclvalue(altyVar) <- defSet$roi.lty[1]
			tclvalue(iltyVar) <- defSet$roi.lty[2]
			tclvalue(alwdVar) <- defSet$roi.lwd[1]
			tclvalue(ilwdVar) <- defSet$roi.lwd[2]
			tclvalue(acexVar) <- defSet$roi.cex[1]
			tclvalue(icexVar) <- defSet$roi.cex[2]
			tclvalue(roiPosVar) <- defSet$roi.labelPos[1]
			if (defSet$roi.w1)
				tclvalue(fixedW1) <- 1
			else
				tclvalue(fixedW1) <- 0
			tclvalue(roiW1Var) <- defSet$roi.w1
			if (defSet$roi.w2)
				tclvalue(fixedW2) <- 1
			else
				tclvalue(fixedW2) <- 0
			tclvalue(roiW2Var) <- defSet$roi.w2
			tclvalue(roiPadVar) <- defSet$roi.pad
			if (defSet$roi.noiseFilt == 2)
				tclvalue(roiFiltVar) <- 'strong'
			else if (defSet$roi.noiseFilt == 1)
				tclvalue(roiFiltVar) <- 'weak'
			else
				tclvalue(roiFiltVar) <- 'none'
		}
	}
	
	##create default button
	defaultButton <- ttkbutton(bottomFrame, text='Defaults', width=10, 
			command=function(...) onDefault(as.numeric(tkindex(epBook, 'current')), 
						createObj('defaultSettings', returnObj=TRUE)))
	
	##create OK button
	onOk <- function(){
		savePref()
		tkdestroy(dlg)
	}
	okButton <- ttkbutton(bottomFrame, text='OK', width=10, command=onOk)
	
	##create cancel button
	cancelButton <- ttkbutton(bottomFrame, text='Cancel', command=function(...)
				tkdestroy(dlg), width=10)
	
	##create apply all button
	onApply <- function(){
		
		##save preferences
		savePref()
		
		##close and redisplay splash screen (if open)
		prevDev <- dev.list()
		if (is.null(fileFolder) || !length(fileFolder)){
			if (length(prevDev)){
				for (i in prevDev)
					dev.off(i)
				if (2 %in% prevDev){
					if (.Platform$OS == 'windows')
						dev.new(title='Main Plot Window', 
								width=defaultSettings$size.main[1],
								height=defaultSettings$size.main[2])
					else
						X11(title='Main Plot Window', width=defaultSettings$size.main[1],	
								height=defaultSettings$size.main[2])
					splashScreen()
				}
			}
			return(invisible())
		}
		
		##update fileFolder
		newFolder <- fileFolder
		for (i in seq_along(newFolder)){
			newFolder[[i]]$graphics.par <- defaultSettings
			newFolder[[i]]$graphics.par$usr <- fileFolder[[i]]$graphics.par$usr
		}
		myAssign('fileFolder', newFolder)
		
		##close and reopen previously displayed devices
		if (length(prevDev)){
			for (i in prevDev)
				dev.off(i)
			if (2 %in% prevDev)
				dd()
			if (3 %in% prevDev)
				rvs()
			if (4 %in% prevDev)
				rvm()
		}
		
		##update preferences GUI
		onDefault()
	}
	applyButton <- ttkbutton(bottomFrame, text='Apply All', width=10, 
			command=onApply)
	
	##add button to bottom of gui
	tkgrid(bottomFrame, column=1, row=2, pady=c(0, 8), sticky='we')
	tkgrid(helpButton, column=1, row=2, padx=c(15, 10))
	tkgrid(defaultButton, column=2, row=2, padx=c(0, 40))
	tkgrid(okButton, column=3, row=2, padx=c(0, 6))
	tkgrid(cancelButton, column=4, row=2, padx=c(0, 6))
	tkgrid(applyButton, column=5, row=2, padx=c(0, 15))
	
	##make buttons a bit smaller on non-windows systems
	if (.Platform$OS.type != 'windows'){
		tkconfigure(browseButton, width=9)
		tkconfigure(defaultButton, width=9)
		tkconfigure(okButton, width=9)
		tkconfigure(cancelButton, width=9)
		tkconfigure(applyButton, width=9)
	}
	
	return(invisible())
}


#############################################################
##                                                          #
##             Conversion Functions                         #
##                                                          #
#############################################################

## Create a UCSF format spectrum
## outPath - character string; full file path for the newly created spectrum
## np - numeric; the number of points in each dimension
## nuc - character string; the nucleus names for each dimension
## sf - numeric; the spectrometer frequency
## sw - numeric; the sweep width (Hz) in each dimension (only required if 
##	writeShifts is set to FALSE, or for compatibility with Sparky)
## center - numeric; the center (PPM) of the spectrum in each dimension (only 
##	required if writeShifts is set to FALSE)
## upShift - numeric; the upfield chemical shift for the spectrum.
## downShift - numeric; the downfield chemical shift for the spectrum
## noiseEst - numeric; the noise estimate for the output spectrum, to be 
##	included in the output header
## data - numeric vector or matrix; the data for the spectrum as it would be 
##	returned by ucsf2D().  The first data point corresponds to the downfield-
##	most point for the spectrum. The last data point in the matrix corresponds 
##	to the upfield-most point for the spectrum. In other words, if you traverse 
##	the matrix by rows, data points in the matrix start at the bottom-left of 
##	the spectrum and move up and to the right (as the spectrum would normally be 
##	viewed)
## inFolder - list; data and file parameters for input spectrum.  This should 
##	match the	output format of ucsf2D().  If provided, fields from this list
##	will be used as values for the any other arguments that are not provided.
## writeShifts - logical; if TRUE, the upfield and downfield chemical shifts
##	are included in the header for the output file.
## cor - logical; if TRUE, the correction factor applied to the upfield
##	chemical shift, center chemical shift, and sweep width when the UCSF file 
##	was orignally read by rNMR will be negated when the new UCSF file is output.
##	In this case, the up and downfield chemical shifts must be provided.  This 
##	adjustment will not be applied to the upfield and downfield shifts 
##	themselves, but will be used in calculating the sweep width and center.
## writeNoise - logical; if TRUE, the noise estimate for the spectrum will be
##	included in the header for the output file.
## Note: file parameters for 2D spectra should be passed in vector format with 
##	the indirect dimension first
writeUcsf <- function(outPath, np, nuc, sf, sw, center, upShift, downShift, 
		noiseEst, data, inFolder, cor=FALSE, writeShifts=FALSE, writeNoise=FALSE){
	
	## Get output path
	if (missing(outPath))
		outPath <- mySave(defaultextension='.ucsf', title='Save spectrum', 
				filetypes=list('ucsf'='UCSF files'))
	if (!length(outPath) || !nzchar(outPath))
		return(invisible())
	
	## Assign arguments if inFolder is provided
	if (!missing(inFolder)){
		if (missing(np))
			np <- inFolder$file.par$matrix_size
		if (missing(nuc))
			nuc <- inFolder$file.par$nucleus
		if (missing(sf))
			sf <- inFolder$file.par$transmitter_MHz
		if (missing(sw))
			sw <- inFolder$file.par$spectrum_width_Hz
		if (missing(center))
			center <- inFolder$file.par$center_ppm
		if (missing(upShift))
			upShift <- inFolder$file.par$upfield_ppm
		if (missing(downShift))
			downShift <- inFolder$file.par$downfield_ppm
		if (missing(noiseEst))
			noiseEst <- inFolder$file.par$noise_est
		if (missing(data))
			data <- inFolder$data
	}else{
		
		## Check for required arguments
		if (missing(np))
			stop('The number of points in the each dimension must be provided')
		if (missing(nuc))
			stop('The nucleus name for each dimension must be provided')
		if (missing(sf))
			stop('The spectrometer frequency for each dimension must be provided')
		if (missing(upShift) || missing(downShift)){
			if (missing(sw))
				stop('The sweep width for each dimension must be provided')
			if (missing(center))
				stop('The center of the spectrum for each dimension must be provided')
			if (writeShifts || cor)
				stop(paste('The up and downfield chemical shifts for each dimension', 
								'must be provided'))
		}
	}

	## Negate correction factor originally applied by rNMR
	if (cor){
		cor <- ((downShift - upShift) / (np - 1))	* -(np %% 2 - 1)
		uf <- upShift - cor
		sw <- (downShift - uf) * sf
		center <- downShift - (sw / sf / 2)
	}else{
		
		## Calculate sweep width and center if not provided
		if (missing(sw) || is.null(sw))
			sw <- (downShift - upShift) * sf
		if (missing(center) || is.null(center))
			center <- downShift - ((downShift - upShift) / 2)
	}
	
	## Calculate tile size
	nDim <- length(np)
	tileDim <- np
	if (nDim == 2){
		size <- (tileDim[1] * tileDim[2] * 4) / 1024
		while (size > 32){
			tileDim <- tileDim / 2
			size <- (round(tileDim[1]) * round(tileDim[2]) * 4) / 1024
		}
	}
	tileDim <- round(tileDim)

	## Write main sparky header
	if (!file.exists(dirname(outPath)))
		dir.create(dirname(outPath), recursive=TRUE)
	writeCon <- file(outPath, "w+b")
	writeBin('UCSF NMR', writeCon, size=1)
	writeBin(as.integer(0), writeCon, size=1, endian='big')
	writeBin(as.integer(c(nDim, 1, 0, 2)), writeCon, size=1, endian='big')		
	
	## Write out noise estimate ****This differs from UCSF format
	if (writeNoise){
		writeBin('noiseEst', writeCon, size=1, endian='big')
		writeBin(as.numeric(noiseEst), writeCon, size=4, endian='big')
		writeBin(as.integer(rep(0, (180 - 27))), writeCon, size=1, endian='big')
	}else
		writeBin(as.integer(rep(0, (180 - 14))), writeCon, size=1, endian='big')
	
	## Write axis headers
	for (i in 1:nDim){
		writeBin(as.character(nuc[i]), writeCon, size=1)
		writeBin(as.integer(rep(0, (8 - nchar(nuc[i]) - 1))), writeCon, size=1, 
				endian='big')
		writeBin(as.integer(np[i]), writeCon, size=4, endian='big')
		writeBin(as.integer(rep(0, 4)), writeCon, size=1, endian='big')
		writeBin(as.integer(tileDim[i]), writeCon, size=4, endian='big')
		writeBin(as.numeric(sf[i]), writeCon, size=4, endian='big')
		writeBin(as.numeric(sw[i]), writeCon, size=4, endian='big')
		writeBin(as.numeric(center[i]), writeCon, size=4, endian='big')
		
		## Write out upfield and downfield shifts ****This differs from UCSF format
		if (writeShifts){
			writeBin(as.numeric(upShift[i]), writeCon, size=4, endian='big')
			writeBin(as.numeric(downShift[i]), writeCon, size=4, endian='big')
			writeBin(as.integer(rep(0, (128 - 40))), writeCon, size=1, endian='big')
		}else
			writeBin(as.integer(rep(0, (128 - 32))), writeCon, size=1, endian='big')
	}
	
	## Retile and write data out to file
	if (nDim == 1)
		writeBin(as.numeric(data), writeCon, size=4, endian='big')
	else{
		
		## Get data for new tile
		data <- t(data)
		tpc <- ceiling(np[1] / tileDim[1])
		tpr <- ceiling(np[2] / tileDim[2])
		for (i in 1:tpc){
			for (j in 1:tpr){
				rowNum <- (i - 1) * tileDim[1] + 1
				colNum <- (j - 1) * tileDim[2] + 1
				if (j == tpr)
					colOut <- ncol(data) - colNum + 1
				else
					colOut <- tileDim[2]
				if (i == tpc)
					rowOut <- nrow(data) - rowNum + 1
				else
					rowOut <- tileDim[1]
				outData <- data[rowNum:(rowNum + rowOut - 1), 
						colNum:(colNum + colOut - 1)]
				
				## Pad tiles if necessary
				tileRem <- np %% tileDim
				if (all(tileRem != 0) && j == tpr && i == tpc){
					
					## Pad final tile
					if (colOut == 1){
						outData <- c(outData, rep(0, tileDim[1] - length(outData)))
						outData <- cbind(as.numeric(outData), matrix(0, nrow=tileDim[1], 
										ncol=tileDim[2] - 1))
					}else if (rowOut == 1){
						outData <- c(outData, rep(0, tileDim[2] - length(outData)))
						outData <- rbind(as.numeric(outData), matrix(0, 
										nrow=tileDim[1] - 1, ncol=tileDim[2]))
					}else{
						outData <- rbind(outData, matrix(0, nrow=tileDim[1] - nrow(outData), 
										ncol=ncol(outData)))
						outData <- cbind(outData, matrix(0, nrow=tileDim[1], 
										ncol=tileDim[2] - ncol(outData)))
					}
				}else{
					
					## Pad tile in last column
					if (tileRem[2] && j == tpr){
						if (colOut == 1)
							outData <- cbind(as.numeric(outData), matrix(0, nrow=tileDim[1], 
											ncol=tileDim[2] - 1))
						else
							outData <- cbind(outData, matrix(0, nrow=tileDim[1], 
											ncol=tileDim[2] - ncol(outData)))
					}
					## Pad tile in last row
					if (tileRem[1] && i == tpc){
						if (rowOut == 1)
							outData <- rbind(as.numeric(outData), matrix(0, 
											nrow=tileDim[1] - 1, ncol=tileDim[2]))
						else
							outData <- rbind(outData, matrix(0, 
											nrow=tileDim[1] - nrow(outData), ncol=tileDim[2]))
					}
				}						
				
				## Write out new tile
				writeBin(as.numeric(t(outData)), writeCon, size=4, endian='big')
			}
		}
	}
	writeBin('\n', writeCon, size=1)
	close(writeCon)	
	
	return(outPath)
}

## Internal utility function driftCorr
## Corrects DC offset problems in 1D data
## inData - Numeric vector of spectrum
## returns - numeric vector of a drift corrected spectrum 
driftCorr <- function( inData ){
	
	dataDim <- dim(inData)
	
	## Correct 1D files
	if ( is.null(dataDim) || any(dataDim == 1) ){
		n <- length(inData)
		x <- c( (1+floor(n*.25)), (floor(n*.25) + floor(n*.5)), 
				(floor(n*.5)+ floor(n*.75)),(floor(n*.75)+ n ) )/2
		y <- c(median(inData[1:floor(n*.25)]), 
				median(inData[floor(n*.25):floor(n*.5)]), 
				median(inData[floor(n*.5):floor(n*.75)]),
				median(inData[floor(n*.75):n]))
		m <- mean( (y[1:3] - y[2:4]) ) / mean( (x[1:3] - x[2:4]) )
		b <- y[1] - m*x[1]
		
		return( inData - ((1:n)*m + b) )
		
		## Do not correct DC offset for 2D data
	}else
		return( inData )
	
}

## Internal function for parsing Bruker acquisition files
## inFile - string; directory containing the necessary acquisition files
## params - string; desired parameters to return, if missing will return
##           relevant paramaters for 1D or 2D file
## note: all values are returned as string arguments
## returns values for the designated acquisition parameters
parseAcqus <- function(inDir, params){ 
	
	## Get input directory
	if (missing(inDir)){
		inDir <- myDir(title = 'Select acqusition directory:')
		if (!nzchar(inDir))
			return(invisible())		
	}
	
	## Designate parameters if not provided
	if (missing(params))
		params <- c('NUC1', 'SFO1')
	paramVar <- paste('##$', params, sep='')
	
	## Search inDir for necessary acquisition parameter files
	acqus <- list.files(inDir, full.names=TRUE, pattern='^acqus$')[1]
	if (is.na(acqus))
		acqus <- list.files(inDir, full.names=TRUE, pattern='^acqu$')[1]	
	if (is.na(acqus))
		stop(paste('Could not find acquisition parameter files ("acqu" or "acqus")', 
						' in:\n"', inDir, '".', sep=''))
	acqu2s <- list.files(inDir, full.names=TRUE, pattern='^acqu2s')[1]
	if (is.na(acqu2s))
		acqu2s <- list.files(inDir, full.names=TRUE, pattern='^acqu2$')[1]
	if (is.na(acqu2s))
		files <- acqus
	else
		files <- c(acqus, acqu2s)
	
	## Search acquisition files for designated parameters
	acquPar <- NULL
	for (i in seq_along(files)){
		
		## Determine paramater/value separator
		for (paramSep in c('= ', '=', ' =', ' = ')){
			splitText <- strsplit(readLines(files[i]), paramSep)
			parNames <- sapply(splitText, function(x) x[1])
			parVals <- sapply(splitText, function(x) x[2])
			matches <- match(paramVar, parNames)
			if (any(is.na(matches)))
				next
			else
				break
		}
		
		## Return an error if any parameters can not be found
		if (any(is.na(matches)))
			stop(paste('One or more of the following parameters could not be found: ', 
							paste("'", params[which(is.na(matches))], "'", sep='', 
									collapse=', '), ' in:\n"', files[i], sep=''))
		acquPar <- rbind(acquPar, parVals[matches])
	}
	
	## Format the data
	colnames(acquPar) <- params
	acquPar <- data.frame(acquPar, stringsAsFactors=FALSE)
	if (!is.null(acquPar$NUC1)){
		for (i in seq_along(acquPar$NUC1)){
			acquPar$NUC1[i] <- unlist(strsplit(unlist(strsplit(acquPar$NUC1[i], 
											'<'))[2], '>'))
		}
	}
	if (!is.na(acqu2s))
		rownames(acquPar) <- c('w2', 'w1')
	
	return(acquPar)
}

## Internal function for parsing Bruker processing files
## inFile - string; directory containing the necessary processing files
## params - string; desired parameters to return, if missing will return
##           relevant paramaters for 1D or 2D file
## note: all values are returned as string arguments
## returns values for the designated processing parameters
parseProcs <- function(inDir, params){ 
	
	## Get input directory
	if (missing(inDir)){
		inDir <- myDir(title = 'Select processing directory:')
		if (!nzchar(inDir))
			return(invisible())		
	}
	
	## Designate parameters if not provided
	if (missing(params))
		params <- c('BYTORDP', 'NC_proc', 'FT_mod', 'SF', 'SI', 'SW_p', 'OFFSET', 
				'XDIM')
	paramVar <- paste('##$', params, sep='')
	
	## Search inDir for necessary processing parameter files
	procs <- list.files(inDir, full.names=TRUE, pattern='^procs$')[1]
	if (is.na(procs))
		procs <- list.files(inDir, full.names=TRUE, pattern='^proc$')[1]
	if (is.na(procs))
		stop(paste('Could not find processing parameter files ("proc" or "procs")', 
						' in:\n"', inDir, '".', sep=''))
	proc2s <- list.files(inDir, full.names=TRUE, pattern='^proc2s$')[1]
	if (is.na(proc2s))
		proc2s <- list.files(inDir, full.names=TRUE, pattern='^proc2$')[1]
	if (is.na(proc2s))
		files <- procs
	else
		files <- c(procs, proc2s)
	
	## Search processing files for designated parameters
	pars <- NULL
	for (i in seq_along(files)){
		
		## Determine paramater/value separator
		for (paramSep in c('= ', '=', ' =', ' = ')){
			splitText <- strsplit(readLines(files[i]), paramSep)
			parNames <- sapply(splitText, function(x) x[1])
			parVals <- sapply(splitText, function(x) x[2])
			matches <- match(paramVar, parNames)
			if (any(is.na(matches)))
				next
			else
				break
		}
		
		## Return an error if any parameters can not be found
		if (any(is.na(matches)))
			stop(paste('One or more of the following parameters could not be found: ', 
							paste("'", params[which(is.na(matches))], "'", sep='', 
									collapse=', '), ' in:\n"', files[i], sep=''))
		pars <- rbind(pars, parVals[matches])
	}
	
	## Format the data
	colnames(pars) <- params
	pars <- data.frame(pars, stringsAsFactors=FALSE)
	if (!is.null(pars$BYTORDP))
		pars$BYTORDP <- ifelse(as.numeric(pars$BYTORDP), 'big', 'little')
	if (!is.na(proc2s))
		rownames(pars) <- c('w2', 'w1')
	
	return(pars)
}

## Internal function for converting 1D bruker files to sparky format
## inFile - full directory path to the bruker processed data file (1r)
## outFile - full directory path for the newly created sparky format file
## nuc1 - string; bruker parameter for w2 nucleus, must be one of the following:
##				'H1', 'H2', 'C13', 'N15', 'P31', 'F19'
## sf01 - numeric; bruker parameter for w2 spectrometer frequency
## bytordp - numeric; bruker parameter indicating byte order
## nc_proc - numeric; bruker intensity scaling parameter
## offset - numeric; downfield shift for each dimension
## sf - numeric; bruker parameter for the w2 reference frequency
## si - numeric; bruker parameter for data size (2 * number of data points)
## sw_p - numeric; bruker parameter for the sweep width (Hz) for w2
## drift - logical; data is corrected for drift if TRUE
bruker1D <- function(inFile, outFile, nuc1, sfo1, bytordp, nc_proc, offset, sf,
		si, sw_p, drift=FALSE){
	
	if (missing(inFile))
		stop('The inFile file path is required')	
	if (missing(outFile))
		stop('The outFile file path is required')	
	if (missing(nuc1))
		stop('The Bruker paramater "nuc1" is required')
	if (missing(sfo1))
		stop('The Bruker paramater "sfo1" is required')
	if (missing(bytordp))		
		stop('The Bruker paramater "bytordp" is required')
	if (missing(nc_proc))
		stop('The Bruker paramater "nc_proc" is required')
	if (missing(offset))
		stop('The Bruker paramater "offset" is required')
	if (missing(sf))
		stop('The Bruker parameter "sf" is required')
	if (missing(si))
		stop('The Bruker paramater "si" is required')
	if (missing(sw_p))
		stop('The Bruker paramater "sw_p" is required')
	
	## Format input data
	sfo1 <- as.numeric(sfo1)
	nc_proc <- as.numeric(nc_proc)
	offset <- as.numeric(offset)
	sf <- as.numeric(sf)
	si <- as.numeric(si)
	sw_p <- as.numeric(sw_p)
	
	## Read data
	readCon <- file(inFile, 'rb')
	data <- try(readBin(readCon, size=4, what='integer', n=si, endian=bytordp),
			silent=TRUE)
	if (class(data) == "try-error"){
		close(readCon)	
		stop(paste('Could not read Bruker processed data file:\n"', inFile, '"', 
						sep=''))
	}
	if (length(data) < si){
		close(readCon)
		stop(paste('Could not convert Bruker processed data file:\n"', inFile, '"', 
						'\nFile size does not match data size.', sep=''))
	}
	close(readCon)
	
	## Resacale and apply drift correction
	data <- as.numeric(data) / (2^-nc_proc)
	if (drift)
		data <- driftCorr(data)
	
	## Write main sparky Header
	if (!file.exists(dirname(outFile)))
		dir.create(dirname(outFile), recursive=TRUE)
	writeCon <- file(outFile, "w+b")
	writeBin('UCSF NMR', writeCon, size=1)
	writeBin(as.integer(0), writeCon, size=1, endian='big')
	writeBin(as.integer(c(1, 1, 0, 2)), writeCon, size=1, endian='big')		
	writeBin(as.integer(rep(0, (180 - 14))), writeCon, size=1, endian='big')
	
	## Write w2 Header
	writeBin(nuc1, writeCon, size=1, endian='big')
	writeBin(as.integer(rep(0, (8 - nchar(nuc1) - 1))), writeCon, size=1, 
			endian='big')
	writeBin(as.integer(si), writeCon, size=4, endian='big')
	writeBin(as.integer(rep(0, 4)), writeCon, size=1, endian='big')
	writeBin(as.integer(si), writeCon, size=4, endian='big')
	writeBin(sfo1, writeCon, size=4, endian='big')
	writeBin(sw_p, writeCon, size=4, endian='big')
	
	## Calculate referenced carrier frequency in ppm and store the spectrometer
	car <- offset - sw_p / 2 / sf
	writeBin(car, writeCon, size=4, endian='big')
	writeBin(as.integer(rep(0, (128 - 32))), writeCon, size=1, endian='big')
	
	## Write data
	writeBin(as.numeric(data), writeCon, size=4, endian='big')	
	close(writeCon)	
	
	return(outFile)
}

## Internal function for converting 2D bruker files to sparky format
## inFile - full directory path to the bruker processed data file (1r)
## outFile - full directory path for the newly created sparky format file
## nuc1 - character vector; nucleus for each dimension, must be one of:
##				'H1', 'H2', 'C13', 'N15', 'P31', 'F19'
## sf01 - numeric; bruker parameter for spectrometer frequencies in each 
##        dimension
## bytordp - numeric; bruker parameter indicating byte order
## nc_proc - numeric; bruker intensity scaling parameter
## offset - numeric; downfield shift for each dimension
## sf - numeric vector; bruker parameter for reference frequencies in each 
##      dimension
## si - numeric vector; bruker parameter for data size in each dimension
## sw_p - numeric vector; bruker parameter for the sweep width (Hz) in each 
##        dimension
## xdim - numeric vector; bruker parameter for the tile size in each dimension
bruker2D <- function(inFile, outFile, nuc1, sfo1, bytordp, nc_proc, offset, sf,
		si, sw_p,	xdim){
	
	if (missing(inFile))
		stop('The inFile file path is required')	
	if (missing(outFile))
		stop('The outFile file path is required')	
	if (missing(nuc1))
		stop('The Bruker paramater "nuc1" is required')
	if (missing(sfo1))
		stop('The Bruker paramater "sfo1" is required')
	if (missing(bytordp))
		stop('The Bruker paramater "bytordp" is required')
	if (missing(nc_proc))
		stop('The Bruker paramater "nc_proc" is required')
	if (missing(offset))
		stop('The Bruker paramater "offset" is required')
	if (missing(sf))
		stop('The Bruker parameter "sf" is required')
	if (missing(si))
		stop('The Bruker paramater "si" is required')
	if (missing(sw_p))
		stop('The Bruker paramater "sw_p" is required')
	if (missing(xdim))
		stop('The Bruker paramater "xdim" is required')
	
	## Format input data
	sfo1 <- as.numeric(sfo1)
	nc_proc <- as.numeric(nc_proc)
	offset <- as.numeric(offset)
	sf <- as.numeric(sf)
	si <- as.numeric(si)
	sw_p <- as.numeric(sw_p)
	xdim <- as.numeric(xdim)
	
	## Test file connection
	readCon <- file(inFile, 'rb')
	testCon <- try(readBin(readCon,	size=4, what='integer',	n=si[1] * si[2], 
					endian=bytordp), silent=TRUE)
	if (class(testCon) == "try-error"){
		close(readCon)	
		stop(paste('Could not read Bruker processed data file:\n"', inFile, '"', 
						sep=''))
	}
	if (length(testCon) < si[1] * si[2]){
		close(readCon)	
		stop(paste('Could not convert Bruker processed data file:\n"', inFile, '"', 
						'\nFile size does not match data size.', sep=''))
	}
	seek(readCon, where=0)
	
	## Read data a block at a time and reformat into a detiled matrix
	data <- matrix(nrow=si[2], ncol=si[1])
	tpc <- si[2] / xdim[2]
	tpr <- si[1] / xdim[1]
	for (i in 1:tpc){
		for (j in 1:tpr){
			rowNum <- (i - 1) * xdim[2] + 1
			colNum <- (j - 1) * xdim[1] + 1
			tileData <- matrix(as.numeric(readBin(readCon,	size=4,	what='integer',
									n=xdim[1] * xdim[2], endian=bytordp)), nrow=xdim[2], 
					ncol=xdim[1],	byrow=TRUE)
			data[rowNum:(rowNum + xdim[2] - 1), colNum:(colNum + xdim[1] - 1)] <- 
					tileData
		}
	}
	close(readCon)
	
	## Resacale data
	data <- data / (2^-nc_proc)
	
	## Calculate new tile size for ucsf format
	tileDim <- si
	size <- (tileDim[1] * tileDim[2] * 4) / 1024
	while (size > 32){
		tileDim <- tileDim / 2
		size <- (round(tileDim[1]) * round(tileDim[2]) * 4) / 1024
	}
	tileDim <- round(tileDim)
	
	## Write main sparky header
	if (!file.exists(dirname(outFile)))
		dir.create(dirname(outFile), recursive=TRUE)
	writeCon <- file(outFile, "w+b")
	writeBin('UCSF NMR', writeCon, size=1, endian='big')
	writeBin(as.integer(0), writeCon, size=1)
	writeBin(as.integer(c(2, 1, 0, 2)), writeCon, size=1, endian='big')		
	writeBin(as.integer(rep(0, (180 - 14))), writeCon, size=1, endian='big')
	
	## Calculate referenced carrier frequency in ppm and store the spectrometer
	car <- offset - sw_p / 2 / sf
	
	## Write axis headers
	for (i in c(2, 1)){
		writeBin(as.character(nuc1[i]), writeCon, size=1, endian='big')
		writeBin(as.integer(rep(0, (8 - nchar(nuc1[i]) - 1))), writeCon, size=1, 
				endian='big')
		writeBin(as.integer(si[i]), writeCon, size=4, endian='big')
		writeBin(as.integer(rep(0, 4)), writeCon, size=1, endian='big')
		writeBin(as.integer(tileDim[i]), writeCon, size=4, endian='big')
		writeBin(as.numeric(sfo1[i]), writeCon, size=4, endian='big')
		writeBin(as.numeric(sw_p[i]), writeCon, size=4, endian='big')
		writeBin(as.numeric(car[i]), writeCon, size=4, endian='big')
		writeBin(as.integer(rep(0, (128 - 32))), writeCon, size=1, endian='big')
	}
	
	## Get data for new tile
	tpc <- ceiling(si[2] / tileDim[2])
	tpr <- ceiling(si[1] / tileDim[1])
	for (i in 1:tpc){
		for (j in 1:tpr){
			rowNum <- (i - 1) * tileDim[2] + 1
			colNum <- (j - 1) * tileDim[1] + 1
			if (j == tpr)
				colOut <- ncol(data) - colNum + 1
			else
				colOut <- tileDim[1]
			if (i == tpc)
				rowOut <- nrow(data) - rowNum + 1
			else
				rowOut <- tileDim[2]
			ucsfData <- data[rowNum:(rowNum + rowOut - 1), 
					colNum:(colNum + colOut - 1)]
			
			## Pad tiles if necessary
			tileRem <- si %% tileDim
			if (all(tileRem != 0) && j == tpr && i == tpc){
				
				## Pad final tile
				if (colOut == 1){
					ucsfData <- c(ucsfData, rep(0, tileDim[2] - length(ucsfData)))
					ucsfData <- cbind(as.numeric(ucsfData), matrix(0, nrow=tileDim[2], 
									ncol=tileDim[1] - 1))
				}else if (rowOut == 1){
					ucsfData <- c(ucsfData, rep(0, tileDim[1] - length(ucsfData)))
					ucsfData <- rbind(as.numeric(ucsfData), matrix(0, 
									nrow=tileDim[2] - 1, ncol=tileDim[1]))
				}else{					
					ucsfData <- rbind(ucsfData, matrix(0, 
									nrow=tileDim[2] - nrow(ucsfData), 
									ncol=ncol(ucsfData)))
					ucsfData <- cbind(ucsfData, matrix(0, nrow=tileDim[2], 
									ncol=tileDim[1] - ncol(ucsfData)))
				}
			}else{
				
				## Pad tile in last column
				if (tileRem[1] && j == tpr){
					if (colOut == 1)
						ucsfData <- cbind(as.numeric(ucsfData), matrix(0, nrow=tileDim[2], 
										ncol=tileDim[1] - 1))
					else
						ucsfData <- cbind(ucsfData, matrix(0, nrow=tileDim[2], 
										ncol=tileDim[1] - ncol(ucsfData)))
				}
				## Pad tile in last row
				if (tileRem[2] && i == tpc){
					if (rowOut == 1)
						ucsfData <- rbind(as.numeric(ucsfData), matrix(0, 
										nrow=tileDim[2] - 1, ncol=tileDim[1]))
					else
						ucsfData <- rbind(ucsfData, matrix(0, 
										nrow=tileDim[2] - nrow(ucsfData), ncol=tileDim[1]))
				}
			}				
			
			## Write out new tile
			writeBin(as.numeric(t(ucsfData)), writeCon, size=4, endian='big')
		}
	}
	close(writeCon)	
	
	return(outFile)
}

## Internal function for converting NMRPipe files to sparky format
## inFile - full directory path to the NMRPipe processed data file
## outFile - full directory path for the newly created sparky format file
## drift - logical; 1D data is corrected for drift if TRUE
pipe2rnmr <- function(inFile, outFile, drift=FALSE){
	
	if (missing(inFile))
		stop('The inFile file path is required')	
	if (missing(outFile))
		stop('The outFile file path is required')	
	
	## Test file connection
	readCon <- file(inFile, 'rb')
	header <- try(readBin(readCon, what='numeric', n=512, size=4), silent=TRUE)
	if (class(header) == "try-error" || length(header) != 512){
		close(readCon)	
		stop(paste('Could not read NMRPipe file:\n"', inFile, '"',	sep=''))
	}
	
	## Check for correct endianness
	if (round(header[3], 3) != 2.345){
		seek(readCon, where=0)
		header <- readBin(readCon, what='numeric', n=512, size=4, endian='swap')
		endianness <- 'swap'
	}else
		endianness <- .Platform$endian
	
	## Check that all data is contained within a single file
	if (header[1] != 0){
		close(readCon)
		stop(paste('Can not convert "', inFile, '",\n  File is not a valid NMRPipe', 
						' format spectrum.', sep=''))
	}
	if (header[443] != 1){
		close(readCon)
		stop(paste('Can not convert "', inFile, '",\n  All data must be contained', 
						' within a single NMRPipe file.', sep=''))
	}
	
	## Check for real data
	if (header[107] != 1){
		close(readCon)
		stop(paste('Can not convert "', inFile, '",\n  rNMR can only convert real',
						' Fourier transformed data.', sep=''))
	}
	
	## Get conversion parameters from NMRPipe file header
	dimOrder <- c(header[25], header[26])
	if (dimOrder[1] == 1)
		np <- c(header[220], header[100])
	else if (dimOrder[1] == 2)
		np <- c(header[100], header[220])
	else{
		close(readCon)
		stop(paste('Can not convert "', inFile, '",\n  rNMR can only convert one', 
						' or two-dimensional data.'), sep='')
	}
	sw <- c(header[101], header[230])
	sf <- c(header[120], header[219])
	upShifts <- c(header[102], header[250]) / sf
	nDim <- header[10]
	transposed <- header[222]
	
	## Get nucleus names from NMRPipe file header
	seek(readCon, where=4*16)
	w2Nuc <- readBin(readCon, what='character', n=1, size=4, endian=endianness)
	seek(readCon, where=5, origin='current')
	w1Nuc <- readBin(readCon, what='character', n=1, size=4, endian=endianness)
	nuc <- c(w2Nuc, w1Nuc)
	
	## Read data
	seek(readCon, where=4*512)
	if (nDim == 1){
		data <- readBin(readCon, size=4, what='numeric', n=np[1], 
				endian=endianness)
		if (length(data) < np[1]){
			close(readCon)
			stop(paste('Can not convert "', inFile, '",\n', 
							'  file size does not match data size.'), sep='')
		}
	}else{
		data <- matrix(readBin(readCon,	size=4,	what='numeric',	n=np[1] * np[2], 
						endian=endianness), nrow=np[2], ncol=np[1], byrow=!transposed)
		if (length(data) < np[1] * np[2]){
			close(readCon)
			stop(paste('Can not convert "', inFile, '",\n', 
							'  file size does not match data size.'), sep='')
		}
	}
	close(readCon)
	
	## Apply drift correction
	if (drift)
		data <- driftCorr(data)
	
	## Calculate new tile size for ucsf format
	tileDim <- np
	if (nDim == 2){
		size <- (tileDim[1] * tileDim[2] * 4) / 1024
		while (size > 32){
			tileDim <- tileDim / 2
			size <- (round(tileDim[1]) * round(tileDim[2]) * 4) / 1024
		}
	}
	tileDim <- round(tileDim)
	
	## Write main sparky header
	if (!file.exists(dirname(outFile)))
		dir.create(dirname(outFile), recursive=TRUE)
	writeCon <- file(outFile, "w+b")
	writeBin('UCSF NMR', writeCon, size=1, endian='big')
	writeBin(as.integer(0), writeCon, size=1, endian='big')
	writeBin(as.integer(c(nDim, 1, 0, 2)), writeCon, size=1, endian='big')		
	writeBin(as.integer(rep(0, (180 - 14))), writeCon, size=1, endian='big')
	
	## Write axis headers
	if (nDim == 1)
		curDim <- 1
	else
		curDim <- c(2, 1)
	for (i in curDim){
		writeBin(as.character(nuc[i]), writeCon, size=1, endian='big')
		writeBin(as.integer(rep(0, (8 - nchar(nuc[i]) - 1))), writeCon, size=1, 
				endian='big')
		writeBin(as.integer(np[i]), writeCon, size=4, endian='big')
		writeBin(as.integer(rep(0, 4)), writeCon, size=1, endian='big')
		writeBin(as.integer(tileDim[i]), writeCon, size=4, endian='big')
		writeBin(as.numeric(sf[i]), writeCon, size=4, endian='big')
		writeBin(as.numeric(sw[i]), writeCon, size=4, endian='big')
		
		## Calculate referenced carrier frequency in ppm and store the spectrometer
		ppmScale <- sw[i] / sf[i] / np[i]
		car <- upShifts[i] + ((np[i] - 2) / 2) * ppmScale
		writeBin(as.numeric(car), writeCon, size=4, endian='big')
		writeBin(as.integer(rep(0, (128 - 32))), writeCon, size=1, endian='big')
	}
	
	## Retile and write data out to file
	if (nDim == 1)
		writeBin(as.numeric(data), writeCon, size=4, endian='big')
	else{
		
		## Get data for new tile
		tpc <- ceiling(np[2] / tileDim[2])
		tpr <- ceiling(np[1] / tileDim[1])
		for (i in 1:tpc){
			for (j in 1:tpr){
				rowNum <- (i - 1) * tileDim[2] + 1
				colNum <- (j - 1) * tileDim[1] + 1
				if (j == tpr)
					colOut <- ncol(data) - colNum + 1
				else
					colOut <- tileDim[1]
				if (i == tpc)
					rowOut <- nrow(data) - rowNum + 1
				else
					rowOut <- tileDim[2]
				ucsfData <- data[rowNum:(rowNum + rowOut - 1), 
						colNum:(colNum + colOut - 1)]
				
				## Pad tiles if necessary
				tileRem <- np %% tileDim
				if (all(tileRem != 0) && j == tpr && i == tpc){
					
					## Pad final tile
					if (colOut == 1){
						ucsfData <- c(ucsfData, rep(0, tileDim[2] - length(ucsfData)))
						ucsfData <- cbind(as.numeric(ucsfData), matrix(0, nrow=tileDim[2], 
										ncol=tileDim[1] - 1))
					}else if (rowOut == 1){
						ucsfData <- c(ucsfData, rep(0, tileDim[1] - length(ucsfData)))
						ucsfData <- rbind(as.numeric(ucsfData), matrix(0, 
										nrow=tileDim[2] - 1, ncol=tileDim[1]))
					}else{
						ucsfData <- rbind(ucsfData, matrix(0, 
										nrow=tileDim[2] - nrow(ucsfData), 
										ncol=ncol(ucsfData)))
						ucsfData <- cbind(ucsfData, matrix(0, nrow=tileDim[2], 
										ncol=tileDim[1] - ncol(ucsfData)))
					}
				}else{
					
					## Pad tile in last column
					if (tileRem[1] && j == tpr){
						if (colOut == 1)
							ucsfData <- cbind(as.numeric(ucsfData), matrix(0, nrow=tileDim[2], 
											ncol=tileDim[1] - 1))
						else
							ucsfData <- cbind(ucsfData, matrix(0, nrow=tileDim[2], 
											ncol=tileDim[1] - ncol(ucsfData)))
					}
					## Pad tile in last row
					if (tileRem[2] && i == tpc){
						if (rowOut == 1)
							ucsfData <- rbind(as.numeric(ucsfData), matrix(0, 
											nrow=tileDim[2] - 1, ncol=tileDim[1]))
						else
							ucsfData <- rbind(ucsfData, matrix(0, 
											nrow=tileDim[2] - nrow(ucsfData), ncol=tileDim[1]))
					}
				}				
				
				## Write out new tile
				writeBin(as.numeric(t(ucsfData)), writeCon, size=4, endian='big')
			}
		}
	}
	close(writeCon)	
	
	return(outFile)
}

## Internal function for parsing the Varian procpar file
## procpar - string; full path to the procpar file
## params  - desired parameters to return, if missing will return
##           relevant paramaters for 1D or 2D file
## idn - character; indirect nucleus name for the spectrum
## note:   - all values are returned as string arguments
## returns a list of procpar values requested
parseProcpar <- function(procpar, params, idn='dn'){
	
	## Look for procpar
	if (missing(procpar)){
		procpar <- myOpen(title = 'Open procpar')
		if (!length(procpar))
			return(invisible())		
	}else{
		if (!length(procpar) || !nzchar(procpar))
			stop('Invalid procpar argument')
		if (!file.exists(procpar))
			stop(paste('Could not find procpar file:\n', '"', procpar, '"', sep=''))
	}
	
	## Parse the procpar file
	varPar <- strsplit(readLines(procpar), ' ')
	varName <- sapply(varPar, function(x){x[1]})
	
	## Find the number of dimensions
	matches <- grep('^ni', varName)
	niVals <- sapply(varPar[matches + 1], function(x) x[2])
	names(niVals) <- varName[matches]
	if (any(niVals > 1))
		nDim <- 2
	else
		nDim <- 1
	if (!length(grep('^np$', varName)))
		stop(paste('Could not read procpar file:\n', '"', procpar, '"', sep=''))
	
	## Check for arrayed 1D spectra
	arrayDim <- 1
	if (nDim == 1){
		matches <- grep('^arraydim', varName)
		arrayDim <- sapply(varPar[matches + 1], function(x) x[2])
	}
	
	## Get rNMR pramaters if none are directly specified
	nucLabel <- NULL
	rename <- FALSE
	if (missing(params)){
		
		## Get parameters for 1D files
		if (nDim == 1){
			params <- c('tn', 'rfl', 'rfp', 'sfrq', 'sw')
			
			## Get parameters for 2D files
		}else{
			
			## Do not read files with more than 1 arrayed parameter
			if (sum(niVals > 1) != 1)
				stop(paste('Can not convert spectrum corresponding to:\n', procpar, 
								',\n  rNMR can only read 1D and 2D data'), sep='')
			
			## Search procpar for indirect nucleus
			if (idn == 'dn'){
				frqLabel <- 'dfrq'
				nucLabel <- 'dn'
			}else{
				matches <- as.vector(na.omit(match(c('tn', 'dn', 'dn2', 'dn3', 'dn4', 
												'dn5'), varName)))
				posNuc <- sapply(varPar[matches + 1], function(x) 
							strsplit(x[2], "\"")[[1]][2])
				nucLabel <- match(idn, posNuc)
				if (is.na(nucLabel))
					stop(paste('Could not find specified nucleus in:\n', procpar, sep=''))
				frqLabel <- switch(nucLabel, 'sfrq', 'dfrq', 'dfrq2', 'dfrq3', 'dfreq4',
						'dfrq5')
				nucLabel <- switch(nucLabel, 'tn', 'dn', 'dn2', 'dn3', 'dn4', 'dn5')
			}
			
			## Find indirect parameter
			params <- switch(names(niVals)[which(niVals != 0)], 
					'ni'=c('tn', 'rfl', 'rfp', 'sfrq', 'sw', nucLabel, 'rfl1', 'rfp1', 
							frqLabel, 'sw1', 'trace'),
					'ni2'=c('tn', 'rfl', 'rfp', 'sfrq', 'sw', nucLabel, 'rfl2', 'rfp2', 
							frqLabel, 'sw2', 'trace'),
					'ni3'=c('tn', 'rfl', 'rfp', 'sfrq', 'sw', nucLabel, 'rfl3', 'rfp3', 
							frqLabel, 'sw3', 'trace'), 
					'ni4'=c('tn', 'rfl', 'rfp', 'sfrq', 'sw', nucLabel, 'rfl4', 'rfp4', 
							frqLabel, 'sw4', 'trace'),
					'ni5'=c('tn', 'rfl', 'rfp', 'sfrq', 'sw', nucLabel, 'rfl5', 'rfp5', 
							frqLabel, 'sw5', 'trace'))
			rename <- TRUE
		}
	}
	
	## Search for possible decoupler nuclei
	if (params[1] == 'posNuc'){
		nucLabels <- c('tn', 'dn', 'dn2', 'dn3', 'dn4', 'dn5')
		matches <- match(nucLabels, varName)
		nuclei <- NULL
		for (i in matches){
			if (!is.na(i))
				nucleus <- strsplit(varPar[i + 1][[1]][2], "\"")[[1]][2]
			else
				nucleus <- ''
			nuclei <- c(nuclei, nucleus)
		}
		nuclei <- c(nuclei, nDim)
		nuclei <- data.frame(t(nuclei), stringsAsFactors=FALSE)
		names(nuclei) <- c(nucLabels, 'nDim')
		return(nuclei)
	}
	
	## Return an error if any parameters can not be found
	matches <- match(params, varName)	
	if (any(is.na(matches)))
		stop(paste('Could not find the following parameters:  ', paste("'", 
								params[which(is.na(matches))], "'", sep='', collapse=', '), 
						' in\n"', procpar, '"', sep=''))
	
	## Format data
	if (length(matches) > 1){
		varFrame <- data.frame(list(varPar[matches + 1], c('1', nDim), 
						c('1', arrayDim)), stringsAsFactors=FALSE)[-1,]
		names(varFrame) <- c(params, 'nDim', 'arrayDim')
	}else{
		varFrame <- unlist(varPar[matches + 1])[-1]
	}
	
	## Remove funky quotes that associated with varian character paramaters
	varFrameChar <- sapply(varFrame, function(x){strsplit(x, "\"")[[1]][2]})
	varFrame[which(!is.na(varFrameChar))] <- 
			varFrameChar[which(!is.na(varFrameChar))]
	if (rename){
		names(varFrame) <- c(params[1:5], 'idn', 'idrfl', 'idrfp', 'idfrq', 'idsw', 
				'trace', 'nDim', 'arrayDim')
		nucLabel <- 'idn'
	}
	
	return(varFrame)
}

## Internal function for converting 1D varian files to sparky format
## phasefile - full directory path to the varian phase file
## outFile - full directory path to the saved file
## tn - string; must be one of the following:
##      'H1', 'H2', 'C13', 'N15', 'P31', 'F19'
## rfl - numeric; w2 reference peak position (Hz)
## rfp - numeric; assigned w2 reference peak frequency (Hz)
## sfrq - numeric; varian parameter for w2 spectrometer frequency
## sw - numeric; varian parameter for the sweep width (Hz) for w2
## drift - logical; data is corrected for drift if TRUE
varian1D <- function(phasefile, outFile, tn, rfl, rfp, sfrq, sw, drift=FALSE){
	
	if (missing(phasefile))
		stop('The Varian phasefile is required')
	if (missing(outFile))
		stop('The outName file path is required')	
	if (missing(tn))
		stop('The Varian paramater "tn" is required')
	if (missing(rfl))
		stop('The Varian paramater "rfl" is required')
	if (missing(rfp))
		stop('The Varian paramater "rfp" is required')
	if (missing(sfrq))
		stop('The Varian paramater "sfrq" is required')
	if (missing(sw))
		stop('The Varian parameter "sw" is required')
	
	## reformat nucleus name to match common UCSF format nucleus names
	nuc <- tn
	nuc <- switch(nuc, 'H1'='1H', 'H2'='2H', 'C13'='13C', 'N15'='15N', 
			'P31'='31P', 'F19'='19F')
	if (!is.null(nuc))
		tn <- nuc
	
	## Format input data
	rfl <- as.numeric(rfl)
	rfp <- as.numeric(rfp)
	sfrq <- as.numeric(sfrq)
	sw <- as.numeric(sw)
	
	## Read main Varian data header from phase file
	readCon <- file(phasefile, "rb")
	varHead <- try(readBin(readCon, size=4, what='integer', n=6), silent=TRUE)
	if (class(varHead) == "try-error" || length(varHead) < 4){
		close(readCon)	
		stop(paste('Could not read Varian phasefile:\n"', phasefile, '"', sep=''))
	}
	
	## Check the binary endian format
	if (varHead[4] != 2 && varHead[4] != 4){
		endFormat <- 'swap'
		seek(readCon, where=0)
		varHead <- readBin(readCon, size=4, what='integer', n=6, endian=endFormat)
		if (varHead[4] != 2 && varHead[4] != 4){
			close(readCon)	
			stop(paste('Could not read Varian phasefile\n"', phasefile, '"', sep=''))
		}
	}else
		endFormat <- .Platform$endian
	
	## Save data structure info
	nblocks <- varHead[1]
	ntraces <- varHead[2]
	np <- varHead[3]
	ebyte <- varHead[4]
	seek(readCon, 2, origin='current')
	status <- rawToBits(readBin(readCon, what='raw', n=2, endian=endFormat))
	nbHead <- readBin(readCon, size=4, what='integer', n=1, endian=endFormat)
	
	## Check for real data
	if (status[13] != 00){
		close(readCon)
		stop(paste('Can not convert "', phasefile, '",\n  rNMR can only convert', 
						' real Fourier transformed data.'), sep='')
	}
	
	## Check for multiple trace 1D files
	if (ntraces > 1){
		cat(paste('Specified spectrum "', phasefile, '",\n contains multiple ',
						'traces, only the first trace will be converted.\n', sep=''))
	}
	
	## Create numbered output names for arrayed spectra
	if (nblocks > 1){
		splitOut <- unlist(strsplit(outFile, '.', fixed=TRUE))
		arrayFile <- paste(splitOut[1:length(splitOut) - 1], collapse='.')
	}
	
	## Read data
	outNames <- NULL
	for (block in 1:nblocks){
		if (nblocks > 1){
			if (length(splitOut) > 1){
				outName <- paste(arrayFile, block, sep='_')
				outName <- paste(outName, splitOut[length(splitOut)], sep='.')
			}else
				outName <- paste(arrayFile, block, sep='_')
			outNames <- c(outNames, outName)
		}else
			outName <- outFile
		scale <- readBin(readCon, size=2, what='integer', n=1, endian=endFormat)
		seek(readCon, 26, origin='current')
		data <- readBin(readCon, size=ebyte, what='double', n=np,	endian=endFormat) 
		if (length(data) < np){
			close(readCon)
			stop(paste('Can not convert "', phasefile, '",\n phasefile size does not',
							' match data size.\n', 'See the rNMR manual for details on ', 
							'exporting data from Vnmr.\n', sep=''))
		}
		if (is.na(max(data))){
			close(readCon)
			stop(paste('Can not convert "', phasefile, '",\n Unable to read ',
							'processed data.\n', 'See the rNMR manual for details on ', 
							'exporting data from Vnmr.\n', sep=''))
		}
		data <- data * 1000000
		if (length(scale) && scale != 0)
			data <- scale * data
		
		## Apply drift correction
		if (drift)
			data <- driftCorr(data)
		
		## Write main sparky Header
		if (!file.exists(dirname(outName)))
			dir.create(dirname(outName), recursive=TRUE)
		writeCon <- file(outName, "w+b")
		writeBin('UCSF NMR', writeCon, size=1, endian='big')
		writeBin(as.integer(0), writeCon, size=1, endian='big')
		writeBin(as.integer(c(1, 1, 0, 2)), writeCon, size=1, endian='big')		
		writeBin(as.integer(rep(0, (180 - 14))), writeCon, size=1, endian='big')
		
		## Calculate w2 center ppm
		w2Downfield <- rfp / sfrq + (sw - rfl) / sfrq
		xcar <- w2Downfield - sw / 2 / sfrq
		
		## Write w2 Header
		writeBin(as.character(tn), writeCon, size=1, endian='big')
		writeBin(as.integer(rep(0, 8 - nchar(tn) - 1)), writeCon, size=1, 
				endian='big')
		writeBin(as.integer(np), writeCon, size=4, endian='big')
		writeBin(as.integer(rep(0, 4)), writeCon, size=1, endian='big')
		writeBin(as.integer(np), writeCon, size=4, endian='big')
		writeBin(as.numeric(sfrq), writeCon, size=4, endian='big')
		writeBin(as.numeric(sw), writeCon, size=4, endian='big')
		writeBin(as.numeric(xcar), writeCon, size=4, endian='big')
		writeBin(as.integer(rep(0, 128 - 32)), writeCon, size=1, endian='big')
		
		## Write data
		writeBin(data, writeCon, size=4, endian='big')
		close(writeCon)
	}
	close(readCon)		
	
	if (is.null(outNames))
		return(outName)
	else
		return(outNames)
}

## Internal function for converting 2D varian files to sparky format
## phasefile - full directory path to the varian phase file
## outFile - full directory path to the saved file
## tn - string; must be one of the following:
##          'H1', 'H2', 'C13', 'N15', 'P31', 'F19'
## rfl - numeric; w2 reference peak position (Hz)
## rfp - numeric; assigned w2 reference peak frequency (Hz)
## sfrq - numeric; varian parameter for w2 spectrometer frequency
## sw - numeric; varian parameter for the sweep width (Hz) for w2
## idn - string;  first decoupler nucleous must be one of the following:
##          'H1', 'H2', 'C13', 'N15', 'P31', 'F19'
## idrfl - numeric; w1 reference peak position (Hz)
## idrfp - numeric; assigned w1 reference peak frequency (Hz)
## idfrq - numeric; varian parameter for the first decoupler nucleus (see note)
## idsw - numeric; indirect sweep width (Hz)
## trace - character string; indicates what trace was set to ('f1' or 'f2') when
##				 the phasefile was saved
varian2D <- function(phasefile, outFile, tn, rfl, rfp, sfrq, sw, idn,	idrfl, 
		idrfp, idfrq, idsw, trace){
	
	if (missing(phasefile))
		stop('The Varian phasefile is required')
	if (missing(outFile))
		stop('The outName file path is required')	
	if (missing(tn))
		stop('The Varian paramater "tn" is required')
	if (missing(rfl))
		stop('The Varian parameter "rfl" is required')
	if (missing(rfp))
		stop('The Varian paramater "rfp" is required')
	if (missing(sfrq))
		stop('The Varian paramater "sfrq" is required')
	if (missing(sw))
		stop('The Varian parameter "sw" is required')
	if (missing(idn))
		stop('The name of the indirect nucleus is required')
	if (missing(idrfl))
		stop('The Varian parameter "rfl" for the indirect dimension is required')
	if (missing(idrfp))
		stop('The Varian paramater "rfp" for the indirect dimension is required')
	if (missing(idfrq))
		stop('The frequency of the indirect nucleus is required')
	if (missing(idsw))
		stop('The indirect sweep width in Hertz is required')
	if (missing(trace))
		stop('The Varian parameter "trace" is required')
	
	## reformat nucleus name to match common UCSF format nucleus names
	dirNuc <- tn
	dirNuc <- switch(dirNuc, 'H1'='1H', 'H2'='2H', 'C13'='13C', 'N15'='15N', 
			'P31'='31P', 'F19'='19F')
	if (!is.null(dirNuc))
		tn <- dirNuc
	indirNuc <- idn
	indirNuc <- switch(indirNuc, 'H1'='1H', 'H2'='2H', 'C13'='13C', 'N15'='15N', 
			'P31'='31P', 'F19'='19F')
	if (!is.null(indirNuc))
		idn <- indirNuc
	
	## Format input data
	rfl <- as.numeric(rfl)
	rfp <- as.numeric(rfp)
	sfrq <- as.numeric(sfrq)
	sw <- as.numeric(sw)
	idrfl <- as.numeric(idrfl)
	idrfp <- as.numeric(idrfp)
	idfrq <- as.numeric(idfrq)
	idsw <- as.numeric(idsw)
	
	## Read main Varian data header from phase file
	readCon <- file(phasefile, "rb")
	varHead <- try(readBin(readCon, size=4, what='integer', n=6), silent=TRUE )
	if (class(varHead) == "try-error" || length(varHead) < 4){
		close(readCon)	
		stop(paste('Could not read Varian phasefile:\n"', phasefile, '"', sep=''))
	}
	
	## Check the binary endian format
	if (varHead[4] != 2 && varHead[4] != 4){
		endFormat <- 'swap'
		seek(readCon, where=0)
		varHead <- readBin(readCon, size=4, what='integer', n=6, endian=endFormat)
		if (varHead[4] != 2 && varHead[4] != 4){
			close(readCon)
			stop(paste('Could not read Varian phasefile:\n"', phasefile, '"', sep=''))
		}
	}else
		endFormat <- .Platform$endian
	
	## Save data structure info
	nblocks <- varHead[1]
	ntraces <- varHead[2]
	np <- varHead[3]
	ebyte <- varHead[4]
	tbyte <- varHead[5]
	bbyte <- varHead[6]
	seek(readCon, 2, origin='current')
	status <- rawToBits(readBin(readCon, what='raw', n=2, endian=endFormat))
	nbHead <- readBin(readCon, size=4, what='integer', n=1, endian=endFormat)
	
	## Test file connection
	seek(readCon, where=32)
	dataLength <- nblocks * bbyte
	testCon <- readBin(readCon, size=1, what='raw', n=dataLength, 
			endian=endFormat)
	if (length(testCon) < dataLength){
		close(readCon)	
		stop(paste('Can not convert Varian phasefile "', phasefile, '"', 
						'\nFile size does not match data size.', sep=''))
	}
	
	## Check for real data
	if (status[13] != 00){
		close(readCon)
		stop(paste('Can not convert "', phasefile, '",\n  rNMR can only convert', 
						' real Fourier transformed data.', sep=''))
	}	
	close(readCon)
	
	## Read data a block at a time and reformat into a detiled matrix
	readData <- function(trace){
		readCon <- file(phasefile, "rb")
		seek(readCon, where=32)
		if (trace == 'f2')
			seek(readCon, dataLength, origin='current')
		data <- matrix(nrow=np, ncol=nblocks * ntraces)
		for (blockNum in 1:nblocks){
			for (k in 1:nbHead){
				if (k == 1){
					scale <- readBin(readCon, size=2, what='integer', n=1, 
							endian=endFormat)
					seek(readCon, 2, origin='current')
					index <- readBin(readCon, size=2, what='integer', n=1, 
							endian=endFormat)
				}else
					seek(readCon, 6, origin='current')
				seek(readCon, 22, origin='current')
			}
			for (traceNum in 1:ntraces){
				traceData <- readBin(readCon, size=ebyte, what='double', n=np, 
						endian=endFormat) * 1000000
				if (length(scale) && scale != 0)
					traceData <- scale * traceData
				colNum <- (blockNum - 1) * ntraces + traceNum
				data[, colNum] <- traceData
			}
		}
		close(readCon)
		
		## Resort data if trace was set to f2
		if (trace == 'f2'){
			sortedData <- NULL
			pointTraceRatio <- np / ntraces
			for (blockNum in 1:(nblocks / pointTraceRatio))
				sortedData <- rbind(sortedData, 
						data[, seq(blockNum, nblocks * ntraces, nblocks / pointTraceRatio)])
			data <- t(sortedData)
		}
		return(data)
	}
	data <- tryCatch(readData(trace), error=function(er){
				closeAllConnections()
				return('switch')
			})
	if (data[1] == 'switch'){
		if (trace == 'f1')
			trace <- 'f2'
		else
			trace <- 'f1'
		data <- tryCatch(readData(trace), error=function(er) 
					stop(paste('Can not convert "', phasefile, '",\n  data in phasefile', 
									' does not match processing parameters.', sep='')))
	}
	
	## Calculate new tile size for ucsf format
	w1Points <- np
	w2Points <- ntraces * nblocks
	tileDim <- c(w2Points, w1Points)
	size <- (tileDim[1] * tileDim[2] * 4) / 1024
	while (size > 32){
		tileDim <- tileDim / 2
		size <- (round(tileDim[1]) * round(tileDim[2]) * 4) / 1024
	}
	tileDim <- round(tileDim)
	
	## Write main sparky Header
	if (!file.exists(dirname(outFile)))
		dir.create(dirname(outFile), recursive=TRUE)
	writeCon <- file(outFile, "w+b")
	writeBin('UCSF NMR', writeCon, size=1, endian='big')
	writeBin(as.integer(0), writeCon, size=1, endian='big')
	writeBin(as.integer(c(2, 1, 0, 2)), writeCon, size=1, endian='big')		
	writeBin(as.integer(rep(0, (180 - 14))), writeCon, size=1, endian='big')
	
	## Calculate w1 center ppm
	w1Downfield <- idrfp / idfrq + (idsw - idrfl) / idfrq
	ycar <- w1Downfield - idsw / 2 / idfrq
	
	## Write w1 axis Header
	writeBin(as.character(idn), writeCon, size=1, endian='big')
	writeBin(as.integer(rep(0, (8 - nchar(idn) - 1))), writeCon, size=1, 
			endian='big')
	writeBin(as.integer(w1Points), writeCon, size=4, endian='big')
	writeBin(as.integer(rep(0, 4)), writeCon, size=1, endian='big')
	writeBin(as.integer(tileDim[2]), writeCon, size=4, endian='big')
	writeBin(as.numeric(idfrq), writeCon, size=4, endian='big')
	writeBin(as.numeric(idsw), writeCon, size=4, endian='big')
	writeBin(as.numeric(ycar), writeCon, size=4, endian='big')
	writeBin(as.integer(rep(0, (128 - 32))), writeCon, size=1, endian='big')
	
	## Calculate w2 center ppm
	w2Downfield <- rfp / sfrq + (sw - rfl) / sfrq
	xcar <- w2Downfield - sw / 2 / sfrq
	
	## Write w2 axis Header
	writeBin(as.character(tn), writeCon, size=1, endian='big')
	writeBin(as.integer(rep(0, (8 - nchar(tn) - 1))), writeCon, size=1, 
			endian='big')
	writeBin(as.integer(w2Points), writeCon, size=4, endian='big')
	writeBin(as.integer(rep(0, 4)), writeCon, size=1, endian='big')
	writeBin(as.integer(tileDim[1]), writeCon, size=4, endian='big')
	writeBin(as.numeric(sfrq), writeCon, size=4, endian='big')
	writeBin(as.numeric(sw), writeCon, size=4, endian='big')
	writeBin(as.numeric(xcar), writeCon, size=4, endian='big')
	writeBin(as.integer(rep(0, (128 - 32))), writeCon, size=1, endian='big')
	
	## Get data for new tile
	tpc <- ceiling(w1Points / tileDim[2])
	tpr <- ceiling(w2Points / tileDim[1])
	for (blockNum in 1:tpc){
		for (traceNum in 1:tpr){
			rowNum <- (blockNum - 1) * tileDim[2] + 1
			colNum <- (traceNum - 1) * tileDim[1] + 1
			if (traceNum == tpr)
				colOut <- ncol(data) - colNum + 1
			else
				colOut <- tileDim[1]
			if (blockNum == tpc)
				rowOut <- nrow(data) - rowNum + 1
			else
				rowOut <- tileDim[2]
			ucsfData <- data[rowNum:(rowNum + rowOut - 1), 
					colNum:(colNum + colOut - 1)]
			
			## Pad tiles if necessary
			tileRem <- c(w2Points, w1Points) %% tileDim
			if (all(tileRem != 0) && traceNum == tpr && blockNum == tpc){
				
				## Pad final tile
				if (colOut == 1){
					ucsfData <- c(ucsfData, rep(0, tileDim[2] - length(ucsfData)))
					ucsfData <- cbind(as.numeric(ucsfData), matrix(0, nrow=tileDim[2], 
									ncol=tileDim[1] - 1))
				}else if (rowOut == 1){
					ucsfData <- c(ucsfData, rep(0, tileDim[1] - length(ucsfData)))
					ucsfData <- rbind(as.numeric(ucsfData), matrix(0, 
									nrow=tileDim[2] - 1, ncol=tileDim[1]))
				}else{					
					ucsfData <- rbind(ucsfData, matrix(0, 
									nrow=tileDim[2] - nrow(ucsfData), 
									ncol=ncol(ucsfData)))
					ucsfData <- cbind(ucsfData, matrix(0, nrow=tileDim[2], 
									ncol=tileDim[1] - ncol(ucsfData)))
				}
			}else{
				
				## Pad tile in last column
				if (tileRem[1] && traceNum == tpr){
					if (colOut == 1)
						ucsfData <- cbind(as.numeric(ucsfData), matrix(0, nrow=tileDim[2], 
										ncol=tileDim[1] - 1))
					else
						ucsfData <- cbind(ucsfData, matrix(0, nrow=tileDim[2], 
										ncol=tileDim[1] - ncol(ucsfData)))
				}
				
				## Pad tile in last row
				if (tileRem[2] && blockNum == tpc){
					if (rowOut == 1)
						ucsfData <- rbind(as.numeric(ucsfData), matrix(0, 
										nrow=tileDim[2] - 1, ncol=tileDim[1]))
					else
						ucsfData <- rbind(ucsfData, matrix(0, 
										nrow=tileDim[2] - nrow(ucsfData), ncol=tileDim[1]))
				}
			}				
			
			## Write out new tile
			writeBin(as.numeric(t(ucsfData)), writeCon, size=4, endian='big')
		}
	}	
	close(writeCon)
	
	return(outFile)
}

## Internal function for converting ASCII files to sparky (ucsf) format
## inFile - full directory path to the ASCII format processed data file
## outFile - full directory path for the newly created sparky format file
## nuc - nucleus names for each axis (direct, indirect)
## freq - magnetic field strength (MHz) in which the data was collected
## drift - logical; 1D data is corrected for drift if TRUE
## transpose - logical; data is transposed before conversion if TRUE (2Ds only)
ascii2rnmr <- function(inFile, outFile, nuc, freq=NA, drift=FALSE, 
		transpose=FALSE){
	
	## Check arguments
	if (missing(inFile))
		stop('A valid ASCII input file is required')
	if (missing(outFile))
		stop('Output file path is required')
	if (missing(nuc))
		stop('The nucleus name(s) for the spectrum are required')
	if (length(nuc) == 1){
		nDim <- 1
	}else
		nDim <- 2
	
	## Check how the text is separated
	line1 <- suppressWarnings(readLines(inFile, 1))
	if (length(grep('\t', line1))){
		sep <- '\t'
	}else{
		sep <- ' '
	}
	
	## Create error message detailing required data format
	formatErr <- paste('Data must contain a column with the chemical shifts for ',
			'each dimension,\nas well as a column containing the intensities for ',
			'each point in the spectrum,\nor must be a matrix of intensities with ',
			'the first row containing shifts for the\ndirect dimension and the first', 
			' column containing shifts for the indirect dimension.\nAll values must', 
			' be numeric.', sep='') 
	
	## Determine data format
	line1 <- strsplit(line1, sep)[[1]]
	if (length(line1) == (nDim + 1)){
		format <- 'table'		
		if (any(is.na(suppressWarnings(as.numeric(line1))))){
			line1 <- strsplit(suppressWarnings(readLines(inFile, 2))[2], sep)[[1]]
			skip <- 1
		}else
			skip <- 0
	}else if (nDim == 2){
		format <- 'matrix'
		skip <- 1
	}else
		stop(formatErr)
	if (any(is.na(as.numeric(line1))))
		stop(formatErr)
	
	
	## Read data
	data <- tryCatch(read.table(inFile, sep=sep, quote='', row.names=NULL, 
					skip=skip, stringsAsFactors=FALSE, colClasses='numeric', 
					comment.char=''), error=function(er) stop(formatErr))
	#data <- data[,1:2]
	
	## Remove any non-numeric values from data
#	data <- suppressWarnings(data.frame(apply(data, 2, function(x) 
#								as.numeric(x))))
#	rmIndices <- ceiling(which(is.na(t(data))) / ncol(data))
#	if (length(rmIndices))
#		data <- data[-rmIndices, ]
#	if (!length(data) || !nrow(data))
#		stop('Data must contain numeric values in plain text (ASCII) format.')
	
	## Place data into a matrix
	if (nDim == 1){
		
		## Format 1D data
		data <- data[order(data[, 1]), ]
		w2Shifts <- data[, 1]
		w1Shifts <- NULL
		np <- length(w2Shifts)
		outData <- rev(data[, 2])
		if (drift)
			outData <- driftCorr(outData)
	}else{
		
		## Format 2D data (matrix)
		if (format == 'matrix'){
			line1[1] <- 0
			data <- as.matrix(rbind(as.numeric(line1), data))
			w2Shifts <- data[1, ][-1]
			w1Shifts <- data[, 1][-1]
			np <- dim(data) - 1
			outData <- data[-1, -1]
		}else{
			
			## Format 2D data (table)
			data <- data[order(data[, 1], data[, 2]), ]
			w2Shifts <- unique(data[, 1])
			w1Shifts <- unique(data[, 2])
			np <- c(length(w1Shifts), length(w2Shifts))
			outData <- matrix(data[, 3], nrow=np[1], byrow=FALSE)
		}
		outData <- matrix(rev(outData), nrow=nrow(outData))
		if (transpose)
			outData <- t(outData)
	}
	
	## Create table of frequencies for common NMR nuclei
	## These data are taken from www.bmrb.wisc.edu
	nucTable <- data.frame(c(1.000000000, 0.153506088, 0.251449530, 0.101329118, 
					0.404808636, 0.9408664, 1.000000000, 0.153506088, 0.251449530, 
					0.101329118, 0.404808636, 0.9408664), stringsAsFactors=FALSE)
	rownames(nucTable) <- c('H1', 'H2', 'C13', 'N15', 'P31', 'F19', '1H', '2H', 
			'13C', '15N', '31P', '19F')
	
	## Calculate spectrometer frequencies 
	nuc <- rev(nuc)
	if (is.na(freq))
		sf <- c(1, 1)
	else
		sf <- nucTable[nuc, ] * freq
	
	## Write out UCSF file
	if (nDim == 1){
		writeUcsf(outFile, np, nuc, sf, upShift=w2Shifts[1], downShift=w2Shifts[np], 
				data=outData, writeShifts=TRUE)
	}else{
		writeUcsf(outFile, np, nuc, sf, upShift=c(w1Shifts[1], w2Shifts[1]), 
				downShift=c(w1Shifts[np[1]], w2Shifts[np[2]]), data=t(outData), 
				writeShifts=TRUE)
	}
	
	return(outFile)
}

## Converts ASCII files to UCSF format
ca <- function(){
	
	##creates main window
	tclCheck()
	dlg <- myToplevel()
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	tkwm.title(dlg, 'ASCII Conversion')
	tcl('wm', 'attributes', dlg, topmost=TRUE)
	inFiles <- NULL
	
	##creates output directory selection button and text box
	outFrame <- ttklabelframe(dlg, text='Output directory:', padding=3)
	outDir <- tclVar(pkgVar$prevDir)
	outEntry <- ttkentry(outFrame, state='readonly', textvariable=outDir)
	onBrowse <- function(){
		newDir <- myDir(parent=dlg)
		if (nzchar(newDir))
			tclvalue(outDir) <- newDir
	}
	outBrowseButton <- ttkbutton(outFrame, text='Browse', command=onBrowse)
	
	##creates tablelist widget
	tableFrame <- ttklabelframe(dlg, text='Conversion settings:', padding=2)
	xscr <- ttkscrollbar(tableFrame, orient='horizontal', command=function(...) 
				tkxview(tableList, ...))
	yscr <- ttkscrollbar(tableFrame, orient='vertical', command=function(...) 
				tkyview(tableList, ...))
	tableList <- tkwidget(tableFrame, 'tablelist::tablelist', bg='white',
			activestyle='underline', height=11, width=80, exportselection=FALSE,
			selectmode='extended', selecttype='row', spacing=2, stretch='all', 
			editselectedonly=TRUE, labelcommand='tablelist::sortByColumn', 
			xscrollcommand=function(...) tkset(xscr, ...),
			yscrollcommand=function(...) tkset(yscr, ...), 
			columns=c('35', 'Input Files', '20', 'Output Names', '14', 
					'Direct Nucleus', 'center', '14', 'Indirect Nucleus', 'center', '15', 
					'Field strength', 'center'))
	
	##configure tableList columns
	tcl(tableList, 'columnconfigure', 0, sortmode='dictionary')
	for (i in 1:4)
		tcl(tableList, 'columnconfigure', i, editable=TRUE, sortmode='dictionary')
	
	##selects all rows Ctrl+A is pressed
	tkbind(dlg, '<Control-a>', function(...) 
				tkselection.set(tableList, 0, 'end'))
	
	##add nucleus selection comboboxes to tablelist widget
	tcl(tableList, 'columnconfigure', 2, editwindow='ttk::combobox')
	tcl(tableList, 'columnconfigure', 3, editwindow='ttk::combobox')
	onNuc <- function(widget, rowNum, colNum, newVal){
		if (colNum == 2 || colNum == 3){
			tkconfigure(tcl(tableList, 'entrypath'), state='readonly', 
					values=c('1H', '2H', '13C', '15N', '31P', '19F'), 
					exportselection=FALSE)
		}
		if (colNum == 3){
			tkconfigure(tcl(tableList, 'entrypath'), state='readonly', 
					values=c('NA', '1H', '2H', '13C', '15N', '31P', '19F'), 
					exportselection=FALSE)
		}
		return(tclVar(as.character(newVal)))
	}
	tkconfigure(tableList, editstartcommand=function(...) onNuc(...))
	
	##check user edited entries
	onEdit <- function(widget, rowNum, colNum, newVal){
		if (!nzchar(gsub(' ', '', newVal)))
			tcl(tableList, 'cancelediting')
		if (colNum == 4)
			newVal <- suppressWarnings(as.numeric(newVal))
		return(tclVar(as.character(newVal)))
	}
	tkconfigure(tableList, editendcommand=function(...) onEdit(...))
	
	##creates add files button
	buttonFrame <- ttkframe(tableFrame)
	inputFrame <- ttklabelframe(buttonFrame, text='Input', padding=3)
	onAdd <- function(){
		newFiles <- myOpen(title='Select ASCII Spectra', parent=dlg)
		if (!length(newFiles))
			return(invisible())
		inNames <- basename(newFiles)
		outNames <- paste(sub('.txt', '', inNames), '.ucsf', sep='')
		data <- cbind(inNames, outNames, rep('1H', length(inNames)), 
				rep('NA', length(inNames)), rep('NA', length(inNames)))
		for (i in 1:nrow(data))
			tkinsert(tableList, 'end', unlist(data[i, ]))
		inFiles <<- c(inFiles, newFiles)
	}
	addButton <- ttkbutton(inputFrame, text='Add Files', width=16, 
			command=onAdd)
	
	##creates remove files button
	onRemove <- function(){
		tcl(tableList, 'finishediting')
		usrSel <- tclvalue(tcl(tableList, 'curselection'))
		if(!length(usrSel))
			return(invisible())
		tkdelete(tableList, usrSel)
		inFiles <<- inFiles[-(as.numeric(usrSel) + 1)]
	}
	removeButton <- ttkbutton(inputFrame, text='Remove Selected', width=16, 
			command=onRemove)
	
	##creates append paths button
	outputFrame <- ttklabelframe(buttonFrame, text='Output', padding=3)
	onAppend <- function(){
		tcl(tableList, 'finishediting')
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if(!length(usrSel))
			return(invisible())
		outNames <- gsub('C:/', '', inFiles[usrSel + 1], fixed=TRUE)
		outNames <- gsub('/', '_', outNames, fixed=TRUE)
		outNames <- paste(sub('.txt', '', outNames), '.ucsf', sep='')
		usrSel <- paste(usrSel, ',1', sep='')
		cellVals <- NULL
		for (i in seq_along(usrSel))
			tcl(tableList, 'cellconfigure', usrSel[i], text=outNames[i])
	}
	appendButton <- ttkbutton(outputFrame, text='Append Paths', width=16, 
			command=onAppend)
	
	##creates drift correction checkbox
	drift <- tclVar(0)
	driftCheck <- ttkcheckbutton(outputFrame, variable=drift, 
			text='1D Drift correction')
	
	##creates direct nucleus selection widgets
	dirNucFrame <- ttklabelframe(buttonFrame, text='Direct nucleus', padding=3)
	dirNuc <- tclVar('1H')
	dirNucBox <- ttkcombobox(dirNucFrame, textvariable=dirNuc, width=9, 
			values=c('1H', '2H', '13C', '15N', '31P', '19F'), state='readonly', 
			exportselection=FALSE)
	onNucApply <- function(dim){
		tcl(tableList, 'finishediting')
		usrSel <- as.character(tcl(tableList, 'curselection'))
		if(!length(usrSel))
			return(invisible())
		if (dim == 'direct'){
			usrSel <-  paste(usrSel, ',2', sep='')
			newNuc <- tclvalue(dirNuc)
		}else{
			usrSel <-  paste(usrSel, ',3', sep='')
			newNuc <- tclvalue(indirNuc)
		}
		for (i in usrSel)
			tcl(tableList, 'cellconfigure', i, text=newNuc)
	}
	dirApplyBtn <- ttkbutton(dirNucFrame, text='Apply', width=11, 
			command=function(...) onNucApply('direct'))
	
	##creates indirect nucleus selection widgets
	indirNucFrame <- ttklabelframe(buttonFrame, text='Indirect nucleus', 
			padding=3)
	indirNuc <- tclVar('NA')
	indirNucBox <- ttkcombobox(indirNucFrame, textvariable=indirNuc, width=9, 
			values=c('NA', '1H', '2H', '13C', '15N', '31P', '19F'), state='readonly', 
			exportselection=FALSE)
	indirApplyBtn <- ttkbutton(indirNucFrame, text='Apply', width=11, 
			command=function(...) onNucApply('indirect'))
	
	##creates field strength editing widgets
	fieldFrame <- ttklabelframe(buttonFrame, text='Field strength', padding=3)
	fieldVar <- tclVar('NA')
	fieldEntry <- ttkentry(fieldFrame, width=11, textvariable=fieldVar)
	onFieldApply <- function(){
		tcl(tableList, 'finishediting')
		usrSel <- as.character(tcl(tableList, 'curselection'))
		if (!length(usrSel))
			return(invisible())
		usrSel <-  paste(usrSel, ',4', sep='')
		newField <- suppressWarnings(as.numeric(tclvalue(fieldVar)))
		for (i in usrSel)
			tcl(tableList, 'cellconfigure', i, text=as.character(newField))
	}
	fieldApplyBtn <- ttkbutton(fieldFrame, text='Apply', width=11, 
			command=onFieldApply)
	
	##converts ASCII spectra
	onConvert <- function(){
		
		##make sure files have been added for conversion
		tcl(tableList, 'finishediting')
		if (!length(inFiles))
			err('You must add files before converting.')
		
		##check for duplicates in outNames
		outNames <- file.path(tclvalue(outDir), as.character(tcl(tableList, 
								'getcolumns', 1)))
		if (!length(outNames))
			err('You must provide an output name for each spectrum.')
		outNames[duplicated(outNames)] <- paste(outNames[duplicated(outNames)], 
				'(2)', sep='')
		for (i in seq_along(outNames[duplicated(outNames)]))
			outNames[duplicated(outNames)] <- gsub(paste(i + 1, ')$', sep=''), 
					paste(i + 2, ')', sep=''), outNames[duplicated(outNames)])
		
		##get direct nuclei
		dirNucs <- as.character(tcl(tableList, 'getcolumns', 2))
		if (any(!nzchar(dirNucs)))
			err('You must provide the direct nucleus for each spectrum.')
		
		##get indirect nuclei
		indirNucs <- as.character(tcl(tableList, 'getcolumns', 3))
		
		##get magnetic field strengths
		fieldStrengths <- suppressWarnings(as.numeric(tcl(tableList, 'getcolumns', 
								4)))
		
		##convert files
		tkconfigure(dlg, cursor='watch')
		cat('Converting . . .\n')
		checkOver <- TRUE
		convertedList <- NULL
		errors <- FALSE
		for (i in seq_along(inFiles)){
			
			## Checks for the existence of outNames[i] and confirms overwrite
			if (checkOver && file.exists(outNames[i])){
				usrSel <- buttonDlg(paste('"', outNames[i], '"', ' already exists.\n',
								'Would you like to overwrite?', sep=''), c('Yes', 'No', 
								'Apply to all'), TRUE, 'No', parent=dlg)
				if (usrSel[[1]] == 'Yes' && usrSel[[2]])
					checkOver <- FALSE
				if (usrSel[[1]] == 'No'){
					if (usrSel[[2]])
						stop('File conversion canceled', call.=FALSE)
					next
				}
			}
			
			##convert the file
			if (indirNucs[i] == 'NA')
				nuc <- dirNucs[i]
			else
				nuc <- c(dirNucs[i], indirNucs[i])
			outMsg <- tryCatch({ascii2rnmr(inFiles[i], outNames[i], nuc, 
								fieldStrengths[i], as.integer(tclvalue(drift)))
						convertedList <- c(convertedList, outNames[i])}, 
					error=function(er){
						errors <<- TRUE
						paste('\n', 'Conversion of "', inFiles[i],
								'"\nproduced an error:\n    ', er$message, '\n', sep='')})
			if (length(outMsg))
				cat(outMsg[length(outMsg)], '\n', sep='')
		}
		
		##display error dialog if errors occurred
		cat('\nConversion complete.\n\n')
		tkconfigure(dlg, cursor='arrow')
		if (errors)
			myMsg(paste('Errors occurred during conversion.',
							'Check the R console for details.', sep='\n'), icon='error', 
					parent=dlg)
		else
			tkdestroy(dlg)
		
		##ask user if newly converted files should be opened
		if (is.null(convertedList))
			return(invisible())
		usrSel <- myMsg('Would you like to open the newly converted files?', 
				'yesno')
		if (usrSel == 'yes'){
			fo(convertedList)
			fs()
		}
	}
	
	##creates convert button
	convertButton <- ttkbutton(dlg, text='Convert Files', width=16, 
			command=function(...) tryCatch(onConvert(), error=function(er) 
							tkconfigure(dlg, cursor='arrow')))
	
	##add widgets to outFrame
	tkgrid(outFrame, column=1, row=1, sticky='we', pady=8, padx=c(13, 0))
	tkgrid(outEntry, column=1, row=1, sticky='we', padx=3)
	tkgrid(outBrowseButton, column=2, row=1, padx=2)
	tkgrid.columnconfigure(outFrame, 1, weight=1)
	
	##add widgets to tableFrame
	tkgrid(tableFrame, column=1, row=2, sticky='nswe', padx=c(13, 0))
	tkgrid(tableList, column=1, row=1, sticky='nswe')
	tkgrid(yscr, column=2, row=1, sticky='ns')
	tkgrid(xscr, column=1, row=2, sticky='we')
	
	##make tableFrame stretch when window is resized
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 2, weight=1)
	tkgrid.columnconfigure(tableFrame, 1, weight=1)
	tkgrid.rowconfigure(tableFrame, 1, weight=1)
	
	##add widgets to buttonFrame
	tkgrid(buttonFrame, column=1, columnspan=3, row=3, pady=8)
	tkgrid(inputFrame, column=1, row=1, padx=30)
	tkgrid(addButton, column=1, row=1, pady=c(2, 6), padx=6)
	tkgrid(removeButton, column=1, row=2, pady=c(0, 4), padx=6)
	
	tkgrid(outputFrame, column=2, row=1, padx=c(20, 10))
	tkgrid(appendButton, column=1, row=1, pady=c(2, 6), padx=4)
	tkgrid(driftCheck, column=1, row=2, pady=c(0, 4), padx=4)
	
	tkgrid(dirNucFrame, column=3, row=1, padx=c(15, 5))
	tkgrid(dirNucBox, column=1, row=1, pady=c(2, 6), padx=4)
	tkgrid(dirApplyBtn, column=1, row=2, pady=c(0, 4), padx=4)
	
	tkgrid(indirNucFrame, column=4, row=1, padx=10)
	tkgrid(indirNucBox, column=1, row=1, pady=c(2, 6), padx=4)
	tkgrid(indirApplyBtn, column=1, row=2, pady=c(0, 4), padx=4)
	
	tkgrid(fieldFrame, column=5, row=1, padx=c(0, 10))
	tkgrid(fieldEntry, column=1, row=1, pady=c(2, 6), padx=4)
	tkgrid(fieldApplyBtn, column=1, row=2, pady=c(0, 4), padx=4)
	
	tkgrid(convertButton, column=1, row=3, pady=c(16, 0))
	tkgrid(ttksizegrip(dlg), column=2, row=5, sticky='se')
	
	return(invisible())
}

## Internal function for converting files
## displays file type specific conversion GUIs
conFiles <- function(type, pathNames, pDataPaths, parent){
	
	##creates main window
	tclCheck()
	tt <- myToplevel(parent=parent)
	tkfocus(tt)
	tkwm.deiconify(tt)
	tcl('wm', 'attributes', tt, topmost=TRUE)
	
	##creates output directory selection button and text box
	dirFrame <- ttklabelframe(tt, text='Output directory', padding=3)
	outDir <- tclVar(pkgVar$prevDir)
	outEntry <- ttkentry(dirFrame, state='readonly', textvariable=outDir)
	onBrowse <- function(){
		newDir <- myDir(parent=tt)
		if (nzchar(newDir))
			tclvalue(outDir) <- newDir
	}
	browseButton <- ttkbutton(dirFrame, text='Browse', command=onBrowse)
	
	##create tablelist widget
	tableFrame <- ttklabelframe(tt, text='Conversion settings:', padding=2)
	xscr <- ttkscrollbar(tableFrame, orient='horizontal', command=function(...) 
				tkxview(tableList, ...))
	yscr <- ttkscrollbar(tableFrame, orient='vertical', command=function(...) 
				tkyview(tableList, ...))
	colVals <- c('57', 'Spectra', '30', 'Output Names')
	if (type == 'varian')
		colVals <- c(colVals, '15', 'Indirect Nucleus', 'center')
	tableList <- tkwidget(tableFrame, 'tablelist::tablelist', columns=colVals, 
			activestyle='underline', height=15, width=108, exportselection=FALSE,
			selectmode='extended', selecttype='row', spacing=2, stretch='all', 
			bg='white', editselectedonly=TRUE, 
			xscrollcommand=function(...) tkset(xscr, ...),
			yscrollcommand=function(...) tkset(yscr, ...))
	buttonFrame <- ttkframe(tableFrame)
	
	##creates output names
	if (type == 'bruker'){
		tkwm.title(tt, 'Bruker Conversion')
		splitPaths <- strsplit(pathNames, '/')
		outNames <- NULL
		for (i in splitPaths){
			numFolders <- length(i)
			foundNumber <- FALSE
			for (j in 1:numFolders){
				if (!is.na(suppressWarnings(as.numeric(i[j])))){
					foundNumber <- TRUE
					if (j == 1)
						outName <- paste(i[j:numFolders], collapse='/')
					else
						outName <- paste(i[(j - 1):numFolders], collapse='/')
					outNames <- c(outNames, outName)
					break
				}else if (j == numFolders && !foundNumber){
					outName <-  i[j]
					outNames <- c(outNames, outName)
					break
				}
			}
		}
		outNames <- gsub('/', '_', paste(outNames, '.ucsf', sep=''))
	}else if (type == 'pipe'){
		tkwm.title(tt, 'NMRPipe Conversion')
		outNames <- paste(basename(pathNames), '.ucsf', sep='')
		outNames <- gsub('.ft2', '', outNames)
		outNames <- gsub('.dat', '', outNames)
	}else{
		tkwm.title(tt, 'Varian Conversion')
		outNames <- paste(basename(pathNames), '.ucsf', sep='')
		outNames <- gsub('.fid', '', outNames)
		
		##get procpar files
		procPaths <- NULL
		for (i in seq_along(pDataPaths)){
			if (basename(dirname(pDataPaths[i])) == 'datdir')
				procDir <- dirname(dirname(pDataPaths[i]))
			else
				procDir <- dirname(pDataPaths[i])
			procPath <- list.files(procDir, full.names=TRUE, pattern="^procpar$")
			if (!length(procPath))
				procPath <- list.files(procDir, full.names=TRUE, pattern="^procpar$", 
						recursive=TRUE)[1]
			procPaths <- c(procPaths, procPath)
		}
		
		##get nuclei from procpar files
		nucList <- NULL
		errors <- FALSE
		for (i in procPaths){
			nucleus <- unlist(tryCatch(suppressWarnings(parseProcpar(i, 'posNuc')),
							error=function(er){
								cat('\n', er$message, '\n\n', sep='')
								errors <<- c(errors, TRUE)}))
			if (nucleus[1] != FALSE)
				nucList <- rbind(nucList, nucleus)
		}
		if (!length(nucList)){
			tkdestroy(tt)
			myMsg('Could not convert selected files.\nSee R console for details.', 
					icon='error')
			return(invisible())
		}
		if (any(errors)){
			invisible(myMsg(paste('Errors occurred while reading the procpar files', 
									'for one or more of the selected files.\n', 
									'See the R console for details.', sep=''), icon='error', 
							parent=tt))
			outNames <- outNames[-which(errors[-1])]
			pathNames <- pathNames[-which(errors[-1])]
			pDataPaths <- pDataPaths[-which(errors[-1])]
			procPaths <- procPaths[-which(errors[-1])]
		}
		nucList <- data.frame(nucList, stringsAsFactors=FALSE, row.names=NULL)
		posNuc <- unique(c(nucList$tn, nucList$dn, nucList$dn2, nucList$dn3, 
						nucList$dn4, nucList$dn5))
		posNuc <- posNuc[nzchar(posNuc)]
		nucList$dn[which(nucList$nDim == 1)] <- 'NA'
		indirNucList <- nucList$dn
		
		##add nucleus selection comboboxes to tablelist widget
		tcl(tableList, 'columnconfigure', 2, editwindow='ttk::combobox')
		onNuc <- function(widget, rowNum, colNum, newVal){
			if (colNum == 2){
				tkconfigure(tcl(tableList, 'entrypath'), values=posNuc, 
						state='readonly')
			}
			return(tclVar(as.character(newVal)))
		}
		tkconfigure(tableList, editstartcommand=function(...) onNuc(...))
		
		##create indirect nucleus combo box
		nucFrame <- ttkframe(buttonFrame)
		nucLabel <- ttklabel(nucFrame, text='Select nucleus:')
		indirNuc <- tclVar('')
		nucBox <- ttkcombobox(nucFrame, textvariable=indirNuc, height=5, 
				width=8, values=posNuc, state='readonly', exportselection=FALSE)
		
		##update nuclei in tablelist
		onCombo <- function(){
			usrSel <- as.character(tcl(tableList, 'curselection'))
			if (!length(usrSel))
				return(invisible())
			tcl(tableList, 'finishediting')
			usrSel <- paste(usrSel, ',2', sep='')
			for (i in usrSel)
				tcl(tableList, 'cellconfigure', i, text=tclvalue(indirNuc))
		}
		tkbind(nucBox, '<<ComboboxSelected>>', onCombo) 
	}
	
	##add items to tablelist widget
	data <- cbind(pathNames, outNames)
	if (type == 'varian')
		data <- cbind(data, indirNucList)
	for (i in 1:nrow(data))
		tkinsert(tableList, 'end', unlist(data[i, ]))
	tcl(tableList, 'columnconfigure', 1, editable=TRUE)
	if (type == 'varian')
		tcl(tableList, 'columnconfigure', 2, editable=TRUE)	
	else{
		tcl(tableList, 'columnconfigure', 0, width=0)
		tcl(tableList, 'columnconfigure', 1, width=0)
	}
	
	##check edited output names
	onEdit <- function(widget, rowNum, colNum, newVal){
		if (!nzchar(gsub(' ', '', newVal)))
			tcl(tableList, 'cancelediting')
		return(tclVar(as.character(newVal)))
	}
	tkconfigure(tableList, editendcommand=function(...) onEdit(...))
	
	##creates drift correction checkbox
	drift <- tclVar(0)
	driftCheck <- ttkcheckbutton(buttonFrame, variable=drift, 
			text='1D Drift correction               ')
	
	##creates append paths button
	onAppend <- function(){
		tcl(tableList, 'finishediting')
		usrSel <- as.numeric(tcl(tableList, 'curselection'))
		if(!length(usrSel))
			return(invisible())
		if (type == 'bruker'){
			outNames <- paste(gsub('/', '_', pathNames[usrSel + 1], fixed=TRUE), 
					'.ucsf', sep='')
			outNames <- sub('._', '', outNames, fixed=TRUE)
		}else{
			outNames <- as.character(tcl(tableList, 'getcolumns', 1))[usrSel + 1]
			outNames <- paste(gsub('/', '_', dirname(pathNames[usrSel + 1]), 
							fixed=TRUE), outNames, sep='_')
			outNames <- sub('._', '', outNames, fixed=TRUE)
		}
		usrSel <- paste(usrSel, ',1', sep='')
		cellVals <- NULL
		for (i in seq_along(usrSel))
			tcl(tableList, 'cellconfigure', usrSel[i], text=outNames[i])
	}
	appendButton <- ttkbutton(buttonFrame, text='Append Paths', width=14, 
			command=onAppend)
	
	##converts Bruker spectra
	conBruk <- function(){
		
		##set necessary variables
		outNames <- file.path(tclvalue(outDir), as.character(tcl(tableList, 
								'getcolumns', 1)))
		acquPaths <- sapply(strsplit(pDataPaths, '/pdata'), function(x) x[1])
		procPaths <- dirname(pDataPaths)
		checkOver <- TRUE
		convertedList <- NULL
		errors <- FALSE
		
		##check for duplicates in outNames
		outNames[duplicated(outNames)] <- paste(outNames[duplicated(outNames)], 
				'(2)', sep='')
		for (i in seq_along(outNames[duplicated(outNames)]))
			outNames[duplicated(outNames)] <- gsub(paste(i + 1, ')$', sep=''), 
					paste(i + 2, ')', sep=''), outNames[duplicated(outNames)])
		
		for (i in seq_along(pDataPaths)){
			
			## Checks for the existence of outNames[i] and confirms overwrite
			if (checkOver && file.exists(outNames[i])){
				usrSel <- buttonDlg(paste('"', outNames[i], '"', ' already exists.\n',
								'Would you like to overwrite?', sep=''), c('Yes', 'No', 
								'Apply to all'), TRUE, 'No', parent=tt)
				if (usrSel[[1]] == 'Yes' && usrSel[[2]])
					checkOver <- FALSE
				if (usrSel[[1]] == 'No'){
					if (usrSel[[2]])
						stop('File conversion canceled', call.=FALSE)
					next
				}
			}
			
			##get conversion parameters
			acquPar <- tryCatch(parseAcqus(acquPaths[i]), error=function(er){
						cat(er$message, '\n')
						errors <- TRUE})
			if (!length(acquPar))
				next
			if (length(grep('2rr$', pDataPaths[i])) && nrow(acquPar) != 2){
				cat('Can not convert "', pDataPaths[i], '",\n  Could not find ',
						'acquisition parameter files ("acqu2" or "acqu2s")\n', sep='')
				errors <- TRUE
				next
			}
			procPar <- tryCatch(parseProcs(procPaths[i]), error=function(er){
						cat(er$message, '\n')
						errors <- TRUE})
			if(!length(procPar))
				next
			if (length(grep('2rr$', pDataPaths[i])) && nrow(procPar) != 2){
				cat('Can not convert "', pDataPaths[i], '",\n  Could not find ',
						'processing parameter files ("proc2" or "proc2s")\n', sep='')
				errors <- TRUE
				next
			}
			
			##check for correct data type
			if (procPar$FT_mod == 'no' || 
					nchar(unlist(strsplit(procPar$FT_mod, 'r'))) == 3){
				cat('Can not convert "', pDataPaths[i], '",\n  rNMR can only ',
						'convert real Fourier transformed data.\n', sep='')
				errors <- TRUE
				next
			}
			
			##convert 1D spectra
			if (length(grep('1r$', pDataPaths[i]))){
				if (nrow(acquPar) == 2)
					acquPar <- acquPar[1, ]
				if (nrow(procPar) == 2)
					procPar <- procPar[1, ]
				outMsg <- tryCatch({bruker1D(pDataPaths[i], outNames[i], acquPar$NUC1, 
									acquPar$SFO1, procPar$BYTORDP, procPar$NC_proc,	
									procPar$OFFSET, procPar$SF,	procPar$SI, procPar$SW_p,	
									as.integer(tclvalue(drift)))
							convertedList <- c(convertedList, outNames[i])}, 
						error=function(er){
							errors <<- TRUE
							paste('\n', 'Conversion of "', pDataPaths[i],
									'"\nproduced an error:\n    ', er$message, '\n', sep='')})
				
				##convert 2D spectra
			}else{
				outMsg <- tryCatch({bruker2D(pDataPaths[i], outNames[i], acquPar$NUC1, 
									acquPar$SFO1, procPar$BYTORDP[1],	procPar$NC_proc[1], 
									procPar$OFFSET, procPar$SF, procPar$SI,	procPar$SW_p, 
									procPar$XDIM)
							convertedList <- c(convertedList, outNames[i])}, 
						error=function(er){
							errors <<- TRUE
							paste('\n', 'Conversion of "', pDataPaths[i],
									'"\nproduced an error:\n    ', er$message, '\n', sep='')})
			}
			if (length(outMsg))
				cat(outMsg[length(outMsg)], '\n', sep='')
		}
		
		##display error dialog if errors occurred
		cat('\nConversion complete.\n\n')
		if (errors)
			myMsg(paste('Errors occurred during conversion.',
							'Check the R console for details.', sep='\n'), icon='error', 
					parent=tt)
		
		return(convertedList)
	}
	
	##converts NMRPipe spectra
	conPipe <- function(){
		
		##check for duplicates in outNames
		outNames <- file.path(tclvalue(outDir), as.character(tcl(tableList, 
								'getcolumns', 1)))
		outNames[duplicated(outNames)] <- paste(outNames[duplicated(outNames)], 
				'(2)', sep='')
		for (i in seq_along(outNames[duplicated(outNames)]))
			outNames[duplicated(outNames)] <- gsub(paste(i + 1, ')$', sep=''), 
					paste(i + 2, ')', sep=''), outNames[duplicated(outNames)])
		
		##convert files
		checkOver <- TRUE
		convertedList <- NULL
		errors <- FALSE
		for (i in seq_along(pDataPaths)){
			
			## Checks for the existence of outNames[i] and confirms overwrite
			if (checkOver && file.exists(outNames[i])){
				usrSel <- buttonDlg(paste('"', outNames[i], '"', ' already exists.\n',
								'Would you like to overwrite?', sep=''), c('Yes', 'No', 
								'Apply to all'), TRUE, 'No', parent=tt)
				if (usrSel[[1]] == 'Yes' && usrSel[[2]])
					checkOver <- FALSE
				if (usrSel[[1]] == 'No'){
					if (usrSel[[2]])
						stop('File conversion canceled', call.=FALSE)
					next
				}
			}
			
			##convert the file
			outMsg <- tryCatch({pipe2rnmr(pDataPaths[i], outNames[i],
								as.integer(tclvalue(drift)))
						convertedList <- c(convertedList, outNames[i])}, 
					error=function(er){
						errors <<- TRUE
						paste('\n', 'Conversion of "', pDataPaths[i],
								'"\nproduced an error:\n    ', er$message, '\n', sep='')})
			if (length(outMsg))
				cat(outMsg[length(outMsg)], '\n', sep='')
		}
		
		##display error dialog if errors occurred
		cat('\nConversion complete.\n\n')
		if (errors)
			myMsg(paste('Errors occurred during conversion.',
							'Check the R console for details.', sep='\n'), icon='error', 
					parent=tt)
		
		return(convertedList)
	}
	
	##converts Varian spectra
	conVar <- function(){
		
		##set output paths and check for duplicates
		outNames <- file.path(tclvalue(outDir), as.character(tcl(tableList, 
								'getcolumns', 1)))
		outNames[duplicated(outNames)] <- paste(outNames[duplicated(outNames)], 
				'(2)', sep='')
		for (i in seq_along(outNames[duplicated(outNames)]))
			outNames[duplicated(outNames)] <- gsub(paste(i + 1, ')$', sep=''), 
					paste(i + 2, ')', sep=''), outNames[duplicated(outNames)])
		
		##convert spectra
		checkOver <- TRUE
		convertedList <- NULL
		errors <- FALSE
		for (i in seq_along(pDataPaths)){
			
			##get processing parameters
			procPar <- tryCatch(parseProcpar(procPaths[i], idn=indirNucList[i]), 
					error=function(er){
						cat(er$message, '\n')
						errors <- TRUE})
			if (!length(procPar))
				next
			
			##convert 1D spectra
			if (procPar$nDim == 1){
				if (procPar$arrayDim > 1){
					
					## Checks for the existence of outNames and confirms overwrite
					splitOut <- unlist(strsplit(outNames[i], '.', fixed=TRUE))
					outArrays <- NULL
					for (array in 1:procPar$arrayDim){
						if (length(splitOut) > 1){
							outArray <- paste(splitOut[1:length(splitOut) - 1], collapse='.')
							outArray <- paste(outArray, array, sep='_')
							outArray <- paste(outArray, splitOut[length(splitOut)], sep='.')
						}else
							outArray <- paste(outArray, array, sep='_')
						if (checkOver && file.exists(outArray)){
							usrSel <- buttonDlg(paste('"', outArray, '"', ' already exists.',
											'\nWould you like to overwrite?', sep=''), c('Yes', 'No', 
											'Apply to all'), TRUE, 'No', parent=tt)
							if (usrSel[[1]] == 'Yes' && usrSel[[2]])
								checkOver <- FALSE
							if (usrSel[[1]] == 'No'){
								if (usrSel[[2]])
									stop('File conversion canceled', call.=FALSE)
								next
							}
						}
						outArrays <- c(outArrays, outArray)
					}
					
					## Converts the file
					outMsg <- tryCatch({varian1D(pDataPaths[i], outNames[i], procPar$tn, 
										procPar$rfl, procPar$rfp, procPar$sfrq, procPar$sw, 
										as.integer(tclvalue(drift)))
								invisible(convertedList <- c(convertedList, outArrays))
								paste('\n', outArrays, sep='')}, 
							error=function(er){
								errors <<- TRUE
								paste('\n', 'Conversion of "', pDataPaths[i],
										'"\nproduced an error:\n    ', er$message, '\n', sep='')})
				}else{
					
					## Checks for the existence of outNames and confirms overwrite
					if (checkOver && file.exists(outNames[i])){
						usrSel <- buttonDlg(paste('"', outNames[i], '"', ' already exists.',
										'\nWould you like to overwrite?', sep=''), c('Yes', 'No', 
										'Apply to all'), TRUE, 'No', parent=tt)
						if (usrSel[[1]] == 'Yes' && usrSel[[2]])
							checkOver <- FALSE
						if (usrSel[[1]] == 'No'){
							if (usrSel[[2]])
								stop('File conversion canceled', call.=FALSE)
							next
						}
					}
					
					## Converts the file
					outMsg <- tryCatch({varian1D(pDataPaths[i], outNames[i], procPar$tn, 
										procPar$rfl, procPar$rfp, procPar$sfrq, procPar$sw, 
										as.integer(tclvalue(drift)))
								invisible(convertedList <- c(convertedList, outNames[i]))
								outNames[i]}, 
							error=function(er){
								errors <<- TRUE
								paste('\n', 'Conversion of "', pDataPaths[i],
										'"\nproduced an error:\n    ', er$message, '\n', sep='')})
				}
			}else{
				
				## Checks for the existence of outNames[i] and confirms overwrite
				if (checkOver && file.exists(outNames[i])){
					usrSel <- buttonDlg(paste('"', outNames[i], '"', ' already exists.\n',
									'Would you like to overwrite?', sep=''), c('Yes', 'No', 
									'Apply to all'), TRUE, 'No', parent=tt)
					if (usrSel[[1]] == 'Yes' && usrSel[[2]])
						checkOver <- FALSE
					if (usrSel[[1]] == 'No'){
						if (usrSel[[2]])
							stop('File conversion canceled', call.=FALSE)
						next
					}
				}
				
				##convert 2D spectra
				outMsg <- tryCatch({varian2D(pDataPaths[i], outNames[i], procPar$tn, 
									procPar$rfl, procPar$rfp, procPar$sfrq, procPar$sw, 
									procPar$idn, procPar$idrfl, procPar$idrfp, procPar$idfrq, 
									procPar$idsw,	procPar$trace)
							invisible(convertedList <- c(convertedList, outNames[i]))
							outNames[i]}, 
						error=function(er){
							errors <<- TRUE
							paste('\n', 'Conversion of "', pDataPaths[i],
									'"\nproduced an error:\n    ', er$message, '\n', sep='')})
			}
			if (length(outMsg))
				cat(outMsg, '\n')
		}
		
		##display error dialog if errors occurred
		cat('\nConversion complete.\n\n')
		if (errors)
			myMsg(paste('Errors occurred during conversion.',
							'Check the R console for details.', sep='\n'), icon='error', 
					parent=tt)
		
		return(convertedList)
	}
	
	##converts spectra
	onConvert <- function(){
		tcl(tableList, 'finishediting')
		tkconfigure(tt, cursor='watch')
		cat('Converting . . .\n')
		if (type == 'bruker')
			convertedFiles <- conBruk()
		else if (type == 'pipe')
			convertedFiles <- conPipe()
		else
			convertedFiles <- conVar()
		tkconfigure(tt, cursor='arrow')
		tkdestroy(tt)
		
		##ask user if newly converted files should be opened
		if (is.null(convertedFiles))
			return(invisible())
		usrSel <- myMsg('Would you like to open the newly converted files?', 
				'yesno')
		if (usrSel == 'yes'){
			fo(convertedFiles)
			fs()
		}
	}
	
	##creates convert button
	convertButton <- ttkbutton(tt, text='Convert', width=16, command=function(...) 
				tryCatch(onConvert(), error=function(er) 
							tkconfigure(tt, cursor='arrow')))
	
	##add widgets to dirFrame
	tkgrid(dirFrame, column=1, row=1, sticky='we', pady=8, padx=c(13, 0))
	tkgrid(outEntry, column=1, row=1, sticky='we', padx=3)
	tkgrid(browseButton, column=2, row=1, padx=2)
	tkgrid.columnconfigure(dirFrame, 1, weight=1)
	
	##add widgets to tableFrame
	tkgrid(tableFrame, column=1, row=2, sticky='nswe', padx=c(13, 0))
	tkgrid(tableList, column=1, row=1, sticky='nswe')
	tkgrid(yscr, column=2, row=1, sticky='ns')
	tkgrid(xscr, column=1, row=2, sticky='we')
	
	##make tableFrame stretch when window is resized
	tkgrid.columnconfigure(tt, 1, weight=1)
	tkgrid.rowconfigure(tt, 2, weight=1)
	tkgrid.columnconfigure(tableFrame, 1, weight=1)
	tkgrid.rowconfigure(tableFrame, 1, weight=1)
	
	##add widgets to buttonFrame
	tkgrid(buttonFrame, column=1, columnspan=3, row=3, pady=8)
	tkgrid(driftCheck, column=1, row=1)
	tkgrid(appendButton, column=2, row=1, padx=c(66, 0))
	if (type == 'varian'){
		tkgrid(nucFrame, column=3, row=1, padx=c(80, 0))
		tkgrid(nucLabel, column=1, row=1, padx=c(0, 4))
		tkgrid(nucBox, column=2, row=1)
	}
	tkgrid(convertButton, column=1, row=3, pady=c(16, 0))
	tkgrid(ttksizegrip(tt), column=2, row=4, sticky='se')
	
	##configure dialog window
	tkwm.deiconify(tt)
	if (as.logical(tkwinfo('viewable', tt)))
		tkgrab.set(tt)
	tkfocus(tt)
	tkwait.window(tt)
	
	return(invisible())
}

## Converts Bruker, NMRPipe, and Varian files to UCSF format
cf <- function(){
	
	##creates main window
	tclCheck()
	dlg <- myToplevel('cf')
	if (is.null(dlg))
		return(invisible())
	tkwm.title(dlg, 'File Conversion')
	tkfocus(dlg)
	tkwm.deiconify(dlg)
	type <- filePaths <- procPaths <- NULL
	
	##creates input directory selection button and text box
	dirFrame <- ttklabelframe(dlg, text='Input directory', padding=3)
	inDir <- tclVar('')
	inEntry <- ttkentry(dirFrame, width=61, state='readonly', textvariable=inDir)
	onBrowse <- function(){
		newDir <- myDir(parent=dlg)
		if (nzchar(newDir)){
			tclvalue(inDir) <- newDir
			tkdelete(tableList, 0, 'end')
			for (i in buttonList)
				tkconfigure(i, state='normal')
			tkconfigure(nextButton, state='disabled')
			filePaths <<- procPaths <<- NULL
		}
	}
	browseButton <- ttkbutton(dirFrame, text='Browse', command=onBrowse)
	
	## function for displaying nested file paths
	dispPaths <- function(filePaths, pDataPaths, checkNumeric=FALSE){
		
		## set necessary variables
		splitFiles <- strsplit(filePaths, '/')
		folderList <- pathNames <- dataPaths <- NULL
		dataIndex <- 1
		spaces <- '      '
		
		## look through the filepaths one at time
		for (i in seq_along(splitFiles)){
			numFolders <- length(splitFiles[[i]])
			
			## look through the current filepath's folders one at a time
			for (j in 1:numFolders){
				
				## get all the filepaths through level j
				mainDirs <- sapply(splitFiles, function(x) paste(x[1:j], collapse='/'))
				
				## set the current path to include directories up to level j
				pathName <- paste(splitFiles[[i]][1:j], collapse='/')
				
				## check if the current path up to level j only appears once (directory 
				##     has only one file)
				if (length(grep(paste('@', pathName, '@', sep=''), 
								paste('@', mainDirs, '@', sep=''),	fixed=TRUE)) == 1){
					
					## check if the current path contains other folders and check if the 
					##    folder containing the current path (j-1) only appears once
					if (numFolders > 1 && length(grep(paste('@', dirname(pathName), '@', 
											sep=''), paste('@', dirname(mainDirs), '@', sep=''), 
									fixed=TRUE)) < 2){
						
						## if the current path is the full path add the current path to the 
						##   folders list, otherwise increment the loop
						if (j == numFolders)
							folderName <- pathName
						else
							next
						
						## if the current path is the full path add the last item in the path
						##    to the folders list
					}else if (j == numFolders){
						folderName <- paste(paste(rep(spaces, j - 1), collapse=''), 
								paste(splitFiles[[i]][j], collapse='/'), sep='')
						
						## if the current path is not the full path add everything up to the 
						##    last item in the path (the lowest directory) to the folders list
					}else{
						if (!checkNumeric || is.na(as.numeric(splitFiles[[i]][j + 1]))){
							folderName <- paste(paste(rep(spaces, j - 1), collapse=''), 
									paste(splitFiles[[i]][j:numFolders], collapse='/'), sep='')
							pathName <- paste(splitFiles[[i]][1:numFolders], collapse='/')
						}else{
							folderName <- paste(paste(rep(spaces, j - 1), collapse=''), 
									paste(splitFiles[[i]][j], collapse='/'), sep='')
							pathName <- paste(splitFiles[[i]][1:j], collapse='/')
						}
					}
					folderList <- c(folderList, folderName)
					pathNames <- c(pathNames, pathName)
					
					## add the data path to the list and increment the data path's index
					dataPaths <- c(dataPaths, pDataPaths[dataIndex])
					dataIndex <- dataIndex + 1
					break
				}else{
					
					## if the current path contains other folders and isn't in the list,
					##     add it to the list
					if (!pathName %in% pathNames){
						folderName <- paste(paste(rep(spaces, j - 1), collapse=''), 
								splitFiles[[i]][j], '/', sep='')
						folderList <- c(folderList, folderName)
						pathNames <- c(pathNames, pathName)
						
						## add a space filler to the datapaths list
						dataPaths <- c(dataPaths, NA)
					}
				}
			}
		}
		returnVal <- list(folderList, pathNames, dataPaths)
		names(returnVal) <- c('folderNames', 'pathNames', 'dataPaths')
		
		return(returnVal)
	}
	
	##creates a list of Bruker files
	onBruker <- function(){
		
		## Reset variables
		tkdelete(tableList, 0, 'end')
		inDir <- tclvalue(inDir)
		filePaths <<- procPaths <<- NULL
		
		## Look for processed data
		pDataPaths <- sort(unique(c(list.files(inDir, recursive=TRUE, 
										full.names=TRUE, pattern="^1r$"), list.files(inDir, 
										recursive=TRUE, full.names=TRUE, pattern="^2rr$"))))
		rmPaths <- NULL
		for (i in seq_along(pDataPaths)){
			if (!length(grep('/pdata/', pDataPaths[i])))
				rmPaths <- c(rmPaths, i)
		}
		if (!is.null(rmPaths))
			pDataPaths <- pDataPaths[-rmPaths]
		if (!length(pDataPaths))
			err('Could not find Bruker format processed data file ("1r" or "2rr")', 
					parent=dlg)
		
		## Look for processing parameter files
		testProc <- list.files(inDir, recursive=TRUE, pattern="^proc")
		if (!length(testProc))
			err('Could not find processing parameter files ("proc" or "procs")', 
					parent=dlg)
		procPaths <- NULL
		for (i in seq_along(pDataPaths)){
			procPath <- dirname(list.files(dirname(pDataPaths[i]), recursive=TRUE,
							pattern="^procs$", full.names=TRUE))
			if (!length(procPath))
				procPath <- dirname(list.files(dirname(pDataPaths[i]), recursive=TRUE, 
								pattern="^proc$", full.names=TRUE))
			if (length(procPath))
				procPaths <- c(procPaths, procPath)
			else
				pDataPaths <- pDataPaths[-i]
		}
		if (!length(procPaths))
			err(paste('Could not find processing parameter files ("proc" or "procs")',
							'in appropriate directories', sep=''),	parent=dlg)
		
		## Look for acquisition parameter files
		testAcqu <- list.files(inDir, recursive=TRUE, pattern="^acqu")
		if (!length(testAcqu))
			err('Could not find acquisition parameter files ("acqu" or "acqus")', 
					parent=dlg)
		acquDirs <- sapply(strsplit(pDataPaths, '/pdata'), function(x) x[1])
		acquPaths <- NULL
		for (i in seq_along(acquDirs)){
			acquPath <- dirname(list.files(acquDirs[i], recursive=TRUE, 
							pattern="^acqus$", full.names=TRUE))
			if (!length(acquPath))
				acquPath <- dirname(list.files(acquDirs[i], recursive=TRUE, 
								pattern="^acqu$", full.names=TRUE))
			if (length(acquPath))
				acquPaths <- c(acquPaths, acquPath)
			else{
				pDataPaths <- pDataPaths[-i]
				procPaths <- procPaths[-i]
			}
		}
		if (!length(acquPaths))
			err(paste('Could not find acquisition parameter files ("acqu" or "acqus")',
							'in appropriate directories', sep=''),	parent=dlg)
		type <<- 'bruker'
		
		## Get file paths for spectra in selected directory
		if (acquPaths[1] == inDir)
			inDir <- dirname(inDir)
		conDirs <- sapply(strsplit(pDataPaths, paste(inDir, '/', sep=''), 
						fixed=TRUE), function(x) x[2])
		conDirs <- dirname(sapply(strsplit(conDirs, '/pdata', fixed=TRUE), 
						function(x) paste(x[1], x[2], sep='', collapse='')))
		filePaths <<- suppressWarnings(dispPaths(conDirs, pDataPaths, TRUE))
	}
	
	##creates a list of NMRPipe files
	onPipe <- function(){
		
		## Reset variables
		tkdelete(tableList, 0, 'end')
		inDir <- tclvalue(inDir)
		filePaths <<- procPaths <<- NULL
		
		## Look for processed data files
		pDataPaths <- sort(unique(c(list.files(inDir, recursive=TRUE, 
										full.names=TRUE, pattern=".dat$"), list.files(inDir, 
										recursive=TRUE, full.names=TRUE, pattern=".ft2$"))))
		if (!length(pDataPaths))
			err('Could not find NMRPipe .dat or .ft2 file', parent=dlg)
		type <<- 'pipe'
		conDirs <- sapply(strsplit(pDataPaths, paste(inDir, '/', sep=''), 
						fixed=TRUE), function(x) x[2])
		filePaths <<- suppressWarnings(dispPaths(conDirs, pDataPaths))
	}
	
	##creates a list of Varian files
	onVarian <- function(){
		
		## Reset variables
		tkdelete(tableList, 0, 'end')
		inDir <- tclvalue(inDir)
		filePaths <<- procPaths <<- NULL
		
		## Look for processed data
		pDataPaths <- sort(unique(list.files(inDir, recursive=TRUE, 
								full.names=TRUE, pattern="^phasefile$")))
		if (!length(pDataPaths))
			err(paste('Could not find Varian processed data file "phasefile"\n', 
							'Please type "?cf" for more information on the requirements for', 
							'converting Varian spectra.'), parent=dlg)
		
		## Look for processing parameters
		testProc <- list.files(inDir, recursive=TRUE, pattern="^procpar$")
		if (!length(testProc))
			err('Could not find processing parameter file "procpar"', parent=dlg)
		conDirs <- NULL
		for (i in seq_along(pDataPaths)){
			if (basename(dirname(pDataPaths[i])) == 'datdir')
				procDir <- dirname(dirname(pDataPaths[i]))
			else
				procDir <- dirname(pDataPaths[i])
			procPath <- list.files(procDir, full.names=TRUE, pattern="^procpar$")
			if (!length(procPath))
				procPath <- list.files(procDir, full.names=TRUE, pattern="^procpar$", 
						recursive=TRUE)[1]
			if (length(procPath)){
				procPaths <- c(procPaths, procPath)
				if (basename(dirname(pDataPaths[i])) == 'datdir'){
					if (dirname(dirname(pDataPaths[i])) == inDir)
						varFolder <- basename(inDir)
					else
						varFolder <- sapply(strsplit(dirname(dirname(pDataPaths[i])), 
										paste(inDir, '/', sep=''), fixed=TRUE), function(x) x[2])
				}else{
					if (dirname(pDataPaths[i]) == inDir)
						varFolder <- basename(inDir)
					else
						varFolder <- sapply(strsplit(dirname(pDataPaths[i]), paste(inDir, 
												'/', sep=''), fixed=TRUE), function(x) x[2])
				}
				conDirs <- c(conDirs, varFolder)
			}else
				pDataPaths <- pDataPaths[-i]
		}
		if (!length(procPaths))
			err(paste('Could not find processing parameter file "procpar" in', 
							'appropriate directories', sep=''),	parent=dlg)
		type <<- 'varian'
		filePaths <<- suppressWarnings(dispPaths(conDirs, pDataPaths))
	}
	
	## creates file type buttons
	buttonFrame <- ttkframe(dlg)
	onFind <- function(type){
		tkconfigure(dlg, cursor='watch')
		
		## Look for spectra of the specified type
		tryCatch({
					if (type == 'bruker'){
						onBruker()
					}else if (type == 'pipe'){
						onPipe()
					}else
						onVarian()}, 
				error=function(er) tkconfigure(dlg, cursor='arrow'))
		if (is.null(filePaths))
			return(invisible())
		
		## Define some local variables
		pathNames <- gsub(' ', '_', filePaths$pathNames)
		spaces <- '      '
		splitFiles <- strsplit(filePaths$folderNames, spaces)
		fileText <- gsub(spaces, '', filePaths$folderNames)
		
		##add items to tableList one at a time
		inDir <- tclvalue(inDir)
		for (i in seq_along(splitFiles)){
			
			##get display text and path for directory\file
			itemName <- paste('i', pathNames[i], sep='')
			if (is.na(filePaths$dataPaths[i])){
				if (basename(inDir) == filePaths$pathNames[i])
					itemPath <- inDir
				else
					itemPath <- file.path(inDir, filePaths$pathNames[i])
			}else{
				itemPath <- filePaths$dataPaths[i]
			}
			
			##get directory\file information
			fileInfo <- file.info(itemPath)
			if (fileInfo$isdir){
				fileName <- paste('D', fileText[i])
				fileInfo$size <- -1
				fileInfo$mtime <- paste('D', as.character(fileInfo$mtime))
			}else{
				fileName <- paste('F', fileText[i])
				fileInfo$mtime <- paste('F', as.character(fileInfo$mtime))
			}
			itemText <- c(fileName, fileInfo$size, fileInfo$mtime)
			
			if (length(splitFiles[[i]]) == 1){
				
				##add root directory\file to tableList
				tcl(tableList, 'insertchild', 'root', 'end', itemText)
				tcl(tableList, 'rowconfigure', i - 1, name=itemName)
			}else{
				
				##add directory\file to tableList
				splitLength <- length(splitFiles[[i]])
				parent <- paste('i', pathNames[max(which(sapply(splitFiles[1:i], 
														function(x)	length(x)) < splitLength))], sep='')
				tcl(tableList, 'insertchild', parent, 'end', itemText)
				tcl(tableList, 'rowconfigure', i - 1, name=itemName)
			}
			
			##add image
			if (itemText[2] == -1)
				tcl(tableList, 'cellconfigure', paste(i - 1, 0, sep=','), 
						image='openFolder')
			else
				tcl(tableList, 'cellconfigure', paste(i - 1, 0, sep=','), 
						image='singleFile')
		}
		tcl(tableList, 'sortbycolumn', 0)
		tkconfigure(nextButton, state='normal')
		tkconfigure(dlg, cursor='arrow')
	}
	brukerButton <- ttkbutton(buttonFrame, text='Bruker', width=12, 
			command=function(...) onFind('bruker'), state='disabled')
	pipeButton <- ttkbutton(buttonFrame, text='NMRPipe', width=12, 
			command=function(...) onFind('pipe'), state='disabled')
	varianButton <- ttkbutton(buttonFrame, text='Varian', width=12, 
			command=function(...) onFind('varian'), state='disabled')
	
	##displays ASCII converter
	onAscii <- function(){
		tkdestroy(dlg)
		ca()
	}
	asciiButton <- ttkbutton(buttonFrame, text='ASCII', width=12, command=onAscii)
	buttonList <- list(brukerButton, pipeButton, varianButton)
	
	##creates a tablelist widget containing files for conversion
	fileFrame <- ttklabelframe(dlg, text='Select files for conversion')
	xscr <- ttkscrollbar(fileFrame, orient='horizontal', command=function(...) 
				tkxview(tableList, ...))
	yscr <- ttkscrollbar(fileFrame, orient='vertical', command=function(...) 
				tkyview(tableList, ...))
	tableList <- tkwidget(fileFrame, 'tablelist::tablelist', columns=c('0', 
					'Name', 'left', '0', 'Size', 'right', '0', 'Date Modified', 'left'),
			height=15, bg='white', selectmode='extended', spacing=2, stretch='all', 
			activestyle='underline', exportselection=FALSE, showarrow=FALSE,
			collapsecommand=function(...) onCollapse(...), 
			expandcommand=function(...) onExpand(...),
			xscrollcommand=function(...) tkset(xscr, ...),
			yscrollcommand=function(...) tkset(yscr, ...))
	
	##create images for files\directories
	createTclImage('openFolder', 'tcltk/tablelist/demos/openFolder.gif')
	createTclImage('clsdFolder', 'tcltk/tablelist/demos/clsdFolder.gif')
	createTclImage('singleFile', 'tcltk/tablelist/demos/file.gif')
	
	##switch images when nodes are collapsed/expanded
	onCollapse <- function(tbl, row){
		tcl(tbl, 'cellconfigure', paste(row, 0, sep=','), image='clsdFolder')
	}
	onExpand <- function(tbl, row){
		tcl(tbl, 'cellconfigure', paste(row, 0, sep=','), image='openFolder')
	}
	
	##format the name column
	formatName <- function(name){
		dispName <- paste(unlist(strsplit(name, ''))[-1], collapse='')
		return(tclVar(dispName))
	}
	tcl(tableList, 'columnconfigure', 0, sortmode='dictionary', 
			formatcommand=function(...) formatName(...))
	
	##format the size column
	formatSize <- function(size){
		size <- as.numeric(size)
		if (size == -1)
			return(tclVar(''))
		if (size < 2^20)
			return(tclVar(paste(signif(size / 2^10, 3), 'KB')))
		else
			return(tclVar(paste(signif(size / 2^20, 3), 'MB')))
	}
	tcl(tableList, 'columnconfigure', 1, sortmode='real', 
			formatcommand=function(...) formatSize(...))
	
	##format the modified column
	formatModified <- function(modified){
		dispModified <- paste(unlist(strsplit(modified, ''))[-1], collapse='')
		return(tclVar(dispModified))
	}
	tcl(tableList, 'columnconfigure', 2, sortmode='dictionary', 
			formatcommand=function(...) formatModified(...))
	
	##selects all rows when Ctrl+A is pressed
	tkbind(dlg, '<Control-a>', function(...) tkselection.set(tableList, 0, 'end'))
	
	##creates next button
	onNext <- function(){
		
		##get selected items
		inDir <- tclvalue(inDir)
		selected <- as.numeric(tcl(tableList, 'curselection'))
		if (!length(selected))
			err('You must select spectra from the files list for conversion', 
					parent=dlg)
		usrSel <- NULL
		for (i in selected){
			selName <- tclvalue(tcl(tableList, 'rowcget', i, '-name'))
			matches <- grep(paste('@', selName, '/', sep=''), paste('@i', gsub(' ', 
									'_', filePaths$pathNames), '/', sep=''), fixed=TRUE)
			if (length(matches))
				usrSel <- c(usrSel, matches)
		}
		usrSel <- unique(usrSel)
		pathNames <- filePaths$pathNames[usrSel]
		pDataPaths <- filePaths$dataPaths[usrSel]
		rmDirs <- which(is.na(pDataPaths))
		if (length(rmDirs)){
			pDataPaths <- pDataPaths[-rmDirs]
			pathNames <- pathNames[-rmDirs]
		}
		
		##open format specific conversion GUIs
		conFiles(type, pathNames, pDataPaths, dlg)
		
		##reset variables
		try(tkdelete(tableList, 0, 'end'), silent=TRUE)
		type <- filePaths <- procPaths <- NULL
	}
	nextButton <- ttkbutton(dlg, width=12, text='Next', state='disabled', 
			command=onNext)
	
	##add widgets to dirFrame
	tkgrid(dirFrame, column=1, row=1, sticky='we', pady=c(5, 3), padx=c(10, 0))
	tkgrid(inEntry, column=1, row=1, sticky='we', padx=3)
	tkgrid(browseButton, column=2, row=1, padx=1)
	tkgrid.columnconfigure(dirFrame, 1, weight=1)
	
	##add file type buttons
	tkgrid(buttonFrame, column=1, row=2, sticky='we', pady=3, padx=c(10, 0))
	tkgrid(ttklabel(buttonFrame, text='File types:'), column=1, 
			row=1, padx=c(14, 8))
	tkgrid(brukerButton, column=2, row=1)
	tkgrid(pipeButton, column=3, row=1, padx=5)
	tkgrid(varianButton, column=4, row=1, padx=c(0, 5))		
	tkgrid(asciiButton, column=5, row=1)
	
	##add widgets to fileFrame
	tkgrid(fileFrame, column=1, row=3, sticky='nswe', pady=c(3, 10), 
			padx=c(10, 0))
	tkgrid(tableList, column=1, row=1, sticky='nswe')
	tkgrid(xscr, column=1, row=2, sticky='we')
	tkgrid(yscr, column=2, row=1, sticky='ns')
	
	##make fileFrame stretch when window is resized
	tkgrid.columnconfigure(dlg, 1, weight=1)
	tkgrid.rowconfigure(dlg, 3, weight=1)
	tkgrid.columnconfigure(fileFrame, 1, weight=1)
	tkgrid.rowconfigure(fileFrame, 1, weight=1)	
	
	tkgrid(nextButton, column=1, row=4)
	tkgrid(ttksizegrip(dlg), column=2, row=5, sticky='se')
	
	##allows users to press the 'Enter' key to make selections
	onEnter <- function(){
		tryCatch(tkinvoke(tkfocus()), error=function(er){})
	}
	tkbind(dlg, '<Return>', onEnter) 
	
	invisible()
}


################################################################################
##                                                                            ##
##     Internal functions that run when the rNMR package is loaded            ##
##                                                                            ##
################################################################################

## Updates rNMR
updater <- function(auto=FALSE){
	
	##display message
	if (auto){
		if (!defaultSettings$update)
			return(invisible())
		cat('\nChecking rNMR for updates . . . ')
	}
	
	##check for installed packages
	pkgs <- as.data.frame(installed.packages(), stringsAsFactors=FALSE)
	rNMRpkgs <- pkgs[grep('rNMR', rownames(pkgs)), ]
	rNMRpaths <- rNMRpkgs[, 'LibPath']
	rNMRvers <- rNMRpkgs[, 'Version']
	
	##check for write permission
	writeDirs <- which(file.access(rNMRpaths, mode=2) == 0)
	if (!length(writeDirs)){
		if (auto){
			cat('cancelled.\n  User does not have write permission.\n')
			return(invisible())
		}else
			err(paste('Could not update rNMR.  You do not have write permission for ', 
							'the rNMR package directory.\nTo update rNMR you must run R as ', 
							'an administrator or change the write permissions for the ', 
							'directory below.\n\n', 'rNMR library location:  ', 
							rNMRpaths[writeDirs[1]], sep=''))
	}
	writeVers <- rNMRvers[writeDirs]
	
	##check for the newest version of rNMR currently installed
	currVers <- writeVers[1]
	if (length(writeDirs) > 1){
		for (i in 2:length(writeVers)){
			cv <- compareVersion(currVers, writeVers[i])
			if (cv < 0)
				currVers <- writeVers[i]
		}
	}
	rNMRpath <- rNMRpaths[match(currVers, rNMRvers)]	
	
	##check if the package is up to date
	newVers <- suppressWarnings(available.packages(contriburl=contrib.url(repos=
									'http://rnmr.nmrfam.wisc.edu/R/', type='source')))
	if (is.null(newVers) || !length(newVers) || !nzchar(newVers)){
		if (auto){
			cat('cancelled.\n  Could not access rNMR repository.\n')
			return(invisible())
		}else
			err(paste('Could not access rNMR repository.\n', 
							'Check your network settings and try again.', sep=''))
	}
	newVers <- newVers['rNMR', 'Version']
	
	##download and install the latest rNMR package if update was selected manually
	if (!auto){
		detach(package:rNMR)
		tryCatch(install.packages('rNMR', lib=rNMRpath, 
						repos='http://rnmr.nmrfam.wisc.edu/R/', type='source'),
				error=function(er)
					stop(paste('Could not update rNMR.\nGo to the rNMR homepage to ',
									'download and manually install the latest version.', 
									sep='')), call.=FALSE)
		
		##check installation
		tryCatch(require(rNMR, quietly=TRUE, warn.conflicts=FALSE), 	
				error=function(er)
					stop(paste('Could not update rNMR.\nGo to the rNMR homepage to ',
									'download and manually install the latest version.', 
									sep='')), call.=FALSE)
		currVers <- suppressWarnings(packageDescription('rNMR', fields='Version', 
						lib.loc=rNMRpath))
		if (currVers == newVers){
			try(Sys.chmod(system.file('linux/rNMR.sh', package='rNMR'), mode = '555'), 
					silent=TRUE)
			myMsg('rNMR update successful.  Restart R to apply the changes.   ', 
					icon='info')
		}
		return(invisible())
	}
	
	##download and install rNMR if the current package is not up-to-date
	if (compareVersion(newVers, currVers) < 1){
		if (auto)
			cat('done.\n')
		return(invisible())
	}
	usrSel <- myMsg(paste('rNMR version ', newVers, ' is now available.\n', 
					'Version ', pkgVar$version, ' is currently installed.\n', 
					'Would you like to update rNMR?', sep=''), type='yesno')
	if (usrSel == 'no'){
		if (auto)
			cat('cancelled.\n')
		return(invisible())
	}
	tryCatch(update.packages(repos='http://rnmr.nmrfam.wisc.edu/R/', ask=FALSE,
					type='source', lib.loc=rNMRpath),
			error=function(er){ 
				require(rNMR, quietly=TRUE, warn.conflicts=FALSE)
				myMsg(paste('Could not update rNMR.\nGo to the ',
								'rNMR homepage to download and manually install the latest ', 
								'version.', sep=''), icon='error')
			})
	
	##check installation
	currVers <- suppressWarnings(packageDescription('rNMR', fields='Version', 
					lib.loc=rNMRpath))
	if (currVers == newVers){
		try(Sys.chmod(system.file('linux/rNMR.sh', package='rNMR'), mode = '555'), 
				silent=TRUE)
		myMsg('rNMR update successful.  Please restart R to apply changes.', 
				icon='info')
		q('no')
	}
	if (auto)
		cat('done.\n')
	
	return(invisible())
}
		
## Check for updates to BMRB standards library
updateLib <- function(auto=FALSE){
	
	##exit if auto updates are turned off
	if (auto && !defaultSettings$libUpdate)
		return(invisible())
	
	##display update message
	cat('\nChecking for updates to standards library . . .')
	flush.console()
	
	##check for write permission
	libDir <- dirname(createObj('defaultSettings', returnObj=TRUE)$libLocs)
	if (file.access(libDir, mode=2)){
		if (auto){
			cat('cancelled.\n  User does not have write permission.\n')
			return(invisible())
		}else
			err(paste('Could not update library.  You do not have write permission ', 
							'for the rNMR package directory.\nTo update the standards ',
							'library you must run R as an administrator or change the write ',
							'permissions for the directory below:', libDir, sep=''))
	}
	
	##read remote library index file
	libUrl <- 'http://rnmr.nmrfam.wisc.edu/pages/data/files/RSD_libraries'
	remoteIndex <- try(read.table(file.path(libUrl, 'index.txt'), head=TRUE, 
					sep='\t', stringsAsFactors=FALSE), silent=TRUE)
	if (is.null(remoteIndex$Name)){
		if (auto){
			cat('cancelled.\n  Could not access rNMR server.\n')
			return(invisible())
		}else
			err(paste('Could not access rNMR server.\n', 
							'Check your network settings and try again.', sep=''))
	}
	remoteRsds <- file.path(remoteIndex$Library, remoteIndex$Name)
	
	##read local library index file
	localIndex <- read.table(file.path(libDir, 'index.txt'), head=TRUE, 
			sep='\t', stringsAsFactors=FALSE)
	localRsds <- file.path(localIndex$Library, localIndex$Name)
	
	##check for new additions
	newFiles <- which(!remoteRsds %in% localRsds)
	if (length(newFiles))
		newFiles <- remoteRsds[newFiles]
	
	##check for updated RSD files
	remoteIndex$Updated <- as.Date(remoteIndex$Updated)
	localIndex$Updated <- as.Date(localIndex$Updated)
	fileUpdates <- NULL
	for (i in seq_along(localRsds)){
		remoteMatch <- match(localRsds[i], remoteRsds)
		if (localIndex$Updated[i] < remoteIndex$Updated[remoteMatch])
			fileUpdates <- c(fileUpdates, remoteRsds[remoteMatch])
	}
	newFiles <- c(fileUpdates, newFiles)
	if (!length(newFiles)){
		cat('\nStandards library is up-to-date.\n')
		return(invisible())
	}
	
	##ask user if they would like to update library
	if (auto){
		updateMsg <- paste('Updates are available for the rNMR standards library.', 
				'Would you like to download the updates now?\n', sep='\n')
		usrSel <- buttonDlg(updateMsg, c('Yes', 'No', 
						'Don\'t display this message again'), TRUE, default='No')
		
		##edit defaultSettings if user doesn't want message to be displayed again
		if (as.logical(usrSel[2])){
			defaultSettings$libUpdate <- FALSE
			writeDef(defSet=defaultSettings)
			myAssign('defaultSettings', defaultSettings, FALSE)
		}
		if (usrSel[1] == 'No'){
			cat('cancelled.\n')
			return(invisible())
		}
	}
		
	##create directories for new libraries
	updatedLibs <- unique(dirname(newFiles))
	for (i in updatedLibs){
		localLibPath <- file.path(libDir, i)
		if (!file.exists(localLibPath))
			dir.create(localLibPath, FALSE, TRUE)
		
		##download library files
		cat('\n')
		download.file(paste(libUrl, i, 'metadata.txt', sep='/'), 
				file.path(localLibPath, 'metadata.txt'))
		download.file(paste(libUrl, i, 'details.txt', sep='/'), 
				file.path(localLibPath, 'details.txt'))
		download.file(paste(libUrl, i, 'roiRecord.roi', sep='/'), 
				file.path(localLibPath, 'roiRecord.roi'))
		download.file(paste(libUrl, i, 'hash.ucsf', sep='/'), 
				file.path(localLibPath, 'hash.ucsf'))
	}
	
	##download RSD files
	for (i in newFiles)
		download.file(file.path(libUrl, i), file.path(libDir, i), mode='wb')
	
	##download index file
	download.file(file.path(libUrl, 'index.txt'), file.path(libDir, 
					'index.txt'))
	cat('Library update complete.\n')
	
	return(invisible())
}

## Checks R version (2.13.1) for presence of bug in image() function
checkImage <- function(){
	
	##get R version
	ver <- R.Version()
	if (ver$major == '2' && ver$minor == '13.1'){
		
		##create main window
		dlg <- tktoplevel()
		tcl('wm', 'attributes', dlg, topmost=TRUE)
		tkwm.resizable(dlg, FALSE, FALSE)
		tkwm.title(dlg, 'rNMR - WARNING')
		tkfocus(dlg)
		tkwm.deiconify(dlg)
		
		##create font for text
		fonts <- tcl('font', 'name')
		if (!'msgFont' %in% as.character(fonts)){
			msgFont <- as.character(tcl('font', 'configure', 'TkDefaultFont'))
			tcl('font', 'create', 'msgFont', msgFont[1], msgFont[2], msgFont[3], 
					'10', msgFont[5], msgFont[6], msgFont[7], msgFont[8], 
					msgFont[9], msgFont[10], msgFont[11], msgFont[12])
		}
		
		##create text box
		textFrame <- ttkframe(dlg)
		textBox <- tktext(textFrame, wrap='word', height=13, width=60,
				font='msgFont', cursor='arrow')
		
		##add text to widget
		msg <- paste('R version 2.13.1 contains a bug in the image() function', 
				'that may prevent certain spectra from being displayed correctly.  ',
				'After a file is opened, the spectrum may be displayed with horizontal',
				'or vertical lines running across it, or the spectrum may not be', 
				'displayed at all.\n\nTo avoid this issue, choose a plot type option', 
				'other than "auto" or "image" (select "Plot settings" from the', 
				'Graphics menu).  This issue is not present in previous versions of',
				'R and we expect that it will be resolved with the next R release. ', 
				'Previous versions of R may be downloaded using the links below.\n\n')
		tkinsert(textBox, '1.0', msg)
		tkinsert(textBox, '10.0', '                 ')
		tkinsert(textBox, '10.end', 'Windows installer', 'winUrl')
		tkinsert(textBox, '10.end', '                 ')
		tkinsert(textBox, '10.end', 'Mac OS X installer', 'macUrl')
		tcl(textBox, 'tag', 'configure', 'winUrl', foreground='blue')
		tcl(textBox, 'tag', 'configure', 'macUrl', foreground='blue')
		tkconfigure(textBox, state='disabled')
		
		##configure windows installer text to display webpage when clicked
		tcl(textBox, 'tag', 'bind', 'winUrl', '<Enter>', function(...){
					tcl(textBox, 'tag', 'configure', 'winUrl', underline=TRUE)
					tkconfigure(textBox, cursor='hand2')
				})
		tcl(textBox, 'tag', 'bind', 'winUrl', '<Leave>', function(...){
					tcl(textBox, 'tag', 'configure', 'winUrl', underline=FALSE)
					tkconfigure(textBox, cursor='arrow')
				})
		winPage <- 'http://cran.opensourceresources.org/bin/windows/base/old/2.13.0'
		tcl(textBox, 'tag', 'bind', 'winUrl', '<Button-1>', function(...)
					browseURL(winPage))
		
		##configure mac installer text to display webpage when clicked
		tcl(textBox, 'tag', 'bind', 'macUrl', '<Enter>', function(...){
					tcl(textBox, 'tag', 'configure', 'macUrl', underline=TRUE)
					tkconfigure(textBox, cursor='hand2')
				})
		tcl(textBox, 'tag', 'bind', 'macUrl', '<Leave>', function(...){
					tcl(textBox, 'tag', 'configure', 'macUrl', underline=FALSE)
					tkconfigure(textBox, cursor='arrow')
				})
		macPage <- 'http://cran.opensourceresources.org/bin/macosx/old/R-2.13.0.pkg'
		tcl(textBox, 'tag', 'bind', 'macUrl', '<Button-1>', function(...)
					browseURL(macPage))
		
		##create ok button
		okButton <- ttkbutton(dlg, text='OK', width=12, default='active', 
				command=function(...) tkdestroy(dlg))
		
		##add widgets to toplevel window
		tkgrid(textFrame, row=1, sticky='nswe', pady=8, padx=8)
		tkgrid(textBox)
		tkgrid(okButton, row=2, pady=c(4, 10))
	}
	
	return(invisible())
}

## Executes a set of tasks whenever the rNMR package loads
.onLoad <- function(lib, pkg){
	
	## Create or update necessary rNMR objects
	rNMR:::patch()
	
	## Exit if rNMR has not been installed
	if (length(grep('apple', Sys.getenv('R_PLATFORM')))){
		installDir <- tryCatch(installed.packages(lib.loc='~')['rNMR','LibPath'], 
				error=function(er) return(NULL))
		if (is.null(installDir))
			installDir <- tryCatch(installed.packages()['rNMR','LibPath'], 
					error=function(er) return(NULL))
		if (is.null(installDir))
			return(invisible())
		defPath <- paste(installDir, '/rNMR/defaultSettings', sep='')
		if (file.access(defPath) == -1){
			rNMR:::writeDef(defPath)
			return(invisible())
		}
	}
	
	## Autoload functions in rNMR namespace
	rNMRfun <- c('aa', 'appendPeak', 'bringFocus', 'buttonDlg', 'ca', 'cl', 'cf', 
			'closeGui', 'co', 'ct', 'ctd', 'ctu', 'cw', 'da', 'dd', 'di', 'dp', 'dr', 
			'draw2D', 'drawNMR', 'drf', 'ed', 'ep', 'err', 'export', 'fc', 'ff', 'fo', 
			'fs', 'getTitles', 'gui', 'hideGui', 'import', 'isNoise', 'loc', 
			'localMax', 'matchShift', 'maxShift', 'mmcd', 'myAssign', 'myDialog', 
			'myDir', 'myFile', 'myMsg', 'myOpen', 'mySave', 'mySelect', 'myToplevel', 
			'nf', 'ol', 'pa', 'paAll', 'pd', 'pDel', 'pDelAll', 'pe', 'peakPick',	
			'peakPick1D', 'peakPick2D', 'peakVolume', 'per', 'ph', 'pj', 'pjv', 'pl', 
			'plot1D', 'plot2D', 'pm', 'pp', 'pr', 'pReg', 'pu', 'pv', 'pw', 'pwAll', 
			'pz', 'ra', 'rb', 'rc', 'rcd', 'rci', 'rd', 'rdAll', 'rDel', 're', 
			'red', 'refresh', 'regionMax', 'rei', 'reset', 'rmd', 'rml', 'rmr', 'rmu', 
			'rn', 'roi', 'rotc', 'rotcc', 'rotd', 'rotu', 'rp', 'rpAll', 'rr', 'rs', 
			'rsAll', 'rsf', 'rSum', 'rv', 'rvm', 'rvs', 'se', 'setGraphics', 
			'setWindow', 'shiftToROI', 'showGui', 'spin', 'sr', 'ss', 'tableEdit', 
			'tclCheck', 'ucsf1D', 'ucsf2D', 'ud', 'vp', 'vpd', 'vpu', 'vs', 'wc', 
			'wl', 'writeUcsf', 'ws', 'zc', 'zf', 'zi', 'zm', 'zo', 'zp', 'zz')
	for (i in rNMRfun)
		suppressPackageStartupMessages(autoload(i, 'rNMR', warn.conflicts=FALSE))
	
	## Set X11 options and display rNMR splash screen
	if (.Platform$OS == 'windows')
		dev.new(title='Main Plot Window', width=defaultSettings$size.main[1], 
				height=defaultSettings$size.main[2])
	else{
		X11.options(type='Xlib')
		X11(title='Main Plot Window', width=defaultSettings$size.main[1],	
				height=defaultSettings$size.main[2])
	}
	tryCatch(rNMR:::splashScreen(), error=function(er){
				if (.Platform$OS != 'windows'){
					invisible(myMsg(paste('Your computer does not have the required ', 
											'fonts to support fast X11 graphics in R.\n',
											'To correct this issue you may need to download some or', 
											' all of the following X11 fonts:     \n\n', 
											'                              xorg-x11-fonts-75dpi\n',
											'                              xorg-x11-fonts-100dpi\n', 
											'                              xorg-x11-fonts-truetype\n',
											'                              xorg-x11-fonts-Type1\n\n', 
											'Please refer to the R Installation and Administration',
											' Manual for more information:\n', 
											'http://cran.r-project.org/doc/manuals/R-admin.html#X11-',
											'issues', 
											sep=''), 'ok', 'info'))
					dev.off()
					X11.options(type='cairo')
					X11(title='Main Plot Window', width=defaultSettings$size.main[1], 
							height=defaultSettings$size.main[2])
					rNMR:::splashScreen()
				}
			})
	
	## Use a functional version of ::tk::dialog::file:: on older Linux systems
	tclVer <- as.character(tcl('info', 'patchlevel'))
	tclVer <- unlist(strsplit(tclVer, '.', fixed=TRUE))
	if (tclVer[1] < 8 || (tclVer[1] == 8 && tclVer[2] < 5) ||
			(tclVer[1] == 8 && tclVer[2] == 5 && tclVer[3] < 5)){
		filePath <- system.file('tcltk/tkfbox.tcl', package='rNMR')
		tcl('source', filePath)
	}
	
	## Add the tablelist package to the Tcl search path and load the package
	invisible(addTclPath(system.file('tcltk/tablelist', package='rNMR')))
	invisible(tclRequire('tablelist_tile'))
	if (.Platform$OS == 'windows')
		tcl('option', 'add', '*Tablelist*selectBackground', 'SystemHighlight')
	tcl('option', 'add', '*Tablelist*stripeBackground', '#ececff')
	
	## Correct problems with the "xpnative" theme for the treeview widget
	if (.Platform$OS == 'windows'){
		tcl('ttk::style', 'configure', 'Treeview', '-background', 'SystemWindow')
		tcl('ttk::style', 'configure', 'Row', '-background', 'SystemWindow')
		tcl('ttk::style', 'configure', 'Cell', '-background', 'SystemWindow')
		tcl('ttk::style', 'map', 'Row', 
				'-background', c('selected', 'SystemHighlight'), 
				'-foreground', c('selected', 'SystemHighlightText'))
		tcl('ttk::style', 'map', 'Cell', 
				'-background', c('selected', 'SystemHighlight'), 
				'-foreground', c('selected', 'SystemHighlightText'))
		tcl('ttk::style', 'map', 'Item', 
				'-background', c('selected', 'SystemHighlight'), 
				'-foreground', c('selected', 'SystemHighlightText'))
	}
	
	## Load rNMR and bring up the plot window when saved workspaces load
	.First <- function(){
		.First.sys()
		require(rNMR, quietly=TRUE, warn.conflicts=FALSE)
		setwd(path.expand('~'))
		autoload('dd', 'rNMR')
		if (exists('fileFolder') && !is.null(fileFolder))
			dd()
		rNMR:::createObj()
		rNMR:::createTclImage('rNMRIcon', 'rNMR.gif')
		tt <- tktoplevel()
		tcl('wm', 'iconphoto', tt, '-default', 'rNMRIcon')
		tkdestroy(tt)
		gui()
	}
	assign(".First", .First, inherits=FALSE, envir=.GlobalEnv)
	
	## Assign the rNMR icon to GUIs
	createTclImage('rNMRIcon', 'rNMR.gif')
	tt <- tktoplevel()
	tcl('wm', 'iconphoto', tt, '-default', 'rNMRIcon')
	
	## Make sure Ttk widgets display the same color background as toplevels
	defBgColor <- as.character(tkcget(tt, '-background'))
	tkdestroy(tt)
	tcl('ttk::style', 'configure', 'TRadiobutton', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TRadiobutton', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TCheckbutton', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TCheckbutton', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TSizegrip', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TSizegrip', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TLabel', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TLabel', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TNotebook', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TNotebook', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'Treeview', '-background', 'white')
	tcl('ttk::style', 'map', 'Treeview', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TFrame', '-background', defBgColor)
	tcl('ttk::style', 'configure', 'TLabelframe', '-background', defBgColor)
	gui()
	
	## Turn on HTML help
	options(htmlhelp=TRUE, help_type='html', chmhelp=FALSE)
	
	## Print message on package load
	cat("\n", "rNMR version", pkgVar$version, "\n", 
			"Copyright (C) 2009 Ian A. Lewis and Seth C. Schommer\n",
			"rNMR is free software and comes with ABSOLUTELY NO WARRANTY.\n",
			"rNMR may be modified and redistributed under certain conditions.\n",
			"Go to http://www.r-project.org/Licenses/GPL-3 for more details.\n\n", 
			"Citation:\n",
			"Lewis, I. A., Schommer, S. C., Markley, J. L.\n",
			"Magn. Reson. Chem. 47, S123-S126 (2009).\n\n")
	
	## Check if the Rgui is running in SDI (multiple windows) mode
	if (.Platform$GUI == 'Rgui')
		sdiCheck()
	
	## Add rNMR to list of repositories and update package if applicable
	if (is.na(match('rNMR', names(getOption('repos')))))
		options(repos=c(getOption('repos'), rNMR='http://rnmr.nmrfam.wisc.edu/R'))
	errMsg <- tryCatch(rNMR:::updater(TRUE), error=function(er) 
				return(er$message))
	if (!is.null(errMsg))
		cat('Non-fatal error occurred while checking for updates:\n  "', errMsg, 
				'"\n\n', sep='')
	
	## Check for standards library updates
	errMsg <- tryCatch(rNMR:::updateLib(TRUE), error=function(er) 
				return(er$message))
	if (!is.null(errMsg))
		cat('Non-fatal error occurred while checking for standards library ',
				'updates:\n  "', errMsg, '"\n\n', sep='')
	
	## Check for image() bug
	checkImage()
}

## Perform necessary actions from .onLoad when running rNMR from source code
if (!'package:rNMR' %in% search() && !exists('fileFolder')){
	
	##assign rNMR objects
	tclCheck()
	patch(FALSE)
	
	## Set X11 options and display open file message
	if (.Platform$OS == 'windows'){
		dev.new(title='Main Plot Window', width=defaultSettings$size.main[1], 
				height=defaultSettings$size.main[2])
	}else{
		X11.options(type='Xlib')
		X11(title='Main Plot Window', width=defaultSettings$size.main[1],	
				height=defaultSettings$size.main[2])
	}
	tryCatch(splashScreen(), error=function(er){
				if (.Platform$OS != 'windows'){
					invisible(myMsg(paste('Your computer does not have the required ', 
											'fonts to support fast X11 graphics in R.\n',
											'To correct this issue you may need to download some or', 
											' all of the following X11 fonts:     \n\n', 
											'                              xorg-x11-fonts-75dpi\n',
											'                              xorg-x11-fonts-100dpi\n', 
											'                              xorg-x11-fonts-truetype\n',
											'                              xorg-x11-fonts-Type1\n\n', 
											'Please refer to the R Installation and Administration',
											' Manual for more information:\n', 
											'http://cran.r-project.org/doc/manuals/R-admin.html#X11-',
											'issues', 
											sep=''), 'ok', 'info'))
					dev.off()
					X11.options(type='cairo')
					X11(title='Main Plot Window', width=defaultSettings$size.main[1], 
							height=defaultSettings$size.main[2])
					splashScreen()
				}
			})
	
	## Use a functional version of ::tk::dialog::file:: on older Linux systems
	tclVer <- as.character(tcl('info', 'patchlevel'))
	tclVer <- unlist(strsplit(tclVer, '.', fixed=TRUE))
	if (tclVer[1] < 8 || (tclVer[1] == 8 && tclVer[2] < 5) ||
			(tclVer[1] == 8 && tclVer[2] == 5 && tclVer[3] < 5)){
		filePath <- system.file('tcltk/tkfbox.tcl', package='rNMR')
		tcl('source', filePath)
	}
	
	## Add the tablelist package to the Tcl search path and load the package
	invisible(addTclPath(system.file('tcltk/tablelist', package='rNMR')))
	invisible(tclRequire('tablelist_tile'))
	if (.Platform$OS == 'windows')
		tcl('option', 'add', '*Tablelist*selectBackground', 'SystemHighlight')
	tcl('option', 'add', '*Tablelist*stripeBackground', '#ececff')
	
	## Correct problems with the "xpnative" theme for the treeview widget
	if (.Platform$OS == 'windows'){
		tcl('ttk::style', 'configure', 'Treeview', '-background', 'white')
		tcl('ttk::style', 'configure', 'Row', '-background', 'white')
		tcl('ttk::style', 'configure', 'Cell', '-background', 'white')
		tcl('ttk::style', 'map', 'Row', 
				'-background', c('selected', 'SystemHighlight'), 
				'-foreground', c('selected', 'SystemHighlightText'))
		tcl('ttk::style', 'map', 'Cell', 
				'-background', c('selected', 'SystemHighlight'), 
				'-foreground', c('selected', 'SystemHighlightText'))
		tcl('ttk::style', 'map', 'Item', 
				'-background', c('selected', 'SystemHighlight'), 
				'-foreground', c('selected', 'SystemHighlightText'))
	}
	
	## Assign the rNMR icon to GUIs
	createTclImage('rNMRIcon', 'rNMR.gif')
	tt <- tktoplevel()
	tcl('wm', 'iconphoto', tt, '-default', 'rNMRIcon')
	
	## Make sure Ttk widgets display the same color background as toplevels
	defBgColor <- as.character(tkcget(tt, '-background'))
	tkdestroy(tt)
	tcl('ttk::style', 'configure', 'TRadiobutton', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TRadiobutton', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TCheckbutton', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TCheckbutton', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TSizegrip', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TSizegrip', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TLabel', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TLabel', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TNotebook', '-background', defBgColor)
	tcl('ttk::style', 'map', 'TNotebook', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'Treeview', '-background', 'white')
	tcl('ttk::style', 'map', 'Treeview', '-background', c('disabled', 
					defBgColor))
	tcl('ttk::style', 'configure', 'TFrame', '-background', defBgColor)
	tcl('ttk::style', 'configure', 'TLabelframe', '-background', defBgColor)
	gui()
	
	## Turn on HTML help
	options(htmlhelp=TRUE, help_type='html', chmhelp=FALSE)
	
	## Print message on package load
	cat("\n", "rNMR version", pkgVar$version, "\n", 
			"Copyright (C) 2009 Ian A. Lewis and Seth C. Schommer\n",
			"rNMR is free software and comes with ABSOLUTELY NO WARRANTY.\n",
			"rNMR may be modified and redistributed under certain conditions.\n",
			"Go to http://www.r-project.org/Licenses/GPL-3 for more details.\n\n", 
			"Citation:\n",
			"Lewis, I. A., Schommer, S. C., Markley, J. L.\n",
			"Magn. Reson. Chem. 47, S123-S126 (2009).\n\n")
}
