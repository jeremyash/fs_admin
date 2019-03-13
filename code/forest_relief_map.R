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
## functions
########################################

relief_sh_crop <- function(SH, RELIEF) {
  temp_1 <- crop(RELIEF, extent(SH))
  temp_2 <- mask(temp_1, SH)
  return(temp_2)
}







#----------------------------------------------------------------------------



########################################
## load data
########################################


# file comes from https://www.sciencebase.gov/catalog/item/581d0543e4b08da350d525fc
relief <- raster("gis/national_relief_tiff/srgr48i0100a.tif")
proj4string(relief)

mon_nf <- readOGR("data/mon_nf")
proj4string(mon_nf)

#----------------------------------------------------------------------------


########################################
## crop data
########################################

# crops to rectangular box around shapefile
mon_relief <- relief_sh_crop(mon_nf, relief)
# # mon_relief_df <- as.data.frame(mon_relief, xy = TRUE)
# 
# 
saveRDS(mon_relief, "data/mon_relief.RDS")




#----------------------------------------------------------------------------



















