WITH

alunos_bronze AS (
  SELECT
    COUNT(*) AS total,
    COUNTIF(proficiencia IS NULL) AS nulos_proficiencia,
    COUNTIF(peso_aluno IS NULL) AS nulos_peso
  FROM
    `macro-coil-475920-k5.bronze.alunos`
),

alunos_silver AS (
  SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT chave_ano_aluno) AS chaves_distintas,
    COUNTIF(status_avaliacao = 'situacao_inconsistente')
      + COUNTIF(classificacao_coerente_743 IS FALSE)
      AS problemas_integridade,
    COUNTIF(proficiencia IS NULL) AS nulos_proficiencia,
    COUNTIF(peso_aluno IS NULL) AS nulos_peso
  FROM
    `macro-coil-475920-k5.silver.alunos`
),

municipio_bronze AS (
  SELECT
    COUNT(*) AS total,
    COUNTIF(
      proporcao_aluno_nivel_0 IS NULL
      OR proporcao_aluno_nivel_1 IS NULL
      OR proporcao_aluno_nivel_2 IS NULL
      OR proporcao_aluno_nivel_3 IS NULL
      OR proporcao_aluno_nivel_4 IS NULL
      OR proporcao_aluno_nivel_5 IS NULL
      OR proporcao_aluno_nivel_6 IS NULL
      OR proporcao_aluno_nivel_7 IS NULL
      OR proporcao_aluno_nivel_8 IS NULL
    ) AS distribuicoes_indisponiveis
  FROM
    `macro-coil-475920-k5.bronze.municipio`
),

municipio_silver AS (
  SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT chave_ano_municipio_serie_rede)
      AS chaves_distintas,
    COUNTIF(NOT municipio_encontrado_no_diretorio)
      + COUNTIF(regiao = 'Região não identificada')
      + COUNTIF(
          ano = 2023
          AND distribuicao_niveis_disponivel
        )
      + COUNTIF(
          ano = 2024
          AND NOT distribuicao_niveis_disponivel
        )
      AS problemas_integridade,
    COUNTIF(NOT distribuicao_niveis_disponivel)
      AS distribuicoes_indisponiveis
  FROM
    `macro-coil-475920-k5.silver.municipio`
),

uf_bronze AS (
  SELECT
    COUNT(*) AS total,
    COUNTIF(
      proporcao_aluno_nivel_0 IS NULL
      OR proporcao_aluno_nivel_1 IS NULL
      OR proporcao_aluno_nivel_2 IS NULL
      OR proporcao_aluno_nivel_3 IS NULL
      OR proporcao_aluno_nivel_4 IS NULL
      OR proporcao_aluno_nivel_5 IS NULL
      OR proporcao_aluno_nivel_6 IS NULL
      OR proporcao_aluno_nivel_7 IS NULL
      OR proporcao_aluno_nivel_8 IS NULL
    ) AS distribuicoes_indisponiveis
  FROM
    `macro-coil-475920-k5.bronze.uf`
),

uf_silver AS (
  SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT chave_ano_uf_serie_rede)
      AS chaves_distintas,
    COUNTIF(regiao = 'Região não identificada')
      + COUNTIF(
          ano = 2023
          AND distribuicao_niveis_disponivel
        )
      + COUNTIF(
          ano = 2024
          AND NOT distribuicao_niveis_disponivel
        )
      AS problemas_integridade,
    COUNTIF(NOT distribuicao_niveis_disponivel)
      AS distribuicoes_indisponiveis
  FROM
    `macro-coil-475920-k5.silver.uf`
),

meta_brasil_bronze AS (
  SELECT
    COUNT(*) AS total,
    COUNTIF(taxa_alfabetizacao IS NULL) AS n_taxa,
    COUNTIF(percentual_participacao IS NULL) AS n_participacao,
    COUNTIF(meta_alfabetizacao_2024 IS NULL) AS n_2024,
    COUNTIF(meta_alfabetizacao_2025 IS NULL) AS n_2025,
    COUNTIF(meta_alfabetizacao_2026 IS NULL) AS n_2026,
    COUNTIF(meta_alfabetizacao_2027 IS NULL) AS n_2027,
    COUNTIF(meta_alfabetizacao_2028 IS NULL) AS n_2028,
    COUNTIF(meta_alfabetizacao_2029 IS NULL) AS n_2029,
    COUNTIF(meta_alfabetizacao_2030 IS NULL) AS n_2030
  FROM
    `macro-coil-475920-k5.bronze.meta_alfabetizacao_brasil`
),

