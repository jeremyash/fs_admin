library(tidyverse)
library(skimr)
library(patchwork)
library(readxl)
library(sp)
library(rgeos)
library(raster)
library(rgdal)
library(scales)
library(units)
library(viridis)
library(plotKML)
#----------------------------------------------------------------------------

########################################
## load data
########################################

region <- readOGR("gis/region")

county <- readOGR("gis/cb_2017_us_county_5m")

states <- readOGR("gis/states")

#----------------------------------------------------------------------------




########################################
## extract region and write to file 
########################################

region_9 <- subset(region, REGION == "09")
plot(region_9)

writeOGR(obj = region_9,
         dsn = "GIS/region_9",
         layer = "region_9",
         driver = "ESRI Shapefile")

#----------------------------------------------------------------------------

########################################
## intersect county with region
########################################

reg_county <- intersect(region_9, county)

writeOGR(obj = reg_county,
         dsn = "GIS/region_9_county",
         layer = "region_9_county",
         driver = "ESRI Shapefile")


reg_states <- intersect(region_9, states)

writeOGR(obj = reg_states,
         dsn = "GIS/region_9_states",
         layer = "region_9_states",
         driver = "ESRI Shapefile")




#----------------------------------------------------------------------------










