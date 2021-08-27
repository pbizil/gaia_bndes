#### area de analise 

library(plotly)
library(readr)


ops_cnpj_completo <- read_csv('data/ops_cnpj_completo.csv', show_col_types = FALSE)
ops_cnpjs_polui <- read_csv("data/ops_cnpjs_polui.csv", show_col_types = FALSE)
ops_mun <- read_csv("data/ops_mun.csv", show_col_types = FALSE)


ops_cnpj_completo$ano_ops <- format(ops_cnpj_completo$data_da_contratacao, "%Y")
ops_cnpj_completo$mes_ops <- format(ops_cnpj_completo$data_da_contratacao, "%m-%Y")

data <- ops_cnpj_completo %>% group_by(mes_ops) %>% summarise(mean_polui_prob = mean(cnpj_polui_prob))

fig <- plot_ly(data, x = ~ano_ops, y = ~contagem, type = 'bar', name = 'SF Zoo')
fig <- fig %>% layout(yaxis = list(title = 'Numero de operacoes'), xaxis = list(title = 'Anos'), barmode = 'group', title = 'Evolucao das operacoes ao longo dos anos')

