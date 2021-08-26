<p align="center">
  <img width="500" height="450" src="https://github.com/pbizil/gaia_bndes/blob/main/gaia_bndes.png">
</p>

Este projeto consiste em uma aplicação voltada para o [Prêmio Dados Abertos para o Desenvolvimento](https://www.bndes.gov.br/wps/portal/site/home/transparencia/iniciativas/!ut/p/z0/fY5PC4JAFMTvfYoue5S3QmRXs_APEUgedC_y0iVe5a7ubtLHT0Q8NocZfjADAwJKEApHeqAjrfA9cSX2dZDHURLu_MuhSCKeR9kEQezHqQ_ZZjtrsxqI_4tyWSz1NaCi5zCIEESjlZNfB-Xxejrf6lRZR-7TzI8YT3QnGS8MKtujkaohZJwUTeloRMt4b2RH2mux1dbDuzROW-hfovoBqFEnTw!!/), realizado pelo BNDES. 

Gaia é um robô que identifica, através de informações sobre o CNPJ, a probabilidade da empresa ser uma poluidora do meio ambiente. O nome do modelo faz alusão à deusa da mitologia grega, que personifica a deusa da Terra, geradora de todos os deuses e criadora do planeta. 

Esta aplicação foi criada com intuito de auxiliar às equipes de negócio BNDES a identificar como a carteira de clientes está a exposta ao risco ambiental, principalmente dos riscos envolvidos nas empresas que tomam crédito. 

## Produtos:

- Análise exploratória dos dados de operações indiretas automáticas do BNDES;
- Modelo de identificação do potencial poluidor de determinada empresa, a partir dos dados do CNPJ;
- Dashboard em shiny com análise dos resultados das previsões do modelo Gaia sobre os dados de operações automáticas indiretas a partir de 2016;


## Bases de dados:

- [Operações indiretas automáticas do BNDES](https://dadosabertos.bndes.gov.br/dataset/operacoes-financiamento/resource/9534f677-9525-4bf8-a3aa-fd5d3e152a93) 
   - **Sobre:** Informações detalhadas sobre as operações indiretas contratadas de forma automática. Nas operações indiretas, a análise do financiamento é feita pela instituição financeira credenciada, que assume o risco de não pagamento da operação. É ela também que negocia com o cliente as condições do financiamento, como prazo de pagamento, spread de risco e garantias exigidas, respeitando algumas regras e limites definidos pelo BNDES. Não foram incluídas nesta listagem as operações do Cartão BNDES e nem as contratadas com Pessoas Físicas. Dados, em reais, a partir de 2002;
   - **Função:** principal dataset deste projeto. Com estes dados foi possível analisar como está a carteira de clientes de operações indiretas do BNDES sob a ótica dos riscos ambientais.

- [Cadastro de empresas potencialmente poluidoras](https://dados.gov.br/dataset/pessoas-juridicas-inscritas-no-ctf-app)
   - **Sobre:** Relação das pessoas jurídicas que efetuaram a inscrição no Cadastro Técnico Federal de Atividades Potencialmente Poluidoras e Utilizadoras de Recursos Naturais – CTF/APP. Neste link consta apenas uma parte de base de dados, que está dividada por Unidade Federativa;
   - **Função:** Dados sobre CNPJ de empresas consideradas potencialmente poluidoras.

- [Acidentes ambientais](https://dados.gov.br/dataset/comunicacao-de-acidentes-ambientais/resource/1fba1942-3070-4434-8ce0-d7ea6137dee9)
   - **Sobre:** é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - **Função:** este dataset foi útil para geolocalizar empresas, principalmente aquelas identificadas no 

- [Áreas embargadas]()
   - **Sobre:** é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - **Função:** este dataset foi útil para geolocalizar empresas, principalmente aquelas identificadas no 

- [Unidades de conservação](https://dados.gov.br/dataset/unidadesdeconservacao)
   - **Sobre:** é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - **Função:** este dataset foi útil para geolocalizar empresas, principalmente aquelas identificadas no 

- [Incêndios](https://dados.gov.br/dataset/unidadesdeconservacao)
   - **Sobre:** é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - **Função:** este dataset foi útil para geolocalizar empresas, principalmente aquelas identificadas no 

- [Reservas indígenas](https://github.com/kelvins/Municipios-Brasileiros)
   - **Sobre:** é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - **Função:** este dataset foi útil para geolocalizar empresas, principalmente aquelas identificadas no 
        - Obs.: dados coletados com pacote do [GeoBR](https://github.com/ipeaGIT/geobr)
   
- [Geolocalização dos municípios brasileiros](https://github.com/kelvins/Municipios-Brasileiros)
   - **Sobre:** é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - **Função:** este dataset foi útil para geolocalizar empresas, principalmente aquelas identificadas no 


## Stack de tecnologia e ferramentas:

- Linguagem Python para extração e organizacao dados, além da modelagem do Gaia;
- Linguagem R para visualização;
- SQL para requisição de dados de CNPJ;
- Shiny para criação do dashboard;
- Biblioteca Leaflet para visualização de dados geolocalizados;
- Biblioteca LightAutoML para construção do modelo Gaia;
- Modelo de NLP pré-treinado;

## Features do dashboard:


## Referências:

- [Minha receita](https://github.com/cuducos/minha-receita): API web para consulta de informações do CNPJ (Cadastro Nacional da Pessoa Jurídica) da Receita Federal.
- [Brasil.io](https://github.com/turicas/brasil.io): referência para quem procura ou quer publicar dados abertos sobre o Brasil de forma organizada, legível por máquina e usando padrões abertos. 
- [BaseDosDados](https://basedosdados.org/): plataforma que visa facilitar o acesso a base de dados nacionais e internacionais. 
- [GeoBR](https://github.com/ipeaGIT/geobr): pacote em R com dados georeferenciados do Brasil sobre diversos temas. Neste trabalho, utilizou-se o georeferenciamento de reservas indígenas e unidades de conservação, ambas bases do IBAMA.
- [LightAutoML (LAMA)](https://github.com/sberbank-ai-lab/LightAutoML): é uma **framework open source de AutoML** desenvolvida pelo Sberbak AI Lab AutoML Group. É uma ferramenta para desenvolvimento de modelos que envolvam problemas de classificação binária, multiclass e regressão. 
- HuggingFace





