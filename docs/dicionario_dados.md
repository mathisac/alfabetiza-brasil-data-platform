# Dicionário de Dados

Este documento descreve as principais estruturas produzidas pela plataforma **Alfabetiza Brasil Data Platform**, organizadas segundo a Arquitetura Medalhão.

A documentação foi construída a partir das consultas SQL versionadas no projeto. Os tipos indicados representam os tipos esperados no BigQuery após as transformações. As tabelas da camada Bronze preservam o schema original das fontes e, por isso, podem acompanhar alterações futuras do dataset público.

---

## Convenções

| Termo | Significado |
|---|---|
| **Grão** | O que cada linha da tabela representa |
| **Chave lógica** | Conjunto de campos usado para identificar unicamente um registro |
| **Disponível** | Campo presente e não nulo na fonte |
| **p.p.** | Pontos percentuais |
| **Meta atingida** | Resultado de alfabetização maior ou igual à meta do ano |
| **Avaliação válida** | Aluno presente, caderno preenchido, proficiência e peso disponíveis |
| **Processado em** | Data e hora em que a tabela foi reconstruída |

---

# 1. Camada Bronze

A camada Bronze recebe os dados com o mínimo de transformação, por meio de cópia integral das tabelas públicas.

Fonte principal:

```text
basedosdados.br_inep_avaliacao_alfabetizacao
```

## 1.1 Inventário das tabelas Bronze

| Tabela | Grão | Descrição |
|---|---|---|
| `bronze.alunos` | Um aluno avaliado por ano | Microdados das avaliações de alfabetização |
| `bronze.dicionario` | Uma variável ou categoria da fonte | Dicionário original disponibilizado pela Base dos Dados |
| `bronze.meta_alfabetizacao_brasil` | Ano e rede no Brasil | Resultado, participação e metas nacionais |
| `bronze.meta_alfabetizacao_uf` | Ano, UF e rede | Resultado, participação e metas estaduais |
| `bronze.meta_alfabetizacao_municipio` | Ano, município e rede | Resultado, participação e metas municipais |
| `bronze.municipio` | Ano, município, série e rede | Indicadores agregados municipais |
| `bronze.uf` | Ano, UF, série e rede | Indicadores agregados estaduais |

## 1.2 Principais campos preservados da fonte

### `bronze.alunos`

| Campo | Descrição |
|---|---|
| `ano` | Ano da avaliação |
| `id_municipio` | Código do município |
| `id_escola` | Identificador da escola |
| `id_aluno` | Identificador anonimizado do aluno |
| `caderno` | Código ou versão do caderno de avaliação |
| `serie` | Série ou etapa avaliada |
| `rede` | Rede de ensino |
| `presenca` | Indicador de presença |
| `preenchimento_caderno` | Indicador de preenchimento do caderno |
| `alfabetizado` | Classificação oficial do aluno |
| `proficiencia` | Pontuação de proficiência |
| `peso_aluno` | Peso amostral do aluno |

### Tabelas de metas

| Campo | Descrição |
|---|---|
| `ano` | Ano do resultado observado |
| `rede` | Rede de ensino |
| `sigla_uf` | Sigla da UF, quando aplicável |
| `id_municipio` | Código municipal, quando aplicável |
| `taxa_alfabetizacao` | Resultado observado de alfabetização |
| `nivel_alfabetizacao` | Nível de alfabetização informado para o município |
| `percentual_participacao` | Percentual de participação na avaliação |
| `meta_alfabetizacao_2024` a `meta_alfabetizacao_2030` | Metas anuais de alfabetização |

### Tabelas territoriais

| Campo | Descrição |
|---|---|
| `ano` | Ano de referência |
| `id_municipio` | Código municipal |
| `sigla_uf` | Sigla da UF |
| `serie` | Série avaliada |
| `rede` | Rede de ensino |
| `taxa_alfabetizacao` | Taxa observada de alfabetização |
| `media_portugues` | Média de desempenho em Língua Portuguesa |
| `proporcao_aluno_nivel_0` a `proporcao_aluno_nivel_8` | Distribuição proporcional dos alunos por nível |

> A definição completa do schema original permanece disponível na própria tabela `bronze.dicionario` e na fonte pública.

---

# 2. Camada Silver

A camada Silver padroniza tipos, normaliza chaves, cria indicadores de qualidade e integra informações territoriais.

