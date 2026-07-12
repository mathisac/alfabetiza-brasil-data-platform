WITH

indicadores AS (
  SELECT
    'indicador_municipio' AS tabela,
    chave_ano_municipio_rede AS chave,
    resultado_alfabetizacao AS resultado,
    meta_alfabetizacao_ano AS meta,
    diferenca_resultado_meta AS diferenca,
    gap_para_meta AS gap,
    excedente_acima_meta AS excedente,
    status_meta AS status

  FROM
    `macro-coil-475920-k5.gold.indicador_municipio`

  UNION ALL

  SELECT
    'indicador_uf' AS tabela,
    chave_ano_uf_rede AS chave,
    resultado_alfabetizacao AS resultado,
    meta_alfabetizacao_ano AS meta,
    diferenca_resultado_meta AS diferenca,
    gap_para_meta AS gap,
    excedente_acima_meta AS excedente,
    status_meta AS status

  FROM
    `macro-coil-475920-k5.gold.indicador_uf`

  UNION ALL

  SELECT
    'indicador_brasil' AS tabela,
    chave_ano_rede AS chave,
    resultado_alfabetizacao AS resultado,
    meta_alfabetizacao_ano AS meta,
    diferenca_resultado_meta AS diferenca,
    gap_para_meta AS gap,
    excedente_acima_meta AS excedente,
    status_meta AS status

  FROM
    `macro-coil-475920-k5.gold.indicador_brasil`
),

indicadores_esperados AS (
  SELECT
    'indicador_municipio' AS tabela,
    COUNT(*) AS linhas_esperadas

  FROM
    `macro-coil-475920-k5.silver.meta_alfabetizacao_municipio`

  UNION ALL

  SELECT
    'indicador_uf' AS tabela,
    COUNT(*) AS linhas_esperadas

  FROM
    `macro-coil-475920-k5.silver.meta_alfabetizacao_uf`

  UNION ALL

  SELECT
    'indicador_brasil' AS tabela,
    COUNT(*) AS linhas_esperadas

  FROM
    `macro-coil-475920-k5.silver.meta_alfabetizacao_brasil`
),

indicadores_validacao AS (
  SELECT
    tabela,
    COUNT(*) AS linhas_obtidas,
    COUNT(DISTINCT chave) AS chaves_distintas,

    COUNTIF(
      status IS DISTINCT FROM
        CASE
          WHEN resultado IS NULL
            THEN 'resultado_indisponivel'

          WHEN meta IS NULL
            THEN 'meta_indisponivel_para_o_ano'

          WHEN resultado >= meta
            THEN 'meta_atingida'

          ELSE 'meta_nao_atingida'
        END

      OR diferenca IS DISTINCT FROM
        CASE
          WHEN
            resultado IS NOT NULL
            AND meta IS NOT NULL
          THEN ROUND(
            resultado - meta,
            2
          )

          ELSE NULL
        END

      OR gap IS DISTINCT FROM
        CASE
          WHEN
            resultado IS NOT NULL
            AND meta IS NOT NULL
          THEN ROUND(
            GREATEST(
              meta - resultado,
              0
            ),
            2
          )

          ELSE NULL
        END

      OR excedente IS DISTINCT FROM
        CASE
          WHEN
            resultado IS NOT NULL
            AND meta IS NOT NULL
          THEN ROUND(
            GREATEST(
              resultado - meta,
              0
            ),
            2
          )

          ELSE NULL
        END
    ) AS problemas_integridade

  FROM
    indicadores

  GROUP BY
    tabela
),

evolucao_esperada AS (
  SELECT
    COUNT(*) AS linhas_esperadas

  FROM (
    SELECT DISTINCT
      id_municipio,
      rede

    FROM
      `macro-coil-475920-k5.gold.indicador_municipio`

    WHERE
      ano IN (2023, 2024)
  )
),

evolucao_validacao AS (
  SELECT
    COUNT(*) AS linhas_obtidas,
    COUNT(DISTINCT chave_municipio_rede)
      AS chaves_distintas,

    COUNTIF(
      variacao_pontos_percentuais IS DISTINCT FROM
        CASE
          WHEN
            resultado_2023 IS NOT NULL
            AND resultado_2024 IS NOT NULL
          THEN ROUND(
            resultado_2024 - resultado_2023,
            2
          )

          ELSE NULL
        END

      OR status_evolucao IS DISTINCT FROM
        CASE
          WHEN
            resultado_2023 IS NULL
            AND resultado_2024 IS NULL
          THEN 'sem_resultados'

          WHEN resultado_2023 IS NULL
            THEN 'sem_base_2023'

          WHEN resultado_2024 IS NULL
            THEN 'sem_resultado_2024'

          WHEN ROUND(
            resultado_2024 - resultado_2023,
            2
          ) >= 0.01
            THEN 'avancou'

          WHEN ROUND(
            resultado_2024 - resultado_2023,
            2
          ) <= -0.01
            THEN 'recuou'

          ELSE 'estavel'
        END
    ) AS problemas_integridade

  FROM
    `macro-coil-475920-k5.gold.evolucao_municipio`
),

resumo_esperado AS (
  SELECT
    COUNT(*) AS linhas_esperadas

  FROM (
    SELECT DISTINCT
      ano,
      regiao,
      rede

    FROM
      `macro-coil-475920-k5.gold.indicador_municipio`
  )
),

