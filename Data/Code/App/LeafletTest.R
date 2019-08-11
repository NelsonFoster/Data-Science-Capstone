#references for basemap and spatial join methods using leaflet.js:
#https://learn.r-journalism.com/en/mapping/census_maps/census-maps/
#https://www.datascience.com/blog/beginners-guide-to-shiny-and-leaflet-for-interactive-mapping

library(shiny)
library(leaflet)
library(dplyr)
library(tidyr)
library(tidyverse)
library(tigris)
options(tigris_use_cache = TRUE)
library(sf)
library(sp)

#defining state boundaries and obtaining census tract data (Large SpatialPolygonsDataFrame)
states <- states(cb=T)

#plotting using embedded dplyr pipes functionality in R
#states %>% 
  leaflet() %>% 
  addTiles() %>% 
  addPolygons(popup=~NAME)

plot(df_shp$geometry, pch = 20, col = "steelblue")
plot(usa$geometry, pch = 20, col = "grey")

#reading in point data 
df = read.csv("./mp_points.csv", stringsAsFactors = F)

#formatting to split GeoPoint column into Lon/lat and formatting for Leaflet 
df <- tidyr::separate(data=df,
                      col=geo_point_2d,
                      into=c("Latitude", "Longitude"),
                      sep=",",
                      remove=FALSE)
df$Latitude <- stringr::str_replace_all(df$Latitude, "[(]", "")
df$Longitude <- stringr::str_replace_all(df$Longitude, "[)]", "")
df$Latitude <- as.numeric(df$Latitude)
df$Longitude <- as.numeric(df$Longitude)

#summarize - Count Missing Persons by State with dplyr

mp_state <- df %>%
  group_by(State_Of_Last_Contact) %>%
  summarize(total=n()) %>%
  mutate(type = "Missing Persons")

#transforming to correct Coordinate Reference System (CRS)
#mp_state <- st_as_sf(mp_state)
#mp_state <-st_transform(mp_state, crs= 4326)

#creating spatial join

states_merged_mp <- geo_join(states, mp_state, "STUSPS", "State_Of_Last_Contact")

# Creating a color palette based on the number range in the total column
pal <- colorNumeric("Blues", domain=states_merged_mp$total)

# Getting rid of rows with NA values using base R as other methods (subset) will not work large spatial data frames

states_merged_mp <- subset(states_merged_mp, !is.na(total))

# Setting up the pop up text
popup_mp <- paste0("Total Missing Persons: ", as.character(states_merged_mp$total))

# Mapping using CartoDB.Positron basemap
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  setView(-98.5795, 39.8283, zoom = 4) %>% #geographic center of the United States
  addPolygons(data = states_merged_mp , 
              fillColor = ~pal(states_merged_mp$total), 
              fillOpacity = 0.7, 
              weight = 0.2, 
              smoothFactor = 0.2, 
              popup = ~popup_mp) %>%
  addLegend(pal = pal, 
            values = states_merged_mp$total, 
            position = "bottomright", 
            title = "Missing Persons in the United States")

