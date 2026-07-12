CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.silver.alunos`

PARTITION BY
  RANGE_BUCKET(ano, GENERATE_ARRAY(2023, 2025, 1))

CLUSTER BY
  id_municipio,
  rede

AS

WITH padronizacao AS (
  SELECT
    ano,
    TRIM(id_municipio) AS id_municipio,
    TRIM(id_escola) AS id_escola,
    TRIM(id_aluno) AS id_aluno,
    TRIM(caderno) AS caderno,
    TRIM(serie) AS serie,
    TRIM(rede) AS rede,
    SAFE_CAST(presenca AS INT64) AS presenca,
    SAFE_CAST(preenchimento_caderno AS INT64)
      AS preenchimento_caderno,
    SAFE_CAST(alfabetizado AS INT64)
      AS alfabetizado_oficial,
    proficiencia,
    peso_aluno

  FROM
    `macro-coil-475920-k5.bronze.alunos`
),

regras AS (
  SELECT
    CONCAT(
      CAST(ano AS STRING),
      '|',
      id_aluno
    ) AS chave_ano_aluno,

    ano,
    id_municipio,
    id_escola,
    id_aluno,
    caderno,
    serie,
    rede,
    presenca,
    preenchimento_caderno,
    alfabetizado_oficial,
    proficiencia,
    peso_aluno,

    presenca = 1 AS presente,

    preenchimento_caderno = 1
      AS caderno_preenchido,

    (
      presenca = 1
      AND preenchimento_caderno = 1
      AND proficiencia IS NOT NULL
      AND peso_aluno IS NOT NULL
    ) AS avaliacao_valida

  FROM
    padronizacao
)

SELECT
  chave_ano_aluno,
  ano,
  id_municipio,
  id_escola,
  id_aluno,
  caderno,
  serie,
  rede,
  presenca,
  preenchimento_caderno,
  alfabetizado_oficial,
  proficiencia,
  peso_aluno,
  presente,
  caderno_preenchido,
  avaliacao_valida,

  CASE
    WHEN presenca = 0
      THEN 'ausente'

    WHEN
      presenca = 1
      AND preenchimento_caderno = 0
      THEN 'presente_sem_preenchimento'

    WHEN avaliacao_valida
      THEN 'avaliacao_valida'

    ELSE 'situacao_inconsistente'
  END AS status_avaliacao,

  CASE
    WHEN avaliacao_valida
      THEN IF(proficiencia >= 743, 1, 0)

    ELSE NULL
  END AS alfabetizado_calculado_743,

  CASE
    WHEN avaliacao_valida
      THEN alfabetizado_oficial
        = IF(proficiencia >= 743, 1, 0)

    ELSE NULL
  END AS classificacao_coerente_743,

  CURRENT_TIMESTAMP() AS processado_em

FROM
  regras