# this example is from https//stevemosher.wordpress.com/modis-reprojection-tool
# download HDF file https://e4ftl01.cr.usgs.gov/MOLT/MOD11A2.005/2006.07.04/MOD11A2.A2006185.h10v04.005.2008134190545.hdf
# download XML file https://e4ftl01.cr.usgs.gov/MOLT/MOD11A2.005/2006.07.04/MOD11A2.A2006185.h10v04.005.2008134190545.hdf.xml

library(raster)

library(rgdal)

day <- "test.LST_Day_1km.tif"

LST <- raster(day)

LST <- LST * .02

LST[LST==0]<-NA

plot(LST)