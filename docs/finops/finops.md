# Estratégia de FinOps

## Objetivo

A estratégia de FinOps busca reduzir desperdícios e tornar o custo da plataforma previsível sem comprometer a qualidade das análises.

## Decisões de eficiência

### BigQuery serverless

O BigQuery elimina a necessidade de provisionar e manter servidores dedicados. O custo está associado principalmente ao armazenamento e ao volume de dados processados pelas consultas.

### Seleção de colunas

Consultas analíticas devem evitar `SELECT *` quando não for necessário. Ler apenas as colunas utilizadas reduz o volume processado e melhora a clareza dos scripts.

### Particionamento

Tabelas com dimensão temporal podem ser particionadas para limitar a leitura aos períodos relevantes. Consultas devem aplicar filtros sobre a coluna de partição.

### Clustering

Clustering pode ser utilizado em chaves frequentemente filtradas ou agrupadas, como UF, município ou identificadores territoriais, reduzindo a quantidade de blocos lidos.

### Parquet

O Parquet foi utilizado nos artefatos do streaming por ser colunar, comprimido e eficiente para análises. Ele tende a reduzir armazenamento e leitura quando comparado a formatos textuais em cenários analíticos.

### Separação de camadas

A arquitetura Medalhão evita repetir tratamentos complexos em toda consulta. As transformações são consolidadas na Silver e as agregações de uso recorrente são materializadas na Gold.

### Quality gates

Validar os dados antes de avançar reduz o custo de processar camadas posteriores com entradas incorretas.

## Full refresh e trade-off

O full refresh foi escolhido pela simplicidade e pelo baixo volume do contexto acadêmico. Em produção, cargas incrementais seriam preferíveis para reduzir reprocessamento e custo.

A mudança para incremental deve considerar:

- campo confiável de atualização;
- particionamento temporal;
- deduplicação;
- tratamento de registros alterados;
- controle de idempotência.

## Controle de consultas

Antes de executar consultas pesadas, recomenda-se utilizar estimativa de bytes processados ou dry run. Limites de custo e alertas de orçamento devem ser configurados no projeto GCP quando disponíveis.

## Armazenamento de artefatos

Somente amostras pequenas e evidências relevantes são versionadas no GitHub. Arquivos completos de maior volume devem permanecer em armazenamento apropriado, como Google Cloud Storage ou Google Drive, com retenção definida.

## Estimativa qualitativa de custos

A arquitetura possui baixo custo no cenário atual porque:

- usa datasets pequenos;
- utiliza BigQuery sob demanda;
- executa notebooks apenas quando necessário;
- não mantém serviços de streaming continuamente ativos;
- armazena apenas pequenos artefatos no repositório.

Em produção, os principais direcionadores de custo seriam volume consultado no BigQuery, retenção de dados, frequência das cargas e uso de serviços gerenciados de orquestração e streaming.
