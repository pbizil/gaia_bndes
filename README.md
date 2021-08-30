<p align="center">
  <img width="500" height="450" src="https://github.com/pbizil/gaia_bndes/blob/main/gaia_bndes.png">
</p>

Este projeto consiste em uma aplicação voltada para o [Prêmio Dados Abertos para o Desenvolvimento](https://www.bndes.gov.br/wps/portal/site/home/transparencia/iniciativas/!ut/p/z0/fY5PC4JAFMTvfYoue5S3QmRXs_APEUgedC_y0iVe5a7ubtLHT0Q8NocZfjADAwJKEApHeqAjrfA9cSX2dZDHURLu_MuhSCKeR9kEQezHqQ_ZZjtrsxqI_4tyWSz1NaCi5zCIEESjlZNfB-Xxejrf6lRZR-7TzI8YT3QnGS8MKtujkaohZJwUTeloRMt4b2RH2mux1dbDuzROW-hfovoBqFEnTw!!/), realizado pelo BNDES. 

Gaia é um robô que identifica, através de informações sobre o CNPJ, a probabilidade da empresa ser uma poluidora do meio ambiente. O nome do modelo faz alusão à deusa da mitologia grega, que personifica a deusa da Terra, geradora de todos os deuses e criadora do planeta. 

Esta aplicação foi criada com intuito de auxiliar às equipes de negócio BNDES a identificar como a carteira de clientes está exposta ao risco ambiental, principalmente daqueles riscos envolvidos nas empresas que tomam crédito junto ao banco.

## Links importantes

- [GAIA dashboard](https://hipotumos.shinyapps.io/gaia_bndes/)
- AED Financiamentos
- Video-pitch

## Produtos

- Análise exploratória dos dados de operações diretas e indiretas automáticas do BNDES;
- Modelo de identificação do potencial poluidor de determinada empresa, a partir dos dados do CNPJ;
- Dashboard em shiny com análise dos resultados das previsões do modelo Gaia sobre os dados de operações automáticas indiretas a partir de 2016;


## Bases de dados

- [Operações indiretas automáticas do BNDES](https://dadosabertos.bndes.gov.br/dataset/operacoes-financiamento/resource/9534f677-9525-4bf8-a3aa-fd5d3e152a93) 
   - **Sobre:** Informações detalhadas sobre as operações indiretas contratadas de forma automática. Nas operações indiretas, a análise do financiamento é feita pela instituição financeira credenciada, que assume o risco de não pagamento da operação. É ela também que negocia com o cliente as condições do financiamento, como prazo de pagamento, spread de risco e garantias exigidas, respeitando algumas regras e limites definidos pelo BNDES. Não foram incluídas nesta listagem as operações do Cartão BNDES e nem as contratadas com Pessoas Físicas. Dados, em reais, a partir de 2002;
   - **Função:** principal dataset deste projeto. Com estes dados foi possível analisar como está a carteira de clientes de operações indiretas do BNDES sob a ótica dos riscos ambientais.

- [Cadastro de empresas potencialmente poluidoras](https://dados.gov.br/dataset/pessoas-juridicas-inscritas-no-ctf-app)
   - **Sobre:** Relação das pessoas jurídicas que efetuaram a inscrição no Cadastro Técnico Federal de Atividades Potencialmente Poluidoras e Utilizadoras de Recursos Naturais – CTF/APP. Neste link consta apenas uma parte de base de dados, que está dividada por Unidade Federativa;
   - **Função:** Dados sobre CNPJ de empresas consideradas potencialmente poluidoras.

- [Coleção de CNPJs e CPFs brasileiros](https://brasil.io/dataset/documentos-brasil/documents/)
   - **Sobre:** Documentos coletados de dados públicos, a partir dos seguintes datasets: socios-brasil, gastos-diretos, gastos-deputados, eleicoes. Nota: os CPFs foram ofuscados por questões de privacidade;
   - **Função:** Coletou-se um conjunto de CNPJs que não constam na base de Cadastro de Empresas potencialmente poluidoras, para identificar padrões de empresas que não seria, a princípio, poluidoras.

- [Emissão de Poluentes Atmosféricos](https://dados.gov.br/dataset/emissoes-de-poluentes-atmosfericos/resource/4c94cd16-9dde-4a4c-bcaa-0b113bd37926)
   - **Sobre:** Relação das pessoas jurídicas inscritas no Cadastro Técnico Federal de Atividades Potencialmente Poluidoras e Utilizadoras de Recursos Naturais – CTF/APP e cadastradas em atividades para as quais é obrigatório o preenchimento do formulário “Emissões de Poluentes Atmosféricos” no Relatório Anual de Atividades Potencialmente Poluidoras e Utilizadoras de Recursos Ambientais – RAPP;
   - **Função:** Dados que serviram para identificar concentração de poluentes atmosféricos por municípios. 

- [Acidentes ambientais](https://dados.gov.br/dataset/comunicacao-de-acidentes-ambientais/resource/1fba1942-3070-4434-8ce0-d7ea6137dee9)
   - **Sobre:** Comunicações de acidentes ambientais registradas no Sistema Nacional de Emergências Ambientais (Siema);
   - **Função:** Dados para de georeferenciamento, para serem comparados com a localização das operações do BNDES nos municípios. 

- [Áreas embargadas](https://dados.gov.br/dataset/areas-embargadas-pelo-ibama/resource/e52f8170-4827-4255-bac0-244a25d552d4)
   - **Sobre:** Dataset de Áreas Embargadas pelo IBAMA;
   - **Função:** Dados para de georeferenciamento, para serem comparados com a localização das operações do BNDES nos municípios.

- [Unidades de conservação](https://dados.gov.br/dataset/unidadesdeconservacao)
   - **Sobre:** Lista das UCs ativas no CNUC com respectivas categorias de manejo, área, esfera de governo e ano de criação;
   - **Função:** Dados para de georeferenciamento, para serem comparados com a localização das operações do BNDES nos municípios.
        - Obs.: dados coletados com pacote do [GeoBR](https://github.com/ipeaGIT/geobr)
  
- [Ocorrências de Incêndio Florestais](https://dados.gov.br/dataset/sisfogo-registro-de-ocorrencias-de-incendio-roi/resource/2042f6b8-73a5-4797-b892-399fea60e429)
   - **Sobre:** Registro de Ocorrências de Incêndio verificadas pelas brigadas Prevfogo;
   - **Função:** Dados para de georeferenciamento, para serem comparados com a localização das operações do BNDES nos municípios.

- [Reservas indígenas](https://dados.gov.br/dataset/tabela-de-terras-indigenas)
   - **Sobre:** Tabelas que contém dados sobre as terras indígenas, aldeias, Coordenações Regionais e Coordenações Técnicas Locais da Funai.;
   - **Função:** Dados para de georeferenciamento, para serem comparados com a localização das operações do BNDES nos municípios
        - Obs.: dados coletados com pacote do [GeoBR](https://github.com/ipeaGIT/geobr)
   
- [Geolocalização dos municípios brasileiros](https://github.com/kelvins/Municipios-Brasileiros)
   - **Sobre:** é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - **Função:** este dataset foi útil para geolocalizar empresas

- [PIB municipal](https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/9088-produto-interno-bruto-dos-municipios.html?=&t=o-que-e)
   - **Sobre:** São apresentados, a preços correntes, os valores adicionados brutos dos três grandes setores de atividade econômica – Agropecuária, Indústria e Serviços – bem como os impostos, líquidos de subsídios, o PIB e o PIB per capita;
   - **Função:** útil para AED dos dados de financiamento

## Modelagem


O modelo preditivo Gaia foi desenvolvido com redes neurais através da biblioteca [LightAutoML (LAMA)](https://github.com/sberbank-ai-lab/LightAutoML). Para processar os textos de variáveis como razão social e CNAE dos clientes, utilizou-se do modelo de vetorização pré-treinado [BERT multilingual base model (cased)](https://huggingface.co/bert-base-multilingual-cased).

## Features do dashboard

<p align="center">
  <img width="600" height="500" src="https://github.com/pbizil/gaia_bndes/blob/main/imgs/map_carbon.png">
</p>

## Stack de tecnologia e ferramentas

- Linguagem Python para extração e organizacao dados, além da modelagem do Gaia;
- Linguagem R para visualização;
- SQL para requisição de dados de CNPJ;
- [ShinyDashboard](https://github.com/rstudio/shinydashboard) para criação do interface de visualização;
- API de [Google Maps Services](https://github.com/googlemaps/google-maps-services-python) para extração de geocode;
- [Leaflet](https://github.com/rstudio/leaflet) para visualização de dados geolocalizados;
- [LightAutoML (LAMA)](https://github.com/sberbank-ai-lab/LightAutoML) para construção do modelo Gaia;
- Modelo [BERT](https://huggingface.co/bert-base-multilingual-cased) para processar os textos em dados tabulares;




## Autores

- Renata Guanaes
- [Pedro Andrade](pedrokeyloger@gmail.com)

## Referências

Agradecemos a todos projetos open-source que tornaram o desenvolvimento dessa solução possível. Tks! :slightly_smiling_face:

- [Minha Receita](https://github.com/cuducos/minha-receita): API web para consulta de informações do CNPJ (Cadastro Nacional da Pessoa Jurídica) da Receita Federal.
- [Brasil.io](https://github.com/turicas/brasil.io): referência para quem procura ou quer publicar dados abertos sobre o Brasil de forma organizada, legível por máquina e usando padrões abertos. 
- [BaseDosDados](https://basedosdados.org/): plataforma que visa facilitar o acesso a base de dados nacionais e internacionais. 
- [GeoBR](https://github.com/ipeaGIT/geobr): pacote em R com dados georeferenciados do Brasil sobre diversos temas. Neste trabalho, utilizou-se o georeferenciamento de reservas indígenas e unidades de conservação, ambas bases do IBAMA.
- [LightAutoML (LAMA)](https://github.com/sberbank-ai-lab/LightAutoML): é uma **framework open source de AutoML** desenvolvida pelo Sberbak AI Lab AutoML Group. É uma ferramenta para desenvolvimento de modelos que envolvam problemas de classificação binária, multiclass e regressão. 
- [HuggingFace](https://huggingface.co/): Comunidade de AI para compartilhar modelos pré-treinados, principalmente voltados a processamento de linguagem natural. 





