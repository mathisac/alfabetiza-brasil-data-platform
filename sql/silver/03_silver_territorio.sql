CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.silver.municipio`

PARTITION BY
  RANGE_BUCKET(ano, GENERATE_ARRAY(2023, 2025, 1))

CLUSTER BY
  sigla_uf,
  id_municipio,
  rede

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
    TRIM(m.serie),
    '|',
    TRIM(m.rede)
  ) AS chave_ano_municipio_serie_rede,

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

  TRIM(m.serie) AS serie,
  TRIM(m.rede) AS rede,

  m.taxa_alfabetizacao
    AS taxa_alfabetizacao_observada,

  m.media_portugues,

  m.proporcao_aluno_nivel_0,
  m.proporcao_aluno_nivel_1,
  m.proporcao_aluno_nivel_2,
  m.proporcao_aluno_nivel_3,
  m.proporcao_aluno_nivel_4,
  m.proporcao_aluno_nivel_5,
  m.proporcao_aluno_nivel_6,
  m.proporcao_aluno_nivel_7,
  m.proporcao_aluno_nivel_8,

  m.taxa_alfabetizacao IS NOT NULL
    AS taxa_observada_disponivel,

  (
    m.proporcao_aluno_nivel_0 IS NOT NULL
    AND m.proporcao_aluno_nivel_1 IS NOT NULL
    AND m.proporcao_aluno_nivel_2 IS NOT NULL
    AND m.proporcao_aluno_nivel_3 IS NOT NULL
    AND m.proporcao_aluno_nivel_4 IS NOT NULL
    AND m.proporcao_aluno_nivel_5 IS NOT NULL
    AND m.proporcao_aluno_nivel_6 IS NOT NULL
    AND m.proporcao_aluno_nivel_7 IS NOT NULL
    AND m.proporcao_aluno_nivel_8 IS NOT NULL
  ) AS distribuicao_niveis_disponivel,

  CASE
    WHEN
      m.proporcao_aluno_nivel_0 IS NOT NULL
      AND m.proporcao_aluno_nivel_1 IS NOT NULL
      AND m.proporcao_aluno_nivel_2 IS NOT NULL
      AND m.proporcao_aluno_nivel_3 IS NOT NULL
      AND m.proporcao_aluno_nivel_4 IS NOT NULL
      AND m.proporcao_aluno_nivel_5 IS NOT NULL
      AND m.proporcao_aluno_nivel_6 IS NOT NULL
      AND m.proporcao_aluno_nivel_7 IS NOT NULL
      AND m.proporcao_aluno_nivel_8 IS NOT NULL
    THEN 'disponivel'

    ELSE 'nao_disponivel_na_fonte'
  END AS status_distribuicao_niveis,

  d.id_municipio IS NOT NULL
    AS municipio_encontrado_no_diretorio,

  CURRENT_TIMESTAMP() AS processado_em

FROM
  `macro-coil-475920-k5.bronze.municipio` AS m

LEFT JOIN
  diretorio_municipios AS d
ON
  TRIM(m.id_municipio) = d.id_municipio;


CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.silver.uf`

PARTITION BY
  RANGE_BUCKET(ano, GENERATE_ARRAY(2023, 2025, 1))

CLUSTER BY
  sigla_uf,
  rede

AS

SELECT
  CONCAT(
    CAST(ano AS STRING),
    '|',
    TRIM(sigla_uf),
    '|',
    TRIM(serie),
    '|',
    TRIM(rede)
  ) AS chave_ano_uf_serie_rede,

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

  TRIM(serie) AS serie,
  TRIM(rede) AS rede,

  taxa_alfabetizacao
    AS taxa_alfabetizacao_observada,

  media_portugues,

  proporcao_aluno_nivel_0,
  proporcao_aluno_nivel_1,
  proporcao_aluno_nivel_2,
  proporcao_aluno_nivel_3,
  proporcao_aluno_nivel_4,
  proporcao_aluno_nivel_5,
  proporcao_aluno_nivel_6,
  proporcao_aluno_nivel_7,
  proporcao_aluno_nivel_8,

  taxa_alfabetizacao IS NOT NULL
    AS taxa_observada_disponivel,

  (
    proporcao_aluno_nivel_0 IS NOT NULL
    AND proporcao_aluno_nivel_1 IS NOT NULL
    AND proporcao_aluno_nivel_2 IS NOT NULL
    AND proporcao_aluno_nivel_3 IS NOT NULL
    AND proporcao_aluno_nivel_4 IS NOT NULL
    AND proporcao_aluno_nivel_5 IS NOT NULL
    AND proporcao_aluno_nivel_6 IS NOT NULL
    AND proporcao_aluno_nivel_7 IS NOT NULL
    AND proporcao_aluno_nivel_8 IS NOT NULL
  ) AS distribuicao_niveis_disponivel,

  CASE
    WHEN
      proporcao_aluno_nivel_0 IS NOT NULL
      AND proporcao_aluno_nivel_1 IS NOT NULL
      AND proporcao_aluno_nivel_2 IS NOT NULL
      AND proporcao_aluno_nivel_3 IS NOT NULL
      AND proporcao_aluno_nivel_4 IS NOT NULL
      AND proporcao_aluno_nivel_5 IS NOT NULL
      AND proporcao_aluno_nivel_6 IS NOT NULL
      AND proporcao_aluno_nivel_7 IS NOT NULL
      AND proporcao_aluno_nivel_8 IS NOT NULL
    THEN 'disponivel'

    ELSE 'nao_disponivel_na_fonte'
  END AS status_distribuicao_niveis,

  CURRENT_TIMESTAMP() AS processado_em

FROM
  `macro-coil-475920-k5.bronze.uf`;


CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.silver.dim_municipio`

CLUSTER BY
  sigla_uf

AS

WITH municipios AS (
  SELECT
    TRIM(id_municipio) AS id_municipio,
    TRIM(nome) AS nome_municipio,
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
    END AS regiao

  FROM
    `basedosdados.br_bd_diretorios_brasil.municipio`

  WHERE
    id_municipio IS NOT NULL
)

SELECT
  id_municipio,
  nome_municipio,
  sigla_uf,
  regiao,
  CURRENT_TIMESTAMP() AS processado_em

FROM
  municipios

QUALIFY
  ROW_NUMBER() OVER (
    PARTITION BY id_municipio
    ORDER BY nome_municipio, sigla_uf
  ) = 1;