meta_brasil_silver AS (
  SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT chave_ano_rede) AS chaves_distintas,
    COUNTIF(chave_ano_rede IS NULL OR chave_ano_rede = '')
      AS problemas_integridade,
    COUNTIF(taxa_alfabetizacao_observada IS NULL) AS n_taxa,
    COUNTIF(percentual_participacao IS NULL) AS n_participacao,
    COUNTIF(meta_alfabetizacao_2024 IS NULL) AS n_2024,
    COUNTIF(meta_alfabetizacao_2025 IS NULL) AS n_2025,
    COUNTIF(meta_alfabetizacao_2026 IS NULL) AS n_2026,
    COUNTIF(meta_alfabetizacao_2027 IS NULL) AS n_2027,
    COUNTIF(meta_alfabetizacao_2028 IS NULL) AS n_2028,
    COUNTIF(meta_alfabetizacao_2029 IS NULL) AS n_2029,
    COUNTIF(meta_alfabetizacao_2030 IS NULL) AS n_2030
  FROM
    `macro-coil-475920-k5.silver.meta_alfabetizacao_brasil`
),

meta_uf_bronze AS (
  SELECT
    COUNT(*) AS total,
    COUNTIF(taxa_alfabetizacao IS NULL) AS n_taxa,
    COUNTIF(percentual_participacao IS NULL) AS n_participacao,
    COUNTIF(meta_alfabetizacao_2024 IS NULL) AS n_2024,
    COUNTIF(meta_alfabetizacao_2025 IS NULL) AS n_2025,
    COUNTIF(meta_alfabetizacao_2026 IS NULL) AS n_2026,
    COUNTIF(meta_alfabetizacao_2027 IS NULL) AS n_2027,
    COUNTIF(meta_alfabetizacao_2028 IS NULL) AS n_2028,
    COUNTIF(meta_alfabetizacao_2029 IS NULL) AS n_2029,
    COUNTIF(meta_alfabetizacao_2030 IS NULL) AS n_2030
  FROM
    `macro-coil-475920-k5.bronze.meta_alfabetizacao_uf`
),

meta_uf_silver AS (
  SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT chave_ano_uf_rede) AS chaves_distintas,
    COUNTIF(regiao = 'Região não identificada')
      AS problemas_integridade,
    COUNTIF(taxa_alfabetizacao_observada IS NULL) AS n_taxa,
    COUNTIF(percentual_participacao IS NULL) AS n_participacao,
    COUNTIF(meta_alfabetizacao_2024 IS NULL) AS n_2024,
    COUNTIF(meta_alfabetizacao_2025 IS NULL) AS n_2025,
    COUNTIF(meta_alfabetizacao_2026 IS NULL) AS n_2026,
    COUNTIF(meta_alfabetizacao_2027 IS NULL) AS n_2027,
    COUNTIF(meta_alfabetizacao_2028 IS NULL) AS n_2028,
    COUNTIF(meta_alfabetizacao_2029 IS NULL) AS n_2029,
    COUNTIF(meta_alfabetizacao_2030 IS NULL) AS n_2030
  FROM
    `macro-coil-475920-k5.silver.meta_alfabetizacao_uf`
),

meta_municipio_bronze AS (
  SELECT
    COUNT(*) AS total,
    COUNTIF(taxa_alfabetizacao IS NULL) AS n_taxa,
    COUNTIF(percentual_participacao IS NULL) AS n_participacao,
    COUNTIF(meta_alfabetizacao_2024 IS NULL) AS n_2024,
    COUNTIF(meta_alfabetizacao_2025 IS NULL) AS n_2025,
    COUNTIF(meta_alfabetizacao_2026 IS NULL) AS n_2026,
    COUNTIF(meta_alfabetizacao_2027 IS NULL) AS n_2027,
    COUNTIF(meta_alfabetizacao_2028 IS NULL) AS n_2028,
    COUNTIF(meta_alfabetizacao_2029 IS NULL) AS n_2029,
    COUNTIF(meta_alfabetizacao_2030 IS NULL) AS n_2030
  FROM
    `macro-coil-475920-k5.bronze.meta_alfabetizacao_municipio`
),

meta_municipio_silver AS (
  SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT chave_ano_municipio_rede)
      AS chaves_distintas,
    COUNTIF(NOT municipio_encontrado_no_diretorio)
      + COUNTIF(regiao = 'Região não identificada')
      AS problemas_integridade,
    COUNTIF(taxa_alfabetizacao_observada IS NULL) AS n_taxa,
    COUNTIF(percentual_participacao IS NULL) AS n_participacao,
    COUNTIF(meta_alfabetizacao_2024 IS NULL) AS n_2024,
    COUNTIF(meta_alfabetizacao_2025 IS NULL) AS n_2025,
    COUNTIF(meta_alfabetizacao_2026 IS NULL) AS n_2026,
    COUNTIF(meta_alfabetizacao_2027 IS NULL) AS n_2027,
    COUNTIF(meta_alfabetizacao_2028 IS NULL) AS n_2028,
    COUNTIF(meta_alfabetizacao_2029 IS NULL) AS n_2029,
    COUNTIF(meta_alfabetizacao_2030 IS NULL) AS n_2030
  FROM
    `macro-coil-475920-k5.silver.meta_alfabetizacao_municipio`
),

