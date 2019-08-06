
#library(jsonlite)

#acquiring data from OpenDatasSoft API
#mp1 <- fromJSON("https://public.opendatasoft.com/api/records/1.0/search/?dataset=namus-missings&sort=modifieddatetime&facet=cityoflastcontact&facet=countydisplaynameoflastcontact&facet=raceethnicity&facet=statedisplaynameoflastcontact&facet=gender")

#acquiring local file of data as a backup
getwd() 
setwd("/Users/nfoster06/Documents/GitHub/Data-Science-Capstone/Data/Code/App")
mp <- read.csv("namus-missings-1.csv",
               stringsAsFactors = FALSE)

na.omit(mp)
summary(mp)
#dropping NAs
mp1 <- na.omit(mp) #omit NAs
head(mp1$Lat)

#Exploring the data
head(mp1)
list(mp1)
colnames(mp1)
str(mp1)
#generate csv file to convert to shp usint web utility
#write.csv(mp1, file = "mp1.csv")
#https://mygeodata.cloud/converter/csv-to-shp

#reading in updatedNAMUSshapefile,
library(rgdal)
library(sf)
library(sp)
library(GISTools)

#reading in shapefile to identify & replicate its Coordinate Reference System (CRS)
mp_shp1 <- st_read("namus-missings.shp")

# identify Coordinate Reference System (CRS)
st_crs(mp_shp1)

# view extent
st_bbox(mp_shp1)

#Creating CRS Object
utm18nCRS <- st_crs(mp_shp1)
utm18nCRS
class(utm18nCRS)

#converting csv dataframe to sf object
point_reference_mp <- st_as_sf(mp1, coords = c("Lat", "Lon"), crs = utm18nCRS)
st_crs(point_reference_mp)
# plot spatial object
plot(point_reference_mp$geometry,
     main = "Missing Persons - NamUS")


#writing shapefile for future reference
st_write(point_reference_mp,
         "point_reference_mp.shp", driver = "ESRI Shapefile")

#plot "quickmap"
library(tmap)
qtm(point_reference_mp$geometry, fill = "blue", style = "natural")
#qtm(point_reference_mp, fill = "Race_Ethni", text.size = 0.5,
#format = "World_wide", style = "classic",
#text.root=5, fill.title="Missing Persons by Race")

library(GISTools) #for us states polygons
data(tornados) #for us states polygons

#establishing boundary
us_states_sf <- st_as_sf(us_states)
AoI.merge_sf <- st_sf(st_union(us_states_sf))
tm_shape(us_states_sf) + tm_borders(col = "darkgreen", lty = 3) + 
  tm_shape(AoI.merge_sf) + tm_borders(lwd = 1.5, col = "black") + 
  tm_layout(frame = F)

class(us_states_sf1)

# plot Boundary
plot(us_states_sf$geometry,
     main = "Missing Persons | CONUS")

# add plot locations

plot(point_reference_mp$geometry,
     pch = 8, add = TRUE)

# view CRS of each to ensure match
st_crs(us_states_sf)
st_crs(point_reference_mp)

# View extent of each

st_bbox(us_states_sf)
st_bbox(point_reference_mp)

#boundaries shapefile with US territories

#world <- st_read("ne_10m_admin_1_states_provinces.shp")
#usa <- st_read("boundary_l_v2.shp")
#North_America <- st_read("North_America.shp")

#library(rnaturalearth)
#library(rnaturalearthdata)
#library(ggplot2)
#library(choroplethrMaps)
#library(USAboundaries)

#shapeFile with all of north america: 
#us_states_sf1 <- st_as_sf(North_America)
#AoI.merge_sf1 <- st_sf(st_union(us_states_sf1))
#tm_shape(us_states_sf1) + tm_borders(col = "darkgreen", lty = 3) +
  #tm_shape(us_states_sf1) + tm_borders(lwd = 1.5, col = "black") +
  #tm_layout(frame = F)

#summary descriptive statistics
#colnames(df)
#summary(df)
#summary(df$Gender)
#summary(as.numeric(df$Computed_1))
#summary(as.numeric(df$Computed_M))
#summary(df$Gender)
#summary(df$Race_Ethni)

#Creating sf data frames for spatial analysis


#plot tmap

#mp_tmap <- st_union(boundary_mp)
#mp_tmap_point <-st_union(point_reference_mp)





#https://geocompr.robinlovelace.net/spatial-class.html <- additional reference
library(leaflet)
install.packages("spData")
library(spData)
devtools::install_github("Nowosad/spDataLarge")
library(spDataLarge)
library(leaflet)

tm_shape() +
  tm_fill() 

