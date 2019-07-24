## SPATIAL
library(sp)
library(rgeos)
library(raster)
library(rgdal)
library(maptools)
library(sf)
library(plotKML)

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

#wilderness 
wild <- readOGR("gis/Wilderness")
wild <- subset(wild, WILDERNE_1 %in% c("Rainbow Lake Wilderness", "Bradwell Bay Wilderness"))
wild <- spTransform(wild, crs_new)

#forests
forest <- readOGR("gis/forest")
forest <- subset(forest, TYPE == "USFS")
forest <- spTransform(forest, crs_new)

#############################################################################
## intersect class 1, wild and regions 8/9
#############################################################################


c1_r8_9 <- raster::intersect(c1, regions)
c1_r8_9@data <- droplevels(c1_r8_9@data)
c1_r8_9@data <- c1_r8_9@data %>% 
  dplyr::select(NAME, STATE) %>% 
  mutate(NAME = as.factor(paste(STATE, " - ", NAME))) %>% 
  # arrange(NAME) %>% 
  dplyr::select(-STATE)

wild@data <- wild@data %>% 
  bind_cols(., NAME = c("FL - Bradwell Bay Wilderness", "WI - Rainbow Lake Wilderness")) %>% 
  mutate(NAME = as.factor(NAME)) %>% 
  dplyr::select(NAME)

c1_r8_9 <- rbind(c1_r8_9, wild)
c1_r8_9@data <- c1_r8_9@data 



#############################################################################
## write to file to create buffer in ArcMap
#############################################################################
# 
# 
# c1_buffer <- gBuffer(c1_r8_9, byid = TRUE, quadsegs = 10, width = 300000)
# c1_buffer <- spTransform(c1_buffer , CRS("+init=epsg:4269"))
# 
# 
# writeOGR(c1_buffer, dsn = "gis/class_one_r8_9_buffer.kml", layer = "ID", driver = "KML", overwrite_layer = TRUE)  
# writeOGR(c1_buffer, dsn = "gis/class_one_r8_9_buffer", layer = "ID", driver = "ESRI Shapefile", overwrite_layer = TRUE)  
# 


# c1_r8_9 <- spTransform(c1_r8_9, CRS("+init=epsg:4269"))
# writeOGR(c1_r8_9, dsn = "gis/class_one_r8_9.kml", layer = "class_one", driver = "KML", overwrite_layer = TRUE)

c1_r8_9 <- spTransform(c1_r8_9, CRS("+init=epsg:4269 +proj=longlat +ellps=GRS80 +DATUM=NAD83 +no_defs +towgs84=0,0,0"))
writeOGR(c1_r8_9, dsn = "gis/class_one_r8_9", layer = "class_one", driver = "ESRI Shapefile", overwrite_layer = TRUE)


#----------------------------------------------------------------------------

#############################################################################
## read in shapefiles from arc, generated using geodesic buffering, and intersect with forests, regions  
#############################################################################

# gis data
c1 <- readOGR("gis/class_one_r8_9")
c1_buffer <- readOGR("gis/class_one_regions8_9_buffer")

crs_new <- proj4string(c1)
regions <- spTransform(regions, crs_new)
forest <- spTransform(forest, crs_new)

# intersect class I with regions and forest
c1 <- raster::intersect(c1, regions)
c1 <- raster::intersect(c1, forest)

c1@data <- droplevels(c1@data)
c1@data <- c1@data %>% 
  dplyr::select(NAME = 'NAME.1', FOREST = 'NAME.2', REGION = REGIONNAME) 

# simplify wilderness values shared across multiple forests; correct Bradwell Bay and Rainbow Lake
c1@data <- c1@data %>% 
  mutate_if(is.factor, as.character)
c1@data$FOREST[c1@data$NAME == "TN-NC  -  Joyce Kilmer-Slickrock Wilderness"] <- "Cherokee & Nantahala National Forests"
c1@data$FOREST[c1@data$NAME == "GA  -  Cohutta Wilderness"] <- "Chattahoochee & Cherokee National Forests"
c1@data$NAME[c1@data$FOREST == "Chattahoochee & Cherokee National Forests"] <- "GA-TN  -  Cohutta Wilderness"

# c1@data$NAME[c1@data$FOREST == "Chequamegon National Forest"] <- "WI - Rainbow Lake Wilderness"
# c1@data$NAME[c1@data$FOREST == "Apalachicola National Forest"] <- "FL - Bradwell Bay Wilderness"

# eliminate duplicate rows
c1@data <- c1@data %>% 
  distinct()

# convert back to factors
c1@data <- c1@data %>% 
  mutate_if(is.character, as.factor) 
  

# read in original shapefile and update data
c1_sf <- readOGR("gis/class_one_r8_9")
c1_sf@data <- c1_sf@data %>% 
  mutate_if(is.factor, as.character)
c1_sf@data[c1_sf@data == "GA  -  Cohutta Wilderness"] <- "GA-TN  -  Cohutta Wilderness"
c1_sf@data <- c1_sf@data %>% 
  mutate_if(is.character, as.factor)
c1_sf@data <- left_join(c1_sf@data, c1@data)

# left_join class I buffer with class I shapefile
c1_buffer@data <- c1_buffer@data %>% 
  mutate_if(is.factor, as.character)
c1_buffer@data[c1_buffer@data == "GA  -  Cohutta Wilderness"] <- "GA-TN  -  Cohutta Wilderness"
c1_buffer@data <- c1_buffer@data %>% 
  mutate_if(is.character, as.factor)
c1_buffer@data <- left_join(c1_buffer@data, c1_sf@data) %>% 
  select(NAME, FOREST, REGION)


# writeOGR(c1, dsn = "gis/class_one_kml/class_one_r8_9.kml", layer = "ID", driver = "KML", overwrite_layer = TRUE)  
# writeOGR(c1_buffer, dsn = "gis/class_one_kml/class_one_r8_9_buffer.kml", layer = "ID", driver = "KML", overwrite_layer = TRUE)  


c1_sf <- st_as_sf(c1_sf) %>% 
  arrange(NAME)
c1_buffer_sf <- st_as_sf(c1_buffer) %>% 
  arrange(NAME)


st_write(c1_sf, "gis/class_one_kml/class_one.kml", driver = "kml", update = TRUE)
st_write(c1_buffer_sf, "gis/class_one_kml/class_one_buffer.kml", driver = "kml", update = TRUE)
















