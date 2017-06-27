# this example is from https//stevemosher.wordpress.com/modis-reprojection-tool

library(raster)

library(rgdal)

day <- "test.LST_Day_1km.tif"

LST <- raster(day)

LST <- LST * .02

LST[LST==0]<-NA

plot(LST)