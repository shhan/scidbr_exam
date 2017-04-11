# it is from http://r-spatial.org/r/2016/05/11/scalable-earth-observation-analytics.html
# it is Marius Appel's work

require(gdalUtils)

# Create 2d array from single GeoTIFF

# delete array to avoid errors if already exists
gdalmanage(mode = "delete", datasetname = "SCIDB:array=chicago confirmDelete=Y" )

## NULL

download.file("http://download.osgeo.org/geotiff/samples/spot/chicago/UTM2GTIF.TIF", destfile = "chicago.tif")
gdal_translate(src_dataset = "chicago.tif", dst_dataset = "SCIDB:array=chicago", of = "SciDB")

## NULL

gdalinfo("SCIDB:array=chicago")

##  [1] "Driver: SciDB/SciDB array driver"                                         
##  [2] "Files: none associated"                                                   
##  [3] "Size is 699, 929"                                                         
##  [4] "Coordinate System is:"                                                    
##  [5] "PROJCS[\"NAD27 / UTM zone 16N\","                                         
##  [6] "    GEOGCS[\"NAD27\","                                                    
##  [7] "        DATUM[\"North_American_Datum_1927\","                             
##  [8] "            SPHEROID[\"Clarke 1866\",6378206.4,294.9786982139006,"        
##  [9] "                AUTHORITY[\"EPSG\",\"7008\"]],"                           
## [10] "            AUTHORITY[\"EPSG\",\"6267\"]],"                               
## [11] "        PRIMEM[\"Greenwich\",0,"                                          
## [12] "            AUTHORITY[\"EPSG\",\"8901\"]],"                               
## [13] "        UNIT[\"degree\",0.0174532925199433,"                              
## [14] "            AUTHORITY[\"EPSG\",\"9122\"]],"                               
## [15] "        AUTHORITY[\"EPSG\",\"4267\"]],"                                   
## [16] "    UNIT[\"metre\",1,"                                                    
## [17] "        AUTHORITY[\"EPSG\",\"9001\"]],"                                   
## [18] "    PROJECTION[\"Transverse_Mercator\"],"                                 
## [19] "    PARAMETER[\"latitude_of_origin\",0],"                                 
## [20] "    PARAMETER[\"central_meridian\",-87],"                                 
## [21] "    PARAMETER[\"scale_factor\",0.9996],"                                  
## [22] "    PARAMETER[\"false_easting\",500000],"                                 
## [23] "    PARAMETER[\"false_northing\",0],"                                     
## [24] "    AUTHORITY[\"EPSG\",\"26716\"],"                                       
## [25] "    AXIS[\"Easting\",EAST],"                                              
## [26] "    AXIS[\"Northing\",NORTH]]"                                            
## [27] "Origin = (444650.000000000000000,4640510.000000000000000)"                
## [28] "Pixel Size = (10.000000000000000,-10.000000000000000)"                    
## [29] "Metadata:"                                                                
## [30] "  AREA_OR_POINT=Area"                                                     
## [31] "  TIFFTAG_RESOLUTIONUNIT=1 (unitless)"                                    
## [32] "  TIFFTAG_XRESOLUTION=72"                                                 
## [33] "  TIFFTAG_YRESOLUTION=72"                                                 
## [34] "Corner Coordinates:"                                                      
## [35] "Upper Left  (  444650.000, 4640510.000) ( 87d40' 2.80\"W, 41d54'59.49\"N)"
## [36] "Lower Left  (  444650.000, 4631220.000) ( 87d39'59.67\"W, 41d49'58.28\"N)"
## [37] "Upper Right (  451640.000, 4640510.000) ( 87d34'59.37\"W, 41d55' 1.14\"N)"
## [38] "Lower Right (  451640.000, 4631220.000) ( 87d34'56.64\"W, 41d49'59.92\"N)"
## [39] "Center      (  448145.000, 4635865.000) ( 87d37'29.62\"W, 41d52'29.73\"N)"
## [40] "Band 1 Block=699x929 Type=Byte, ColorInterp=Undefined"                    
## [41] "  Minimum=6.000, Maximum=255.000, Mean=115.044, StdDev=50.709"

# download 2d array as a png and plot in R
gdal_translate(src_dataset = "SCIDB:array=chicago", dst_dataset = "chicago.png" , of = "PNG")

## NULL

require(rgdal)
img = readGDAL("chicago.png")

## chicago.png has GDAL driver PNG 
## and has 929 rows and 699 columns

spplot(img)
