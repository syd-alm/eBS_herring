# load / install libraries 
library(devtools)
devtools::install_github("MikkoVihtakari/ggOceanMapsData") # required by ggOceanMaps
devtools::install_github("oswaldosantos/ggsn")

#install.packages(c("ggOceanMaps"), repos = "https://mikkovihtakari.github.io/drat")
library(ggOceanMaps)
library(ggspatial)
library(cowplot)
library(dplyr)
library(paletteer)
# color palettes: https://pmassicotte.github.io/paletteer_gallery/#qualitative 

# guide here:
# https://mikkovihtakari.github.io/ggOceanMaps/articles/ggOceanMaps.html

# ggplot shape options:
# https://blog.albertkuo.me/post/point-shape-options-in-ggplot/


#######
# NGOA sample map 
######
setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/sampling_map")

ngoa_locations <- read.csv("NGOA_sequenced_locations.csv")

qmap(ngoa_locations, color=location, expand.factor=1.38, rotate = TRUE)

ngoa_map <- basemap(limits = c(-180, -140, 50, 65), expand.factor=0.8, bathymetry = TRUE, rotate= TRUE, bathy.style="rbb")+
  ggspatial::geom_spatial_point(data=ngoa_locations, mapping=aes(x=lon, y=lat, color=location), size=1.8)+
  ggspatial::annotation_north_arrow(location = "tr", which_north = "true", height = unit(0.7, "cm"), width = unit(0.7, "cm"))+
  ggspatial::annotation_scale(location = "br")+
  ggtitle("NGOA sampling locations")+
  theme(axis.title = element_blank())+
  scale_color_paletteer_d("khroma::okabeitoblack", name = "Location", 
                          labels = c("Cordova", "Constantine Bay", "Kodiak: Outer Kiliuda Bay", "Kodiak: South Arm of Uganik Bay", "Popof Island","Port Moller","Togiak"))

ngoa_map 
outlined_ngoa_map <- ngoa_map + ggspatial::geom_spatial_point(data=ngoa_locations, mapping=aes(x=lon, y=lat), size=1.95, pch=21)
outlined_ngoa_map

#######################
# Bering Sea + GOA spawning sample map 
#####################
setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/sample_collection_info")
locations <- read.csv("EBS_GOA_spawning_samples.csv")

# set pop as factor so it can be reordered 
locations$Location <- as.factor(locations$Location)

# re-factor data for arrangement of pops from north to south 
locations$Location <- factor(locations$Location, 
                        levels=c("Kotzebue", "Norton Sound","Nelson Island",
                                 "Goodnews Bay", "Togiak",  "Port Moller", 
                                 "Unalaska", "Cordova", "Kodiak - Kiliuda", 
                                 "Kodiak - Uganik"))

# minimal narrow map for including with PCAs 
simple_narrow <- qmap(locations, color=Location,
                      expand.factor=1.15, rotate = TRUE)+
  ggspatial::geom_spatial_point(data=locations, mapping=aes(x=Longitude, y=Latitude, color = Location), size=4)+
  theme(axis.title = element_blank(),legend.position = "none")+
  scale_color_manual(values = c("#D53E4F","#FDAE61","#E6F598","#ABDDA4","#33a02c","#3288BD", "#8c86d2", "#4FA3F7","#E78AC3","#D9488B"))

outlined_simple_narrow <- simple_narrow + 
  ggspatial::geom_spatial_point(data=locations, 
                                mapping=aes(x=Longitude, y=Latitude), size=4.2, pch=21)
outlined_simple_narrow


# larger outline only map without bathymtry
simple <- basemap(limits = c(-180, -140, 50, 72),
                  grid.col = "grey39", grid.size=0.1,land.col = "gray70",
                  bathymetry = FALSE, rotate= TRUE)+
  ggspatial::geom_spatial_point(data=bs_spawning, mapping=aes(x=Longitude, y=Latitude, color = Location), size=3)+
  ggspatial::annotation_north_arrow(location = "tr", which_north = "true", height = unit(.8, "cm"), width = unit(.8, "cm"),)+
  ggspatial::annotation_scale(location = "br")+
  theme(axis.title = element_blank(),legend.position = "none")+
  scale_color_manual(values = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD", "#8c86d2"))


# detailed sampling map
bs_map <- 
  basemap(limits = c(-180, -140, 50, 70), expand.factor=0.8, 
          grid.col = "lightgrey", grid.size=0.1,
          bathymetry = TRUE, rotate= TRUE, bathy.style="rbb")+
  ggspatial::geom_spatial_point(data=bs_spawning, mapping=aes(x=Longitude, y=Latitude, color = Location), size=4)+
  ggspatial::annotation_north_arrow(location = "tr", which_north = "true", height = unit(1, "cm"), width = unit(1, "cm"),)+
  ggspatial::annotation_scale(location = "br")+
  ggtitle("Bering Sea Sampling Locations")+
  theme(axis.title = element_blank())+
  scale_color_manual(values = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD", "#8c86d2"))

bs_map 

# add black outline around points
outlined_bs_map <- bs_map + ggspatial::geom_spatial_point(data=bs_locations, mapping=aes(x=Longitude, y=Latitude, shape = spawning_type), size=4, pch=21)

outlined_bs_map

