require(rgdal)
setwd("/home/scidb/Downloads")
img1 = readGDAL("pusan_01.tiff")

## pusan_01.tif has GDAL driver GTiff 

spplot(img1)