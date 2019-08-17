#references for basemap and spatial join methods using leaflet.js:
#https://learn.r-journalism.com/en/mapping/census_maps/census-maps/
#https://www.datascience.com/blog/beginners-guide-to-shiny-and-leaflet-for-interactive-mapping

library(shiny)
library(leaflet)
library(dplyr)
library(tidyr)
library(tidyverse)
library(tidycensus)
library(tigris)
options(tigris_use_cache = TRUE)
library(sf)
library(sp)
library(censusapi)
library(rgdal)
library(KernSmooth)
library(spatstat)
library(spdep)
library(GISTools)
library(tmap)
library(tmaptools)
library(maptools)
library(data.table)
library(raster)
library(ggplot2)
library(reshape2)
library(rgeos)


#defining state boundaries and obtaining census tract data (Large SpatialPolygonsDataFrame)
states <- states(cb=T)

#plotting using embedded dplyr pipes functionality in R
states %>% 
  leaflet() %>% 
  addTiles() %>% 
  addPolygons(popup=~NAME)

#plot(df_shp$geometry, pch = 20, col = "steelblue")
#plot(states$geometry, pch = 20, col = "grey")

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

#updating Race & Ethnicity categories for "cleaner" aggregaions
#to be used in hypothesis testing later (reference: https://nces.ed.gov/statprog/2002/std1_5.asp)

df$Race_Ethnicity[df$Race_Ethnicity=="Black / African American;Hispanic / Latino"] <- "Black / African American"
df$Race_Ethnicity[df$Race_Ethnicity=="Black / African American;White / Caucasian"] <- "Black / African American"
df$Race_Ethnicity[df$Race_Ethnicity=="Hispanic / Latino;Asian"] <- "Hispanic / Latino"
df$Race_Ethnicity[df$Race_Ethnicity=="Hispanic / Latino;Native American / Alaskan Native"] <- "Hispanic / Latino"
df$Race_Ethnicity[df$Race_Ethnicity=="Hispanic / Latino;Uncertain"] <- "Hispanic / Latino"
df$Race_Ethnicity[df$Race_Ethnicity=="Other"] <- "Other/Uncertain"
df$Race_Ethnicity[df$Race_Ethnicity=="Uncertain"] <- "Other/Uncertain"
df$Race_Ethnicity[df$Race_Ethnicity=="White / Caucasian;Black / African American"] <- "White / Caucasian"
df$Race_Ethnicity[df$Race_Ethnicity=="White / Caucasian;Hispanic / Latino"] <- "White / Caucasian"
df$Race_Ethnicity[df$Race_Ethnicity=="White / Caucasian;Uncertain"] <- "White / Caucasian"


#summarize - Count Missing Persons by State with dplyr

mp_state <- df %>%
  group_by(State_Of_Last_Contact) %>%
  summarize(total=n()) %>%
  mutate(type = "Missing Persons")

#summarize - Count Missing Persons by race/ethnicity with dplyr

mp_race_ethnicity <- df %>%
  group_by(Race_Ethnicity) %>%
  summarize(total=n()) %>%
  mutate(type = "Race/Ethnicity")

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
  setView(-98.483330, 38.712046, zoom = 4) %>% #geographic center of the United States
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

# Creating new map using census data to adjust for population density
#add Census API Key to R environment
# Add key to .Renviron
Sys.setenv(CENSUS_KEY="31fff949176a736010c1e360cacac97f81c300b8")
# Reload .Renviron
readRenviron("~/.Renviron")
# Check to see that the expected key is output in your R console
Sys.getenv("CENSUS_KEY")

#view list of APIs available
#apis <- listCensusApis()
#View(apis)

census_key <- ("31fff949176a736010c1e360cacac97f81c300b8")

#read in population data via Census API Key
state_pop <-  getCensus(name="acs/acs5", 
                        vintage=2015,
                        key=census_key, 
                        vars=c("NAME", "B01003_001E"), 
                        region="state:*")

# Cleaning up the column names
colnames(state_pop) <- c("state_id", "NAME", "population")
state_pop$state_id <- as.numeric(state_pop$state_id)
# Hm, data comes in numbers of fully spelled out, not abbreviations

