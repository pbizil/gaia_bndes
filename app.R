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
library(geobr)
library(sf)
library(colourvalues)
library(leafgl)
library(rgdal)
library(rgeos)
library(reshape2)
library(tidyverse)
library(plotly)

###### CARGA DOS DADOS


### operacoes indiretas

ops_cnpj_completo <- read_csv('data/ops_cnpj_completo.csv', show_col_types = FALSE)
ops_cnpjs_polui <- read_csv("data/ops_cnpjs_polui.csv", show_col_types = FALSE)
ops_mun <- read_csv("data/ops_mun.csv", show_col_types = FALSE)


### area

areas_emb_sf <- st_read("data/geo/areas_emb.shp", quiet = T)
units_con_sf  <- st_read("data/geo/units_con.shp",  quiet = T)
land_ind_sf <- st_read("data/geo/land_ind.shp",  quiet = T)

### emissao de carbono

mon_carb_local <- read_csv('data/mon_carb_local.csv', show_col_types = FALSE)

### incendios 

incendios_local <- read_csv('data/incend_local.csv', show_col_types = FALSE)

### acidentes ambientais 

acidentes_amb_local <- read_csv('data/acid_amb_local.csv', show_col_types = FALSE)




### app gaia

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
        "Empresas poluidoras", 
        tabName = "emp_poten", 
        icon = icon("chart-bar"),
        menuSubItem("Analise", tabName = "analise"),
        menuSubItem("Consulta", tabName = "consulta")
      ),
      menuItem(
        "Mapas", 
        tabName = "maps", 
        icon = icon("map"),
        menuSubItem("Emissao de carbono", tabName = "map_carbon"),
        menuSubItem("Areas ambientais", tabName = "map_areas"),
        menuSubItem("Ocorrencias ambientais", tabName = "map_ocorrencias")
      )
  )),
  dashboardBody(
    tags$head(tags$style(HTML('
      .content-wrapper {
        background-color: #fff;
      }
    '))),
    
    tabItems(
    tabItem(tabName = "sobre", box(title = "Sobre o projeto", status = "success", solidHeader = F, width = 12,
                                   fluidPage(fluidRow(column(12, align="center", imageOutput("logo"))),
                                             fluidRow(textOutput("text_about"))))),
    tabItem(tabName = "analise", box(title = "Analise dos resultados do GAIA sobre as operacoes automaticas", status = "success", solidHeader = T, width = 12,
            fluidPage(fluidRow(valueBoxOutput("wallet_s"), 
                               valueBoxOutput("wallet_n"),
                               valueBoxOutput("empresa_s"), 
                              valueBoxOutput("empresa_n"),
                              valueBoxOutput("prob_emp"), 
                              valueBoxOutput("count_ops")))
            )),
    tabItem(tabName = "consulta", box(title = "Consulta - Potencial de empresas poluidoras por CNAE", status = "success", solidHeader = T, width = 12,
                                     fluidPage(
                                       fluidRow(selectizeInput("select_cnae", label = "Selecione CNAE", choices =  unique(ops_cnpjs_polui$cnae_fiscal_descricao))),
                                       fluidRow(valueBoxOutput("negative_empresas"), valueBoxOutput("positive_empresas"), valueBoxOutput("mean_prob_cnae")),
                                       fluidRow(column(12, dataTableOutput('tableCNAE')))))),
    tabItem(tabName = "map_carbon", box(title = "Distribuicao espacial das operacoes automaticas comparadas a regioes emissoras de carbono", 
                                        status = "success", solidHeader = F, width = 12, leafletOutput("map_carbono", height=1000))),
    tabItem(tabName = "map_areas",
            box(title = "Distribuicao espacial das operacoes automaticas comparadas a unid. de conserv., reservas indigenas e areas embargadas", 
                status = "success", solidHeader = F, width = 12, leafletOutput("map_areas", height=1000))),
    tabItem(tabName = "map_ocorrencias",
            box(title = "Distribuicao espacial das operacoes automaticas  comparadas a incendios locais e acidentes ambientais", 
                status = "success", solidHeader = F, width = 12, leafletOutput("map_ocorrencias", height=1000)))
    )
  )
)


server <- function(input, output, session) {
  
  
  #### SOBRE
  
  output$text_about <- renderText({"Gaia é um robô que identifica, através de informações do CNPJ, a probabilidade da empresa  \n
  ser uma poluidora do meio ambiente. O nome do modelo faz alusão à deusa da mitologia grega, que personifica a deusa da Terra, \n 
  geradora de todos os deuses e criadora do planeta. \n
  \n
  Este projeto consiste em uma aplicação voltada para o Prêmio Dados Abertos do BNDES."})
  
  output$logo <- renderImage({
    return(list(src = "gaia_bndes.png", contentType = "image/png", height = 400, width = 400))
  }, deleteFile = FALSE)
  
  
  
  #### ANALISE
  
  
  output$wallet_s <- renderValueBox({
    valueBox(table(ops_cnpj_completo$cnpj_polui)["s"], subtitle = "Operacoes com empresas potencialmente poluidoras", icon = icon("exclamation-circle"), color = "yellow")
  })
  
  output$wallet_n <- renderValueBox({
    valueBox(table(ops_cnpj_completo$cnpj_polui)["n"], subtitle = "Operacoes com empresas nao potencialmente poluidoras", icon = icon("feather-alt"), color = "green")
  })
  
  output$empresa_s <- renderValueBox({
    valueBox(table(ops_cnpjs_polui$cnpj_polui)["s"], subtitle = "Empresas potencialmente poluidoras", icon = icon("exclamation-circle"), color = "yellow")
  })
  
  output$empresa_n <- renderValueBox({
    valueBox(table(ops_cnpjs_polui$cnpj_polui)["n"], subtitle = "Empresas nao potencialmente poluidoras", icon = icon("feather-alt"), color = "green")
  })
  
  output$prob_emp <- renderValueBox({
    valueBox(mean(ops_cnpj_completo$cnpj_polui_prob), subtitle = "Média da probabilidade geral de ser uma empresa poluidora", color = "navy")
  })
  
  output$count_ops <- renderValueBox({
    valueBox(dim(ops_cnpj_completo)[1], subtitle = "Contagem de operacoes analisadas", color = "black")
  })
  
  

  
  #### CONSULTAS
  
  tab <- reactive({ ops_cnpj_completo %>% 
      filter(cnae_fiscal_descricao == input$select_cnae) %>% select(cliente, cnpj, municipio, uf, setor_cnae, subsetor_cnae_agrupado, 
                                                                    setor_bndes, porte_do_cliente, cnae_fiscal_descricao, cnpj_polui, cnpj_polui_prob)})
  
  neg <- reactive({dim(ops_cnpj_completo %>% filter(cnae_fiscal_descricao == input$select_cnae) %>% 
                         filter(cnpj_polui == "s"))[1]})
  
  posit <- reactive({dim(ops_cnpj_completo %>% filter(cnae_fiscal_descricao == input$select_cnae) %>% 
                         filter(cnpj_polui == "n"))[1]})
  
  media <- reactive({ops_cnpj_completo %>% filter(cnae_fiscal_descricao == input$select_cnae) %>% summarize(m = mean(cnpj_polui_prob))})
  
  output$negative_empresas <- renderValueBox({
    valueBox(neg(), subtitle = "Empresas potencialmente poluidoras", icon = icon("exclamation-circle"), color = "yellow")
  })
  
  output$positive_empresas <- renderValueBox({
    valueBox(posit(), subtitle = "Empresas nao potencialmente poluidoras", icon = icon("feather-alt"), color = "green")
  })
  
  output$mean_prob_cnae <- renderValueBox({
    valueBox(media(), subtitle = "Média das probabilidades do CNAE selecionado", color = "navy")
  })
  
  output$tableCNAE <- renderDataTable({tab()})
  
##### MAPAS 
  
output$map_carbono <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(data = mon_carb_local, stroke = FALSE, fillOpacity = 0.8,
                       clusterOptions = markerClusterOptions(), # adds summary circles
                       popup = paste0("<b>Municipio: </b>", mon_carb_local$municipio,"<br>",
                                      "<b>Quant. co2: </b>", mon_carb_local$sum_quant)
      ) %>% 
      addHeatmap(data = mon_carb_local, lat = mon_carb_local$lat, lng = mon_carb_local$lng, radius = 9, intensity = ~sum_quant)  %>% 
      addMarkers(data = ops_mun, clusterOption=markerClusterOptions(), popup = paste0("<b>Municipio: </b>", ops_mun$municipio,"<br>",
                                                                                      "<b>UF: </b>", ops_mun$uf,"<br>",
                                                                                      "<b>Quant. empresas poten. polui.: </b>", ops_mun$s, "<br>",
                                                                                      "<b>Quant. empresas nao poten. polui.:  </b>", ops_mun$n))
  })
  
  output$map_areas <- renderLeaflet({ leaflet() %>%
      addProviderTiles(provider = providers$CartoDB.DarkMatterNoLabels) %>%
      addGlPolygons(data = units_con_sf, group = "pols", color = "#52c588", fillOpacity = 0.2, popup = paste0("<b> Nome Unid. Conserv.: </b>", units_con_sf$nm_cns_,"<br>",
                                                                                                              "<b> Categoria: </b>", units_con_sf$categry,"<br>",
                                                                                                              "<b> Nivel gov: </b>", units_con_sf$gvrnmn_,"<br>",
                                                                                                              "<b> Ano criacao: </b>", units_con_sf$crtn_yr,"<br>",
                                                                                                              "<b> Legislacao: </b>", units_con_sf$legsltn)) %>%
      addGlPolygons(data = land_ind_sf, group = "pols", color = "#e6e062", fillOpacity = 0.2, popup = paste0("<b> Nome da terra: </b>", land_ind_sf$terr_nm,"<br>",
                                                                                                             "<b> Etnia: </b>", land_ind_sf$etni_nm,"<br>",
                                                                                                             "<b> Nome municipio: </b>", land_ind_sf$name_mn,"<br>",
                                                                                                             "<b> Estado: </b>", land_ind_sf$abbrv_s,"<br>",
                                                                                                             "<b> Modalidade: </b>", land_ind_sf$modaldd)) %>% 
      addGlPolygons(data = areas_emb_sf, group = "pols", color = "#f75959", fillOpacity = 0.3) %>% 
      addMarkers(data = ops_mun, clusterOption=markerClusterOptions(), popup = paste0("<b>Municipio: </b>", ops_mun$municipio,"<br>",
                                                                                      "<b>UF: </b>", ops_mun$uf,"<br>",
                                                                                      "<b>Quant. empresas poten. polui.: </b>", ops_mun$s, "<br>",
                                                                                      "<b>Quant. empresas não poten. polui.:  </b>", ops_mun$n))
    
  })
  
  output$map_ocorrencias <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% addCircleMarkers(data = incendios_local, 
                                                                        radius = 4, stroke = FALSE,
                                                                        color = "#ea5f52", fillOpacity = 0.8,
                                                                        popup = paste0("<b> Localidade: </b>", incendios_local$localidade,"<br>",
                                                                                       "<b> Municipio: </b>", incendios_local$mun, "<br>",
                                                                                       "<b> UF: </b>", incendios_local$uf, "<br>",
                                                                                       "<b> Provavel causa: </b>", incendios_local$provavel_causa)) %>% 
      addCircleMarkers(data = acidentes_amb_local, 
                       radius = 3, stroke = FALSE,
                       color = "#e1b638", fillOpacity = 0.5,
                       popup = paste0("<b> Municipio: </b>", acidentes_amb_local$municipio, "<br>",
                                      "<b> UF: </b>", acidentes_amb_local$uf, "<br>",
                                      "<b> Ocorrencia: </b>", acidentes_amb_local$des_ocorrencia)) %>%
      addMarkers(data = ops_mun, clusterOption=markerClusterOptions(), popup = paste0("<b>Municipio: </b>", ops_mun$municipio,"<br>",
                                                                                  "<b>UF: </b>", ops_mun$uf,"<br>",
                                                                                  "<b>Quant. empresas poten. polui.: </b>", ops_mun$s, "<br>",
                                                                                  "<b>Quant. empresas nao poten. polui.:  </b>", ops_mun$n))
  })
  

}

runApp(shinyApp(ui, server), launch.browser = TRUE)



