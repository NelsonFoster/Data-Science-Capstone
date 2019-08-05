
#library(jsonlite)

#acquiring data from OpenDatasSoft API
#mp1 <- fromJSON("https://public.opendatasoft.com/api/records/1.0/search/?dataset=namus-missings&sort=modifieddatetime&facet=cityoflastcontact&facet=countydisplaynameoflastcontact&facet=raceethnicity&facet=statedisplaynameoflastcontact&facet=gender")

#acquiring local file of data as a backup
#mp <-read.csv("namus-missings-1.csv") 

mp <- read.csv("namus-missings-1.csv")

mp1 <- na.omit(mp) #omit NAs
str(mp1)
str(mp)
#print(mp2$Lat, digits=10) #verifying import retained precision of Lat/lon

#Exploring the data
head(mp)
list(mp)
colnames(mp)
str(mp)

#reading in NAMUSshapefile
library(rgdal)
library(sf)
library(sf)
library(sp)
library(GISTools)

#Exploring the data
mp_shp <- st_read("namus-missings.shp")
head(mp_shp)
colnames(mp_shp)
str(mp_shp)


#removing missing coordinates (c(NaN, NaN))

#mp_shp2 = subset(mp_shp$geometry == "c(NaN, NaN)")

#generate csv file to convert to shp usint web utility
#https://mygeodata.cloud/converter/csv-to-shp
#write.csv(mp1, file = "mp1.csv")

#using converted files 

mp_shp1 <- st_read("mp1-point.shp")
summary()

df = subset(mp_shp1, select = -c(c.NA_character_..NA_character_..NA_character_..NA_character_..) )

#summary descriptive statistics
colnames(df)
summary(df)
summary(df$Gender)
summary(as.numeric(df$Computed_1))
summary(as.numeric(df$Computed_M))
summary(df$Gender)
summary(df$Race_Ethni)

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
