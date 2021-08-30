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
library(ggplot2)
library(devtools)
library(GGally)
library(rstatix)



#setwd("~/Desktop/gaia")
#setwd("C:/guanaes/02 Hackatons/01 BNDES/GAIA")


ops_cnpj_completo <- read_csv('data/ops_cnpj_completo.csv', show_col_types = FALSE)
ops_cnpjs_polui <- read_csv("data/ops_cnpjs_polui.csv", show_col_types = FALSE)
ops_mun <- read_csv("data/ops_mun.csv", show_col_types = FALSE)
ops_cnpj_completo$cnpj <- as.character(ops_cnpj_completo$cnpj)
ops_cnpjs_polui$cnpj <- as.character(ops_cnpjs_polui$cnpj)

## -----------------------------------------
## Manipulacao dataframe ops_cnpj_completo
## -----------------------------------------
# correcao valores 
ops_cnpj_completo$valor_da_operacao_em_reais <- ops_cnpj_completo$valor_da_operacao_em_reais/10
ops_cnpj_completo$valor_desembolsado_reais <- ops_cnpj_completo$valor_desembolsado_reais/100

# Adicionando colunas ao dataframe
ops_cnpj_completo$ano_ops <- format(ops_cnpj_completo$data_da_contratacao, "%Y")
ops_cnpj_completo$mes_ops <- format(ops_cnpj_completo$data_da_contratacao, "%m-%Y")
ops_cnpj_completo$valor_da_operacao_log <- log10(ops_cnpj_completo$valor_da_operacao_em_reais)
ops_cnpj_completo$valor_desembolsado_log <- log10(ops_cnpj_completo$valor_desembolsado_reais)

# Convertendo colunas em categoricas
ops_cnpj_completo$uf <- as.factor(ops_cnpj_completo$uf)
ops_cnpj_completo$fonte_de_recurso_desembolsos <- as.factor(ops_cnpj_completo$fonte_de_recurso_desembolsos)
ops_cnpj_completo$custo_financeiro <- as.factor(ops_cnpj_completo$custo_financeiro)
ops_cnpj_completo$modalidade_de_apoio <- as.factor(ops_cnpj_completo$modalidade_de_apoio)
ops_cnpj_completo$forma_de_apoio <- as.factor(ops_cnpj_completo$forma_de_apoio)
ops_cnpj_completo$produto <- as.factor(ops_cnpj_completo$produto)
ops_cnpj_completo$instrumento_financeiro <- as.factor(ops_cnpj_completo$instrumento_financeiro)
ops_cnpj_completo$inovacao <- as.factor(ops_cnpj_completo$inovacao)
ops_cnpj_completo$area_operacional <- as.factor(ops_cnpj_completo$area_operacional)
ops_cnpj_completo$setor_cnae <- as.factor(ops_cnpj_completo$setor_cnae)
ops_cnpj_completo$setor_bndes <- as.factor(ops_cnpj_completo$setor_bndes)
ops_cnpj_completo$instituicao_financeira_credenciada <- as.factor(ops_cnpj_completo$instituicao_financeira_credenciada)
ops_cnpj_completo$porte_do_cliente <- as.factor(ops_cnpj_completo$porte_do_cliente)
ops_cnpj_completo$natureza_do_cliente <- as.factor(ops_cnpj_completo$natureza_do_cliente)
ops_cnpj_completo$situacao_da_operacao <- as.factor(ops_cnpj_completo$situacao_da_operacao)  
ops_cnpj_completo$cnpj_polui <- as.factor(ops_cnpj_completo$cnpj_polui)  

# Add cnpj_polui como numero
ops_cnpj_completo <- ops_cnpj_completo %>% 
  mutate(cnpj_polui_num =  if_else(cnpj_polui=='n', '0', '1'))

# Add campo mais sucinto para Porte Cliente 
ops_cnpj_completo <- ops_cnpj_completo %>% 
  mutate(porte_cli =  case_when (porte_do_cliente =='GRANDE' ~ 'GRDE',
                                 porte_do_cliente =='MICRO'  ~  'MICR',
                                 porte_do_cliente =='MÉDIA' ~ 'MED',
                                 porte_do_cliente =='PEQUENA' ~ 'PEQ'))

# Add campo mais sucinto para Natureza Cliente 
ops_cnpj_completo <- ops_cnpj_completo %>% 
  mutate(natur_cli =  case_when (natureza_do_cliente =='ADMINISTRAÇÃO PÚBLICA DIRETA - GOVERNO ESTADUAL' ~ 'APD-Est',
                                 natureza_do_cliente =='ADMINISTRAÇÃO PÚBLICA DIRETA - GOVERNO FEDERAL'  ~  'APD-Fed',
                                 natureza_do_cliente =='ADMINISTRAÇÃO PÚBLICA DIRETA - GOVERNO MUNICIPAL' ~ 'APD-Mun',
                                 natureza_do_cliente =='PRIVADA' ~ 'Priv',
                                 natureza_do_cliente =='PÚBLICA INDIRETA' ~ 'API'))


# Add campo mais sucinto para Setor CNAE 
ops_cnpj_completo <- ops_cnpj_completo %>% 
  mutate(set_cnae =  case_when (setor_cnae =='AGROPECUÁRIA E PESCA' ~ 'AGRO/PSC',
                                setor_cnae =='COMERCIO E SERVICOS'  ~  'COM/SRV',
                                setor_cnae =='INDUSTRIA DE TRANSFORMAÇÃO' ~ 'IND_TRF',
                                setor_cnae =='INDUSTRIA EXTRATIVA' ~ 'IND_EXTR'))


# Add campo mais sucinto para Setor BNDES 
ops_cnpj_completo <- ops_cnpj_completo %>% 
  mutate(set_bndes =  case_when (setor_bndes =='AGROPECUÁRIA' ~ 'AGRO',
                                setor_bndes =='COMERCIO/SERVICOS'  ~  'COM/SRV',
                                setor_bndes =='INDUSTRIA' ~ 'IND',
                                setor_bndes =='INFRA-ESTRUTURA' ~ 'IE'))