## 2.1 `silver.alunos`

**Grão:** um aluno por ano.  
**Chave lógica:** `(ano, id_aluno)`.  
**Particionamento:** `ano`.  
**Clustering:** `id_municipio`, `rede`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_aluno` | STRING | Chave composta no formato `ano|id_aluno` |
| `ano` | INT64 | Ano da avaliação |
| `id_municipio` | STRING | Código municipal padronizado |
| `id_escola` | STRING | Identificador da escola padronizado |
| `id_aluno` | STRING | Identificador anonimizado do aluno |
| `caderno` | STRING | Código ou versão do caderno |
| `serie` | STRING | Série ou etapa avaliada |
| `rede` | STRING | Rede de ensino |
| `presenca` | INT64 | Indicador original de presença |
| `preenchimento_caderno` | INT64 | Indicador original de preenchimento |
| `alfabetizado_oficial` | INT64 | Classificação oficial da fonte |
| `proficiencia` | FLOAT64 | Pontuação de proficiência |
| `peso_aluno` | FLOAT64 | Peso amostral |
| `presente` | BOOL | Verdadeiro quando `presenca = 1` |
| `caderno_preenchido` | BOOL | Verdadeiro quando `preenchimento_caderno = 1` |
| `avaliacao_valida` | BOOL | Presença, preenchimento, proficiência e peso disponíveis |
| `status_avaliacao` | STRING | Situação consolidada da avaliação |
| `alfabetizado_calculado_743` | INT64 | Classificação recalculada pelo corte de 743 pontos |
| `classificacao_coerente_743` | BOOL | Indica coerência entre a classificação oficial e o corte de 743 |
| `processado_em` | TIMESTAMP | Momento de processamento |

### Valores de `status_avaliacao`

| Valor | Regra |
|---|---|
| `ausente` | `presenca = 0` |
| `presente_sem_preenchimento` | Presente, mas sem preenchimento |
| `avaliacao_valida` | Atende a todas as condições de validade |
| `situacao_inconsistente` | Não se enquadra nas regras anteriores |

---

## 2.2 `silver.municipio`

**Grão:** ano, município, série e rede.  
**Chave lógica:** `(ano, id_municipio, serie, rede)`.  
**Particionamento:** `ano`.  
**Clustering:** `sigla_uf`, `id_municipio`, `rede`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_municipio_serie_rede` | STRING | Chave composta da linha |
| `ano` | INT64 | Ano de referência |
| `id_municipio` | STRING | Código municipal |
| `nome_municipio` | STRING | Nome oficial do município |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |
| `serie` | STRING | Série avaliada |
| `rede` | STRING | Rede de ensino |
| `taxa_alfabetizacao_observada` | FLOAT64 | Taxa observada de alfabetização |
| `media_portugues` | FLOAT64 | Média de Língua Portuguesa |
| `proporcao_aluno_nivel_0` a `proporcao_aluno_nivel_8` | FLOAT64 | Distribuição proporcional por nível |
| `taxa_observada_disponivel` | BOOL | Indica presença da taxa observada |
| `distribuicao_niveis_disponivel` | BOOL | Indica disponibilidade de todos os níveis |
| `status_distribuicao_niveis` | STRING | `disponivel` ou `nao_disponivel_na_fonte` |
| `municipio_encontrado_no_diretorio` | BOOL | Indica correspondência no diretório territorial |
| `processado_em` | TIMESTAMP | Momento de processamento |

---

## 2.3 `silver.uf`

**Grão:** ano, UF, série e rede.  
**Chave lógica:** `(ano, sigla_uf, serie, rede)`.  
**Particionamento:** `ano`.  
**Clustering:** `sigla_uf`, `rede`.

