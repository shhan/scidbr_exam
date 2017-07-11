# r_exec should be already installed in the Docker container (scripts are provided)
# devtools::install_github("Paradigm4/SciDBR", ref="laboratory")

# remove previously created arrays
gdalmanage(mode = "delete",datasetname = "SCIDB:array=MOD13A3_T confirmDelete=Y" )

## NULL

gdalmanage(mode = "delete",datasetname = "SCIDB:array=MOD13A3_MODEL_OUTPUT confirmDelete=Y" )

## NULL

gdalmanage(mode = "delete",datasetname = "SCIDB:array=MOD13A3_MODEL_SP confirmDelete=Y" )

## NULL

require(scidb)

## Loading required package: scidb

##    ____    _ ___  ___
##   / __/___(_) _ \/ _ )
##  _\ \/ __/ / // / _  |
## /___/\__/_/____/____/     Copyright 2016, Paradigm4, Inc.

## 
## Attaching package: 'scidb'

## The following object is masked from 'package:rgdal':
## 
##     project

## The following object is masked from 'package:sp':
## 
##     dimensions

## The following objects are masked from 'package:stats':
## 
##     phyper, qhyper

#scidbconnect(host = SCIDB_HOST,port=SCIDB_PORT, username = SCIDB_USER, password = SCIDB_PW, auth_type = "digest",protocol = "https")
scidbconnect(host = "localhost",port=8083, username = "scidb", password = "scidb", auth_type = "digest",protocol = "https")


#1. Rearrange chunks to contain complete time series and convert integers to NDVI doubles
query.preprocess = "store(merge(repart(project(apply(MOD13A3,ndvi,double(band1) / 10000.0),ndvi),<ndvi : double>[y=0:1199,64,0, x=0:1199,64,0, t=0:*,256,0]), build(<ndvi : double>[y=0:1199,64,0, x=0:1199,64,0, t=0:60,256,0],-1)), MOD13A3_T)"
iquery(query.preprocess)


#2. Apply R function over individual time series      
query.R = "store(unpack(r_exec(project(apply(MOD13A3_T,X,double(x),Y,double(y),T,double(t)), ndvi,X,Y,T),'output_attrs=6','expr=
dim1 = length(unique(Y))
dim2 = length(unique(X))
dim3 = length(unique(T))
ndvi = array(ndvi,c(dim3,dim2,dim1))
t = 1:dim3
ndvi.fitted = apply(ndvi,c(3,2),function(x) {
x[which(x < -0.29)] = NA 
x = filter(x,c(1,1,1)/3,circular=TRUE)
if (all(is.na(x))) return(c(0,0,0,-1))
ndvi.seasonal = lm(x ~ sin(t/6) + cos(t/6))
intercept = coef(ndvi.seasonal)[1]
ampl  = sqrt(coef(ndvi.seasonal)[2]^2 + coef(ndvi.seasonal)[3]^2 )
phase = atan2(coef(ndvi.seasonal)[2],coef(ndvi.seasonal)[3])
ssr = sum(residuals(ndvi.seasonal)^2)
return(c(intercept, ampl, phase, ssr))
})
coords = expand.grid(unique(Y),unique(X))
list(as.double(coords[,1]),as.double(coords[,2]), ndvi.fitted[1,,], ndvi.fitted[2,,], ndvi.fitted[3,,], ndvi.fitted[4,,]  )'),i), MOD13A3_MODEL_OUTPUT)"

iquery(query.R)



# 3. Reshape the array to two dimensions
query.postprocess = "store(redimension(project(apply(MOD13A3_MODEL_OUTPUT,y,int64(expr_value_0), x,int64(expr_value_1), p0,expr_value_2, p1, expr_value_3, p2, expr_value_4, ssr, expr_value_5),y,x,p0,p1,p2,ssr), <p0 : double, p1 : double, p2 : double, ssr : double>[y=0:1199,2048,0, x=0:1199,2048,0]), MOD13A3_MODEL_SP)"

iquery(query.postprocess)
iquery("eo_setsrs(MOD13A3_MODEL_SP,'x','y','SR-ORG',6842,'x0=-6671703.118 y0=0 a11=926.625433055833 a22=-926.625433055833 a12=0 a21=0')")