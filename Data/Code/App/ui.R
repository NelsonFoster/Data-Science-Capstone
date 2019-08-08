#ui.R
library(shiny)

ui <- fluidPage(
  
  # Page title
  titlePanel("Mapping the Missing | An Interactive Spatial Analysis Tool"),
  
  # Link to source data
  helpText( "Data Courtesy of "
            , a("The National Missing and Unidentified Persons System (Namus), Department of Justice", href = "https://www.namus.gov")
            , "."
  ),
  
  # Sidebar with controls
  sidebarLayout( sidebarPanel( selectInput( inputId = 'variable' 
                                            , label   = "Choose a variable"
                                            , choices = list()  # place holder!
  )
  )
  
  # Leaflet map
  , mainPanel( leafletOutput( outputId = 'map') )
  )
  
)

shinyApp(ui = ui, server = server)