Os campos analíticos são equivalentes aos de `silver.municipio`, com substituição do município pela UF:

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_uf_serie_rede` | STRING | Chave composta da linha |
| `ano` | INT64 | Ano de referência |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |
| `serie` | STRING | Série avaliada |
| `rede` | STRING | Rede de ensino |
| `taxa_alfabetizacao_observada` | FLOAT64 | Taxa observada de alfabetização |
| `media_portugues` | FLOAT64 | Média de Língua Portuguesa |
| `proporcao_aluno_nivel_0` a `proporcao_aluno_nivel_8` | FLOAT64 | Distribuição proporcional por nível |
| `taxa_observada_disponivel` | BOOL | Indica presença da taxa |
| `distribuicao_niveis_disponivel` | BOOL | Indica disponibilidade de todos os níveis |
| `status_distribuicao_niveis` | STRING | Situação da distribuição |
| `processado_em` | TIMESTAMP | Momento de processamento |

---

## 2.4 `silver.dim_municipio`

**Grão:** um município.  
**Chave lógica:** `id_municipio`.  
**Clustering:** `sigla_uf`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `id_municipio` | STRING | Código municipal |
| `nome_municipio` | STRING | Nome oficial do município |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |
| `processado_em` | TIMESTAMP | Momento de processamento |

---

## 2.5 `silver.meta_alfabetizacao_brasil`

**Grão:** ano e rede.  
**Chave lógica:** `(ano, rede)`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_rede` | STRING | Chave composta |
| `ano` | INT64 | Ano do resultado observado |
| `rede` | STRING | Rede de ensino |
| `taxa_alfabetizacao_observada` | FLOAT64 | Resultado nacional observado |
| `percentual_participacao` | FLOAT64 | Participação nacional |
| `meta_alfabetizacao_2024` a `meta_alfabetizacao_2030` | FLOAT64 | Metas anuais |
| `taxa_observada_disponivel` | BOOL | Presença do resultado observado |
| `participacao_disponivel` | BOOL | Presença da participação |
| `meta_2024_disponivel` a `meta_2030_disponivel` | BOOL | Presença de cada meta |
| `serie_metas_completa` | BOOL | Todas as metas de 2024 a 2030 disponíveis |
| `status_serie_metas` | STRING | `completa` ou `incompleta_na_fonte` |
| `processado_em` | TIMESTAMP | Momento de processamento |

---

## 2.6 `silver.meta_alfabetizacao_uf`

**Grão:** ano, UF e rede.  
**Chave lógica:** `(ano, sigla_uf, rede)`.

Possui os mesmos campos da tabela nacional, acrescidos de:

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_uf_rede` | STRING | Chave composta |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |

---

## 2.7 `silver.meta_alfabetizacao_municipio`

**Grão:** ano, município e rede.  
**Chave lógica:** `(ano, id_municipio, rede)`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_municipio_rede` | STRING | Chave composta |
| `ano` | INT64 | Ano do resultado observado |
| `id_municipio` | STRING | Código municipal |
| `nome_municipio` | STRING | Nome oficial do município |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |
| `rede` | STRING | Rede de ensino |
| `taxa_alfabetizacao_observada` | FLOAT64 | Resultado municipal observado |
| `nivel_alfabetizacao` | FLOAT64 | Nível informado pela fonte |
| `percentual_participacao` | FLOAT64 | Participação municipal |
| `meta_alfabetizacao_2024` a `meta_alfabetizacao_2030` | FLOAT64 | Metas anuais |
| `taxa_observada_disponivel` | BOOL | Presença do resultado |
| `nivel_alfabetizacao_disponivel` | BOOL | Presença do nível |
| `participacao_disponivel` | BOOL | Presença da participação |
| `meta_2024_disponivel` a `meta_2030_disponivel` | BOOL | Presença de cada meta |
| `serie_metas_completa` | BOOL | Todas as metas disponíveis |
| `status_serie_metas` | STRING | Situação da série de metas |
| `municipio_encontrado_no_diretorio` | BOOL | Correspondência territorial válida |
| `processado_em` | TIMESTAMP | Momento de processamento |

---

# 3. Camada Gold

A camada Gold contém estruturas orientadas à análise, acompanhamento de metas, evolução temporal e preparação para Machine Learning.

## 3.1 `gold.indicador_municipio`

