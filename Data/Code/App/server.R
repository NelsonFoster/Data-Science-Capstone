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
                 popup = paste("Missing Person", df$id_Formatted, "<br>",
                               "Date Missing:", df$Date_Of_Last_Contact))
    m
  })
  
  
}