#pulling in R's state abbreviations
state_off <- data.frame(state.abb, state.name)
#head(state_off)

#creating relational dataframe between states and state abbreviations
# Cleaning up the names for easier joining
colnames(state_off) <- c("state", "NAME")

# Joining state population dataframe to relationship file
state_pop <- left_join(state_pop, state_off)

# The relationship dataframe didnt have DC or Puerto Rico, so these must be imputted manually
state_pop$state <- ifelse(state_pop$NAME=="District of Columbia", "DC", as.character(state_pop$state))
state_pop$state <- ifelse(state_pop$NAME=="Puerto Rico", "PR", as.character(state_pop$state))

# Joining mp_state dataframe to adjusted state population dataframe
#changing colname for join

names(mp_state)[names(mp_state) == "State_Of_Last_Contact"] <- "state"

mp_state_pop <- left_join(mp_state, state_pop)

# calculating per capita missing persons (1 per 100,000 standard, rounded)
#reference - https://www.thebalance.com/per-capita-what-it-means-calculation-how-to-use-it-3305876

mp_state_pop$per_capita <- round(mp_state_pop$total/mp_state_pop$population*100000,2)

# Eliminating rows with NA
#mp_state_pop <- filter(mp_state_pop, !is.na(per_capita))
#head(mp_state_pop)

#creating new map with per capita values

states_merged_mp_pc <- geo_join(states, mp_state_pop, "STUSPS", "state")

pal_mp <- colorNumeric("Blues", domain=states_merged_mp_pc$per_capita)
states_merged_mp_pc <- subset(states_merged_mp_pc, !is.na(per_capita))

# new popup withs state-specific data reactive upon click
popup_mp <- paste0("<strong>", states_merged_mp_pc$NAME, 
                   "</strong><br />Total: ", states_merged_mp_pc$total,
                   "<br />Per capita: ", 
                   as.character(states_merged_mp_pc$per_capita))
#head(popup_mp)

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(-98.483330, 38.712046, zoom = 4) %>% 
  addPolygons(data = states_merged_mp_pc , 
              fillColor = ~pal_mp(states_merged_mp_pc$per_capita), 
              fillOpacity = 0.9, 
              weight = 0.2, 
              smoothFactor = 0.2, 
              popup = ~popup_mp) %>%
  addLegend(pal = pal_mp, 
            values = states_merged_mp_pc$per_capita, 
            position = "bottomright", 
            title = "Missing Persons<br />per 100,000<br/>residents")



#implementing spatial analyses 

#working with sf formats to create spatial polygons data frame

#reading in previously generated shapefile from csv
df_points <- st_read("df_points.shp")

#verify proper sf format and Coordinate Reference System (CRS)
class(df_points)
st_crs(df_points)

#updating Race & Ethnicity categories in df_points for "cleaner" aggregaions
#to be used in hypothesis testing later (reference: https://nces.ed.gov/statprog/2002/std1_5.asp)

df_points$Rc_Et[df_points$Rc_Et=="Black / African American;Hispanic / Latino"] <- "Black / African American"
df_points$Rc_Et[df_points$Rc_Et=="Black / African American;White / Caucasian"] <- "Black / African American"
df_points$Rc_Et[df_points$Rc_Et=="Hispanic / Latino;Asian"] <- "Hispanic / Latino"
df_points$Rc_Et[df_points$Rc_Et=="Hispanic / Latino;Native American / Alaskan Native"] <- "Hispanic / Latino"
df_points$Rc_Et[df_points$Rc_Et=="Hispanic / Latino;Uncertain"] <- "Hispanic / Latino"
df_points$Rc_Et[df_points$Rc_Et=="Other"] <- "Other/Uncertain"
df_points$Rc_Et[df_points$Rc_Et=="Uncertain"] <- "Other/Uncertain"
df_points$Rc_Et[df_points$Rc_Et=="White / Caucasian;Black / African American"] <- "White / Caucasian"
df_points$Rc_Et[df_points$Rc_Et=="White / Caucasian;Hispanic / Latino"] <- "White / Caucasian"
df_points$Rc_Et[df_points$Rc_Et=="White / Caucasian;Uncertain"] <- "White / Caucasian"