**Grão:** ano, município e rede.  
**Chave lógica:** `(ano, id_municipio, rede)`.  
**Particionamento:** `ano`.  
**Clustering:** `sigla_uf`, `id_municipio`, `rede`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_municipio_rede` | STRING | Chave composta |
| `ano` | INT64 | Ano de referência |
| `id_municipio` | STRING | Código municipal |
| `nome_municipio` | STRING | Nome oficial do município |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |
| `rede` | STRING | Rede de ensino |
| `resultado_alfabetizacao` | NUMERIC | Resultado observado arredondado |
| `meta_alfabetizacao_ano` | NUMERIC | Meta correspondente ao ano da linha |
| `diferenca_resultado_meta` | NUMERIC | Resultado menos meta, em p.p. |
| `gap_para_meta` | NUMERIC | Quanto falta para atingir a meta; zero quando atingida |
| `excedente_acima_meta` | NUMERIC | Quanto o resultado supera a meta; zero quando não supera |
| `status_meta` | STRING | Situação do resultado em relação à meta |
| `nivel_alfabetizacao` | FLOAT64 | Nível municipal informado pela fonte |
| `percentual_participacao` | NUMERIC | Participação na avaliação |
| `taxa_observada_disponivel` | BOOL | Presença do resultado |
| `participacao_disponivel` | BOOL | Presença da participação |
| `serie_metas_completa` | BOOL | Disponibilidade das metas de 2024 a 2030 |
| `status_serie_metas` | STRING | Situação da série de metas |
| `municipio_encontrado_no_diretorio` | BOOL | Correspondência no diretório |
| `processado_em` | TIMESTAMP | Momento de processamento |

### Valores de `status_meta`

| Valor | Regra |
|---|---|
| `resultado_indisponivel` | Resultado nulo |
| `meta_indisponivel_para_o_ano` | Meta do ano nula |
| `meta_atingida` | Resultado maior ou igual à meta |
| `meta_nao_atingida` | Resultado abaixo da meta |

---

## 3.2 `gold.indicador_uf`

**Grão:** ano, UF e rede.  
**Chave lógica:** `(ano, sigla_uf, rede)`.  
**Clustering:** `sigla_uf`, `rede`.

Possui os mesmos indicadores de resultado e meta da tabela municipal:

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_uf_rede` | STRING | Chave composta |
| `ano` | INT64 | Ano |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |
| `rede` | STRING | Rede de ensino |
| `resultado_alfabetizacao` | NUMERIC | Resultado estadual |
| `meta_alfabetizacao_ano` | NUMERIC | Meta estadual do ano |
| `diferenca_resultado_meta` | NUMERIC | Resultado menos meta |
| `gap_para_meta` | NUMERIC | Déficit para alcançar a meta |
| `excedente_acima_meta` | NUMERIC | Excedente sobre a meta |
| `status_meta` | STRING | Situação em relação à meta |
| `percentual_participacao` | NUMERIC | Participação estadual |
| `taxa_observada_disponivel` | BOOL | Presença do resultado |
| `participacao_disponivel` | BOOL | Presença da participação |
| `serie_metas_completa` | BOOL | Série de metas completa |
| `status_serie_metas` | STRING | Situação da série |
| `processado_em` | TIMESTAMP | Momento de processamento |

---

## 3.3 `gold.indicador_brasil`

**Grão:** ano e rede.  
**Chave lógica:** `(ano, rede)`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_rede` | STRING | Chave composta |
| `ano` | INT64 | Ano |
| `rede` | STRING | Rede de ensino |
| `resultado_alfabetizacao` | NUMERIC | Resultado nacional |
| `meta_alfabetizacao_ano` | NUMERIC | Meta nacional do ano |
| `diferenca_resultado_meta` | NUMERIC | Resultado menos meta |
| `gap_para_meta` | NUMERIC | Déficit para alcançar a meta |
| `excedente_acima_meta` | NUMERIC | Excedente sobre a meta |
| `status_meta` | STRING | Situação em relação à meta |
| `percentual_participacao` | NUMERIC | Participação nacional |
| `taxa_observada_disponivel` | BOOL | Presença do resultado |
| `participacao_disponivel` | BOOL | Presença da participação |
| `serie_metas_completa` | BOOL | Série de metas completa |
| `status_serie_metas` | STRING | Situação da série |
| `processado_em` | TIMESTAMP | Momento de processamento |

---

## 3.4 `gold.evolucao_municipio`

**Grão:** município e rede, consolidando 2023 e 2024.  
**Chave lógica:** `(id_municipio, rede)`.  
**Clustering:** `sigla_uf`, `id_municipio`, `rede`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_municipio_rede` | STRING | Chave no formato `id_municipio|rede` |
| `id_municipio` | STRING | Código municipal |
| `nome_municipio` | STRING | Nome do município |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |
| `rede` | STRING | Rede de ensino |
| `resultado_2023` | NUMERIC | Resultado de 2023 |
| `resultado_2024` | NUMERIC | Resultado de 2024 |
| `variacao_pontos_percentuais` | NUMERIC | Resultado de 2024 menos resultado de 2023 |
| `status_evolucao` | STRING | Classificação da evolução |
| `meta_2024` | NUMERIC | Meta municipal de 2024 |
| `status_meta_2024` | STRING | Situação da meta em 2024 |
| `percentual_participacao_2024` | NUMERIC | Participação em 2024 |
| `processado_em` | TIMESTAMP | Momento de processamento |

