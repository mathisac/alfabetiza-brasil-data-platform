# Decisões Técnicas

## Visão geral

A Alfabetiza Brasil Data Platform foi construída em GCP para integrar, tratar e disponibilizar dados educacionais relacionados à alfabetização infantil no Brasil. A solução combina ingestão batch, streaming simulado, arquitetura Medalhão e validações de qualidade antes da disponibilização da camada analítica.

## Ambiente de nuvem

O BigQuery foi adotado como mecanismo principal de armazenamento e processamento analítico por oferecer execução serverless, integração direta com Python e SQL, escalabilidade sob demanda e baixa necessidade de administração de infraestrutura.

O desenvolvimento e a orquestração acadêmica foram realizados no Google Colab. Os datasets Bronze, Silver e Gold foram provisionados manualmente no BigQuery, enquanto os notebooks executam as cargas, transformações, validações e exportações de evidências.

## Arquitetura Medalhão

A solução foi organizada em três camadas:

- **Bronze:** preserva os dados ingeridos com o mínimo de transformação.
- **Silver:** realiza limpeza, padronização, tratamento de tipos, normalização de chaves e integração entre fontes.
- **Gold:** disponibiliza tabelas analíticas para comparação entre resultados e metas, evolução temporal, análises territoriais e aplicações futuras de machine learning.

Essa separação melhora a rastreabilidade e reduz o risco de regras analíticas serem aplicadas diretamente sobre dados brutos.

## Processamento batch

O pipeline batch utiliza full refresh para reconstruir as tabelas de referência a partir das fontes históricas. Essa abordagem foi escolhida por simplicidade operacional e reprodutibilidade no contexto acadêmico.

Em um ambiente de produção com maior volume ou frequência de atualização, a estratégia pode ser substituída por cargas incrementais baseadas em data de atualização, partições ou mecanismos de change data capture.

## Streaming simulado

O streaming foi implementado como simulação local no Google Colab. O ambiente não permanece ativo continuamente como um serviço gerenciado de produção, mas a solução reproduz conceitos essenciais:

- chegada sequencial de eventos;
- validação de esquema;
- separação entre registros aceitos e rejeitados;
- persistência em JSONL e Parquet;
- geração de logs, resumo e manifesto;
- identificação única da execução.

Os eventos simulados foram mantidos isolados dos dados oficiais para evitar contaminação das análises.

## Formatos de armazenamento

O JSONL foi utilizado para representar eventos sequenciais e facilitar inspeção e auditoria. O Parquet foi utilizado como formato colunar para demonstrar eficiência de armazenamento, preservação de tipos e melhor adequação a cargas analíticas.

## Qualidade de dados

O quality gate da Bronze foi implementado em Python porque envolve inspeção dinâmica de metadados do BigQuery, existência de tabelas, contagem de registros e tratamento de exceções da API.

Os quality gates da Silver e Gold foram implementados em SQL porque concentram validações sobre o conteúdo dos dados, como duplicidades, valores ausentes, integridade de chaves e consistência entre tabelas.

O pipeline deve interromper a progressão para a próxima camada quando um quality gate é reprovado.

## Valores ausentes

Valores nulos não são preenchidos automaticamente sem justificativa de negócio. A preservação de ausências legítimas evita a criação de informação artificial e permite que a camada analítica trate cada caso de acordo com seu contexto.

## Critério de alfabetização

O ponto de corte de 743 pontos na escala de proficiência do Saeb foi mantido como referência para classificação de alfabetização, conforme o contexto do Indicador Criança Alfabetizada.

## Camada Gold e machine learning

A camada Gold inclui uma visão preparada para futuras aplicações de machine learning. A seleção de variáveis deve respeitar o momento em que cada informação se torna disponível, evitando data leakage.

Variáveis que só existem após a medição do resultado não devem ser usadas para prever esse mesmo resultado.

## Particionamento e clustering

Particionamento e clustering são utilizados quando compatíveis com a granularidade e o padrão de consulta das tabelas. A reconstrução de tabelas Gold pode ser necessária quando a especificação física de armazenamento precisa ser alterada.

## Limitações

- O streaming é uma simulação e não um serviço continuamente ativo.
- A solução foi desenvolvida em ambiente acadêmico e não possui orquestrador gerenciado.
- O full refresh prioriza simplicidade e pode não ser a melhor opção para grandes volumes.
- Monitoramento e alertas são registrados por arquivos e podem evoluir para serviços nativos da GCP.