#displaying Quick Thematic Map (QTM) using tmap

qtm(states_merged_mp_pc, fill = "blue", style = "natural")

#total missing persons
qtm(states_merged_mp_pc, fill="total", text="state", text.size=0.5, 
    format="World_wide", style="classic", 
    text.root=5, fill.title="Total Missing Persons")

#per capita missing persons
qtm(states_merged_mp_pc, fill="per_capita", text="state", text.size=0.5, 
    format="World_wide", style="classic", 
    text.root=5, fill.title="Total Missing Persons")

#creating tmap with histogram
tm_shape(states_merged_mp_pc) +
  tm_polygons("per_capita", title = "Missing Persons Per Capita", palette = "GnBu", 
              breaks = c(0, round(quantileCuts(states_merged_mp_pc$per_capita, 6), 1)), 
              legend.hist = T) +
  tm_scale_bar(width = 0.02) +
  tm_compass(position = c(0.01, 0.01)) +
  tm_layout(frame = F, title = "United States", 
            title.size = 0.25, title.position = c(0.25, "top"), 
            legend.hist.size = 0.25)

tmap_mode("view")
tm_shape(df_points) +
  tm_dots(size = 0.5, shape = 19, col = "blue", alpha = 0.5)



#summary statistics
ggplot(states_merged_mp_pc@data, aes(total)) +
  geom_histogram(col = "salmon", fill = "cyan", bins = 52) +
  xlab("Number of Missing persions") +
  labs(title = "Distribution of Missing Persons - Total")

ggplot(states_merged_mp_pc@data, aes(per_capita)) +
  geom_histogram(col = "salmon", fill = "cyan", bins = 52) +
  xlab("Per Capita Missing persions") +
  labs(title = "Distribution of Missing Persions - Per Capita")



ggplot(states_merged_mp@data, aes()) +
  geom_histogram(col = "salmon", fill = "cyan", bins = 52) +
  xlab("Number of Missing persions") +
  labs(title = "Distribution of Missing persions")

#kernel Density Estimation

#initial map of missing persons incidences per state

tmap_mode('view')
#tmap mode set to interactive viewing
tm_shape(states_merged_mp_pc) + tm_borders() + tm_shape(df_points) +
  tm_dots(col='navyblue')

#choosing bandwidth using Bowman & Azzalini / Scott Rule

choose_bw <- function(spdf) {
  X <- coordinates(spdf)
  sigma <- c(sd(X[, 1]), sd(X[,2])) * (2 / (3 * nrow(X)) ^ (1/6))
  return(sigma/1000)
}


#reprojection to common CRS:  

#choosing World Azimuthal Equal Area - North Amaerica to Preserve Distances
#European Petroleum Survey Group (EPSG) Spatial Reference System Identifier (SRID) code 54032
#references https://epsg.io/54032, http://desktop.arcgis.com/en/arcmap/10.3/guide-books/map-projections/azimuthal-equidistant.htm
#http://desktop.arcgis.com/en/arcmap/10.3/manage-data/using-sql-with-gdbs/what-is-an-srid.htm

df_points_transform <- st_transform(df_points,"+proj=aeqd +lat_0=38.7 +lon_0=-98.5 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

                                      

states_merged_mp_pc_transform <- spTransform(states_merged_mp_pc, CRS("+proj=aeqd +lat_0=38.7 +lon_0=-98.5 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))

#states_merged_mp_pc_transform <- gSimplify(states_merged_mp_pc_transform, tol = 0.00001)
#states_merged_mp_pc_transform <- spTransform(states_merged_mp_pc, CRS("+proj=aeqd +lat_0=0 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"))

#germG <- spTransform(mapG, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
#plotting densities 

tmap_mode("view")

mp_dens <- smooth_map(df_points_transform, cover=states_merged_mp_pc_transform, choose_bw(df_points_transform))
tm_shape(mp_dens$raster) + tm_raster()


#using isolines

tm_shape(states_merged_mp_pc_transform) + tm_borders(alpha=0.5) +
  tm_shape(mp_dens$iso) + tm_lines(col='darkred', lwd=2)



