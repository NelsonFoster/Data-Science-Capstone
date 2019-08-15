#ui.R

ui <- fluidPage(
  #Title
  titlePanel("Mapping the Missing | An Interactive Spatial Analysis Tool"),
  helpText( "Source data provided by the "
            , a("The National Missing and Unidentified Persons System (Namus), Department of Justice", href = "https://www.namus.gov")
            , "."
  
  )
  
  # Leaflet map
  
  ,navbarPage(title = "Maps of Missing Persons",
             tabPanel("Point Map", mainPanel( leafletOutput("mymap",height = 1000) )
             ),
             tabPanel("Population Map", mainPanel( leafletOutput("mymap1",height = 1000)) 
             ),
             tabPanel("Per Capita Map", mainPanel( leafletOutput("mymap2",height = 1000))
  )
  )
)

  
  

 
  
  
