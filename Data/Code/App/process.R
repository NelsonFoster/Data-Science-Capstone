library(leaflet)
library(dplyr)
library(tidyr)
library(tidyverse)
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