resumo_validacao AS (
  SELECT
    COUNT(*) AS linhas_obtidas,
    COUNT(DISTINCT chave_ano_regiao_rede)
      AS chaves_distintas,

    COUNTIF(
      municipios_com_comparacao
        != municipios_meta_atingida
        + municipios_meta_nao_atingida

      OR municipios_total
        < municipios_com_resultado

      OR municipios_total
        < municipios_com_meta

      OR percentual_municipios_meta_atingida
        IS DISTINCT FROM
          ROUND(
            SAFE_DIVIDE(
              municipios_meta_atingida,
              municipios_com_comparacao
            ) * 100,
            2
          )
    ) AS problemas_integridade

  FROM
    `macro-coil-475920-k5.gold.resumo_regiao`
),

alunos_esperados AS (
  SELECT
    COUNT(*) AS linhas_esperadas

  FROM
    `macro-coil-475920-k5.silver.alunos`
),

alunos_validacao AS (
  SELECT
    COUNT(*) AS linhas_obtidas,
    COUNT(DISTINCT chave_ano_aluno)
      AS chaves_distintas,

    COUNTIF(
      NOT COALESCE(
        municipio_encontrado_na_dimensao,
        FALSE
      )

      OR nome_municipio IS NULL
      OR sigla_uf IS NULL
      OR regiao IS NULL
    ) AS problemas_integridade

  FROM
    `macro-coil-475920-k5.gold.aluno_analitico`
),

ml_esperado AS (
  SELECT
    COUNTIF(
      avaliacao_valida
      AND alfabetizado_oficial IS NOT NULL
    ) AS linhas_esperadas

  FROM
    `macro-coil-475920-k5.silver.alunos`
),

ml_validacao AS (
  SELECT
    COUNT(*) AS linhas_obtidas,
    COUNT(DISTINCT chave_ano_aluno)
      AS chaves_distintas,

    COUNTIF(
      target_alfabetizado IS NULL

      OR target_alfabetizado NOT IN (0, 1)

      OR divisao_ml IS NULL

      OR divisao_ml NOT IN (
        'treino',
        'validacao',
        'teste'
      )

      OR NOT COALESCE(
        municipio_encontrado_na_dimensao,
        FALSE
      )
    ) AS problemas_integridade

  FROM
    `macro-coil-475920-k5.gold.base_ml_aluno`
),

ml_colunas AS (
  SELECT
    COUNTIF(
      column_name IN (
        'proficiencia',
        'alfabetizado_calculado_743',
        'classificacao_coerente_743'
      )
    ) AS colunas_com_vazamento

  FROM
    `macro-coil-475920-k5.gold.INFORMATION_SCHEMA.COLUMNS`

  WHERE
    table_name = 'base_ml_aluno'
)

SELECT
  v.tabela,
  e.linhas_esperadas,
  v.linhas_obtidas,

  e.linhas_esperadas = v.linhas_obtidas
    AS contagem_confere,

  v.chaves_distintas,

  v.linhas_obtidas = v.chaves_distintas
    AS chave_unica_confere,

  v.problemas_integridade,

  v.problemas_integridade = 0
    AS validacao_especifica

FROM
  indicadores_validacao AS v

JOIN
  indicadores_esperados AS e
USING
  (tabela)

UNION ALL

SELECT
  'evolucao_municipio' AS tabela,
  e.linhas_esperadas,
  v.linhas_obtidas,
  e.linhas_esperadas = v.linhas_obtidas,
  v.chaves_distintas,
  v.linhas_obtidas = v.chaves_distintas,
  v.problemas_integridade,
  v.problemas_integridade = 0

FROM
  evolucao_esperada AS e

CROSS JOIN
  evolucao_validacao AS v

UNION ALL

SELECT
  'resumo_regiao' AS tabela,
  e.linhas_esperadas,
  v.linhas_obtidas,
  e.linhas_esperadas = v.linhas_obtidas,
  v.chaves_distintas,
  v.linhas_obtidas = v.chaves_distintas,
  v.problemas_integridade,
  v.problemas_integridade = 0

FROM
  resumo_esperado AS e

CROSS JOIN
  resumo_validacao AS v

UNION ALL

SELECT
  'aluno_analitico' AS tabela,
  e.linhas_esperadas,
  v.linhas_obtidas,
  e.linhas_esperadas = v.linhas_obtidas,
  v.chaves_distintas,
  v.linhas_obtidas = v.chaves_distintas,
  v.problemas_integridade,
  v.problemas_integridade = 0

FROM
  alunos_esperados AS e

CROSS JOIN
  alunos_validacao AS v

UNION ALL

SELECT
  'base_ml_aluno' AS tabela,
  e.linhas_esperadas,
  v.linhas_obtidas,
  e.linhas_esperadas = v.linhas_obtidas,
  v.chaves_distintas,
  v.linhas_obtidas = v.chaves_distintas,
  v.problemas_integridade,

  c.colunas_com_vazamento = 0
    AND v.problemas_integridade = 0
    AS validacao_especifica

FROM
  ml_esperado AS e

CROSS JOIN
  ml_validacao AS v

CROSS JOIN
  ml_colunas AS c

ORDER BY
  tabela