dim_fonte AS (
  SELECT
    COUNT(DISTINCT TRIM(id_municipio)) AS total
  FROM
    `basedosdados.br_bd_diretorios_brasil.municipio`
  WHERE
    id_municipio IS NOT NULL
),

dim_silver AS (
  SELECT
    COUNT(*) AS total,
    COUNT(DISTINCT id_municipio) AS chaves_distintas,
    COUNTIF(
      id_municipio IS NULL
      OR nome_municipio IS NULL
      OR sigla_uf IS NULL
      OR regiao IS NULL
      OR regiao = 'Região não identificada'
    ) AS problemas_integridade
  FROM
    `macro-coil-475920-k5.silver.dim_municipio`
)

SELECT
  'alunos' AS tabela,
  b.total AS linhas_fonte,
  s.total AS linhas_silver,
  b.total = s.total AS contagem_confere,
  s.chaves_distintas,
  s.total = s.chaves_distintas AS chave_unica_confere,
  s.problemas_integridade,
  (
    b.nulos_proficiencia = s.nulos_proficiencia
    AND b.nulos_peso = s.nulos_peso
  ) AS ausencias_preservadas
FROM alunos_bronze b
CROSS JOIN alunos_silver s

UNION ALL

SELECT
  'municipio',
  b.total,
  s.total,
  b.total = s.total,
  s.chaves_distintas,
  s.total = s.chaves_distintas,
  s.problemas_integridade,
  b.distribuicoes_indisponiveis
    = s.distribuicoes_indisponiveis
FROM municipio_bronze b
CROSS JOIN municipio_silver s

UNION ALL

SELECT
  'uf',
  b.total,
  s.total,
  b.total = s.total,
  s.chaves_distintas,
  s.total = s.chaves_distintas,
  s.problemas_integridade,
  b.distribuicoes_indisponiveis
    = s.distribuicoes_indisponiveis
FROM uf_bronze b
CROSS JOIN uf_silver s

UNION ALL

SELECT
  'meta_alfabetizacao_brasil',
  b.total,
  s.total,
  b.total = s.total,
  s.chaves_distintas,
  s.total = s.chaves_distintas,
  s.problemas_integridade,
  (
    b.n_taxa = s.n_taxa
    AND b.n_participacao = s.n_participacao
    AND b.n_2024 = s.n_2024
    AND b.n_2025 = s.n_2025
    AND b.n_2026 = s.n_2026
    AND b.n_2027 = s.n_2027
    AND b.n_2028 = s.n_2028
    AND b.n_2029 = s.n_2029
    AND b.n_2030 = s.n_2030
  )
FROM meta_brasil_bronze b
CROSS JOIN meta_brasil_silver s

UNION ALL

SELECT
  'meta_alfabetizacao_uf',
  b.total,
  s.total,
  b.total = s.total,
  s.chaves_distintas,
  s.total = s.chaves_distintas,
  s.problemas_integridade,
  (
    b.n_taxa = s.n_taxa
    AND b.n_participacao = s.n_participacao
    AND b.n_2024 = s.n_2024
    AND b.n_2025 = s.n_2025
    AND b.n_2026 = s.n_2026
    AND b.n_2027 = s.n_2027
    AND b.n_2028 = s.n_2028
    AND b.n_2029 = s.n_2029
    AND b.n_2030 = s.n_2030
  )
FROM meta_uf_bronze b
CROSS JOIN meta_uf_silver s

UNION ALL

SELECT
  'meta_alfabetizacao_municipio',
  b.total,
  s.total,
  b.total = s.total,
  s.chaves_distintas,
  s.total = s.chaves_distintas,
  s.problemas_integridade,
  (
    b.n_taxa = s.n_taxa
    AND b.n_participacao = s.n_participacao
    AND b.n_2024 = s.n_2024
    AND b.n_2025 = s.n_2025
    AND b.n_2026 = s.n_2026
    AND b.n_2027 = s.n_2027
    AND b.n_2028 = s.n_2028
    AND b.n_2029 = s.n_2029
    AND b.n_2030 = s.n_2030
  )
FROM meta_municipio_bronze b
CROSS JOIN meta_municipio_silver s

UNION ALL

SELECT
  'dim_municipio',
  f.total,
  s.total,
  f.total = s.total,
  s.chaves_distintas,
  s.total = s.chaves_distintas,
  s.problemas_integridade,
  s.problemas_integridade = 0
FROM dim_fonte f
CROSS JOIN dim_silver s

ORDER BY
  tabela