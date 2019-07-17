## SPATIAL
library(sp)
library(rgeos)
library(raster)
library(rgdal)
library(maptools)
library(sf)

## DATA MANAGEMENT
library(tidyverse)
library(skimr)
library(patchwork)
library(readxl)
# library(zoo)

## PLOTTING
library(scales)
library(units)
library(viridis)
library(extrafont)
library(gtable)
library(grid)
#----------------------------------------------------------------------------

#############################################################################
## load gis
#############################################################################

# class 1
c1 <- readOGR("gis/classI")
c1 <- subset(c1, AGENCY == "FS")
crs_new <- proj4string(c1)

# regions
regions <- readOGR("gis/region")
regions <- subset(regions, REGION %in% c("08", "09"))
regions <- spTransform(regions, crs_new)

#############################################################################
## intersect class 1 and regions 8/9
#############################################################################

c1_r8_9 <- raster::intersect(c1, regions)
c1_r8_9@data <- droplevels(c1_r8_9@data)
c1_r8_9@data <- c1_r8_9@data %>% 
  dplyr::select(NAME, STATE) %>% 
  mutate(NAME = as.factor(paste(STATE, " - ", NAME))) %>% 
  arrange(NAME)


#############################################################################
## create buffer and write to files
#############################################################################

c1_buffer <- gBuffer(c1_r8_9, byid = TRUE, width = 300000)
c1_buffer <- spTransform(c1_buffer , CRS("+init=epsg:4269"))


writeOGR(c1_buffer, dsn = "gis/class_one_r8_9_buffer.kml", layer = "ID", driver = "KML", overwrite_layer = TRUE)  










c1_r8_9 <- spTransform(c1_r8_9, CRS("+init=epsg:4269"))

writeOGR(c1_r8_9, dsn = "gis/class_one_r8_9.kml", layer = "class_one", driver = "KML", overwrite_layer = TRUE)
