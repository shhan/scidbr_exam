# HDF file is from https://e4ftl01.cr.usgs.gov/MOLT/MOD11A2.005/2006.07.04/MOD11A2.A2006185.h10v04.005.2008134190545.hdf
# XML fils is from https://e4ftl01.cr.usgs.gov/MOLT/MOD11A2.005/2006.07.04/MOD11A2.A2006185.h10v04.005.2008134190545.hdf.xml

library(raster)
library(rgdal)
day <- "test.LST_Day_1km.tif"
night <- "test.LST_Night_1km.tif"
LST <- raster(day)
LST <- LST * .02
LST[LST==0]<-NA
plot(LST)

#dir.create("/home/scidb/MODIS_ARC/PROCESSED/.auxiliaries",recursive=TRUE,showWarnings=showWarnings)