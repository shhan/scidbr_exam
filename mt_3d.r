# it is from http://r-spatial.org/r/2016/05/11/scalable-earth-observation-analytics.html
# it is Marius Appel's work

# install packages it these packages were not
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
setwd("/home/scidb")
require(gdalUtils)

## if Error in "MRT_HOME not set/found!
Sys.setenv(MRT_DATA_DIR = "/home/scidb/MRT/data",
           MRT_HOME = "/home/scidb/MRT/bin",
           PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")

MODISoptions(localArcPath = paste(getwd(), "MODIS_ARC", sep="/"), outDirPath = paste(getwd(), "MODIS_ARC", "PROCESSED", sep="/"))

## Though you installed MRT successfully, 

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

hdf.download[1]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.02.01/MOD13A3.A2000032.h12v09.005.2006271172944.hdf"
hdf.download[2] <-'/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.03.01/MOD13A3.A2000061.h12v09.005.2007130123751.hdf'
hdf.download[3]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.04.01/MOD13A3.A2000092.h12v09.005.2007111063049.hdf"
hdf.download[4]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.05.01/MOD13A3.A2000122.h12v09.005.2007111070124.hdf"
hdf.download[5]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.06.01/MOD13A3.A2000153.h12v09.005.2006298121359.hdf"
hdf.download[6]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.07.01/MOD13A3.A2000183.h12v09.005.2006310224808.hdf"
hdf.download[7]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.08.01/MOD13A3.A2000214.h12v09.005.2007111194458.hdf"
hdf.download[8]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.09.01/MOD13A3.A2001244.h12v09.005.2007112123321.hdf"
hdf.download[9]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.10.01/MOD13A3.A2000275.h12v09.005.2007111210518.hdf"
hdf.download[10]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.11.01/MOD13A3.A2000306.h12v09.005.2007130180756.hdf"
hdf.download[11]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2000.12.01/MOD13A3.A2000336.h12v09.005.2007112103625.hdf"
hdf.download[12]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.01.01/MOD13A3.A2001001.h12v09.005.2007112110237.hdf"
hdf.download[13]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.02.01/MOD13A3.A2001032.h12v09.005.2007112111436.hdf"
hdf.download[14]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.03.01/MOD13A3.A2001060.h12v09.005.2007112112847.hdf"
hdf.download[15]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.04.01/MOD13A3.A2001091.h12v09.005.2007112114141.hdf"
hdf.download[16]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.05.01/MOD13A3.A2001121.h12v09.005.2007112115405.hdf"
hdf.download[17]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.06.01/MOD13A3.A2001152.h12v09.005.2007176164644.hdf"
hdf.download[18]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.07.01/MOD13A3.A2001182.h12v09.005.2007112121537.hdf"
hdf.download[19]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.08.01/MOD13A3.A2001213.h12v09.005.2007112122515.hdf"
hdf.download[20]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.09.01/MOD13A3.A2000032.h12v09.005.2006271172944.hdf"
hdf.download[21]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.10.01/MOD13A3.A2001274.h12v09.005.2007109184226.hdf"
hdf.download[22]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.11.01/MOD13A3.A2001305.h12v09.005.2007110161850.hdf"
hdf.download[23]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2001.12.01/MOD13A3.A2001335.h12v09.005.2007113001138.hdf"
hdf.download[24]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.01.01/MOD13A3.A2002001.h12v09.005.2007132041300.hdf"
hdf.download[25]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.02.01/MOD13A3.A2002032.h12v09.005.2007133144602.hdf"
hdf.download[26]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.03.01/MOD13A3.A2002060.h12v09.005.2007139061147.hdf"
hdf.download[27]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.04.01/MOD13A3.A2002091.h12v09.005.2007151132452.hdf"
hdf.download[28]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.05.01/MOD13A3.A2002121.h12v09.005.2007161011301.hdf"
hdf.download[29]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.06.01/MOD13A3.A2002152.h12v09.005.2007179105431.hdf"
hdf.download[30]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.07.01/MOD13A3.A2002182.h12v09.005.2007197094239.hdf"
hdf.download[31]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.08.01/MOD13A3.A2002213.h12v09.005.2007207174636.hdf"
hdf.download[32]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.09.01/MOD13A3.A2002244.h12v09.005.2007224015027.hdf"
hdf.download[32]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.10.01/MOD13A3.A2002274.h12v09.005.2007232173607.hdf"
hdf.download[34]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.11.01/MOD13A3.A2002305.h12v09.005.2007256191049.hdf"
hdf.download[35]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2002.12.01/MOD13A3.A2002335.h12v09.005.2007262074848.hdf"
hdf.download[36]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.01.01/MOD13A3.A2003001.h12v09.005.2008052221453.hdf"
hdf.download[37]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.02.01/MOD13A3.A2003032.h12v09.005.2007287234314.hdf"
hdf.download[38]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.03.01/MOD13A3.A2003060.h12v09.005.2007310162401.hdf"
hdf.download[39]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.04.01/MOD13A3.A2003091.h12v09.005.2007330030627.hdf"
hdf.download[40]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.05.01/MOD13A3.A2003121.h12v09.005.2007334120941.hdf"
hdf.download[41]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.06.01/MOD13A3.A2003152.h12v09.005.2007339095419.hdf"
hdf.download[42]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.07.01/MOD13A3.A2003182.h12v09.005.2007353122430.hdf"
hdf.download[43]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.08.01/MOD13A3.A2003213.h12v09.005.2008003084501.hdf"
hdf.download[44]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.09.01/MOD13A3.A2003244.h12v09.005.2008013235646.hdf"
hdf.download[45]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.10.01/MOD13A3.A2003274.h12v09.005.2008022091245.hdf"
hdf.download[46]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.11.01/MOD13A3.A2003305.h12v09.005.2008042093215.hdf"
hdf.download[47]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.12.01/MOD13A3.A2003335.h12v09.005.2008045050726.hdf"
hdf.download[48]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.01.01/MOD13A3.A2004001.h12v09.005.2007246031730.hdf"
hdf.download[49]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.02.01/MOD13A3.A2004032.h12v09.005.2007254000251.hdf"
hdf.download[50]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.03.01/MOD13A3.A2004061.h12v09.005.2007264133752.hdf"
hdf.download[51]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.04.01/MOD13A3.A2004092.h12v09.005.2007277200459.hdf"
hdf.download[52]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.05.01/MOD13A3.A2004122.h12v09.005.2007288090515.hdf"
hdf.download[53]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.06.01/MOD13A3.A2004153.h12v09.005.2007295084243.hdf"
hdf.download[54]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.07.01/MOD13A3.A2004183.h12v09.005.2007309003954.hdf"
hdf.download[55]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.08.01/MOD13A3.A2004214.h12v09.005.2007316120955.hdf"
hdf.download[56]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.09.01/MOD13A3.A2004245.h12v09.005.2007325150725.hdf"
hdf.download[57]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.10.01/MOD13A3.A2004275.h12v09.005.2007332132041.hdf"
hdf.download[58]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.11.01/MOD13A3.A2004306.h12v09.005.2007338120656.hdf"
hdf.download[59]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2004.12.01/MOD13A3.A2004336.h12v09.005.2007354005335.hdf"
hdf.download[60]="/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2005.01.01/MOD13A3.A2005001.h12v09.005.2007355094710.hdf"


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

gdal_translate(src_dataset = "HDF4_EOS:EOS_GRID:/home/scidb/MODIS_ARC/MODIS/MOD13A3.005/2003.07.01/MOD13A3.A2003182.h12v09.005.2007353122430.hdf:MOD_Grid_monthly_1km_VI:1 km monthly NDVI",
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
