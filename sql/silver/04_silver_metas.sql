CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.silver.meta_alfabetizacao_brasil`

AS

SELECT
  CONCAT(
    CAST(ano AS STRING),
    '|',
    TRIM(rede)
  ) AS chave_ano_rede,

  ano,
  TRIM(rede) AS rede,

  taxa_alfabetizacao
    AS taxa_alfabetizacao_observada,

  percentual_participacao,

  meta_alfabetizacao_2024,
  meta_alfabetizacao_2025,
  meta_alfabetizacao_2026,
  meta_alfabetizacao_2027,
  meta_alfabetizacao_2028,
  meta_alfabetizacao_2029,
  meta_alfabetizacao_2030,

  taxa_alfabetizacao IS NOT NULL
    AS taxa_observada_disponivel,

  percentual_participacao IS NOT NULL
    AS participacao_disponivel,

  meta_alfabetizacao_2024 IS NOT NULL
    AS meta_2024_disponivel,

  meta_alfabetizacao_2025 IS NOT NULL
    AS meta_2025_disponivel,

  meta_alfabetizacao_2026 IS NOT NULL
    AS meta_2026_disponivel,

  meta_alfabetizacao_2027 IS NOT NULL
    AS meta_2027_disponivel,

  meta_alfabetizacao_2028 IS NOT NULL
    AS meta_2028_disponivel,

  meta_alfabetizacao_2029 IS NOT NULL
    AS meta_2029_disponivel,

  meta_alfabetizacao_2030 IS NOT NULL
    AS meta_2030_disponivel,

  (
    meta_alfabetizacao_2024 IS NOT NULL
    AND meta_alfabetizacao_2025 IS NOT NULL
    AND meta_alfabetizacao_2026 IS NOT NULL
    AND meta_alfabetizacao_2027 IS NOT NULL
    AND meta_alfabetizacao_2028 IS NOT NULL
    AND meta_alfabetizacao_2029 IS NOT NULL
    AND meta_alfabetizacao_2030 IS NOT NULL
  ) AS serie_metas_completa,

  CASE
    WHEN
      meta_alfabetizacao_2024 IS NOT NULL
      AND meta_alfabetizacao_2025 IS NOT NULL
      AND meta_alfabetizacao_2026 IS NOT NULL
      AND meta_alfabetizacao_2027 IS NOT NULL
      AND meta_alfabetizacao_2028 IS NOT NULL
      AND meta_alfabetizacao_2029 IS NOT NULL
      AND meta_alfabetizacao_2030 IS NOT NULL
    THEN 'completa'

    ELSE 'incompleta_na_fonte'
  END AS status_serie_metas,

  CURRENT_TIMESTAMP() AS processado_em

FROM
  `macro-coil-475920-k5.bronze.meta_alfabetizacao_brasil`;


CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.silver.meta_alfabetizacao_uf`

AS

SELECT
  CONCAT(
    CAST(ano AS STRING),
    '|',
    TRIM(sigla_uf),
    '|',
    TRIM(rede)
  ) AS chave_ano_uf_rede,

  ano,
  TRIM(sigla_uf) AS sigla_uf,

  CASE
    WHEN TRIM(sigla_uf) IN (
      'AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO'
    ) THEN 'Norte'

    WHEN TRIM(sigla_uf) IN (
      'AL', 'BA', 'CE', 'MA', 'PB',
      'PE', 'PI', 'RN', 'SE'
    ) THEN 'Nordeste'

    WHEN TRIM(sigla_uf) IN (
      'DF', 'GO', 'MT', 'MS'
    ) THEN 'Centro-Oeste'

    WHEN TRIM(sigla_uf) IN (
      'ES', 'MG', 'RJ', 'SP'
    ) THEN 'Sudeste'

    WHEN TRIM(sigla_uf) IN (
      'PR', 'RS', 'SC'
    ) THEN 'Sul'

    ELSE 'Região não identificada'
  END AS regiao,

  TRIM(rede) AS rede,

  taxa_alfabetizacao
    AS taxa_alfabetizacao_observada,

  percentual_participacao,

  meta_alfabetizacao_2024,
  meta_alfabetizacao_2025,
  meta_alfabetizacao_2026,
  meta_alfabetizacao_2027,
  meta_alfabetizacao_2028,
  meta_alfabetizacao_2029,
  meta_alfabetizacao_2030,

  taxa_alfabetizacao IS NOT NULL
    AS taxa_observada_disponivel,

  percentual_participacao IS NOT NULL
    AS participacao_disponivel,

  meta_alfabetizacao_2024 IS NOT NULL
    AS meta_2024_disponivel,

  meta_alfabetizacao_2025 IS NOT NULL
    AS meta_2025_disponivel,

  meta_alfabetizacao_2026 IS NOT NULL
    AS meta_2026_disponivel,

  meta_alfabetizacao_2027 IS NOT NULL
    AS meta_2027_disponivel,

  meta_alfabetizacao_2028 IS NOT NULL
    AS meta_2028_disponivel,

  meta_alfabetizacao_2029 IS NOT NULL
    AS meta_2029_disponivel,

  meta_alfabetizacao_2030 IS NOT NULL
    AS meta_2030_disponivel,

  (
    meta_alfabetizacao_2024 IS NOT NULL
    AND meta_alfabetizacao_2025 IS NOT NULL
    AND meta_alfabetizacao_2026 IS NOT NULL
    AND meta_alfabetizacao_2027 IS NOT NULL
    AND meta_alfabetizacao_2028 IS NOT NULL
    AND meta_alfabetizacao_2029 IS NOT NULL
    AND meta_alfabetizacao_2030 IS NOT NULL
  ) AS serie_metas_completa,

  CASE
    WHEN
      meta_alfabetizacao_2024 IS NOT NULL
      AND meta_alfabetizacao_2025 IS NOT NULL
      AND meta_alfabetizacao_2026 IS NOT NULL
      AND meta_alfabetizacao_2027 IS NOT NULL
      AND meta_alfabetizacao_2028 IS NOT NULL
      AND meta_alfabetizacao_2029 IS NOT NULL
      AND meta_alfabetizacao_2030 IS NOT NULL
    THEN 'completa'

    ELSE 'incompleta_na_fonte'
  END AS status_serie_metas,

  CURRENT_TIMESTAMP() AS processado_em