# Criacao de dataframe com agrupamento
data <- ops_cnpj_completo %>% group_by(mes_ops) %>% summarise(mean_polui_prob = mean(cnpj_polui_prob))


# ------------------------------------------------------
## Carga dados de financiamentos e PIB
# ------------------------------------------------------
pib_contr <- read.csv(file = "data/pib_contr.csv", 
                      header = TRUE, 
                      encoding = "UTF-8", sep = ";")
lista_regioes <- unique(pib_contr[c("Regiao")])
lista_speed <- c('lento','normal','acelerado')
lista_n_mun <- c(10, 25, 50, 75, 100, 150, 200)

# selecionar colunas relevantes
pib_contr <- select(pib_contr, Ano, Regiao, UF, NomeMun, PIB_Agropecuaria, 
                    PIB_Industria, PIB_Serv, PIB_outras,  PIB_perCapita, 
                    POP2013, POP2013_Faixa, POP2013_Peso, 
                    CAPITAL, POP2013_log, 
                    Soma_ValorContr, Soma_ValorContr_log, 
                    Menor_ValorContr, Maior_ValorContr, Total_Contr)


# -----------------------------------------------
# Preparando os dados para os plots
# -----------------------------------------------

# Plot01
vlr_contr_ano <- aggregate(valor_da_operacao_em_reais ~ ano_ops, ops_cnpj_completo, sum)
vlr_desemb_ano <- aggregate(valor_desembolsado_reais ~ ano_ops, ops_cnpj_completo, sum)
df_vlr_ano <- data.frame(vlr_contr_ano, vlr_desemb_ano)

# Plot02
vlr_poluicao_ano <- aggregate(cnpj_polui_prob ~ ano_ops, ops_cnpj_completo, mean)
df_vlr_poluicao_ano <- data.frame(vlr_poluicao_ano)

# Plot04
ops_cnpj_poluid = subset(ops_cnpj_completo, cnpj_polui_prob > 0.5)
ops_cnpj_n_poluid = subset(ops_cnpj_completo, cnpj_polui_prob <= 0.5)


# Plot 24 
corr01 <- select(ops_cnpj_completo, 
                 valor_da_operacao_log,
                 natur_cli,
                 porte_cli)

# Plot 25
corr02 <- select(ops_cnpj_completo, 
                 valor_da_operacao_log,
                 set_bndes,
                 set_cnae)


### area emb
areas_emb_sf <- st_read("data/geo/areas_emb.shp", quiet = T)
units_con_sf  <- st_read("data/geo/units_con.shp",  quiet = T)
land_ind_sf <- st_read("data/geo/land_ind.shp",  quiet = T)

### emissao de carbono
mon_carb_local <- read_csv('data/mon_carb_local.csv', show_col_types = FALSE)

### incendios 
incendios_local <- read_csv('data/incend_local.csv', show_col_types = FALSE)
incendios_local <- incendios_local[is_extreme(incendios_local$lat) == FALSE,]
incendios_local <- incendios_local[is_extreme(incendios_local$lng) == FALSE,]


### acidentes ambientais 
acidentes_amb_local <- read_csv('data/acid_amb_local.csv', show_col_types = FALSE)
acidentes_amb_local <- acidentes_amb_local[is_extreme(acidentes_amb_local$lat) == FALSE,]
acidentes_amb_local <- acidentes_amb_local[is_extreme(acidentes_amb_local$lng) == FALSE,]



