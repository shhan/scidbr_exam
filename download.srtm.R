# This file downloads and extracts files a couple of SRTM 30m files to the current working directory.

srtm_download_url = "http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/"
srtm_files = c("srtm_46_11.zip", "srtm_45_11.zip", "srtm_44_11.zip","srtm_43_11.zip","srtm_45_10.zip", "srtm_44_10.zip", "srtm_43_10.zip")
srtm_urls = paste0(srtm_download_url,srtm_files)
srtm_destfiles = paste0("srtm/",srtm_files)
          
if (!dir.exists("srtm")) dir.create("srtm")
for (i in 1:length(srtm_urls)) {
  if (!file.exists(srtm_destfiles[i])) download.file(srtm_urls[i],destfile = srtm_destfiles[i])
}

for (i in 1:length(srtm_urls)) {
  if (!file.exists(sub(srtm_destfiles[i], pattern= ".zip$", replacement= ".tif"))) unzip(srtm_destfiles[i], exdir = "srtm")
}