### Valores de `status_evolucao`

| Valor | Regra |
|---|---|
| `sem_resultados` | Resultados de 2023 e 2024 ausentes |
| `sem_base_2023` | Resultado de 2023 ausente |
| `sem_resultado_2024` | Resultado de 2024 ausente |
| `avancou` | Variação maior ou igual a 0,01 p.p. |
| `recuou` | Variação menor ou igual a −0,01 p.p. |
| `estavel` | Variação entre −0,01 e 0,01 p.p. |

---

## 3.5 `gold.resumo_regiao`

**Grão:** ano, região e rede.  
**Chave lógica:** `(ano, regiao, rede)`.  
**Clustering:** `regiao`, `rede`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_regiao_rede` | STRING | Chave composta |
| `ano` | INT64 | Ano |
| `regiao` | STRING | Região geográfica |
| `rede` | STRING | Rede de ensino |
| `municipios_total` | INT64 | Total de municípios |
| `municipios_com_resultado` | INT64 | Municípios com resultado |
| `municipios_com_meta` | INT64 | Municípios com meta |
| `municipios_com_comparacao` | INT64 | Municípios com resultado e meta |
| `municipios_meta_atingida` | INT64 | Municípios que atingiram a meta |
| `municipios_meta_nao_atingida` | INT64 | Municípios abaixo da meta |
| `media_resultado_alfabetizacao` | FLOAT64 | Média simples dos resultados municipais |
| `media_meta_alfabetizacao` | FLOAT64 | Média simples das metas municipais |
| `media_diferenca_resultado_meta` | FLOAT64 | Média de resultado menos meta |
| `media_gap_para_meta` | FLOAT64 | Média do gap, incluindo zero para metas atingidas |
| `percentual_municipios_meta_atingida` | FLOAT64 | Percentual de comparações válidas com meta atingida |
| `processado_em` | TIMESTAMP | Momento de processamento |

> As médias regionais são médias simples dos registros municipais e não taxas oficiais ponderadas por população ou quantidade de alunos.

---

## 3.6 `gold.aluno_analitico`

**Grão:** um aluno por ano.  
**Chave lógica:** `(ano, id_aluno)`.  
**Particionamento:** `ano`.  
**Clustering:** `id_municipio`, `rede`.

| Campo | Tipo esperado | Descrição |
|---|---|---|
| `chave_ano_aluno` | STRING | Chave composta |
| `ano` | INT64 | Ano da avaliação |
| `id_municipio` | STRING | Código municipal |
| `nome_municipio` | STRING | Nome do município |
| `sigla_uf` | STRING | Sigla da UF |
| `regiao` | STRING | Região geográfica |
| `id_escola` | STRING | Identificador da escola |
| `id_aluno` | STRING | Identificador anonimizado |
| `caderno` | STRING | Código do caderno |
| `serie` | STRING | Série avaliada |
| `rede` | STRING | Rede de ensino |
| `presenca` | INT64 | Indicador de presença |
| `preenchimento_caderno` | INT64 | Indicador de preenchimento |
| `alfabetizado_oficial` | INT64 | Classificação oficial |
| `proficiencia` | FLOAT64 | Pontuação de proficiência |
| `peso_aluno` | FLOAT64 | Peso amostral |
| `presente` | BOOL | Presença padronizada |
| `caderno_preenchido` | BOOL | Preenchimento padronizado |
| `avaliacao_valida` | BOOL | Avaliação elegível |
| `status_avaliacao` | STRING | Situação consolidada |
| `alfabetizado_calculado_743` | INT64 | Classificação calculada pelo corte |
| `classificacao_coerente_743` | BOOL | Coerência da classificação |
| `municipio_encontrado_na_dimensao` | BOOL | Correspondência com `dim_municipio` |
| `processado_em` | TIMESTAMP | Momento de processamento |

---

## 3.7 `gold.base_ml_aluno`

**Tipo:** view.  
**Grão:** um aluno com avaliação válida por ano.  
**Chave lógica:** `(ano, id_aluno)`.

| Campo | Tipo esperado | Descrição | Uso no modelo |
|---|---|---|---|
| `chave_ano_aluno` | STRING | Chave técnica | Rastreabilidade |
| `ano` | INT64 | Ano da avaliação | Candidata |
| `id_municipio` | STRING | Código municipal | Não usar diretamente |
| `nome_municipio` | STRING | Nome municipal | Não usar diretamente |
| `sigla_uf` | STRING | UF | Categórica |
| `regiao` | STRING | Região | Categórica |
| `id_escola` | STRING | Identificador da escola | Não usar diretamente |
| `id_aluno` | STRING | Identificador anonimizado | Não usar diretamente |
| `caderno` | STRING | Versão do caderno | Categórica |
| `serie` | STRING | Série | Categórica |
| `rede` | STRING | Rede de ensino | Categórica |
| `presenca` | INT64 | Presença original | Avaliar utilidade |
| `preenchimento_caderno` | INT64 | Preenchimento original | Avaliar utilidade |
| `presente` | BOOL | Presença padronizada | Avaliar utilidade |
| `caderno_preenchido` | BOOL | Preenchimento padronizado | Avaliar utilidade |
| `peso_aluno` | FLOAT64 | Peso amostral | Peso ou variável auxiliar |
| `target_alfabetizado` | INT64 | Variável-alvo oficial | Target |
| `municipio_encontrado_na_dimensao` | BOOL | Qualidade do vínculo territorial | Controle de qualidade |
| `divisao_ml` | STRING | `treino`, `validacao` ou `teste` | Separação determinística |

### Proteção contra data leakage

A view não expõe:

- `proficiencia`;
- `alfabetizado_calculado_743`;
- `classificacao_coerente_743`.

Esses campos possuem relação direta com a definição da variável-alvo e foram excluídos da base de modelagem.

Os identificadores permanecem disponíveis somente para rastreabilidade e não devem ser usados como variáveis preditoras.

---

# 4. Relacionamentos principais

| Origem | Campo | Destino | Campo | Cardinalidade esperada |
|---|---|---|---|---|
| `silver.alunos` | `id_municipio` | `silver.dim_municipio` | `id_municipio` | Muitos para um |
| `silver.meta_alfabetizacao_municipio` | `id_municipio` | `silver.dim_municipio` | `id_municipio` | Muitos para um |
| `gold.indicador_municipio` | `id_municipio` | `silver.dim_municipio` | `id_municipio` | Muitos para um |
| `gold.aluno_analitico` | `id_municipio` | `silver.dim_municipio` | `id_municipio` | Muitos para um |
| `gold.evolucao_municipio` | `id_municipio`, `rede` | `gold.indicador_municipio` | `id_municipio`, `rede` | Um para vários anos |

---

# 5. Regras de qualidade e tratamento de nulos

- Valores ausentes legítimos da fonte são preservados.
- Proficiência e peso não são imputados.
- Ausência de meta não é substituída por zero.
- `gap_para_meta` é nulo quando não existe comparação válida.
- Quando a comparação existe e a meta é atingida, `gap_para_meta` recebe zero.
- Chaves textuais são padronizadas com remoção de espaços laterais.
- Conversões potencialmente inválidas utilizam `SAFE_CAST`.
- O pipeline é interrompido quando um quality gate obrigatório é reprovado.
- Os dados simulados do streaming não são misturados aos dados públicos oficiais.

---

# 6. Linhagem resumida

```text
Base dos Dados
    ↓
Bronze — preservação da fonte
    ↓
Silver — limpeza, padronização, qualidade e integração territorial
    ↓
Gold — indicadores, metas, evolução, análises e Machine Learning
```

---

# 7. Observações de manutenção

Este documento deve ser atualizado quando ocorrer:

- inclusão ou remoção de tabelas;
- alteração do grão;
- criação de novas colunas;
- alteração das regras de classificação;
- mudança no corte de proficiência;
- alteração da regra de divisão da base de Machine Learning;
- mudança de fonte ou schema na Base dos Dados.
