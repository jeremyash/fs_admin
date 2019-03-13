r## SPATIAL
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


baileys <- readOGR("raw_data/baileys_ecoreg")


# subset to province 212 and write to shapefile
prov_212 <- baileys[baileys$PROVINCE == "Laurentian Mixed Forest Province",]

writeOGR(obj = prov_212, 
         dsn = "gis/prov_212", 
         layer = "prov_212", 
         driver = "ESRI Shapefile")
