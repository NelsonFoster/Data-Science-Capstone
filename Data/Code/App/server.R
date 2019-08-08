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
  
  
}