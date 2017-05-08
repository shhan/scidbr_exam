# it is from http://r-spatial.org/r/2016/05/11/scalable-earth-observation-analytics.html
# it is Marius Appel's work


# SRTM example over Ethopia

# First file

require(gdalUtils)

# download files, this might take some time(!)
setwd("/home/scidb/work/scidbr_exam")
source("download.srtm.R")

# find files
files = list.files(path = "srtm", pattern = "*.tif", full.names = TRUE)

# delete array to avoid errors if already exists
gdalmanage(mode = "delete",datasetname = "SCIDB:array=srtm confirmDelete=Y")

## NULL

# Create a 2d SciDB array with given extent and add first image
# this may produce an error if array already exists
gdal_translate(src_dataset = files[1],
               dst_dataset = "SCIDB:array=srtm", of = "SciDB",
               co = list("bbox=30 5 50 15", "srs=EPSG:4326", "type=S"))

## NULL

# Iteratively add further images to this array
for (i in 2:length(files)) { # takes around 2 minutes each on my machine
  gdal_translate(verbose = T, src_dataset = files[i],  dst_dataset = "SCIDB:array=srtm", of = "SciDB", co = list("type=S", "srs=EPSG:4326"))
}

## Checking gdal_installation...

## Scanning for GDAL installations...

## Checking the gdalUtils_gdalPath option...

## GDAL version 2.0.1

## GDAL command being used: "/usr/local/bin/gdal_translate" -of "SciDB" -co "type=S" -co "srs=EPSG:4326" "srtm/srtm_43_11.tif" "SCIDB:array=srtm"

## Input file size is 6001, 60010...10...20...30...40...50...60...70...80...90...100 - done.

## Checking gdal_installation...

## Scanning for GDAL installations...

## Checking the gdalUtils_gdalPath option...

## GDAL version 2.0.1

## GDAL command being used: "/usr/local/bin/gdal_translate" -of "SciDB" -co "type=S" -co "srs=EPSG:4326" "srtm/srtm_44_10.tif" "SCIDB:array=srtm"

## Input file size is 6001, 60010...10...20...30...40...50...60...70...80...90...100 - done.

## Checking gdal_installation...

## Scanning for GDAL installations...

## Checking the gdalUtils_gdalPath option...

## GDAL version 2.0.1

## GDAL command being used: "/usr/local/bin/gdal_translate" -of "SciDB" -co "type=S" -co "srs=EPSG:4326" "srtm/srtm_44_11.tif" "SCIDB:array=srtm"

## Input file size is 6001, 60010...10...20...30...40...50...60...70...80...90...100 - done.

## Checking gdal_installation...

## Scanning for GDAL installations...

## Checking the gdalUtils_gdalPath option...

## GDAL version 2.0.1

## GDAL command being used: "/usr/local/bin/gdal_translate" -of "SciDB" -co "type=S" -co "srs=EPSG:4326" "srtm/srtm_45_10.tif" "SCIDB:array=srtm"

## Input file size is 6001, 60010...10...20...30...40...50...60...70...80...90...100 - done.

## Checking gdal_installation...

## Scanning for GDAL installations...

## Checking the gdalUtils_gdalPath option...

## GDAL version 2.0.1

## GDAL command being used: "/usr/local/bin/gdal_translate" -of "SciDB" -co "type=S" -co "srs=EPSG:4326" "srtm/srtm_45_11.tif" "SCIDB:array=srtm"

## Input file size is 6001, 60010...10...20...30...40...50...60...70...80...90...100 - done.

## Checking gdal_installation...

## Scanning for GDAL installations...

## Checking the gdalUtils_gdalPath option...

## GDAL version 2.0.1

## GDAL command being used: "/usr/local/bin/gdal_translate" -of "SciDB" -co "type=S" -co "srs=EPSG:4326" "srtm/srtm_46_11.tif" "SCIDB:array=srtm"

## Input file size is 6001, 60010...10...20...30...40...50...60...70...80...90...100 - done.

# Second file
# Running gdalinfo shows that the created array has 24001 x 12001 pixels.

require(gdalUtils)
gdalinfo("SCIDB:array=srtm")

##  [1] "Driver: SciDB/SciDB array driver"                                         
##  [2] "Files: none associated"                                                   
##  [3] "Size is 24001, 12001"                                                     
##  [4] "Coordinate System is:"                                                    
##  [5] "GEOGCS[\"WGS 84\","                                                       
##  [6] "    DATUM[\"WGS_1984\","                                                  
##  [7] "        SPHEROID[\"WGS 84\",6378137,298.257223563,"                       
##  [8] "            AUTHORITY[\"EPSG\",\"7030\"]],"                               
##  [9] "        AUTHORITY[\"EPSG\",\"6326\"]],"                                   
## [10] "    PRIMEM[\"Greenwich\",0,"                                              
## [11] "        AUTHORITY[\"EPSG\",\"8901\"]],"                                   
## [12] "    UNIT[\"degree\",0.0174532925199433,"                                  
## [13] "        AUTHORITY[\"EPSG\",\"9122\"]],"                                   
## [14] "    AUTHORITY[\"EPSG\",\"4326\"]]"                                        
## [15] "Origin = (29.999583333323201,15.000416884586100)"                         
## [16] "Pixel Size = (0.000833333333333,-0.000833333333333)"                      
## [17] "Metadata:"                                                                
## [18] "  AREA_OR_POINT=Area"                                                     
## [19] "Corner Coordinates:"                                                      
## [20] "Upper Left  (  29.9995833,  15.0004169) ( 29d59'58.50\"E, 15d 0' 1.50\"N)"
## [21] "Lower Left  (  29.9995833,   4.9995836) ( 29d59'58.50\"E,  4d59'58.50\"N)"
## [22] "Upper Right (  50.0004167,  15.0004169) ( 50d 0' 1.50\"E, 15d 0' 1.50\"N)"
## [23] "Lower Right (  50.0004167,   4.9995836) ( 50d 0' 1.50\"E,  4d59'58.50\"N)"
## [24] "Center      (  40.0000000,  10.0000002) ( 40d 0' 0.00\"E, 10d 0' 0.00\"N)"
## [25] "Band 1 Block=2048x2048 Type=Int16, ColorInterp=Undefined"                 
## [26] "  Minimum=-197.000, Maximum=4517.000, Mean=926.244, StdDev=684.170"       
## [27] "  NoData Value=-32768"

# third file
require(rgdal)
srtm.sp = readGDAL("SCIDB:array=srtm",offset = c(8000,3000), region.dim = c(1000,1000) )

## SCIDB:array=srtm has GDAL driver SciDB 
## and has 12001 rows and 24001 columns

spplot(srtm.sp,  scales = list(TRUE))

