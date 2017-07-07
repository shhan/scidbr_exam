# it is from http://r-spatial.org/r/2016/05/11/scalable-earth-observation-analytics.html
# it is Marius Appel's work

install.packages("MODIS")
setRepositories() # activate CRAN, R-forge, and Omegahat and then: 
install.packages(c('rgeos', 'maps', 'mapdata', 'ptw', 'XML '),dependencies=TRUE)
install.packages('RCurl')
install.packages('rgeos')

require(MODIS)

## Loading required package: MODIS

## Loading required package: raster

## MODIS_manual: https://ivfl-rio.boku.ac.at/owncloud/public.php?service=files&t=660dc830afb091237cc40b3dea2fdf6b

## 
## Attaching package: 'MODIS'

## The following object is masked from 'package:base':
## 
##     file.size

require(gdalUtils)
MODISoptions(localArcPath = paste(getwd(), "MODIS_ARC", sep="/"), outDirPath = paste(getwd(), "MODIS_ARC", "PROCESSED", sep="/"))

## To install all required and suggested packages run:
##  setRepositories() # activate CRAN, R-forge, and Omegahat and then: 
##  install.packages(c(' ptw '),dependencies=TRUE)
## 
##   'MRT_HOME' not set/found! MRT is NOT enabled! See: 'https://lpdaac.usgs.gov/tools/modis_reprojection_tool'

## Detecting available write drivers!

## Found: 63 candidate drivers, detecting file extensions...

## 0 usable drivers detected!

## 
## STORAGE:
## _______________
## localArcPath : /home/edzer/marius/MODIS 
## outDirPath   : /home/edzer/MODIS_ARC/PROCESSED 
## 
## 
## DOWNLOAD:
## _______________
## MODISserverOrder : LPDAAC, LAADS 
## dlmethod         : auto 
## stubbornness     : high 
## 
## 
## PROCESSING:
## _______________
## GDAL           : GDAL 2.0.1, released 2015/09/15 
## MRT            : Not available. Use 'MODIS:::checkTools('MRT')' for more information! 
## pixelSize      : asIn 
## outProj        : asIn 
## resamplingType : NN 
## dataFormat     : GTiff 
## 
## 
## DEPENDENCIES:
## _______________
## 
# debug getHdf of Modis
# setwd("/home2/scidb/work/scidbr_exam")
# source("mygetHdf.R")
# debugonce(getStruc)
# hdf.download = mygetHdf("MOD13A3",begin="2000-01-01", end="2005-01-01",tileH = 12, tileV = 9,collection = "005")
# https://e4ftl01.cr.usgs.gov/ shhan
# for this, create or update .netrc on $HOME directory with "machine urs.earthdata.nasa.gov"
#                                                           "login shhan"
#                                                           "password xxxxxxxx" ; you need to create login id/passwd first.
hdf.download = getHdf("MOD13A3",begin="2000-01-01", end="2005-01-01",tileH = 12, tileV = 9,collection = "005")
# download.file('ftp://ladsftp.nascom.nasa.gov/allData/6/MOD11C3/2007/182/MOD11C3.A2007182.006.2015321160040.hdf', tempfile())

## Loading required package: rgeos

## rgeos version: 0.3-8, (SVN revision 460)
##  GEOS runtime version: 3.4.2-CAPI-1.8.2 r3921 
##  Polygon checking: TRUE

# MODIS HDF files have subdatasets for bands, we only want NDVI
filenames = basename(hdf.download$MOD13A3.005)
datasets  = paste0("HDF4_EOS:EOS_GRID:", hdf.download$MOD13A3.005, ":MOD_Grid_monthly_1km_VI:1 km monthly NDVI")

gdalmanage(mode = "delete",datasetname = "SCIDB:array=MOD13A3 confirmDelete=Y" )

## NULL

# MODIS sinusoidal is not in SPATIAL_REF_SYS and must be added
wkt = "PROJCS[\"Sinusoidal\",GEOGCS[\"GCS_Undefined\",DATUM[\"Undefined\",SPHEROID[\"User_Defined_Spheroid\",6371007.181,0.0]],PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199433]],PROJECTION[\"Sinusoidal\"],PARAMETER[\"False_Easting\",0.0],PARAMETER[\"False_Northing\",0.0],PARAMETER[\"Central_Meridian\",0.0],UNIT[\"Meter\",1.0],AUTHORITY[\"SR-ORG\",\"6842\"]]"


# Create a 3d SciDB spacetime array and add first image
# this may produce an error if array already exists
gdal_translate(src_dataset = datasets[1],
               dst_dataset = "SCIDB:array=MOD13A3", of = "SciDB", a_srs = wkt,
               co = list("t=2000-01", "dt=P1M", "type=STS"))

## NULL

# Iteratively add further images to this array
for (i in 2:length(datasets)) { 
  d = strptime(substr(filenames[i],10,16), format="%Y%j")
  
  gdal_translate(src_dataset = datasets[i],  dst_dataset = "SCIDB:array=MOD13A3", of = "SciDB",  a_srs = wkt, co = list("type=ST", "dt=P1M", paste("t=",format(d,"%Y-%m"),sep="")))
}

...

# Download temporal slice
gdal_translate(src_dataset = "SCIDB:array=MOD13A3[t,2001-04-01]", dst_dataset = "mod.tif" , of = "GTiff")

...

## NULL

require(rgdal)
img = readGDAL("mod.tif")

## mod.tif has GDAL driver GTiff 
## and has 1200 rows and 1200 columns

spplot(img)
