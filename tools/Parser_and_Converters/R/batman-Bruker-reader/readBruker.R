readBruker<-function(BrukerDataDir)
{
  ## written by Dr. Jie Hao, Imperial College London
  warnDef<-options("warn")$warn
  warnRead<-options(warn = -1)
  datapath<-BrukerDataDir
  
  ## read in bruker spectra
  ## find the data files
  ppm <- NULL
  pfile <-list.files(path = datapath, pattern = "^procs$", all.files = FALSE,full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
  rfile <-list.files(path = datapath, pattern = "^1r$", all.files = FALSE,full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
  L<-length(pfile)
  Lr<-length(rfile)
  sa <- NULL
  snam <- NULL
  if (L==0 || Lr==0 || L!=Lr)
  {
    return (cat("Bruker file does not exist in datapath, or other problems with bruker files...\n"))
  } else {
    for (i in 1:L)
    {    
      con  <- file(pfile[i], open = "r")
      aLine <- readLines(con, n = -1, warn = FALSE)
      myV <- strsplit(aLine, "=")    
      close(con)
      
      for (j in 1:length(myV))
      {
        if (match("##$OFFSET",myV[[j]][1],nomatch = 0))
        {    offset <- as.numeric(myV[[j]][2]);
        }
        if (match("##$SW_p",myV[[j]][1],nomatch = 0))
        {    sw <- as.numeric(myV[[j]][2]);
        }
        if (match("##$SF",myV[[j]][1],nomatch = 0))
        {
          sf <- as.numeric(myV[[j]][2]);
        }
        if (match("##$SI",myV[[j]][1],nomatch = 0))
        {  
          si <- as.numeric(myV[[j]][2]);
        }
        if (match("##$BYTORDP",myV[[j]][1],nomatch = 0))
        {    bytordp <- as.numeric(myV[[j]][2]);
        }
        if (match("##$NC_proc",myV[[j]][1],nomatch = 0))
        {
          ncproc <- as.numeric(myV[[j]][2]);
        }
      }
      
      if (bytordp==0){machine_format =  "little"}
      else {machine_format = "big"}
      
      s<-readBin(rfile[i], what="int",70000, size = 4, signed = T, endian =machine_format)
      s<- ((2^ncproc)* s)
      nspec <- length(s)
      
      tmpppm <- ppm
      
      swp <- sw/sf
      dppm <- swp/(nspec-1)
      ppm<-offset
      ppm<-seq(offset,(offset-swp),by=-dppm)
      
      ## interpolation
      if (!is.null(tmpppm))
      {
        if (length(tmpppm) != length(ppm))
        {
          sinter <- approx(ppm, s, xout = tmpppm)
          s <- sinter$y
          s[is.na(s)]<-0
          ppm <- tmpppm
        }
      }
      
      sa<- cbind(sa,s)
      ## find corresponding title
      stitle<-paste(substr(rfile[i],1,nchar(rfile[i])-2),"title",sep="")
      if (!file.exists(stitle))
        stitle<-paste(substr(rfile[i],1,nchar(rfile[i])-2),"TITLE",sep="")
      if (file.exists(stitle))
      {
        if (!file.info(stitle)$size == 0)
        {
          con<-file(stitle,open="r")
          ntem <- readLines(con, n = 1, warn = FALSE)
          close(con)
        } else {
          sT <- strsplit(rfile[i], "/")
          sTitle <-sT[[1]]         
          lsT<-length(sTitle)
          if (lsT>4)
            ntem<-paste(sTitle[lsT-4],"_",sTitle[lsT-3],"_",sTitle[lsT-1],sep="")
          else if (lsT>3)
            ntem<-paste(sTitle[lsT-3],"_",sTitle[lsT-1],sep="")
          else if (lsT>=1)
            ntem<-paste(sTitle[lsT-1],sep="")
          else
            ntem<-i
        }
      } else {
        sT <- strsplit(rfile[i], "/")
        sTitle <-sT[[1]]         
        lsT<-length(sTitle)
        if (lsT>4)
          ntem<-paste(sTitle[lsT-4],"_",sTitle[lsT-3],"_",sTitle[lsT-1],sep="")
        else if (lsT>3)
          ntem<-paste(sTitle[lsT-3],"_",sTitle[lsT-1],sep="")
        else if (lsT>=1)
          ntem<-paste(sTitle[lsT-1],sep="")
        else
          ntem<-i
      }
      snam<- cbind(snam, ntem)            
    }
  }
  snam <- cbind("ppm", snam)
  sa <- cbind(ppm,sa)
  colnames(sa)<- snam
  warnRead<-options(warn = warnDef)
  return (sa)
}
