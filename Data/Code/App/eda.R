
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

mp_shp1 <- st_read("mp1-point.shp")
#summary()
#dropping conversion-generated column
mp_shp2 = subset(mp_shp1, select = -c(c.NA_character_..NA_character_..NA_character_..NA_character_..) )

# identify Coordinate Reference System (CRS)
st_crs(mp_shp2)
# view extent
st_bbox(mp_shp2)

#Creating CRS Object
utm18nCRS <- st_crs(mp_shp2)
utm18nCRS

class(utm18nCRS)

#converting csv dataframe to sf object
point_reference_mp <- st_as_sf(mp1, coords = c("Lat", "Lon"), crs = utm18nCRS)
st_crs(point_reference_mp)
# plot spatial object
plot(point_reference_mp$geometry,
     main = "Map of Plot Locations")

# create boundary object
boundary_mp <- mp_shp2

# plot Boundary
plot(boundary_mp$geometry,
     main = "Missing Persions - NamUS")

# add plot locations
plot(point_reference_mp$geometry,
     pch = 8, add = TRUE)
# view CRS of each
st_crs(boundary_mp)
st_crs(point_reference_mp)

# View extent of each

st_bbox(boundary_mp)
st_bbox(point_reference_mp)

#export new shapefile for future use

# write a shapefile
st_write(point_reference_mp,
         "point_reference_mp.shp", driver = "ESRI Shapefile")

#summary descriptive statistics
#colnames(df)
#summary(df)
#summary(df$Gender)
#summary(as.numeric(df$Computed_1))
#summary(as.numeric(df$Computed_M))
#summary(df$Gender)
#summary(df$Race_Ethni)

#Creating sf data frames for spatial analysis

library(raster)
library(tmap)

mp_sf <- st_as_sf(df)
qtm(df, fill = "blue", style = "natural")

#create dataframe with just geometries

#geo_shape <- data.frame(mp_sf$geometry)

#create dataframe with just thematic data

#geo_themes = subset(mp_sf, select = -c(geometry) )

#df = subset(mydata, select = -c(x,z) )

class(mp_sf)
data.frame(mp_sf)

head(data.frame(mp_sf))

#creating dataframes for spatial analyses

st_as_sf(geo_shape)
summary(geo_shape)

race_ethnicity <-data.frame(mp_sf$Race_Ethni)



summary(race_ethnicity)
class(race_ethnicity)

#ensure it is a data frame
class(mp_sf)

mp_sf_v2 <-as(mp_sf, "Spatial")
class(mp_sf_v2)

#https://geocompr.robinlovelace.net/spatial-class.html <- additional reference
library(leaflet)
install.packages("spData")
library(spData)
devtools::install_github("Nowosad/spDataLarge")
library(spDataLarge)
library(leaflet)

basemap <- tm_shape(World$continent)
colnames(basemap)
str(basemap)

tm_shape(basemap) +
  tm_polygons("df")
library(mapdeck)


plot(mp_sf$namus2Numb)
