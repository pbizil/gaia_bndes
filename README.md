<p align="center">
  <img width="500" height="450" src="https://github.com/pbizil/gaia_bndes/blob/main/gaia_bndes.png">
</p>

Este projeto consiste em uma aplicação voltada para o Prêmio Dados Abertos do BNDES. 

Gaia é um robô que identifica, através de informações sobre o CNPJ, a probabilidade da empresa ser uma poluidora do meio ambiente. O nome do modelo faz alusão à deusa da mitologia grega, que personifica a deusa da Terra, geradora de todos os deuses e criadora do planeta. 

Esta aplicação foi criada com intuito de auxiliar às equipes de negócio BNDES a identificar como a carteira de clientes está a exposta ao risco ambiental, principalmente dos riscos envolvidos nas empresas que tomam crédito. 

## Produtos:

- Análise exploratória dos dados de operações indiretas automáticas do BNDES;
- Modelo de identificação do potencial poluidor de determinada empresa, a partir dos dados do CNPJ;
- Dashboard em shiny com análise dos resultados das previsões do modelo Gaia;


## Bases de dados:

- [Operações indiretas automáticas do BNDES]() 
- Cadastro de empresas potencialmente poluidoras
- Acidentes ambientais
- Áreas embargadas 
- [Unidades de conservação](https://dados.gov.br/dataset/unidadesdeconservacao)
- [Incêndios](https://dados.gov.br/dataset/unidadesdeconservacao)
- [Reservas indígenas](https://github.com/kelvins/Municipios-Brasileiros)
   - Sobre: é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - Função: este dataset foi útil para geolocalizar empresas, principalmente aquelas identificadas no 
- [Geolocalização dos municípios brasileiros](https://github.com/kelvins/Municipios-Brasileiros)
   - Sobre: é um dataset simples, mas eficaz, latitude e longitude dos municípios brasileiros;
   - Função: este dataset foi útil para geolocalizar empresas, principalmente aquelas identificadas no 


## Stack de tecnologia e ferramentas:

- Linguagem Python para extração e organizacao dados, além da modelagem do Gaia;
- Linguagem R para visualização;
- Shiny para criação do dashboard;

## Features do dashboard:


## Referências:

- [Minha receita](https://github.com/cuducos/minha-receita): API web para consulta de informações do CNPJ (Cadastro Nacional da Pessoa Jurídica) da Receita Federal.
- [Brasil.io](https://github.com/turicas/brasil.io): referência para quem procura ou quer publicar dados abertos sobre o Brasil de forma organizada, legível por máquina e usando padrões abertos. 
- [BaseDosDados](https://basedosdados.org/): plataforma que visa facilitar o acesso a base de dados nacionais e internacionais. 
- [GeoBR](https://github.com/ipeaGIT/geobr): pacote em R com dados georeferenciados do Brasil sobre diversos temas. Neste trabalho, utilizou-se o georeferenciamento de reservas indígenas e unidades de conservação, ambas bases do IBAMA.
- [LightAutoML (LAMA)](https://github.com/sberbank-ai-lab/LightAutoML): é uma **framework open source de AutoML** desenvolvida pelo Sberbak AI Lab AutoML Group. É uma ferramenta para desenvolvimento de modelos que envolvam problemas de classificação binária, multiclass e regressão. 





