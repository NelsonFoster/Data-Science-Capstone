
library(jsonlite)

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
library(GISTools)

#Exploring the data
mp_shp <- st_read("namus-missings.shp")
head(mp_shp)
colnames(mp_shp)
str(mp_shp)
#dropping NA records
mp_shp1 <- na.omit(mp_shp) 

#veriying data is an sf data frame and colnames are intact
class(mp_shp1)
colnames(mp_shp1)

library(tmap)
library(rgdal)
library(raster)

#removing missing coordinates (c(NaN, NaN))

#mp_shp2 = subset(mp_shp$geometry == "c(NaN, NaN)")

#generate csv file to convert to shp usint web utility
#https://mygeodata.cloud/converter/csv-to-shp
#write.csv(mp1, file = "mp1.csv")

library(raster)
library(sf)
library(sp)
library(rgdal)

class(mp1)

#using converted files 

mp_shp2 <- st_read("mp1-point.shp",
                   stringsAsFactors=FALSE)

df = subset(mp_shp2, select = -c(c.NA_character_..NA_character_..NA_character_..NA_character_..) )


#summary descriptive statistics


summary(mp$Computed_Missing_Min_Age)
class(df$Computed_1)
class(mp$Computed_Missing_Max_Age)
class(df$Computed_M)
summary(as.numeric(df$Computed_M))
summary(as.factor(df$Gender))
#Creating sf data frames 

