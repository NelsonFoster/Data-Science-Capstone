#process.R

#getwd() 
#setwd("/Users/nfoster06/Documents/GitHub/Data-Science-Capstone/Data/Code/App")

library(shiny)
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
library(data.table)
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
library(tmaptools)
library(maptools)
library(raster)

#defining state boundaries and obtaining census tract data (Large SpatialPolygonsDataFrame)
states <- states(cb=T)

saveRDS(states, "./states.rds")

#acquiring missing persons data
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
saveRDS(df, "./data.rds")

sample_data <- df
saveRDS(sample_data, "./sample_data.rds")

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

saveRDS(mp_state, "./mp_state.rds")
saveRDS(mp_race_ethnicity, "./mp_race_ethnicity.rds")

#creating spatial join

states_merged_mp <- geo_join(states, mp_state, "STUSPS", "State_Of_Last_Contact")
# Getting rid of rows with NA values using base R as other methods (subset) will not work large spatial data frames
states_merged_mp <- subset(states_merged_mp, !is.na(total))

saveRDS(states_merged_mp, "./states_merged_mp.rds")

# Creating a color palette based on the number range in the total column
pal <- colorNumeric("Blues", domain=states_merged_mp$total)
saveRDS(pal, "./pal.rds")

# Setting up the pop up text
popup_mp <- paste0("Total Missing Persons: ", as.character(states_merged_mp$total))
saveRDS(popup_mp, "./popup_mp.rds")

# Creating new map using census data to adjust for population density
#add Census API Key to R environment
# Add key to .Renviron
Sys.setenv(CENSUS_KEY="31fff949176a736010c1e360cacac97f81c300b8")
# Reload .Renviron
readRenviron("~/.Renviron")
# Check to see that the expected key is output in your R console
Sys.getenv("CENSUS_KEY")

#read in population data via Census API Key
state_pop <-  getCensus(name="acs/acs5", 
                        vintage=2015,
                        key=census_key, 
                        vars=c("NAME", "B01003_001E"), 
                        region="state:*")
# Cleaning up the column names
colnames(state_pop) <- c("state_id", "NAME", "population")
state_pop$state_id <- as.numeric(state_pop$state_id)
#numbers of fully spelled out, not abbreviations

saveRDS(state_pop, "./state_pop.rds")
#pulling in R's state abbreviations
state_off <- data.frame(state.abb, state.name)
#head(state_off)

#creating relational dataframe between states and state abbreviations
# Cleaning up the names for easier joining
colnames(state_off) <- c("state", "NAME")

# Joining state population dataframe to relationship file
state_pop <- left_join(state_pop, state_off)

saveRDS(state_off, "./state_off.rds")

# The relationship dataframe didnt have DC or Puerto Rico, so these must be imputted manually
state_pop$state <- ifelse(state_pop$NAME=="District of Columbia", "DC", as.character(state_pop$state))
state_pop$state <- ifelse(state_pop$NAME=="Puerto Rico", "PR", as.character(state_pop$state))
saveRDS(state_pop, "./state_pop.rds")
# Joining mp_state dataframe to adjusted state population dataframe
#changing colname for join

names(mp_state)[names(mp_state) == "State_Of_Last_Contact"] <- "state"

mp_state_pop <- left_join(mp_state, state_pop)
saveRDS(mp_state_pop, "./mp_state_pop.rds")

# calculating per capita missing persons (1 per 100,000 standard, rounded)
#reference - https://www.thebalance.com/per-capita-what-it-means-calculation-how-to-use-it-3305876

mp_state_pop$per_capita <- round(mp_state_pop$total/mp_state_pop$population*100000,2)
saveRDS(mp_state_pop, "./mp_state_pop.rds")
# Eliminating rows with NA
#mp_state_pop <- filter(mp_state_pop, !is.na(per_capita))
#head(mp_state_pop)

#creating new map with per capita values

states_merged_mp_pc <- geo_join(states, mp_state_pop, "STUSPS", "state")
saveRDS(states_merged_mp_pc, "./states_merged_mp_pc.rds")

pal_mp <- colorNumeric("Blues", domain=states_merged_mp_pc$per_capita)

states_merged_mp_pc <- subset(states_merged_mp_pc, !is.na(per_capita))
saveRDS(states_merged_mp_pc, "./states_merged_mp_pc.rds")
# new popup withs state-specific data reactive upon click
popup_mp <- paste0("<strong>", states_merged_mp_pc$NAME, 
                   "</strong><br />Total: ", states_merged_mp_pc$total,
                   "<br />Per capita: ", 
                   as.character(states_merged_mp_pc$per_capita))
#head(popup_mp)

saveRDS(pal_mp, "./pal_mp.rds")
saveRDS(popup_mp, "./popup_mp.rds")


