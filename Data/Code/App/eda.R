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
library(ggplot2)

#reading in shapefile to identify & replicate its Coordinate Reference System (CRS)
mp_shp1 <- st_read("namus-missings.shp")

# identify Coordinate Reference System (CRS)
st_crs(mp_shp1)

# view extent
st_bbox(mp_shp1)

#establish CRS
utm18nCRS <- st_crs(mp_shp1)

st_crs(utm18nCRS)

class(utm18nCRS)

#converting csv dataframe to sf object
point_reference_mp <- st_as_sf(mp1, coords = c("Lat", "Lon"), crs = utm18nCRS)
st_crs(point_reference_mp)
point_reference_mp1 <-st_transform(point_reference_mp, crs= 4326)
st_crs(point_reference_mp1)

# plot spatial object
plot(point_reference_mp1$geometry,
     main = "Missing Persons - NamUS")

#writing shapefile for future reference
#st_write(point_reference_mp,
         #"point_reference_mp.shp", driver = "ESRI Shapefile")

#plot "quickmap"
library(tmap)
qtm(point_reference_mp$geometry, fill = "blue", style = "natural")


library(GISTools) #for us states polygons
data(tornados) #for us states polygons

#establishing boundary

us_states_sf <- st_as_sf(us_states)
AoI.merge_sf <- st_sf(st_union(us_states_sf))
tm_shape(us_states_sf) + tm_borders(col = "darkgreen", lty = 3) + 
  tm_shape(AoI.merge_sf) + tm_borders(lwd = 1.5, col = "black") + 
  tm_layout(frame = F)

class(us_states_sf)

# plot Boundary
plot(us_states_sf$geometry,
     main = "Missing Persons | CONUS")

# add plot locations

plot(point_reference_mp$geometry,
     pch = 8, add = TRUE)

#view CRS of each to ensure match
st_crs(us_states_sf)
st_crs(point_reference_mp)

#View extent of each

st_bbox(us_states_sf)
st_bbox(point_reference_mp)

#point in polygon calculations

library(raster)
library(spatstat)

#points <- data.frame(point_reference_mp)

#Q <- quadratcount(points, nx= 6, ny=3)
#pointsinpoly <- over(points,us_states_sf)

require(GISTools)
require(tmap)

library(spData)
usa <- spData::us_states #map of contiguous United States
colnames(usa)
head(usa)
st_crs(usa)
plot(usa$geometry)
head(usa$geometry,1)

colnames(usa)

states <- usa$NAME

#preparing data for Shiny App

#https://geocompr.robinlovelace.net/spatial-class.html <- additional reference
library(leaflet)
install.packages("spData")
library(spData)
devtools::install_github("Nowosad/spDataLarge")
library(spDataLarge)
library(leaflet)
library(maps)
library(ggplot2)

states$name
states <- map("state", fill = TRUE, plot = FALSE)
#linking the two 
mp_state <- mp1[as.character(state.fips$abb), -1]

#identify state names in states dataframe
states$names
#identify state names in missing persons dataset
row.names(mp1) <- mp1$State_Of_Last_Contact
#identify state codes in states dataframe
head(state.fips)
head(state.fips)

mp1$State_Of_Last_Contact

#linking the two 
mp_state <- mp1[as.character(state.fips$abb), -1]

library(dplyr)
library(plyr)
#dataframes for analyses
mp <- read.csv("mp1.csv")


mp_per_state <- count(mp, "State_Of_Last_Contact")
mp_per_county <- count(mp, "State_Of_Last_Contact", "County_Of_Last_Contact")
mp_per_city <- count(mp, "City_Of_Last_Contact")

head(state.fips)
count(df, "State_Of_Last_Contact")

colnames(mp_per_state)

summary(mp_per_state)

colnames(mp)
mp_per_state$namus2Number
row.names(df) <- data.frame(df$State_Of_Last_Contact)

colnames(mp)

dfnew5 <- count(df, "State_Of_Last_Contact", "County_Of_Last_Contact")



###problem areas###
#library(jsonlite)

#acquiring data from OpenDatasSoft API
#mp1 <- fromJSON("https://public.opendatasoft.com/api/records/1.0/search/?dataset=namus-missings&sort=modifieddatetime&facet=cityoflastcontact&facet=countydisplaynameoflastcontact&facet=raceethnicity&facet=statedisplaynameoflastcontact&facet=gender")

#updating maps to reflect appropriate north american projection to preserve distances in statistical models (World Azimuthal Equdistant)
#adjusting to set central meridian to center of united states (37.0902° N, 95.7129° W)
#reference - http://desktop.arcgis.com/en/arcmap/10.3/guide-books/map-projections/azimuthal-equidistant.htm

#library(mapproj)
#establishing new boundary with North America and appropriate projections

#us_territories <- st_read("US_States_all_PR.shp")
#transforming to conform to us territories CRS
#us_states_proj <- map("state", projection="azequalarea")

#us_states_proj1 <- st_transform(us_states_proj, crs=54032)

#proj_states <- st_as_sf(us_states_proj)

#st_crs(us_states_proj)
#class(us_states_proj)


#us_territories_sf1 <- st_as_sf(us_territories1)
#AoI.merge_sf1 <- st_sf(st_union(us_territories1))
#tm_shape(us_territories_sf1) + tm_borders(col = "darkgreen", lty = 3) + 
#tm_shape(AoI.merge_sf) + tm_borders(lwd = 1.5, col = "black") + 
#tm_layout(frame = F)

#class(us_territories_sf1)

#library(spData) 
#usa <- spData::us_states #map of contiguous United States
#colnames(usa)
#head(usa)
#st_crs(usa)
#plot(usa$geometry)
#head(usa$geometry,1)

#usa1 <- st_transform(usa, crs= "+proj=aeqd +lat_0=39.8 +lon_0=-98.5 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

#st_crs(usa1)

#plot(usa1$geometry)

#creating coordinate referece system (CRS) based on usa1 
#Verify application of EPSG code (crs)

#usa2 <- st_transform(usa, crs=4326)
#st_crs(usa2)

#class(usa)

#class(usa1)

#usa_sf <- st_as_sf(usa2)
#AoI.merge_sf <- st_sf(st_union(usa_sf))
#tm_shape(usa_sf) + tm_borders(col = "darkgreen", lty = 3) + 
  #tm_shape(AoI.merge_sf) + tm_borders(lwd = 1.5, col = "black") + 
  #tm_layout(frame = F)

#class(us_territories_sf1)

# plot Boundary
#plot(usa_sf$geometry,
     #main = "Missing Persons | CONUS")

# add plot locations

#plot(point_reference_mp1$geometry,
     #pch = 8, add = TRUE)