### app gaia
ui <- dashboardPage(skin = "green",
  dashboardHeader(title = "GAIA.dash"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        "Sobre o projeto", 
        tabName = "sobre", 
        icon = icon("project-diagram")
      ),
      menuItem(
        "AED - Financiamentos", 
        tabName = "fin", 
        icon = icon("dollar"),
        menuSubItem("Invest x PIB Percapita", tabName = "anim01"),
        menuSubItem("Invest x PIB Agronegocio", tabName = "anim02"),
        menuSubItem("Invest x PIB Industria", tabName = "anim03"),
        menuSubItem("Invest x PIB Servico", tabName = "anim04")
      ),
      menuItem(
        "AED - Resultados GAIA", 
        tabName = "aed_resultados", 
        icon = icon("chart-bar"),
        menuSubItem("Evolucao e Histogramas", tabName = "sub01"),
        menuSubItem("Distribuicao Valores por Ano",  tabName = "sub02"),
        menuSubItem("Modalidade e Forma Apoio",  tabName = "sub03"),
        menuSubItem("Porte e Natureza Cliente",  tabName = "sub04"),
        menuSubItem("Setor CNAE e Setor BNDES",  tabName = "sub05"),
        menuSubItem("Produto e Status Operacao",  tabName = "sub06"),
        menuSubItem("Correlacao Porte e Natureza",  tabName = "sub07"),
        menuSubItem("Correlacao Setor CNAE e BNDES",  tabName = "sub08"),
        menuSubItem("Localidades",  tabName = "sub09")
      ),
      menuItem(
        "Consulta - Resultados GAIA", 
        tabName = "consulta", 
        icon = icon("search"),
        menuSubItem("Por CNAE", tabName = "consulta_cnaes"),
        menuSubItem("Por Municipio", tabName = "consulta_mun")
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
    tags$head(tags$style(HTML('.content-wrapper {background-color: #fff;}
    .wrapper {height: auto !important; position:relative; overflow-x:hidden; overflow-y:hidden}'))),

    
    tabItems(
      
      tabItem(tabName = "sobre", box(title = "Sobre o projeto", status = "success", solidHeader = F, width = 12,
                                     fluidPage(fluidRow(column(12, align="center", imageOutput("logo"))),
                                               fluidRow(textOutput("text_about"))))),
    
    tabItem(tabName = "anim01",
            fluidPage(box(title='Evolucao dos Investimentos com PIB PerCapita do Municipio',
                status = "success", solidHeader = T, width = 12, height=1100,
                fluidPage(fluidRow(box(width=2,
                               selectInput(inputId = "select_regiao01",
                                           label="Selecione a Regiao de interesse:",
                                           choices = lista_regioes, selected=1),
                               selectInput(inputId = "select_velocidade01",
                                           label="Selecione a velocidade da animacao:",
                                           choices = lista_speed, selected=1),
                               selectInput(inputId="qtd_municipios01",
                                           label="Informe a quantidade de municipios para o grafico:",
                                           choices = lista_n_mun, selected=1))), 
                  fluidRow(plotlyOutput(outputId = 'plot_anim01', height=700)) 
                )))),
    
    tabItem(tabName = "anim02",
            fluidPage(box(title='Evolucao dos Investimentos com PIB Agronegocio do Municipio',
                status = "success", solidHeader = T, width = 12, height=1100,
                fluidPage(fluidRow(box(width=2,
                               selectInput(inputId = "select_regiao02",
                                           label="Selecione a Regiao de interesse:",
                                           choices = lista_regioes, selected=1),
                               selectInput(inputId = "select_velocidade02",
                                           label="Selecione a velocidade da animacao:",
                                           choices = lista_speed, selected=1),
                               selectInput(inputId="qtd_municipios02",
                                           label="Informe a quantidade de municipios para o grafico:",
                                           choices = lista_n_mun, selected=1))), 
                  fluidRow(plotlyOutput(outputId = 'plot_anim02', height=700)) 
                )))),
    
    
    tabItem(tabName = "anim03",
            fluidPage(box(title='Evolucao dos Investimentos com PIB Industria do Municipio',
                status = "success", solidHeader = T, width = 12, height=1100,
                fluidPage(
                  fluidRow(box(width=2,
                               selectInput(inputId = "select_regiao03",
                                           label="Selecione a Regiao de interesse:",
                                           choices = lista_regioes, selected=1),
                               selectInput(inputId = "select_velocidade03",
                                           label="Selecione a velocidade da animacao:",
                                           choices = lista_speed, selected=1),
                               selectInput(inputId="qtd_municipios03",
                                           label="Informe a quantidade de municipios para o grafico:",
                                           choices = lista_n_mun, selected=1))), 
                  fluidRow(plotlyOutput(outputId = 'plot_anim03', height=700)) 
                )))),
    
    tabItem(tabName = "anim04",
            fluidPage(box(title='Evolucao dos Investimentos com PIB Servicos do Municipio',
                status = "success", solidHeader = T, width = 12, height=1100,
                fluidPage(
                  fluidRow(box(width=2,
                               selectInput(inputId = "select_regiao04",
                                           label="Selecione a Regiao de interesse:",
                                           choices = lista_regioes, selected=1),
                               selectInput(inputId = "select_velocidade04",
                                           label="Selecione a velocidade da animacao:",
                                           choices = lista_speed, selected=1),
                               selectInput(inputId="qtd_municipios04",
                                           label="Informe a quantidade de municipios para o grafico:",
                                           choices = lista_n_mun, selected=1))), 
                  fluidRow(plotlyOutput(outputId = 'plot_anim04', height=700)) 
                )))),
    
    tabItem(tabName = "consulta_cnaes", fluidPage(box(title = "Consulta - Potencial de empresas poluidoras por CNAE", status = "success", solidHeader = T, width = 12,
                                     fluidPage(fluidRow(textOutput("text_consulta_cnae")),
                                               br(),
                                       fluidRow(selectizeInput("select_cnae", label = "Selecione CNAE", choices =  unique(ops_cnpjs_polui$cnae_fiscal_descricao))),
                                       fluidRow(valueBoxOutput("negative_empresas"), valueBoxOutput("positive_empresas"), valueBoxOutput("mean_prob_cnae")),
                                       fluidRow(column(10, dataTableOutput('tableCNAE'))))))),
    tabItem(tabName = "consulta_mun", fluidPage(box(title = "Consulta - Potencial de empresas poluidoras por Municipio", status = "success", solidHeader = T, width = 12,
                                            fluidPage(fluidRow(textOutput("text_consulta_mun")),
                                              br(),
                                              fluidRow(selectizeInput("select_mun", label = "Selecione Municipio", choices =  unique(ops_cnpj_completo$municipio))),
                                              fluidRow(valueBoxOutput("negative_empresas_mun"), valueBoxOutput("positive_empresas_mun"), valueBoxOutput("mean_prob_mun")),
                                              fluidRow(column(10, dataTableOutput('tableMUN'))))))),
    tabItem(tabName = "map_carbon", fluidPage(box(title = "Distribuicao espacial das operacoes automaticas comparadas a regioes emissoras de carbono", 
                                        status = "success", solidHeader = F, width = 12, fluidPage(fluidRow(textOutput("text_map_carbono")),
                                        br(), br(),
                                        fluidRow(leafletOutput("map_carbono", height=1000)))))),
    tabItem(tabName = "map_areas",
            fluidPage(box(title = "Distribuicao espacial das operacoes automaticas comparadas a unid. de conserv., reservas indigenas e areas embargadas", 
                status = "success", solidHeader = F, width = 12,fluidPage(fluidRow(textOutput("text_map_areas")),
                br(), br(),
                fluidRow(leafletOutput("map_areas", height=1000)))))),
    tabItem(tabName = "map_ocorrencias",
            fluidPage(box(title = "Distribuicao espacial das operacoes automaticas  comparadas a incendios locais e acidentes ambientais", 
                status = "success", solidHeader = F, width = 12, fluidPage(fluidRow(textOutput("text_map_ocorrencias")),
                 br(), br(),
                 fluidRow(leafletOutput("map_ocorrencias", height=1000)))))),
    tabItem(tabName = "sub01",
            fluidPage(box(title = "Evolucao dos Valores Contratados/Desembolsados e Evolucao da Probabilidade media de Empresas Poluidoras",
                status = "success", solidHeader = T, width = 12, height=1000,
                fluidPage(
                  fluidRow(splitLayout(cellWidths = c("50%", "50%"), 
                                       plotlyOutput(outputId = 'plot01', height = 400),
                                       plotlyOutput(outputId = 'plot02', height = 400))),
                  br(), br(),
                  fluidRow(splitLayout(cellWidths = c("50%", "50%"), 
                                       plotlyOutput(outputId = 'plot03', height = 500),
                                       plotlyOutput(outputId = 'plot04', height = 500))))))),
    tabItem(tabName = "sub02",
            fluidPage(box(title='Distribuicao dos Valores Contratados e de Probabilidades de Empresas serem Poluidoras - por Ano',
                status = "success", solidHeader = T, width = 12, height=1000,
                fluidPage(fluidRow(splitLayout(cellWidths = c("50%", "50%"),
                                plotlyOutput(outputId = 'plot05', height = 500),
                                plotlyOutput(outputId = 'plot06', height = 500))),
                br(), br(),
                fluidRow(plotlyOutput(outputId = 'plot07'))
               )))),
              
    
    tabItem(tabName = "sub03",
            fluidPage(box(title='Distribuicao dos Valores/ Empresas Poluidoras por Modalidade e Forma de Apoio',
                status = "success", solidHeader = T, width = 12, height=1000,
                fluidPage(fluidRow(splitLayout(cellWidths = c("50%", "50%"),
                                               plotlyOutput(outputId = 'plot08', height = 500),
                                               plotlyOutput(outputId = 'plot09', height = 500))),
                          br(), br(),
                          fluidRow(splitLayout(cellWidths = c("50%", "50%"), 
                                               plotlyOutput(outputId = 'plot10', height = 500),
                                               plotlyOutput(outputId = 'plot11', height = 500)))
                )))),
    
    tabItem(tabName = "sub04",
            fluidPage(box(title='Distribuicao dos Valores/ Empresas Poluidoras por Porte e Natureza do Cliente',
                status = "success", solidHeader = T, width = 12, height=1000,
                fluidPage(fluidRow(splitLayout(cellWidths = c("50%", "50%"),
                                               plotlyOutput(outputId = 'plot12', height = 500),
                                               plotlyOutput(outputId = 'plot13', height = 500))),
                          br(), br(),
                          fluidRow(splitLayout(cellWidths = c("50%", "50%"), 
                                               plotlyOutput(outputId = 'plot14', height = 500),
                                               plotlyOutput(outputId = 'plot15', height = 500)))
                )))),
    
    tabItem(tabName = "sub05",
            fluidPage(box(title='Distribuicao dos Valores/ Empresas Poluidoras por Setor CNAE e Setor BNDES',
                status = "success", solidHeader = T, width = 12, height=1000,
                fluidPage(fluidRow(splitLayout(cellWidths = c("50%", "50%"),
                                               plotlyOutput(outputId = 'plot16', height = 500),
                                               plotlyOutput(outputId = 'plot17', height = 500))),
                          br(), br(),
                          fluidRow(splitLayout(cellWidths = c("50%", "50%"), 
                                               plotlyOutput(outputId = 'plot18', height = 500),
                                               plotlyOutput(outputId = 'plot19', height = 500)))
                )))),
    
    tabItem(tabName = "sub06",
            fluidPage(box(title='Distribuicao dos Valores/ Empresas Poluidoras por Produto e Situação da Operação',
                status = "success", solidHeader = T, width = 12, height=1000,
                fluidPage(fluidRow(splitLayout(cellWidths = c("50%", "50%"),
                                               plotlyOutput(outputId = 'plot20', height = 500),
                                               plotlyOutput(outputId = 'plot21', height = 500))),
                          br(), br(),
                          fluidRow(splitLayout(cellWidths = c("50%", "50%"), 
                                               plotlyOutput(outputId = 'plot22', height = 500),
                                               plotlyOutput(outputId = 'plot23', height = 500)))
                )))),
    
    tabItem(tabName = "sub07",
            fluidPage(box(title = 'Correlacao entre Valores Contratados com Porte/ Natureza do Cliente',
                status = "success", solidHeader = T, width = 12, height=1100,
                fluidPage(fluidRow(plotlyOutput(outputId = 'plot24', height=1000))
                )))),
    
    tabItem(tabName = "sub08",
            fluidPage(box(title = 'Correlacao entre Valores Contratados com Setor CNAE/ Setor BNDES',
                status = "success", solidHeader = T, width = 12, height=1100,
                fluidPage(fluidRow(plotlyOutput(outputId = 'plot25', height=1000))
                )))),
    
    tabItem(tabName = "sub09",
            fluidPage(box(title = 'Valores Contratados e Localidades dos CNPJs Potencialmente Poluidores',
                status = "success", solidHeader = T, width = 12, height=1100,
                fluidPage(fluidRow(plotlyOutput(outputId = 'plot26', height=1000))
                ))))
    )))

server <- function(input, output, session) {
  #### SOBRE
  output$text_about <- renderText({"Este projeto consiste em uma aplicação voltada para o Premio Dados Abertos do BNDES.
  Gaia é um robo que identifica, atraves de informações do CNPJ, a probabilidade da empresa  \n
  ser uma poluidora do meio ambiente. O nome do modelo faz alusao ? deusa da mitologia grega, que personifica a deusa da Terra, \n 
  geradora de todos os deuses e criadora do planeta. \n  \n
  O Gaia.dash, por sua vez, é uma aplicação que permite visualizar os dados envolvidos neste projeto, 
    desde dados do principal dataset de financiamentos aos resultados de maneira geolocalizada."})
  
  output$logo <- renderImage({return(list(src = "gaia_bndes.png", contentType = "image/png", height = 400, width = 400))}, deleteFile = FALSE)
  
  
  ## Graficos Investimentos x PIB Percapita
  ## -------------------------------------------------
  output$plot_anim01 <- renderPlotly( {
    
    # dados de entrada
    speed <- switch(input$select_velocidade01, "lento" = 2500, "normal"= 1500,"acelerado" = 500)
    data = pib_contr %>% filter(Regiao==input$select_regiao01) %>%
      group_by(Ano, UF) %>% slice_max(order_by = Soma_ValorContr, n=as.numeric(input$qtd_municipios01))
    
    fig <- data %>%
      plot_ly(
        x = ~Soma_ValorContr, y = ~PIB_perCapita, size = ~POP2013_Peso, color= ~UF, colors = "Set1",
        frame = ~Ano, symbol = ~CAPITAL, symbols = c("circle","star"),
        text = ~paste0("UF: ", UF, "<br>Municipio: ", NomeMun, 
                       "<br>Populacao: ", POP2013,
                       "<br>PIB_PerCapita: ", PIB_perCapita,
                       "<br>Total de contratos: ",Total_Contr,
                       "<br>Menor Valor Contr: ", Menor_ValorContr, 
                       "<br>Maior Valor Contr: ", Maior_ValorContr,
                       "<br>Soma Contratos: ", Soma_ValorContr),
        hoverinfo='text', type = 'scatter', mode = 'markers')
    fig <- fig %>% layout(
      xaxis = list(type = "log"),
      yaxis = list(type = "log"),
      paper_bgcolor='', plot_bgcolor='#f1f2f0')
    fig <- fig %>% animation_opts(speed, easing = "linear", redraw = FALSE, mode="immediate")
    fig  })
  
  
  ## Graficos Investimentos x PIB Agroneg?cio
  ## -------------------------------------------------
  output$plot_anim02 <- renderPlotly( {
    
    # dados de entrada
    speed <- switch(input$select_velocidade02, "lento" = 2500, "normal"= 1500,"acelerado" = 500)
    data = pib_contr %>% filter(Regiao==input$select_regiao02) %>%
      group_by(Ano, UF) %>% slice_max(order_by = Soma_ValorContr, n=as.numeric(input$qtd_municipios02))
    
    fig <- data %>%
      plot_ly(
        x = ~Soma_ValorContr, y = ~PIB_Agropecuaria, size = ~POP2013_Peso, color= ~UF, colors = "Set1",
        frame = ~Ano, symbol = ~CAPITAL, symbols = c("circle","star"),
        text = ~paste0("UF: ", UF, "<br>Municipio: ", NomeMun, 
                       "<br>Populacao: ", POP2013,
                       "<br>PIB_Agropecuaria: ", PIB_Agropecuaria,
                       "<br>Total de contratos: ",Total_Contr,
                       "<br>Menor Valor Contr: ", Menor_ValorContr, 
                       "<br>Maior Valor Contr: ", Maior_ValorContr,
                       "<br>Soma Contratos: ", Soma_ValorContr),
        hoverinfo='text', type = 'scatter', mode = 'markers')
    fig <- fig %>% layout(
      xaxis = list(type = "log"),
      yaxis = list(type = "log"),
      paper_bgcolor='', plot_bgcolor='#f1f2f0')
    fig <- fig %>% animation_opts(speed, easing = "linear", redraw = FALSE, mode="immediate")
    fig  })
  
  ## Graficos Investimentos x PIB Industria
  ## -------------------------------------------------
  output$plot_anim03 <- renderPlotly( {
    
    # dados de entrada
    speed <- switch(input$select_velocidade03, "lento" = 2500, "normal"= 1500,"acelerado" = 500)
    data = pib_contr %>% filter(Regiao==input$select_regiao03) %>%
      group_by(Ano, UF) %>% slice_max(order_by = Soma_ValorContr, n=as.numeric(input$qtd_municipios03))
    
    fig <- data %>%
      plot_ly(
        x = ~Soma_ValorContr, y = ~PIB_Industria, size = ~POP2013_Peso, color= ~UF, colors = "Set1",
        frame = ~Ano, symbol = ~CAPITAL, symbols = c("circle","star"),
        text = ~paste0("UF: ", UF, "<br>Municipio: ", NomeMun, 
                       "<br>Populacao: ", POP2013,
                       "<br>PIB_Industria: ", PIB_Industria,
                       "<br>Total de contratos: ",Total_Contr,
                       "<br>Menor Valor Contr: ", Menor_ValorContr, 
                       "<br>Maior Valor Contr: ", Maior_ValorContr,
                       "<br>Soma Contratos: ", Soma_ValorContr),
        hoverinfo='text', type = 'scatter', mode = 'markers')
    fig <- fig %>% layout(
      xaxis = list(type = "log"),
      yaxis = list(type = "log"),
      paper_bgcolor='', plot_bgcolor='#f1f2f0')
    fig <- fig %>% animation_opts(speed, easing = "linear", redraw = FALSE, mode="immediate")
    fig  })
  
  
  ## Graficos Investimentos x PIB Servi?os
  ## -------------------------------------------------
  output$plot_anim04 <- renderPlotly( {
    
    # dados de entrada
    speed <- switch(input$select_velocidade04, "lento" = 2500, "normal"= 1500,"acelerado" = 500)
    data = pib_contr %>% filter(Regiao==input$select_regiao04) %>%
      group_by(Ano, UF) %>% slice_max(order_by = Soma_ValorContr, n=as.numeric(input$qtd_municipios04))
    
    fig <- data %>%
      plot_ly(
        x = ~Soma_ValorContr, y = ~PIB_Serv, size = ~POP2013_Peso, color= ~UF, colors = "Set1",
        frame = ~Ano, symbol = ~CAPITAL, symbols = c("circle","star"),
        text = ~paste0("UF: ", UF, "<br>Municipio: ", NomeMun, 
                       "<br>Populacao: ", POP2013,
                       "<br>PIB_Servicos: ", PIB_Serv,
                       "<br>Total de contratos: ",Total_Contr,
                       "<br>Menor Valor Contr: ", Menor_ValorContr, 
                       "<br>Maior Valor Contr: ", Maior_ValorContr,
                       "<br>Soma Contratos: ", Soma_ValorContr),
        hoverinfo='text', type = 'scatter', mode = 'markers')
    fig <- fig %>% layout(
      xaxis = list(type = "log"),
      yaxis = list(type = "log"),
      paper_bgcolor='', plot_bgcolor='#f1f2f0')
    fig <- fig %>% animation_opts(speed, easing = "linear", redraw = FALSE, mode="immediate")
    fig  })
  
  
  
  #### CONSULTAS
  
  ### por cnae
  
  output$text_consulta_cnae <- renderText({"Consulta por CNAE das operações feitas com empresas. 
  A coluna “cnpj_polui” representa se a empresa é poluidora, segundo o Gaia. 
  Se tiver o atributo “s”, é poluidora. A coluna ”cnpj_polui_prob” é o atributo que representa a probabilidade de ser uma empresa poluidora, 
  variando entre 0 e 1.Quando mais alto este valor, maior a probabilidade da empresa ser poluidora."})
  
  
  tab <- reactive({ ops_cnpj_completo %>% 
      filter(cnae_fiscal_descricao == input$select_cnae) %>% select(data_da_contratacao, cliente, cnpj, municipio, uf, subsetor_cnae_agrupado, 
                                                                    setor_bndes, porte_do_cliente, valor_da_operacao_em_reais,cnpj_polui, cnpj_polui_prob)})
  
  neg <- reactive({dim(ops_cnpj_completo %>% filter(cnae_fiscal_descricao == input$select_cnae) %>% 
                         filter(cnpj_polui == "s"))[1]})
  
  posit <- reactive({dim(ops_cnpj_completo %>% filter(cnae_fiscal_descricao == input$select_cnae) %>% 
                         filter(cnpj_polui == "n"))[1]})
  
  media <- reactive({ops_cnpj_completo %>% filter(cnae_fiscal_descricao == input$select_cnae) %>% summarize(m = mean(cnpj_polui_prob))})
  
  output$negative_empresas <- renderValueBox({
    valueBox(neg(), subtitle = "Operacoes com empresas potencialmente poluidoras", icon = icon("exclamation-circle"), color = "yellow")})
  
  output$positive_empresas <- renderValueBox({
    valueBox(posit(), subtitle = "Operacoes com empresas nao potencialmente poluidoras", icon = icon("feather-alt"), color = "green")})
  
  output$mean_prob_cnae <- renderValueBox({
    valueBox(media(), subtitle = "Média das probabilidades do CNAE selecionado", color = "navy")})
  
  output$tableCNAE <- renderDataTable({tab()}, options = list(pageLength = 10))
  
  
  ### por municipio

  
  output$text_consulta_mun <- renderText({"Consulta por Municipio das operações feitas com empresas. 
  A coluna “cnpj_polui” representa se a empresa é poluidora, segundo o Gaia. 
  Se tiver o atributo “s”, é poluidora. A coluna ”cnpj_polui_prob” é o atributo que representa a probabilidade de ser uma empresa poluidora, 
  variando entre 0 e 1.Quando mais alto este valor, maior a probabilidade da empresa ser poluidora."})
  
  
  tab_mun <- reactive({ ops_cnpj_completo %>% 
      filter(municipio == input$select_mun) %>% select(data_da_contratacao, cliente, cnpj, setor_cnae, subsetor_cnae_agrupado, 
                                                       porte_do_cliente, cnae_fiscal_descricao, valor_da_operacao_em_reais, cnpj_polui, cnpj_polui_prob)})
  
  neg_mun <- reactive({dim(ops_cnpj_completo %>% filter(municipio == input$select_mun) %>% 
                         filter(cnpj_polui == "s"))[1]})
  
  posit_mun <- reactive({dim(ops_cnpj_completo %>% filter(municipio == input$select_mun) %>% 
                           filter(cnpj_polui == "n"))[1]})
  
  media_mun <- reactive({ops_cnpj_completo %>% filter(municipio == input$select_mun) %>% summarize(m = mean(cnpj_polui_prob))})
  
  output$negative_empresas_mun <- renderValueBox({
    valueBox(neg_mun(), subtitle = "Operacoes com empresas potencialmente poluidoras", icon = icon("exclamation-circle"), color = "yellow")})
  
  output$positive_empresas_mun <- renderValueBox({
    valueBox(posit_mun(), subtitle = "Operacoes com empresas nao potencialmente poluidoras", icon = icon("feather-alt"), color = "green")})
  
  output$mean_prob_mun <- renderValueBox({
    valueBox(media_mun(), subtitle = "Média das probabilidades do Municipio selecionado", color = "navy")})
  
  output$tableMUN <- renderDataTable({tab_mun()}, options = list(pageLength = 10))
  
##### MAPAS 
  
output$text_map_carbono <- renderText({"O mapa abaixo evidencia a relação geográfica entre as operações automáticas indiretas do BNDES e a localidade de empresas emissoras de monóxido de carbono. 
As marcas de calor, por exemplo, são clusters nas quais concentram municípios com empresas que emitem carbono. 
Os municípios com empresas emissoras de carbono estão marcados com circulo laranja. 
Os pinos azuis representam municípios com ao menos uma empresa que contratou financiamento indireto com o BNDES. 
Por fim, os números representam clusters de municípios com alguma operação do BNDES. 
Tanto os círculos laranjas quanto os pinos são cliclaveis, e apresentam informações sobre o nome do município, emissão de carbono e 
quantas empresas que contratam financiamento com BNDES são ou não potencialmente poluidoras."})

output$map_carbono <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(data = mon_carb_local, stroke = FALSE, fillOpacity = 0.8, color = "orange",
                       clusterOptions = markerClusterOptions(), # adds summary circles
                       popup = paste0("<b>Municipio: </b>", mon_carb_local$municipio,"<br>",
                                      "<b>Quant. co2: </b>", mon_carb_local$sum_quant)
      ) %>% 
      addHeatmap(data = mon_carb_local, lat = mon_carb_local$lat, lng = mon_carb_local$lng, radius = 9, intensity = ~sum_quant)  %>% 
      addMarkers(data = ops_mun, clusterOption=markerClusterOptions(), popup = paste0("<b>Municipio: </b>", ops_mun$municipio,"<br>",
                                                                                      "<b>UF: </b>", ops_mun$uf,"<br>",
                                                                                      "<b>Quant. empresas poten. polui.: </b>", ops_mun$s, "<br>",
                                                                                      "<b>Quant. empresas nao poten. polui.:  </b>", ops_mun$n))}) 

output$text_map_areas <- renderText({"O mapa abaixo evidencia a relação geográfica entre as operações automáticas indiretas do BNDES e 
áreas de Unidade de Conservação, Terras Indígenas e Áreas Embargadas. 
Os pinos azuis representam municípios com ao menos uma empresa que contratou financiamento indireto com o BNDES. 
Os números representam clusters de municípios com alguma operação do BNDES. Tanto as áreas marcadas quanto os pinos são clicáveis, e 
apresentam informações sobre a área e também  o nome do município, emissão de carbono e quantas empresas são potencialmente poluidoras ou não possuem empresas desta natureza."})


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
                                                                                      "<b>Quant. empresas não poten. polui.:  </b>", ops_mun$n)) %>%
      addLegend("bottomleft", colors=c("#52c588", "#e6e062", "#f75959"), labels=c("Unidade de Conservacao", "Terra Indígena", "Area Embargada"), title = "Legenda")})
  
  
output$text_map_ocorrencias <- renderText({"O mapa abaixo evidencia a relação geográfica entre as operações automáticas indiretas do BNDES e 
  ocorrências de incêndios florestais ou acidentes ambientais. 
  Os pinos azuis representam municípios com ao menos uma empresa que contratou financiamento indireto com o BNDES. 
  Os números representam clusters de municípios com alguma operação do BNDES. 
  Tanto os pontos de ocorrências quanto os pinos são clicáveis, e apresentam informações sobre a ocorrência e também  o nome do município, 
  emissão de carbono e quantas empresas são potencialmente poluidoras ou não possuem empresas desta natureza."})
  
  
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
                                                                                  "<b>Quant. empresas nao poten. polui.:  </b>", ops_mun$n)) %>%
      addLegend("bottomleft", colors=c("#ea5f52", "#e1b638"), labels=c("Incendios locais", "Acidentes ambientais"), title = "Legenda")}) 
  
  
  ##### ANALISES EXPLORATORIAS: Evolucao e Histogramas
  ## -------------------------------------------------
  output$plot01 <- renderPlotly({
    fig <- plot_ly(df_vlr_ano, x = ~ano_ops, y = ~valor_da_operacao_em_reais, 
                   line = list(width=3, color='cornflowerblue'),
                   type = 'scatter', mode ='lines', name = 'Valores Contratados') 
    fig <- fig %>% add_trace(y = ~valor_desembolsado_reais, 
                             type = 'scatter', mode ='lines', 
                             line = list(width=3, dash='dot', color='red'),
                             name = 'Valores Desembolsados')
    fig <- fig %>% layout(title = "Total do Valor Contratado/ Desembolsado por Ano")
    fig
    })
  
 output$plot02 <- renderPlotly({
    fig <- plot_ly(df_vlr_poluicao_ano, x = ~ano_ops, y = ~cnpj_polui_prob, 
                   line = list(width=4, dash='dot', color='darkgoldenrod4'),
                   type = 'scatter', mode ='lines', name = 'probabilidade média de ser poluidora') 
    fig <- fig %>% layout(title = "Probabilidade Média de Empresas Poluidoras por Ano")
    fig
    })
 
 output$plot03 <- renderPlotly({
   fig <- plot_ly(alpha = 0.6, nbinsx =50)
   fig <- fig %>% add_histogram(x = ~ops_cnpj_completo$valor_da_operacao_log, 
                                name='Valores Contratados', 
                                marker = list(color='cornflowerblue'))
   
   fig <- fig %>% add_histogram(x = ~ops_cnpj_completo$valor_desembolsado_log, 
                                name = 'Valores desembolsados', 
                                marker = list(color='red'))
   
   fig <- fig %>% layout(barmode = "stack")
   fig <- fig %>% layout(title='Distribuicao dos Valores Contratados/ Desembolsados (log)',
                         xaxis=list(title=''))
   fig
 })
 
 output$plot04 <- renderPlotly({
   fig <- plot_ly(alpha = 0.6, nbinsx =50)
   fig <- fig %>% add_histogram(x = ~ops_cnpj_poluid$cnpj_polui_prob, 
                              name='Probabilidade - Empresas Poluidoras', 
                              marker = list(color='darkorange'))
 
 fig <- fig %>% add_histogram(x = ~ops_cnpj_n_poluid$cnpj_polui_prob, 
                              name = 'Probabilidade - Empresas Não Poluidoras',
                              marker = list(color='forestgreen'))
 
 fig <- fig %>% layout(barmode = "stack")
 fig <- fig %>% layout(title='Distribuicao das Probabilidades',
                       xaxis=list(title=''))
 fig
 })
 
 ##### ANALISES EXPLORATORIAS: Distribuicao Valores por Ano
 ## -----------------------------------------------------------
 output$plot05 <- renderPlotly({
 fig <- plot_ly (
   ops_cnpj_completo,
   x = ~ano_ops, y = ~valor_da_operacao_log, colors = "Set1", type="box", name='Valores Contratados (log)')
 fig <- fig %>% 
   layout(boxmode = "group",
          title='Distribuicao dos Valores Contratados (log) por Ano',
          showlegend=TRUE)
 fig
 })
 
 output$plot06 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~valor_da_operacao_log, color= ~cnpj_polui,
                   colors = c('forestgreen','darkorange'), type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Se CNPJ Poluente',
            showlegend=TRUE)
   fig
 })
 
 output$plot07 <- renderPlotly({
   fig <- plot_ly (
     ops_cnpj_completo,
     x = ~ano_ops, y = ~cnpj_polui_prob, color= ~cnpj_polui, colors = c('forestgreen','darkorange'), type="box" )
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao de Probabilidades de Empresas Poluidoras por Ano',
            showlegend=TRUE)
   fig
 })
 
 ##### ANALISES EXPLORATORIAS: Modalidade e Forma Apoio
 ## -------------------------------------------------------
 output$plot08 <- renderPlotly({
   fig <- plot_ly (
     ops_cnpj_completo,
     x = ~ano_ops, y = ~valor_da_operacao_log, color= ~forma_de_apoio,
     colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Forma Apoio',
            showlegend=TRUE)
   fig
 })
 
 output$plot09 <- renderPlotly({
   fig <- plot_ly (
     ops_cnpj_completo,
     x = ~ano_ops, y = ~cnpj_polui_prob, color= ~forma_de_apoio, colors = "Set1", type="box" )
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao de Probabilidades de Empresas Poluidoras por Ano/ Forma Apoio',
            showlegend=TRUE)
   fig
 })
 
 output$plot10 <- renderPlotly({
   fig <- plot_ly (
     ops_cnpj_completo,
     x = ~ano_ops, y = ~valor_da_operacao_log, color= ~modalidade_de_apoio,
     colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Modalidade de Apoio',
            showlegend=TRUE)
   fig
 })
 
 output$plot11 <- renderPlotly({
   fig <- plot_ly (
     ops_cnpj_completo,
     x = ~ano_ops, y = ~cnpj_polui_prob, color= ~modalidade_de_apoio, colors = "Set1", type="box" )
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao de Probabilidades de Empresas Poluidoras por Ano/ Modalidade de Apoio',
            showlegend=TRUE)
   fig
 })
 

 ##### ANALISES EXPLORATORIAS: Porte e Natureza Cliente
 ## -------------------------------------------------
 output$plot12 <- renderPlotly({
   fig <- plot_ly (
     ops_cnpj_completo,
     x = ~ano_ops, y = ~valor_da_operacao_log, color= ~porte_do_cliente,
     colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Porte Cliente',
            showlegend=TRUE)
   fig
   
 })
 
 output$plot13 <- renderPlotly({
   fig <- plot_ly (
     ops_cnpj_completo,
     x = ~ano_ops, y = ~cnpj_polui_prob, color= ~porte_do_cliente, colors = "Set1", type="box" )
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao de Probabilidades de Empresas Poluidoras por Ano/Porte Cliente',
            showlegend=TRUE)
   fig
 })
 
 output$plot14 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~valor_da_operacao_log, color= ~natureza_do_cliente,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Natureza Cliente',
            showlegend=TRUE)
   fig
 })
 
 output$plot15 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~cnpj_polui_prob, color= ~natureza_do_cliente,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao das Probabilidades de Poluicao por Ano/ Natureza Cliente',
            showlegend=TRUE)
   fig
 })
 
 ##### ANALISES EXPLORATORIAS: Setor CNAE e Setor BNDES
 ## -------------------------------------------------
 output$plot16 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~valor_da_operacao_log, color= ~setor_cnae,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Setor CNAE',
            showlegend=TRUE)
   fig
 })
 
 output$plot17 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~cnpj_polui_prob, color= ~setor_cnae,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao das Probabilidades de Poluicao por Ano/ Setor CNAE',
            showlegend=TRUE)
   fig
 })
 
 output$plot18 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~valor_da_operacao_log, color= ~setor_bndes,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Setor BNDES',
            showlegend=TRUE)
   fig
 })
 
 output$plot19 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~cnpj_polui_prob, color= ~setor_bndes,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao das Probabilidades de Poluicao por  Ano/ Setor BNDES',
            showlegend=TRUE)
   fig
 })
 
 ##### ANALISES EXPLORATORIAS: Produto e Status Operação
 ## -------------------------------------------------
 output$plot20 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~valor_da_operacao_log, color= ~produto,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Produto',
            showlegend=TRUE)
   fig
 })
 
 output$plot21 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~cnpj_polui_prob, color= ~produto,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao das Probabilidades de Poluicao por Ano/ Produto',
            showlegend=TRUE)
   fig
 })
 
 output$plot22 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~valor_da_operacao_log, color= ~situacao_da_operacao,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao dos Valores Contratados (log) por Ano/ Situacao da Operacao',
            showlegend=TRUE)
   fig
 })
 
 output$plot23 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~ano_ops,  y = ~cnpj_polui_prob, color= ~situacao_da_operacao,
                   colors = "Set1", type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='Distribuicao das Probabilidades de Poluicao por  Ano/ Situacao da Operacao',
            showlegend=TRUE)
   fig
 })
 
 ##### ANALISES EXPLORATORIAS: Correlacao Porte e Natureza
 ## -------------------------------------------------
 output$plot24 <- renderPlotly({
   g <- ggpairs(corr01, 
                #title="Correlacao dos valores Contratados e Poluicao com Porte/ Natureza Cliente", 
                ggplot2::aes(color = ops_cnpj_completo$cnpj_polui), legend=1) 
   g <- g + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
   g <- g + theme(legend.position = "bottom")
   for(i in 1:g$nrow) {
     for(j in 1:g$ncol){
       g[i,j] <- g[i,j] + 
         scale_fill_manual(values=c("forestgreen", "darkorange")) +
         scale_color_manual(values=c("forestgreen", "darkorange"))  }}
   g
 })
 
 
 ##### ANALISES EXPLORATORIAS: Correlacao Setor CNAE e BNDES
 ## -------------------------------------------------
 output$plot25 <- renderPlotly({
   g <- ggpairs(corr02, 
                #title="Correlacao dos valores Contratados e Poluicao com Setor CNAE", 
                ggplot2::aes(color = ops_cnpj_completo$cnpj_polui), legend=1) 
   g <- g + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
   g <- g + theme(legend.position = "bottom")
   for(i in 1:g$nrow) {
     for(j in 1:g$ncol){
       g[i,j] <- g[i,j] + 
         scale_fill_manual(values=c("forestgreen", "darkorange")) +
         scale_color_manual(values=c("forestgreen", "darkorange"))  }}
   g
 })
 
 
 ##### ANALISES EXPLORATORIAS: Localidades
 ## -------------------------------------------------
 output$plot26 <- renderPlotly({
   fig <- plot_ly (ops_cnpj_completo,
                   x = ~uf,  y = ~valor_da_operacao_log, color= ~cnpj_polui,
                   colors = c('darkgreen','darkorange'), type="box")
   fig <- fig %>% 
     layout(boxmode = "group",
            title='BoxPlot - Valores Contratados e Localidades dos CNPJs Poluidores',
            showlegend=TRUE)
   fig
 })
  
  }

#rsconnect::deployApp("~/Desktop/gaia", appName = "gaia_bndes")
#runApp(shinyApp(ui, server), launch.browser = TRUE)
shinyApp(ui, server)