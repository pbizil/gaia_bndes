library(shiny)
library(shinydashboard)
library(leaflet)
library(leaflet.extras)
library(rgdal)
library(sp)
library(raster)
library(readxl)
library(dplyr)
library(rjson)
library(readr)

### emissao de carbono

ep_mon_carbono_local <- read_excel("data/ep_mon_carbono_local.xlsx")
mon_carb_local <- ep_mon_carbono_local[, c("razao_social", "mun_uf", "latitude", "longitude", "quant")] %>% group_by(razao_social, mun_uf, latitude, longitude) %>% summarise(mean_quant = mean(quant))
colnames(mon_carb_local) <- c("razao_social", "municipio", "lat", "lng", "quant")
mon_carb_local <- mon_carb_local %>% group_by(municipio, lat, lng) %>% summarise(sum_quant = sum(quant))

#range01 <- function(x){(x-min(x))/(max(x)-min(x))}
#mon_carb_local$quant <- range01(mon_carb_local$quant)

### incendios 

incendios_local <- read_csv("data/incendios_local.csv")

### acidentes ambientais 

acidentes_amb_local <- read_csv("data/acidentes_amb_local.csv")


### operacoes indiretas

op_indiretas_locais <- read_csv("data/op_indiretas_locais.csv")
ops <- op_indiretas_locais  %>% group_by(municipio, uf, latitude, longitude, cpf_cnpj) %>% summarise(count = n(), sum = sum(valor_da_operacao_em_reais))
ops <- ops %>% group_by(municipio, uf, latitude, longitude) %>% summarise(count = n(), sum = sum(sum))

R --version

ui <- dashboardPage(skin = "green",
  dashboardHeader(title = "GAIA"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        "Sobre o projeto", 
        tabName = "sobre", 
        icon = icon("project-diagram")
      ),
      menuItem(
        "Emissão de carbono", 
        tabName = "carbono", 
        icon = icon("globe"),
        menuSubItem("Dash", tabName = "chart_carbono", icon = icon("dashboard")),
        menuSubItem("Mapa", tabName = "map_carbono", icon = icon("map"))
      ),
      menuItem(
        "Ocorrências ambientais", 
        tabName = "ocorrencias", 
        icon = icon("envira"),
        menuSubItem("Dash", tabName = "chart_ocorrencias", icon = icon("dashboard")),
        menuSubItem("Mapa", tabName = "map_ocorrencias", icon = icon("map"))
      )
  )),
  dashboardBody(
    tabItems(tabItem(tabName = "sobre", imageOutput("logo", height = 80)),
    tabItem(tabName = "chart_carbono"),
    tabItem(tabName = "map_carbono",
      leafletOutput("map_carbono", height=1000)),
    tabItem(tabName = "chart_ocorrencias"),
    tabItem(tabName = "map_ocorrencias",
            leafletOutput("map_ocorrencias", height=1000)))
    )
  )


server <- function(input, output, session) {
  output$map_carbono <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(data = mon_carb_local, stroke = FALSE, fillOpacity = 0.8,
                       clusterOptions = markerClusterOptions(), # adds summary circles
                       popup = paste0("<b>Município: </b>", mon_carb_local$municipio,"<br>",
                                      "<b>Quant. co2: </b>", mon_carb_local$sum_quant)
      ) %>% 
      addHeatmap(data = mon_carb_local, lat = mon_carb_local$lat, lng = mon_carb_local$lng, radius = 9, intensity = ~sum_quant)  %>% 
      addMarkers(data = ops, clusterOption=markerClusterOptions(), popup = paste0("<b>Município: </b>", ops$municipio,"<br>",
                                                                                  "<b>UF: </b>", ops$uf,"<br>",
                                                                                  "<b>Quant. empresas: </b>", ops$count))
  })
  
  output$map_ocorrencias <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% addCircleMarkers(data = incendios_local, 
                                                                        radius = 4, stroke = FALSE,
                                                                        color = "#ea5f52", fillOpacity = 0.8,
                                                                        popup = paste0("<b> Localidade: </b>", incendios_local$localidade,"<br>",
                                                                                       "<b> Município: </b>", incendios_local$mun, "<br>",
                                                                                       "<b> UF: </b>", incendios_local$uf, "<br>",
                                                                                       "<b> Provavel causa: </b>", incendios_local$provavel_causa)) %>% 
      addCircleMarkers(data = acidentes_amb_local, 
                       radius = 3, stroke = FALSE,
                       color = "#e1b638", fillOpacity = 0.5,
                       popup = paste0("<b> Município: </b>", acidentes_amb_local$municipio, "<br>",
                                      "<b> UF: </b>", acidentes_amb_local$uf, "<br>",
                                      "<b> Ocorrência: </b>", acidentes_amb_local$des_ocorrencia)) %>%
      addMarkers(data = ops, clusterOption=markerClusterOptions(), popup = paste0("<b>Município: </b>", ops$municipio,"<br>",
                                                                                  "<b>UF: </b>", ops$uf,"<br>",
                                                                                  "<b>Quant. empresas: </b>", ops$count))
  })
  
  output$logo <- renderImage({
    return(list(src = "/Users/pbizil/Desktop/gaia/gaia_bndes.png", contentType = "image/png"))
  }, deleteFile = FALSE)

  
}

runApp(shinyApp(ui, server), launch.browser = TRUE)



