
library(shiny)
library(shinydashboard)
library(jpeg)
library(shinyalert)
library(shinymaterial)
library(shinyjs)
library(V8)
library(reticulate)
require(keras)

# Set global variables
options(shiny.port = 8888)

options(shiny.host = "192.168.43.239")

shiny.maxRequestSize=1*1024^2

jsResetCode <- "shinyjs.reset = function() {history.go(0)}" 


#  
ui <- dashboardPage(

  dashboardHeader(title = "Hautanalyse"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Einführung", tabName = "einführung", icon = icon("book")),
      menuItem("Ausprobieren", tabName = "ausprobieren", icon = icon("search"), badgeLabel = "beta", badgeColor = "red"),
      menuItem("Informationen zu Errgebnissen", tabName = "informationen", icon = icon("file-alt"))
    )
  ),

 dashboardBody(
   useShinyalert(),
   shinyjs::useShinyjs(),
   extendShinyjs(text = jsResetCode), 
   
   
   #Tab Einführung
   tabItems(
     tabItem(tabName = "einführung",
             tags$head(tags$script('
                                var dimension = [0, 0];
                                   $(document).on("shiny:connected", function(e) {
                                   dimension[0] = window.innerWidth;
                                   dimension[1] = window.innerHeight;
                                   Shiny.onInputChange("dimension", dimension);
                                   });
                                   $(window).resize(function(e) {
                                   dimension[0] = window.innerWidth;
                                   dimension[1] = window.innerHeight;
                                   Shiny.onInputChange("dimension", dimension);
                                   });
                                   ')),
      useShinyalert(),
      fluidRow(
        valueBox("200.000", "Neuerkrankungen pro Jahr", color = "red", icon = icon("stethoscope")) ,
        valueBox("328 von 100.000", "Menschen erkranken jährlich", color = "red", icon = icon("chart-pie")),
        valueBox("38 von 100.000", "erkranken am gefährlichen maligne Melanom", color = "red", icon = icon("procedures"))
        
      ),
      fluidRow(
      valueBox("Früherkenung", "Ermöglicht meist erfolgreiche Behandlung", color = "green", icon = icon("child"), width = 12)),
      
      fluidRow(
      
      box(
        uiOutput("video")
       
        ),
      
      
      box(title = "Mit künstlicher Intelligenz zu mehr Gesundheit",
          column(6,
          p("Deshalb habe ich eine Allgorythmus entwickelt, welcher mit über 7.000 klinischen Bilden auf das Erkennen 
            von Hauterkrankungen trainiert wurde. In durch ein Validierungsverfahren mit über 2.000 klischen Bildern 
            konnte eine Genauigkeit von 75% erreicht werden. Die Wahrscheinlichkeit, dass das tatsächliche Ergebisse in
            den TOP-3 Vorhersagen liegt ist 95%. Es handelt sich hierbei jedoch nur um eine technische Demo, welche
            nicht für die Diagnose von Krankheiten geeignet ist. Sie sollten in jedem Fall die Meinung eines Fachartzes einholen.")
       ),
       column(6,
              fluidRow(
              img(src='bild.png', align = "right", width = "220px", height = "320px")),
         
              p("IMG: Creator Jochen Luithardt")
              )
        )
      
      )
      ),
     
   
   
   #Tab Ausprobieren

  tabItem(tabName = "ausprobieren",
           
   fluidRow(
     valueBoxOutput("first_pred"),
     valueBoxOutput("second_pred"),
     valueBoxOutput("thrid_pred")
    ),
   
   fluidRow(
     box(title = "Nutzerinformationen",
      textInput("alter", "Bitte geben Sie ihr Alter an:", ""),
      selectInput('geschlecht', 'Bitte wählen Sie ihr Geschlecht aus:', c("-- Bitte auswählen --", "männlich","weiblich", "divers")),
      selectInput('ort', 'Bitte wählen Sie den Ort der zu untersuchenden Stelle aus:', c("-- Bitte auswählen --", "Kopf","Hals", "Brust", "Rücken", "Unterleib", "Extrimitäten")),
      tabPanel("Bitte wählen das gewünschte Bild für die Analyse aus:", fileInput('file1', "Bitte wählen das gewünschte Bild für die Analyse aus:")),
      actionButton("start","Analyse starten")
     ),
     box(
       title = "Hochgeladenes Bild",
       imageOutput("img1")
     )
   )

   ),
  
   tabItem(tabName = "informationen",
          fluidPage(
            box(
              title = "BKL",
              p("Beschriebt die benigne Keratose. Es handelt sich hierbei um eine gutartige Hauterkrankung, welche aufgrund seiner physiologischen Ähnlichkeit mit Hautkrebs häufig mit ihm verwechselt wird. Diese Erkrankung bedarf für gewöhnlich keiner weiteren Behandlung.")
             
              
          ), valueBox("Erkrankung", subtitle = "Gutartig",color = "green", icon = icon("smile")) 
          ),
          
          fluidPage(
            box(
              title = "DF",
              p("Beschreibt ein Dermatofibrom. Hierbei handelt es sich um eine gutartige Hautläsion. Ein Dermatofibrom ist entweder eine gutartige Proliferation oder eine entzündliche Reaktion auf ein minimales Trauma.")
              
              
            ), valueBox("Erkrankung",subtitle = "Gutartig", color = "green", icon = icon("smile")) 
          ),
          
          fluidPage(
            box(
              title = "NV",
              p("Beschreibt eine melanozytäre Nävi. Hierbei handelt es sich für gewöhnlich um gutartige Neoplasien von Melanozyten, bzw. Pigmentflecken. Im Volksmund werden sie häufig als Leberflecke oder Muttermale beschrieben. Eine hohe Anzahl der melanozytäre Nävi am gesamten Körper wird jedoch mit erhöhtem Hautkrebsrisiko in Verbindung gebracht.")
              
              
            ), valueBox("Erkrankung", subtitle = "Gutartig",color = "green", icon = icon("smile")) 
          ),
          
          fluidPage(
            box(
              title = "VASC",
              p("Beschriebt Vaskuläre Hautläsionen. Hierbei handelt es sich um eine gutartige Wucherungen oder Fehlbildung der Gefäße in oder unter der Haut, die rote oder purpurne Hautverfärbungen verursachen. Behandlung hängt vom Typ der vorliegenden Wucherung ab.")
              
              
            ), valueBox("Erkrankung", subtitle = "Gewöhnlich gutartig",color = "yellow", icon = icon("meh")) 
          ),
          
          fluidPage(
            box(
              title = "AKIEC",
              p("Beschriebt eine aktinische Keratose oder ein intraepitheliales Karzinom. Diese beiden Formen der Hauterkrankung können sich langfristig zu einem bösartigen Plattenepithelkarzinom entwickeln. Diese beide Vorstufen des Plattenepithelkarzinom entstehen für gewöhnlich durch UV-Strahlung, wie sie im Sonnenlicht enthalten ist. In selten Fällen eine Infektion mit dem humanen Papillomavirus zu einer Erkrankung führen. Zuletzt es besteht die Möglichkeit derartige Erkrankungen lokal ohne Operation zu behandeln.")
              
              
            ), valueBox("Erkrankung",subtitle = "Evtl. Vorstufe eines Tumors",color = "yellow", icon = icon("meh")) 
          ),
          
          fluidPage(
            box(
              title = "BCC",
              p("Beschreibt ein Basalzellkarzinom. Hierbei handelt es sich um eine bösartige Form des Hautkrebses der auch als „weißer“ Hautkrebs bezeichnet. Dieser bildet zwar nur selten Metastasen, führt jedoch bei unbehandelten Fällen zu destruktivem Wachstum.")
              
            ), valueBox("Erkrankung", subtitle = "Bösartig",color = "red", icon = icon("frown")) 
          ),
          
          fluidPage(
            box(
              title = "MEL",
              p("Beschreibt ein Melanom. Hierbei handelt es sich um einen hochgradig bösartigen Hautkrebs. Er kennzeichnet sich durch eine frühe Metastahen bildung. Die auch als „schwarzer“ Hautkrebs bezeichnete Erkrankung ist die am häufigsten tödlich verlaufende Hautkrankheit. Wenn sie zu einem frühen Zeitpunkt erkannt wird, kann sie durch einfache chirurgische Entfernung geheilt werden.")
              
            ), valueBox("Erkrankung", subtitle = "Bösartig",color = "red", icon = icon("frown")) 
          )
           
   )))
 )

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  model_cancer <- keras::load_model_hdf5("model_cancer.hdf5")
  
  output$video <- renderUI({
  
    e <- paste0('<iframe id="app" src="https://www.youtube.com/embed/9Y0tQVQg4v8" width="',input$dimension[1] - 800,'" height="', input$dimension[2] -500, '" frameborder="0" allowfullscreen></iframe>')

    HTML(e)
  })
  
  
  output$img1 <- renderImage({
    
    
    width  <- session$clientData$output_img1_width
    height <- session$clientData$output_img1_height
    
    # Return a list containing the filename and alt text
    list(src = "www/beispiel.jpg",
         width = width,
         height = height)
    
  }, deleteFile = FALSE)
  
  values <- reactiveValues(
    upload_state = 1
  )
  
  print(lobstr::mem_used())
  
  shinyalert(
    title = "Log in",
    text = "Haftungsausschluss: Es handelt sich bei dieser Webanwendung um die technische Demontration,
eines Klassifikationsverfahren von Bilder der Haut. Es besteht keinerlei diagnostische Validität des Verfahrens. Sollten Sie sich 
bezüglich bestimmter Hautmerkmale unsicher fühlen, suchen Sie in jedem Fall einen Fachartzt auf.
    In dem Sie Ihr Zugangspasswort eingeben bestätigen Sie, dass Sie den Haftungsausschluss zur Kenntniss genommen haben. \n
Passwort 
    ",
    type = "input",
    closeOnEsc = F,
    closeOnClickOutside = F,
    showCancelButton = F,
    showConfirmButton = T,
    inputType = "password",
    inputPlaceholder = "Zugangspasswort",
    inputValue = "",
    confirmButtonCol = "#26a69a"
  )
  
  observeEvent(input$shinyalert, {
 
    if (input$shinyalert == "Haut_AI_2019") {
      # If user successfully authenticated.
      print("successfully authenticated")
      showNotification("Sie wurden erfolgreich eingeloggt!")
      withProgress(message = "Analysemodell wird geladen...", value = 0, {
        # Number of times we'll go through the loop
        n <- 100
        
        for (i in 1:n) {
          
          incProgress(1/n, detail = paste0(i, "%"))
          

          # Pause for 0.1 seconds to simulate a long computation.
          Sys.sleep(0.05)
          
          
        }
        showNotification("Analysemodell wurde erfolgreich geladen!")
        
      })

    } else {
      # Bad password.
      
      showNotification("Falsches Passwort!", type = "error")
      Sys.sleep(0.1)
      
      js$reset()
      print("Bad password")
    }
  })
  
  
  
  
  output$first_pred <- renderValueBox({
    valueBox("- %", 
             "Ergebnis der Analyse", 
             icon = icon("table"), 
             color = "light-blue")
    
  })
  
  output$second_pred <- renderValueBox({
    valueBox("- %", 
             "Ergebnis der Analyse", 
             icon = icon("table"), 
             color = "light-blue")
    
  })
  
  output$thrid_pred <- renderValueBox({
    valueBox("- %", 
             "Ergebnis der Analyse", 
             icon = icon("table"), 
             color = "light-blue")
    
    
  })

  observeEvent(input$file1, {
    values$upload_state <- 2
  })
  
  observeEvent(input$start, {
    print("model pre")
    print(lobstr::mem_used())

    print(lobstr::mem_used())
    
    print(values$upload_state)
    
    if(input$alter == ""| input$geschlecht == "-- Bitte auswählen --" |
       input$ort == "-- Bitte auswählen --" |  values$upload_state == 1){
      
      showNotification("Bitte füllen Sie alle Felder (Alter, Geschlecht, Ort) aus und Laden das gewünschte Bild hoch.",
                 type = "warning", duration = 1)
      
    }else  {
      

  
    
    showNotification("Analyse beginnt!", duration = 1.5)
 
    re1 <- reactive({gsub("\\\\", "/", input$file1$datapath)})
    
    print(input$file1$datapath)

    # Send a pre-rendered image, and don't delete the image after sending it
    output$img1 <- renderImage({
      
      
      width  <- session$clientData$output_img1_width
      height <- session$clientData$output_img1_height
      
      # Return a list containing the filename and alt text
      list(src = re1(),
           width = width,
           height = height)
      
    }, deleteFile = FALSE)
    
    
    ## Predict
    print("Transform Image")
    
    img <- image_load(re1(), target_size = c(150, 150))
    x <- image_to_array(img)
    x <- array_reshape(x, dim = c(1, 150, 150, 3))
    
    x <- x / 255
    
    print(lobstr::mem_used())
    print("Start Prediction")
    prediction <- data.frame(keras::predict_proba(model_cancer, x))
    colnames(prediction) <- c("AKIEC", "BCC", "BKL", "DF", "MEL", "NV", "VASC")
    good_bad <- c("meh", "frown", "smile", "smile", "frown", "smile", "meh")
    good_bad_col <- c("yellow", "red", "green", "green", "red", "green", "yellow")
    top_3 <- sort(prediction, decreasing = T) 
    

    print("Display Prediction")
    #Display

    output$first_pred <- renderValueBox({
      valueBox(paste0(names(top_3[1]), ": ", round(top_3 [1] * 100,2), "%") , 
               "Ergebnis der Analyse", 
               icon = icon(good_bad [which(colnames(prediction) == names(top_3[1]))]), 
               color = good_bad_col [which(colnames(prediction) == names(top_3[1]))])
      
    })
    
    output$second_pred <- renderValueBox({
      valueBox(paste0(names(top_3[2]), ": ", round(top_3 [2] * 100,2), "%") , 
               "Ergebnis der Analyse", 
               icon = icon(good_bad [which(colnames(prediction) == names(top_3[2]))]), 
               color = good_bad_col [which(colnames(prediction) == names(top_3[2]))])
      
    })
    
    output$thrid_pred <- renderValueBox({
      valueBox(paste0(names(top_3[3]), ": ", round(top_3 [2] * 100,2), "%") , 
               "Ergebnis der Analyse", 
               icon = icon(good_bad [which(colnames(prediction) == names(top_3[3]))]), 
               color = good_bad_col [which(colnames(prediction) == names(top_3[3]))])
      
    })
    
    
    }
    
  })

  
}
options(shiny.host = '0.0.0.0')
options(shiny.port = 8888)

# Run the application 
shinyApp(ui = ui, server = server)

