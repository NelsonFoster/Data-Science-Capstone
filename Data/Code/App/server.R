#server.R
server <- function(input,output, session){
  
  data <- reactive({
    x <- df
  })
  
  output$mymap <- renderLeaflet({
    df <- data()
    
    m <- leaflet(data = df) %>%
      addTiles() %>%
      addMarkers(lng = ~Longitude,
                 lat = ~Latitude,
                 popup = paste("ID:", df$id_Formatted, "<br>",
                               "First Name:", df$First_Name, "<br>",
                               "Last Name:", df$Last_Name, "<br>",
                               "Date Missing:", df$Date_Of_Last_Contact,"<br>",
                               "City:", df$City_Of_Last_Contact, "<br>",
                               "County:", df$County_Of_Last_Contact, "<br>",
                               "State:", df$State_Of_Last_Contact,"<br>",
                               "Age:", df$Computed_Missing_Min_Age,"<br>",
                               "Gender:", df$Gender,"<br>",
                               "Race/Ethnicity:", df$Race_Ethnicity))
    
    m
    

  })
  
  data <- reactive({
    x <- df
  })
  
  output$mymap1 <- renderLeaflet({
    n <- leaflet(data=states_merged_mp) %>%
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
    
    n
    
    
  })
  
  
  data <- reactive({
    x <- df
  })
  
  output$mymap2 <- renderLeaflet({
    o <- leaflet(data=states_merged_mp_pc) %>%
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
    
    o
  })
}