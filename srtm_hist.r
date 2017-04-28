library(ggplot2)

setwd("/home2/scidb/work/gdal/data/SRTM")

ex_hist=function()
{
  min <- 101
  max <- 548
  buc_cnt <- 256
  
  interval <- (max - min) / (buc_cnt-1)
  val_hist <- read.table("hist.txt", header=FALSE)
  val_hist2 <- matrix(nrow=256, ncol=2)
  colnames(val_hist2) <- c("value", "count")
  i <- 1
  interval2 <- 0
  for (n in val_hist) {
    val_hist2[i, 1] = min + interval2 
    val_hist2[i, 2] = n
    i <- i + 1
    interval2 <- interval2 + interval
  }
  
  val_hist2 <-as.data.frame(val_hist2)
  
  ggplot(data = val_hist2) + 
    geom_line(mapping = aes(x = value , y = count ))
  
  ggplot(data = val_hist2) + 
    geom_line(mapping = aes(value , count ))
}