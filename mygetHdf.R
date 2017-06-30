mygetHdf=function (product, begin = NULL, end = NULL, tileH = NULL, tileV = NULL, 
          extent = NULL, collection = NULL, HdfName, quiet = FALSE, 
          wait = 0.5, checkIntegrity = FALSE, ...) 
{
  opts <- combineOptions(...)
  sturheit <- stubborn(level = opts$stubbornness)
  wait <- as.numeric(wait)
  if (!missing(HdfName)) {
    HdfName <- unlist(HdfName)
    dates <- list()
    for (i in seq_along(HdfName)) {
      HdfName[i] <- basename(HdfName[i])
      path <- genString(HdfName[i], ...)
      path$localPath <- setPath(path$localPath)
      if (!file.exists(paste0(path$localPath, "/", HdfName[i]))) {
        ModisFileDownloader(HdfName[i], quiet = quiet, 
                            ...)
      }
      if (checkIntegrity) {
        doCheckIntegrity(HdfName[i], quiet = quiet, 
                         ...)
      }
      dates[[i]] <- paste0(path$local, "/", HdfName[i])
    }
    return(invisible(unlist(dates)))
  }
  else {
    if (missing(product)) {
      stop("Please provide the supported-'product'. See in: 'getProduct()'")
    }
    product <- getProduct(x = product, quiet = TRUE)
    if (is.null(collection)) {
      product$CCC <- getCollection(product = product, 
                                   collection = collection, quiet = TRUE)[[1]]
    }
    else {
      product$CCC <- sprintf("%03d", as.numeric(unlist(collection)[1]))
    }
    if (product$SENSOR[1] == "MODIS") {
      if (is.null(begin)) {
        cat("No begin(-date) set, getting data from the beginning\n")
      }
      if (is.null(end)) {
        cat("No end(-date) set, getting data up to the most actual\n")
      }
      tLimits <- transDate(begin = begin, end = end)
    }
    else if (product$SENSOR == "C-Band-RADAR") {
      if (!is.null(tileH) & !is.null(tileV)) {
        tileID <- getTile(tileH = tileH, tileV = tileV, 
                          system = "SRTM")$tile
      }
      else {
        tileID <- getTile(extent = extent, system = "SRTM")$tile
      }
      ntiles <- length(tileID)
      ntiles <- length(tileID)
      path <- genString("SRTM")
      files <- paste0("srtm", tileID, ".zip")
      dir.create(path$localPath, showWarnings = FALSE, 
                 recursive = TRUE)
      if (!file.exists(paste(path$localPath, "meta.zip", 
                             sep = "/"))) {
        cat("Getting SRTM metadata from: ftp://xftp.jrc.it\nThis is done once (the metadata is not used at the moment!)\n")
        download.file("ftp://xftp.jrc.it/pub/srtmV4/SRTM_META/meta.zip", 
                      paste(path$localPath, "meta.zip", sep = "/"), 
                      mode = "wb", method = opts$dlmethod, quiet = quiet, 
                      cacheOK = TRUE)
      }
      if (!file.exists(paste(path$localPath, ".SRTM_sizes", 
                             sep = "/"))) {
        if (!require(RCurl)) {
          stop("You need to install the 'RCurl' package: install.packages('RCurl')")
        }
        sizes <- getURL(paste0(path$remotePath[[1]], 
                               "/"))
        sizes <- strsplit(sizes, if (.Platform$OS.type == 
                                     "unix") {
          "\n"
        }
        else {
          "\r\n"
        })[[1]]
        sizes <- sapply(sizes, function(x) {
          x <- strsplit(x, " ")[[1]]
          paste(x[length(x)], x[length(x) - 5], sep = " ")
        })
        names(sizes) <- NULL
        write.table(sizes, paste(path$localPath, ".SRTM_sizes", 
                                 sep = "/"), quote = FALSE, row.names = FALSE, 
                    col.names = FALSE)
      }
      sizes <- read.table(paste(path$localPath, ".SRTM_sizes", 
                                sep = "/"))
      files <- files[files %in% sizes[, 1]]
      startIND <- 1:length(path$remotePath)
      startIND <- rep(startIND, length(files))
      cat("Be avare, that sources for SRTM data have limited the number of requests!\nNormally it suspends the download, and after a while it continues. So may you have to be patient!\n")
      for (d in seq_along(files)) {
        isOK <- TRUE
        if (file.exists(paste0(path$localPath, "/", 
                               files[d]))) {
          isOK <- checksizefun(file = paste0(path$localPath, 
                                             "/", files[d]), sizeInfo = sizes, flexB = 50000)$isOK
        }
        if (!file.exists(paste0(path$localPath, "/", 
                                files[d])) | !isOK) {
          timeout <- options("timeout")
          options(timeout = 15)
          for (g in 1:sturheit) {
            server <- names(path$remotePath)[rep(startIND[d:(d + 
                                                               length(path$remotePath) - 1)], length = sturheit)]
            cat("Getting SRTM data from:", server[g], 
                "\n")
            Sys.sleep(wait)
            hdf = 1
            try(hdf <- download.file(paste0(path$remotePath[[server[g]]], 
                                            "/", files[d]), destfile = paste0(path$localPath, 
                                                                              "/", files[d]), mode = "wb", method = opts$dlmethod, 
                                     quiet = quiet, cacheOK = TRUE), silent = TRUE)
            if (hdf == 0) {
              SizeCheck <- checksizefun(file = paste0(path$localPath, 
                                                      "/", files[d]), sizeInfo = sizes, flexB = 50000)
              if (!SizeCheck$isOK) {
                hdf = 1
              }
            }
            if (hdf == 0 & !quiet) {
              lastused <- server[g]
              if (g == 1) {
                cat("Downloaded by the first try!\n\n")
              }
              else {
                cat("Downloaded after", g, "retries!\n\n")
              }
            }
            if (hdf == 0) {
              break
            }
          }
          options(timeout = as.numeric(timeout))
        }
      }
      SRTM <- paste0(path$localPath, "/", files)
      return(invisible(SRTM))
    }
    dates <- list()
    output <- list()
    l = 0
    for (z in seq_along(product$PRODUCT)) {
      if (product$TYPE[z] == "Swath") {
        cat("'Swath'-products not yet supported, jumping to the next.\n")
      }
      else {
        todo <- paste0(product$PRODUCT[z], ".", product$CCC)
        for (u in seq_along(todo)) {
          if (product$TYPE[z] == "CMG") {
            tileID = "GLOBAL"
            ntiles = 1
          }
          else {
            if (!is.null(tileH) & !is.null(tileV)) {
              extent <- getTile(tileH = tileH, tileV = tileV)
            }
            else {
              extent <- getTile(extent = extent)
            }
            tileID <- extent$tile
            ntiles <- length(tileID)
          }
          onlineInfo <- getStruc(product = product$PRODUCT[z], 
                                 collection = product$CCC, server = opts$MODISserverOrder[1], 
                                 begin = tLimits$begin, end = tLimits$end, 
                                 wait = 0)
          if (!is.na(onlineInfo$online)) {
            if (!onlineInfo$online & length(opts$MODISserverOrder) == 
                2) {
              cat(opts$MODISserverOrder[1], " seams not online, trying on '", 
                  opts$MODISserverOrder[2], "':\n", sep = "")
              onlineInfo <- getStruc(product = product$PRODUCT[z], 
                                     collection = product$CCC, begin = tLimits$begin, 
                                     end = tLimits$end, wait = 0, server = opts$MODISserverOrder[2])
            }
            if (is.null(onlineInfo$dates)) {
              stop("Could not connect to server(s), and no data is available offline!\n")
            }
            if (!is.na(onlineInfo$online)) {
              if (!onlineInfo$online) {
                cat("Could not connect to server(s), data download disabled!\n")
              }
            }
          }
          datedirs <- as.Date(onlineInfo$dates)
          datedirs <- datedirs[!is.na(datedirs)]
          sel <- datedirs
          us <- sel >= tLimits$begin & sel <= tLimits$end
          if (sum(us, na.rm = TRUE) > 0) {
            suboutput <- list()
            l = l + 1
            dates[[l]] <- datedirs[us]
            dates[[l]] <- cbind(as.character(dates[[l]]), 
                                matrix(rep(NA, length(dates[[l]]) * ntiles), 
                                       ncol = ntiles, nrow = length(dates[[l]])))
            colnames(dates[[l]]) <- c("date", tileID)
            for (i in 1:nrow(dates[[l]])) {
              year <- format(as.Date(dates[[l]][i, 1]), 
                             "%Y")
              doy <- as.integer(format(as.Date(dates[[l]][i, 
                                                          1]), "%j"))
              doy <- sprintf("%03d", doy)
              mtr <- rep(1, ntiles)
              path <- genString(x = strsplit(todo[u], 
                                             "\\.")[[1]][1], collection = strsplit(todo[u], 
                                                                                   "\\.")[[1]][2], date = dates[[l]][i, 
                                                                                                                     1])
              for (j in 1:ntiles) {
                dates[[l]][i, j + 1] <- paste0(strsplit(todo[u], 
                                                        "\\.")[[1]][1], ".", paste0("A", year, 
                                                                                    doy), ".", if (tileID[j] != "GLOBAL") {
                                                                                      paste0(tileID[j], ".")
                                                                                    }, strsplit(todo[u], "\\.")[[1]][2], 
                                               ".*.hdf$")
                if (length(dir(path$localPath, pattern = dates[[l]][i, 
                                                                    j + 1])) > 0) {
                  HDF <- dir(path$localPath, pattern = dates[[l]][i, 
                                                                  j + 1])
                  if (length(HDF) > 1) {
                    select <- list()
                    for (d in 1:length(HDF)) {
                      select[[d]] <- strsplit(HDF[d], 
                                              "\\.")[[1]][5]
                    }
                    HDF <- HDF[which.max(unlist(select))]
                  }
                  dates[[l]][i, j + 1] <- HDF
                  mtr[j] <- 0
                }
              }
              if (sum(mtr) != 0 & (onlineInfo$online | 
                                   is.na(onlineInfo$online))) {
                if (exists("ftpfiles")) {
                  rm(ftpfiles)
                }
                if (!require(RCurl)) {
                  stop("You need to install the 'RCurl' package: install.packages('RCurl')")
                }
                for (g in 1:sturheit) {
                  ftpfiles <- try(filesUrl(path$remotePath[[which(names(path$remotePath) == 
                                                                    onlineInfo$source)]]), silent = TRUE)
                  if (ftpfiles[1] == FALSE) {
                    rm(ftpfiles)
                  }
                  if (exists("ftpfiles")) {
                    break
                  }
                  Sys.sleep(wait)
                }
                if (!exists("ftpfiles")) {
                  stop("Problems with online connections try a little later")
                }
                if (ftpfiles[1] != "total 0") {
                  ftpfiles <- unlist(lapply(strsplit(ftpfiles, 
                                                     " "), function(x) {
                                                       x[length(x)]
                                                     }))
                  for (j in 1:ntiles) {
                    if (mtr[j] == 1) {
                      onFtp <- grep(ftpfiles, pattern = dates[[l]][i, 
                                                                   j + 1], value = TRUE)
                      HDF <- grep(onFtp, pattern = ".hdf$", 
                                  value = TRUE)
                      if (length(HDF) > 0) {
                        if (length(HDF) > 1) {
                          select <- list()
                          for (d in seq_along(HDF)) {
                            select[[d]] <- strsplit(HDF[d], 
                                                    "\\.")[[1]][5]
                          }
                          HDF <- HDF[which.max(unlist(select))]
                        }
                        dates[[l]][i, j + 1] <- HDF
                        hdf <- ModisFileDownloader(HDF, 
                                                   wait = wait, quiet = quiet)
                        mtr[j] <- hdf
                      }
                      else {
                        dates[[l]][i, j + 1] <- NA
                      }
                    }
                  }
                }
                else {
                  dates[[l]][i, (j + 1):ncol(dates[[l]])] <- NA
                }
              }
              if (checkIntegrity) {
                isIn <- doCheckIntegrity(paste0(path$localPath, 
                                                dates[[l]][i, -1]), wait = wait, quiet = quiet, 
                                         ...)
              }
              suboutput[[i]] <- paste0(path$localPath, 
                                       dates[[l]][i, -1])
            }
            output[[l]] <- as.character(unlist(suboutput))
            names(output)[l] <- todo[u]
          }
          else {
            cat(paste0("No files on ftp in date range for: ", 
                       todo[u], "\n\n"))
          }
        }
      }
    }
    return(invisible(output))
  }
}

# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3

# product="MOD13Q1"; collection=NULL; server="LPDAAC"; begin=NULL; end=NULL; forceCheck=FALSE; wait=0; stubbornness=1

getStruc <- function(product, collection=NULL, server=getOption("MODIS_MODISserverOrder")[1], begin=NULL, end=NULL, forceCheck=FALSE, wait=1, stubbornness=10)
{
  server <- toupper(server)[1]
  if(!server %in% c("LPDAAC","LAADS"))
  {
    stop("getStruc() Error! Server must be or 'LPDAAC' or 'LAADS'")
  }
  opts     <- combineOptions()
  sturheit <- stubborn(level=stubbornness)
  
  setPath(opts$auxPath, ask=FALSE)
  #########################
  # Check Platform and product
  product <- getProduct(x=product,quiet=TRUE)
  # Check collection
  if (!is.null(collection))
  {
    product$CCC <- getCollection(product=product,collection=collection) 
  }
  if (length(product$CCC)==0)
  {
    product$CCC <- getCollection(product=product) # if collection isn't provided, this gets the newest for the selected products.
  }
  
  dates <- transDate(begin=begin,end=end)
  todoy <- format(as.Date(format(Sys.time(),"%Y-%m-%d")),"%Y%j")
  ########################
  
  # load aux
  col    <- product$CCC[[1]]
  basnam <- paste0(product$PRODUCT[1],".",product$CCC[[1]],".",server)
  info   <- list.files(path=opts$auxPath,pattern=paste0(basnam,".*.txt"),full.names=TRUE)[1]
  
  output <- list(dates=NULL,source=server,online=NA)
  class(output) <- "MODISonlineFolderInfo" 
  
  if (is.na(info))
  {
    getIT <- TRUE
  } else
  {
    lastcheck    <- as.Date(strsplit(basename(info),"\\.")[[1]][4],"%Y%j")
    output$dates <- na.omit(as.Date(read.table(info,stringsAsFactors=FALSE)[,1]))
    if (max(output$dates,na.rm=TRUE) > dates$end)
    { 
      getIT <- FALSE
    } else if (lastcheck < as.Date(todoy,"%Y%j"))
    {
      getIT <- TRUE
    } else
    {
      getIT <- FALSE
    }
  }
  
  if (getIT | forceCheck)
  {
    if (!require(RCurl))
    {
      stop("You need to install the 'RCurl' package: install.packages('RCurl')")
    }
    
    lockfile <- paste0(opts$auxPath, basnam,".lock")[[1]]
    if(file.exists(lockfile))
    {
      if(as.numeric(Sys.time() - file.info(lockfile)$mtime) > 10)
      {
        unlink(lockfile)
      } else
      {
        readonly <- TRUE
      }
    } else
    {
      zz <- file(description=lockfile, open="wt")  # open an output file connection
      write('deleteme',zz)
      close(zz)
      
      readonly <- FALSE
      on.exit(unlink(lockfile))
    }
    
    path <- genString(x=product$PRODUCT[1], collection=col, local=FALSE)
    
    cat("Downloading structure on '",server,"' for: ",product$PRODUCT[1],".",col,"\n",sep="")
    
    if(exists("FtpDayDirs"))
    {
      rm(FtpDayDirs)
    }
    
    if (server=="LPDAAC")
    {
      startPath <- strsplit(path$remotePath$LPDAAC,"DATE")[[1]][1] # cut away everything behind DATE
      for (g in 1:sturheit)
      {
        cat("Try:",g," \r")
        FtpDayDirs <- try(MODIS:::filesUrl(startPath))
        cat("             \r")
        if(exists("FtpDayDirs"))
        {    
          break
        }
        Sys.sleep(wait)
      }
      FtpDayDirs <- as.Date(as.character(FtpDayDirs),"%Y.%m.%d")
    } else if (server=="LAADS")
    {
      startPath <- strsplit(path$remotePath$LAADS,"YYYY")[[1]][1] # cut away everything behind YYYY
      opt <- options("warn")
      options("warn"=-1)
      rm(years)
      
      once <- TRUE
      for (g in 1:sturheit)
      {
        cat("Downloading structure from 'LAADS'-server! Try:",g,"\r")
        years <- try(filesUrl(startPath))
        years <- as.character(na.omit(as.numeric(years))) # removes folders/files probably not containing data
        
        if(g < (sturheit/2))
        {
          Sys.sleep(wait)
        } else
        {
          if(once & (30 > wait)) {cat("Server problems, trying with 'wait=",max(30,wait),"\n")}
          once <- FALSE                        
          Sys.sleep(max(30,wait))
        }
        if(exists("years"))
        {    
          break
        }
        cat("                                                      \r") 
      }
      options("warn"=opt$warn)
      
      Ypath <- paste0(startPath,years,"/")
      
      ouou <- vector(length=length(years),mode="list")
      for(ix in seq_along(Ypath))
      {
        cat("Downloading structure of '",years[ix],"' from '",server,"'-server.                        \r",sep="")
        ouou[[ix]] <- paste0(years[ix], filesUrl(Ypath[ix]))
      }
      cat("                                                                    \r")
      FtpDayDirs <- as.Date(unlist(ouou),"%Y%j")
    }
    
    if(!exists("FtpDayDirs"))
    {
      cat("Couldn't get structure from",server,"server. Using offline information!\n")
      output$online <- FALSE
    } else if (FtpDayDirs[1]==FALSE)
    {
      cat("Couldn't get structure from",server,"server. Using offline information!\n")
      output$online <- FALSE
    } else
    {
      output$dates  <- FtpDayDirs
      output$online <- TRUE
    }
    
    if(!readonly)
    {
      unlink(list.files(path=opts$auxPath, pattern=paste0(basnam,".*.txt"), full.names=TRUE))
      unlink(lockfile)
      write.table(output$dates, paste0(opts$auxPath,basnam,".",todoy,".txt"), row.names=FALSE, col.names=FALSE)  
    }
  }  
  return(output)
}

# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : February 2012
# Licence GPL v3

# 'date' is the date of an existing file! result from getStruc() and passed as single date! For format see ?transDate

genString <- function(x, collection=NULL, date=NULL, what="images", local=TRUE, remote=TRUE, 
                      opts = NULL, ...)
{
  product <- getProduct(x=x,quiet=TRUE)
  
  if(length(product$PRODUCT)>1)
  {
    warning("genString() does not support multiple products! Generating 'path' for the first product:", product$PRODUCT[1], "\n")
    product <- lapply(product,function(x){x[1]}) # take only the first argument
  }
  
  if(length(product$CCC)==0)
  {
    product$CCC <- getCollection(product=product$PRODUCT,collection=collection, 
                                 checkTools = FALSE)[[1]]
  }
  
  if (!is.null(date)) 
  {
    product$DATE <- list(paste0("A",transDate(date)$beginDOY)) # generates MODIS file date format "AYYYYDDD"
  }
  
  ## if options have not been passed down, create them from '...'
  if (is.null(opts))
    opts <- combineOptions(checkTools = FALSE, ...)
  
  opts$auxPath <- setPath(opts$auxPath)
  remotePath <- localPath <- NULL    
  
  if (is.null(product$DATE)) # if x is a PRODUCT and date is not provided 
  { 
    if (local) 
    {
      tempString <- strsplit(opts$arcStructure,"/")[[1]]
      
      string <- list()
      l=0
      for (i in 1:length(tempString))
      {
        s <- strsplit(tempString[i],"\\.")[[1]]
        
        if (length(s)>0) 
        {
          tmp <- list()
          for (u in 1:length(s))
          {
            if (s[u] %in% c("DATE","YYYY","DDD")) 
            {
              tmp[[u]] <- s[u]
            } else 
            {
              tmp[[u]] <- getPart(x=product,s[u])
            }
          }
          if (length(tmp)>0)
          {
            l=l+1
            string[[l]] <- paste0(unlist(tmp),collapse=".")
          }
        }
      }
      localPath <- setPath(path.expand(paste0(opts$localArcPath,paste0(unlist(string),collapse="/"))))
    }
    
    if (remote) 
    {
      namesFTP <- names(MODIS_FTPinfo)
      Hmany <- grep(namesFTP,pattern="^ftpstring*.")
      
      remotePath <- list()
      n = 0
      for (e in Hmany)
      {
        stringX <- MODIS_FTPinfo[[e]]
        
        if(length(grep(product$SOURCE,pattern=stringX$name))>0 & what %in% stringX$content)
        {
          n=n+1                    
          if(is.null(stringX$variablepath))
          {
            remotePath[[n]] <- stringX$basepath
          } else 
          {
            struc      <- stringX$variablepath    
            tempString <- strsplit(struc,"/")[[1]]
            
            string <- list()
            l=0
            for (i in 1:length(tempString))
            {
              s <- strsplit(tempString[i],"\\.")[[1]]
              
              if (length(s)> 0) 
              {
                l=l+1    
                tmp <- list()
                for (u in 1:length(s))
                {
                  if (s[u] %in% c("DATE","YYYY","DDD")) 
                  {
                    tmp[[u]] <- s[u]
                  } else 
                  {
                    tmp[[u]] <- getPart(x=product,s[u])
                  }
                }                                
                string[[l]] <- paste0(unlist(tmp),collapse=".")
                
                ## append '_MERRAGMAO' if product is hosted at NTSG
                if ("NTSG" %in% unlist(product$SOURCE) & i == 2)
                  string[[l]] <- paste0(string[[l]], "_MERRAGMAO")
              }
            }
            remotePath[[n]] <- path.expand(paste(stringX$basepath,paste0(unlist(string),collapse="/"),sep="/"))
          }
          names(remotePath)[n] <- stringX$name
        }
      }
    }
  } else 
  { # if x is a file name
    
    if (local) 
    {
      tempString <- strsplit(opts$arcStructure,"/")[[1]]
      
      string <- list()
      l=0
      for (i in 1:length(tempString))
      {
        s <- strsplit(tempString[i],"\\.")[[1]]
        
        if (length(s)>0)
        {
          l=l+1
          tmp <- list()
          for (u in seq_along(s))
          {
            tmp[[u]] <- getPart(x=product,s[u])
          }
          string[[l]] <- paste0(unlist(tmp),collapse=".")
        }
      } 
      localPath <- setPath(path.expand(paste0(opts$localArcPath,paste0(unlist(string),collapse="/"))))
    }
    
    if (remote) 
    {
      if (!what %in% c("images","metadata")) 
      {
        stop("Parameter 'what' must be 'images' or 'metadata'")
      }
      
      namesFTP <- names(MODIS_FTPinfo)
      Hmany <- grep(namesFTP,pattern="^ftpstring*.") # get ftpstrings in ./MODIS_opts.R
      
      remotePath <- list()
      n = 0
      for (e in Hmany)
      {
        stringX <- MODIS_FTPinfo[[e]]
        
        if(length(grep(product$SOURCE,pattern=stringX$name))>0 & what %in% stringX$content)
        {
          struc <- stringX$variablepath    
          tempString <- strsplit(struc,"/")[[1]]
          
          string <- list()
          l=0        
          for (i in 1:length(tempString))
          {
            s <- strsplit(tempString[i],"\\.")[[1]]
            
            if (length(s)>0)
            {
              l=l+1
              tmp <- list()
              for (u in seq_along(s))
              {
                tmp[[u]] <- getPart(x=product,s[u])
              }
              string[[l]] <- paste0(unlist(tmp),collapse=".")
              
              ## if working on NTSG server
              if ("NTSG" %in% unlist(product$SOURCE)) {
                # add '_MERRAGMAO' suffix
                if (i == 2)
                  string[[l]] <- paste0(string[[l]], "_MERRAGMAO")
                
                # add leading 'Y' to year
                if (i == 3) 
                  string[[l]] <- paste0("Y", string[[l]])
                
                # add leading 'D' to day of year 
                if (i == 4)
                  
                  # MOD16A2
                  if (product$PRODUCT == "MOD16A2")
                    string[[l]] <- paste0("D", string[[l]])
                  else 
                    string[[l]] <- ""
              }
              
            }
          }
          n=n+1
          remotePath[[n]]      <- path.expand(paste(stringX$basepath,paste0(unlist(string),collapse="/"),sep="/"))
          names(remotePath)[n] <- stringX$name
        }
      }        
    }
  }        
  return(list(localPath=correctPath(localPath), remotePath=remotePath))
}
