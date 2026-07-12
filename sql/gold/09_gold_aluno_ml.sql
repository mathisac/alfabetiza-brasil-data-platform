CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.gold.aluno_analitico`

PARTITION BY
  RANGE_BUCKET(ano, GENERATE_ARRAY(2023, 2025, 1))

CLUSTER BY
  id_municipio,
  rede

AS

SELECT
  a.chave_ano_aluno,
  a.ano,
  a.id_municipio,
  d.nome_municipio,
  d.sigla_uf,
  d.regiao,
  a.id_escola,
  a.id_aluno,
  a.caderno,
  a.serie,
  a.rede,
  a.presenca,
  a.preenchimento_caderno,
  a.alfabetizado_oficial,
  a.proficiencia,
  a.peso_aluno,
  a.presente,
  a.caderno_preenchido,
  a.avaliacao_valida,
  a.status_avaliacao,
  a.alfabetizado_calculado_743,
  a.classificacao_coerente_743,
  d.id_municipio IS NOT NULL
    AS municipio_encontrado_na_dimensao,
  CURRENT_TIMESTAMP() AS processado_em

FROM
  `macro-coil-475920-k5.silver.alunos` AS a

LEFT JOIN
  `macro-coil-475920-k5.silver.dim_municipio` AS d
ON
  a.id_municipio = d.id_municipio;


CREATE OR REPLACE VIEW
  `macro-coil-475920-k5.gold.base_ml_aluno`

AS

WITH base AS (
  SELECT
    chave_ano_aluno,
    ano,
    id_municipio,
    nome_municipio,
    sigla_uf,
    regiao,
    id_escola,
    id_aluno,
    caderno,
    serie,
    rede,
    presenca,
    preenchimento_caderno,
    presente,
    caderno_preenchido,
    peso_aluno,
    alfabetizado_oficial
      AS target_alfabetizado,
    municipio_encontrado_na_dimensao,

    MOD(
      MOD(
        FARM_FINGERPRINT(chave_ano_aluno),
        100
      ) + 100,
      100
    ) AS numero_divisao

  FROM
    `macro-coil-475920-k5.gold.aluno_analitico`

  WHERE
    avaliacao_valida
    AND alfabetizado_oficial IS NOT NULL
)

SELECT
  chave_ano_aluno,
  ano,
  id_municipio,
  nome_municipio,
  sigla_uf,
  regiao,
  id_escola,
  id_aluno,
  caderno,
  serie,
  rede,
  presenca,
  preenchimento_caderno,
  presente,
  caderno_preenchido,
  peso_aluno,
  target_alfabetizado,
  municipio_encontrado_na_dimensao,

  CASE
    WHEN numero_divisao < 70
      THEN 'treino'

    WHEN numero_divisao < 85
      THEN 'validacao'

    ELSE 'teste'
  END AS divisao_ml

FROM
  base