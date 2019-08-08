#getwd() 
#setwd("/Users/nfoster06/Documents/GitHub/Data-Science-Capstone/Data/Code/App")

library(leaflet)
library(dplyr)
library(tidyr)
library(tidyverse)
library(maps)
library(GISTools)
library(tmap)
library(raster)
library(spatstat)
library(rgdal)
library(sf)
library(sp)
library(data.table)

#data(tornados) 

#process.R

df = read.csv("./mp_points.csv", stringsAsFactors = F)


df <- tidyr::separate(data=df,
                      col=geo_point_2d,
                      into=c("Latitude", "Longitude"),
                      sep=",",
                      remove=FALSE)

df$Latitude <- stringr::str_replace_all(df$Latitude, "[(]", "")
df$Longitude <- stringr::str_replace_all(df$Longitude, "[)]", "")


df$Latitude <- as.numeric(df$Latitude)
df$Longitude <- as.numeric(df$Longitude)
saveRDS(df, "./data.rds")


sample_data <- df
saveRDS(sample_data, "./sample_data.rds")

#additional variables
date_missing <- as.Date(df$Date_Of_Last_Contact)




