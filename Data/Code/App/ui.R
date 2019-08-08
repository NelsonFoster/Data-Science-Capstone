#ui.R

ui <- fluidPage(
  #Title
  titlePanel("Mapping the Missing | An Interactive Spatial Analysis Tool"),
  helpText( "Source data provided by the "
            , a("The National Missing and Unidentified Persons System (Namus), Department of Justice", href = "https://www.namus.gov")
            , "."
  ),

  sidebarLayout( sidebarPanel( selectInput( inputId = 'variable' 
                                            , label   = "Choose a State"
                                            , choices = colnames(df$State_Of_Last_Contact)
  )
  )
  
  # Leaflet map
  , mainPanel( leafletOutput("mymap",height = 1000) )
  )
  
)
  

  
