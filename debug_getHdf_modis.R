# debug getHdf of Modis
setwd("/home/scidb/work/scidbr_exam") # it must be changed with source directory.
source("mygetHdf.R")
source("doOptions.R")
source("minorFuns.R")
debugonce(getStruc)

hdf.download = mygetHdf("MOD13A3",begin="2000-01-01", end="2000-02-01",tileH = 12, tileV = 9,collection = "005")
