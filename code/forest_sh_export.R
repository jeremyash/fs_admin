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

forest <- readOGR("gis/forest")
wild <- readOGR("gis/Wilderness")


#----------------------------------------------------------------------------

########################################
## SUBSET AND EXPORT SHAPEFILE
########################################

fs_names <- data_frame(unit = unique(forest@data$NAME))

forest_to_sh <- function(UNIT, PATH) {
  dat_sub <- forest[forest@data$NAME %in% c(UNIT),]
  writeOGR(obj = dat_sub, dsn = PATH, layer = UNIT, driver = "ESRI Shapefile")
}


forest_to_sh("Monongahela National Forest", "data/mon_nf")

forest_to_sh("Midewin National Tallgrass Prairie", "data/midewin")

forest_to_sh("Wayne National Forest", "data/wayne_nf")

forest_to_sh("Shawnee National Forest", "data/shawnee_nf")

forest_to_sh("Hoosier National Forest", "data/hoosier_nf")

#----------------------------------------------------------------------------

########################################
## wilderness to shapefile
########################################

wild_names <- data_frame(unit = unique(wild@data$WILDERNE_1))

wild_to_sh <- function(UNIT, PATH) {
  dat_sub <- wild[wild@data$WILDERNE_1 %in% c(UNIT),]
  writeOGR(obj = dat_sub, dsn = PATH, layer = UNIT, driver = "ESRI Shapefile")
}


wild_to_sh("Boundary Waters Canoe Area Wilderness", "data/bwcaw")