FROM
  `macro-coil-475920-k5.bronze.meta_alfabetizacao_uf`;


CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.silver.meta_alfabetizacao_municipio`

AS

WITH diretorio_municipios AS (
  SELECT DISTINCT
    TRIM(id_municipio) AS id_municipio,
    TRIM(nome) AS nome_municipio,
    TRIM(sigla_uf) AS sigla_uf

  FROM
    `basedosdados.br_bd_diretorios_brasil.municipio`
)

SELECT
  CONCAT(
    CAST(m.ano AS STRING),
    '|',
    TRIM(m.id_municipio),
    '|',
    TRIM(m.rede)
  ) AS chave_ano_municipio_rede,

  m.ano,
  TRIM(m.id_municipio) AS id_municipio,
  d.nome_municipio,
  d.sigla_uf,

  CASE
    WHEN d.sigla_uf IN (
      'AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO'
    ) THEN 'Norte'

    WHEN d.sigla_uf IN (
      'AL', 'BA', 'CE', 'MA', 'PB',
      'PE', 'PI', 'RN', 'SE'
    ) THEN 'Nordeste'

    WHEN d.sigla_uf IN (
      'DF', 'GO', 'MT', 'MS'
    ) THEN 'Centro-Oeste'

    WHEN d.sigla_uf IN (
      'ES', 'MG', 'RJ', 'SP'
    ) THEN 'Sudeste'

    WHEN d.sigla_uf IN (
      'PR', 'RS', 'SC'
    ) THEN 'Sul'

    ELSE 'Região não identificada'
  END AS regiao,

  TRIM(m.rede) AS rede,

  m.taxa_alfabetizacao
    AS taxa_alfabetizacao_observada,

  m.nivel_alfabetizacao,
  m.percentual_participacao,

  m.meta_alfabetizacao_2024,
  m.meta_alfabetizacao_2025,
  m.meta_alfabetizacao_2026,
  m.meta_alfabetizacao_2027,
  m.meta_alfabetizacao_2028,
  m.meta_alfabetizacao_2029,
  m.meta_alfabetizacao_2030,

  m.taxa_alfabetizacao IS NOT NULL
    AS taxa_observada_disponivel,

  m.nivel_alfabetizacao IS NOT NULL
    AS nivel_alfabetizacao_disponivel,

  m.percentual_participacao IS NOT NULL
    AS participacao_disponivel,

  m.meta_alfabetizacao_2024 IS NOT NULL
    AS meta_2024_disponivel,

  m.meta_alfabetizacao_2025 IS NOT NULL
    AS meta_2025_disponivel,

  m.meta_alfabetizacao_2026 IS NOT NULL
    AS meta_2026_disponivel,

  m.meta_alfabetizacao_2027 IS NOT NULL
    AS meta_2027_disponivel,

  m.meta_alfabetizacao_2028 IS NOT NULL
    AS meta_2028_disponivel,

  m.meta_alfabetizacao_2029 IS NOT NULL
    AS meta_2029_disponivel,

  m.meta_alfabetizacao_2030 IS NOT NULL
    AS meta_2030_disponivel,

  (
    m.meta_alfabetizacao_2024 IS NOT NULL
    AND m.meta_alfabetizacao_2025 IS NOT NULL
    AND m.meta_alfabetizacao_2026 IS NOT NULL
    AND m.meta_alfabetizacao_2027 IS NOT NULL
    AND m.meta_alfabetizacao_2028 IS NOT NULL
    AND m.meta_alfabetizacao_2029 IS NOT NULL
    AND m.meta_alfabetizacao_2030 IS NOT NULL
  ) AS serie_metas_completa,

  CASE
    WHEN
      m.meta_alfabetizacao_2024 IS NOT NULL
      AND m.meta_alfabetizacao_2025 IS NOT NULL
      AND m.meta_alfabetizacao_2026 IS NOT NULL
      AND m.meta_alfabetizacao_2027 IS NOT NULL
      AND m.meta_alfabetizacao_2028 IS NOT NULL
      AND m.meta_alfabetizacao_2029 IS NOT NULL
      AND m.meta_alfabetizacao_2030 IS NOT NULL
    THEN 'completa'

    ELSE 'incompleta_na_fonte'
  END AS status_serie_metas,

  d.id_municipio IS NOT NULL
    AS municipio_encontrado_no_diretorio,

  CURRENT_TIMESTAMP() AS processado_em

FROM
  `macro-coil-475920-k5.bronze.meta_alfabetizacao_municipio` AS m

LEFT JOIN
  diretorio_municipios AS d
ON
  TRIM(m.id_municipio) = d.id_municipio;