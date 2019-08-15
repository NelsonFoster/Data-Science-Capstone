#global.R

library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)

df <- readRDS("./sample_data.rds")
mp_state <- readRDS("./mp_state.rds")
mp_race_ethnicity <- readRDS("./mp_race_ethnicity.rds")
states_merged_mp <- readRDS("./states_merged_mp.rds")
popup_mp <- readRDS("./popup_mp.rds")
state_pop <- readRDS("./state_pop.rds")
pal  <- readRDS("./pal.rds")
popup_mp  <- readRDS("./popup_mp.rds")
state_off  <- readRDS("./state_off.rds")
states_merged_mp_pc <- readRDS("./states_merged_mp_pc.rds")
pal_mp <- readRDS("./pal_mp.rds")

