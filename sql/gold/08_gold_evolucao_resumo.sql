CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.gold.evolucao_municipio`

CLUSTER BY
  sigla_uf,
  id_municipio,
  rede

AS

WITH consolidacao AS (
  SELECT
    id_municipio,
    ANY_VALUE(nome_municipio) AS nome_municipio,
    ANY_VALUE(sigla_uf) AS sigla_uf,
    ANY_VALUE(regiao) AS regiao,
    rede,

    MAX(
      IF(
        ano = 2023,
        resultado_alfabetizacao,
        NULL
      )
    ) AS resultado_2023,

    MAX(
      IF(
        ano = 2024,
        resultado_alfabetizacao,
        NULL
      )
    ) AS resultado_2024,

    MAX(
      IF(
        ano = 2024,
        meta_alfabetizacao_ano,
        NULL
      )
    ) AS meta_2024,

    MAX(
      IF(
        ano = 2024,
        status_meta,
        NULL
      )
    ) AS status_meta_2024,

    MAX(
      IF(
        ano = 2024,
        percentual_participacao,
        NULL
      )
    ) AS percentual_participacao_2024

  FROM
    `macro-coil-475920-k5.gold.indicador_municipio`

  WHERE
    ano IN (2023, 2024)

  GROUP BY
    id_municipio,
    rede
),

metricas AS (
  SELECT
    id_municipio,
    nome_municipio,
    sigla_uf,
    regiao,
    rede,
    resultado_2023,
    resultado_2024,
    meta_2024,
    status_meta_2024,
    percentual_participacao_2024,

    CASE
      WHEN
        resultado_2023 IS NOT NULL
        AND resultado_2024 IS NOT NULL
      THEN ROUND(
        resultado_2024 - resultado_2023,
        2
      )

      ELSE NULL
    END AS variacao_pontos_percentuais

  FROM
    consolidacao
)

SELECT
  CONCAT(
    id_municipio,
    '|',
    rede
  ) AS chave_municipio_rede,

  id_municipio,
  nome_municipio,
  sigla_uf,
  regiao,
  rede,
  resultado_2023,
  resultado_2024,
  variacao_pontos_percentuais,

  CASE
    WHEN resultado_2023 IS NULL
      AND resultado_2024 IS NULL
      THEN 'sem_resultados'

    WHEN resultado_2023 IS NULL
      THEN 'sem_base_2023'

    WHEN resultado_2024 IS NULL
      THEN 'sem_resultado_2024'

    WHEN variacao_pontos_percentuais >= 0.01
      THEN 'avancou'

    WHEN variacao_pontos_percentuais <= -0.01
      THEN 'recuou'

    ELSE 'estavel'
  END AS status_evolucao,

  meta_2024,
  status_meta_2024,
  percentual_participacao_2024,
  CURRENT_TIMESTAMP() AS processado_em

FROM
  metricas;


CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.gold.resumo_regiao`

CLUSTER BY
  regiao,
  rede

AS

WITH agregacao AS (
  SELECT
    ano,
    regiao,
    rede,

    COUNT(*) AS municipios_total,

    COUNTIF(
      resultado_alfabetizacao IS NOT NULL
    ) AS municipios_com_resultado,

    COUNTIF(
      meta_alfabetizacao_ano IS NOT NULL
    ) AS municipios_com_meta,

    COUNTIF(
      resultado_alfabetizacao IS NOT NULL
      AND meta_alfabetizacao_ano IS NOT NULL
    ) AS municipios_com_comparacao,

    COUNTIF(
      status_meta = 'meta_atingida'
    ) AS municipios_meta_atingida,

    COUNTIF(
      status_meta = 'meta_nao_atingida'
    ) AS municipios_meta_nao_atingida,

    ROUND(
      AVG(resultado_alfabetizacao),
      2
    ) AS media_resultado_alfabetizacao,

    ROUND(
      AVG(meta_alfabetizacao_ano),
      2
    ) AS media_meta_alfabetizacao,

    ROUND(
      AVG(diferenca_resultado_meta),
      2
    ) AS media_diferenca_resultado_meta,

    ROUND(
      AVG(gap_para_meta),
      2
    ) AS media_gap_para_meta

  FROM
    `macro-coil-475920-k5.gold.indicador_municipio`

  GROUP BY
    ano,
    regiao,
    rede
)

SELECT
  CONCAT(
    CAST(ano AS STRING),
    '|',
    regiao,
    '|',
    rede
  ) AS chave_ano_regiao_rede,

  ano,
  regiao,
  rede,
  municipios_total,
  municipios_com_resultado,
  municipios_com_meta,
  municipios_com_comparacao,
  municipios_meta_atingida,
  municipios_meta_nao_atingida,
  media_resultado_alfabetizacao,
  media_meta_alfabetizacao,
  media_diferenca_resultado_meta,
  media_gap_para_meta,

  ROUND(
    SAFE_DIVIDE(
      municipios_meta_atingida,
      municipios_com_comparacao
    ) * 100,
    2
  ) AS percentual_municipios_meta_atingida,

  CURRENT_TIMESTAMP() AS processado_em

FROM
  agregacao