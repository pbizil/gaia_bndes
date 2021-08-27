library(sp)
library(raster)
library(readxl)
library(dplyr)
library(rjson)
library(readr)
library(geobr)
library(sf)
library(leafgl)
library(rgdal)
library(rgeos)
library(reshape2)
library(tidyverse)


### operacoes indiretas

ops_cnpj_completo <- read_csv("data/ops_cnpj_completo.csv")
ops_cnpjs_polui <- read_csv("data/ops_cnpjs_polui.csv")
ops_mun <- ops_cnpj_completo  %>% group_by(municipio_codigo, municipio, uf, latitude, longitude) %>% count(cnpj_polui)
ops_mun <- dcast(ops_mun, municipio_codigo + municipio + uf + latitude + longitude ~ cnpj_polui , sum, value.var = "n")
ops_cnpj_completo$cnpj <- as.character(ops_cnpj_completo$cnpj)
ops_cnpjs_polui$cnpj <- as.character(ops_cnpjs_polui$cnpj)
con <- file('data/ops_cnpj_completo.csv', encoding="UTF-8")
write.csv(ops_cnpj_completo, file=con)
con <- file('data/ops_cnpjs_polui.csv', encoding="UTF-8")
write.csv(ops_cnpjs_polui, file=con)
con <- file('data/ops_mun.csv', encoding="UTF-8")
write.csv(ops_mun, file=con)


### area emb

areas_emb <- read_csv("data/area_emb_local.csv")
areas_emb$...1 <- NULL
areas_emb$geom <- st_as_sfc(areas_emb$geom)
areas_emb_sf <- sf::st_cast(areas_emb$geom, 'POLYGON')
st_write(areas_emb_sf, "data/areas_emb.shp")
areas_emb_sf <- st_read("data/areas_emb.shp")


units_con <- geobr::read_conservation_units()
units_con_sf  <- sf::st_cast(units_con, 'POLYGON')
st_write(units_con_sf, "data/units_con.shp")
units_con_sf  <- st_read("data/units_con.shp")


land_ind <- geobr::read_indigenous_land()
land_ind_sf  <- sf::st_cast(land_ind, 'POLYGON')
st_write(land_ind_sf, "data/land_ind.shp")
land_ind_sf <- st_read("data/land_ind.shp")


### emissao de carbono

ep_mon_carbono_local <- read_excel("data/ep_mon_carbono_local.xlsx")
mon_carb_local <- ep_mon_carbono_local[, c("razao_social", "mun_uf", "latitude", "longitude", "quant")] %>% group_by(razao_social, mun_uf, latitude, longitude) %>% summarise(mean_quant = mean(quant))
colnames(mon_carb_local) <- c("razao_social", "municipio", "lat", "lng", "quant")
mon_carb_local <- mon_carb_local %>% group_by(municipio, lat, lng) %>% summarise(sum_quant = sum(quant))

con <- file('data/mon_carb_local.csv', encoding="UTF-8")
write.csv(mon_carb_local, file=con)

### incendios 

incendios_local <- read_csv("data/incendios_local.csv")
con <- file('data/incend_local.csv', encoding="UTF-8")
write.csv(incendios_local, file=con)


### acidentes ambientais 

acidentes_amb_local <- read_csv("data/acidentes_amb_local.csv")
con <- file('data/acid_amb_local.csv', encoding="UTF-8")
write.csv(acidentes_amb_local, file=con)
