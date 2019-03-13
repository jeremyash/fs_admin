library(tidyverse)
library(skimr)
library(patchwork)
library(readxl)
library(sp)
library(rgeos)
library(raster)
library(rgdal)
# library(scales)
# library(units)
# library(viridis)
#---------------------------------------------------------------------------- 

########################################
## LOAD DATA
########################################

r9 <- readOGR("gis/region_9") 



forest <- readOGR("gis/S_USA.AdministrativeForest")
forest <- spTransform(forest, CRS = proj4string(r9))

#----------------------------------------------------------------------------

########################################
## create r9 forest shapefile
########################################

r9_units <- raster::intersect(r9, forest)

writeOGR(r9_units,
         layer = "r9_units",
         dsn = "gis/r9_units",
         driver = "ESRI Shapefile")



#----------------------------------------------------------------------------

