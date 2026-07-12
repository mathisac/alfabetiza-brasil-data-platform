CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.gold.indicador_uf`

CLUSTER BY
  sigla_uf,
  rede

AS

WITH metas_alinhadas AS (
  SELECT
    chave_ano_uf_rede,
    ano,
    sigla_uf,
    regiao,
    rede,

    ROUND(
      CAST(taxa_alfabetizacao_observada AS NUMERIC),
      2
    ) AS resultado_alfabetizacao,

    ROUND(
      CAST(percentual_participacao AS NUMERIC),
      2
    ) AS percentual_participacao,

    CASE ano
      WHEN 2024 THEN meta_alfabetizacao_2024
      WHEN 2025 THEN meta_alfabetizacao_2025
      WHEN 2026 THEN meta_alfabetizacao_2026
      WHEN 2027 THEN meta_alfabetizacao_2027
      WHEN 2028 THEN meta_alfabetizacao_2028
      WHEN 2029 THEN meta_alfabetizacao_2029
      WHEN 2030 THEN meta_alfabetizacao_2030
      ELSE NULL
    END AS meta_alfabetizacao_ano,

    taxa_observada_disponivel,
    participacao_disponivel,
    serie_metas_completa,
    status_serie_metas

  FROM
    `macro-coil-475920-k5.silver.meta_alfabetizacao_uf`
),

metricas AS (
  SELECT
    chave_ano_uf_rede,
    ano,
    sigla_uf,
    regiao,
    rede,
    resultado_alfabetizacao,
    percentual_participacao,

    ROUND(
      CAST(meta_alfabetizacao_ano AS NUMERIC),
      2
    ) AS meta_alfabetizacao_ano,

    taxa_observada_disponivel,
    participacao_disponivel,
    serie_metas_completa,
    status_serie_metas

  FROM
    metas_alinhadas
)

SELECT
  chave_ano_uf_rede,
  ano,
  sigla_uf,
  regiao,
  rede,
  resultado_alfabetizacao,
  meta_alfabetizacao_ano,

  CASE
    WHEN
      resultado_alfabetizacao IS NOT NULL
      AND meta_alfabetizacao_ano IS NOT NULL
    THEN ROUND(
      resultado_alfabetizacao
      - meta_alfabetizacao_ano,
      2
    )

    ELSE NULL
  END AS diferenca_resultado_meta,

  CASE
    WHEN
      resultado_alfabetizacao IS NOT NULL
      AND meta_alfabetizacao_ano IS NOT NULL
    THEN ROUND(
      GREATEST(
        meta_alfabetizacao_ano
        - resultado_alfabetizacao,
        0
      ),
      2
    )

    ELSE NULL
  END AS gap_para_meta,

  CASE
    WHEN
      resultado_alfabetizacao IS NOT NULL
      AND meta_alfabetizacao_ano IS NOT NULL
    THEN ROUND(
      GREATEST(
        resultado_alfabetizacao
        - meta_alfabetizacao_ano,
        0
      ),
      2
    )

    ELSE NULL
  END AS excedente_acima_meta,

  CASE
    WHEN resultado_alfabetizacao IS NULL
      THEN 'resultado_indisponivel'

    WHEN meta_alfabetizacao_ano IS NULL
      THEN 'meta_indisponivel_para_o_ano'

    WHEN resultado_alfabetizacao >= meta_alfabetizacao_ano
      THEN 'meta_atingida'

    ELSE 'meta_nao_atingida'
  END AS status_meta,

  percentual_participacao,
  taxa_observada_disponivel,
  participacao_disponivel,
  serie_metas_completa,
  status_serie_metas,
  CURRENT_TIMESTAMP() AS processado_em

FROM
  metricas;


CREATE OR REPLACE TABLE
  `macro-coil-475920-k5.gold.indicador_brasil`

AS

WITH metas_alinhadas AS (
  SELECT
    chave_ano_rede,
    ano,
    rede,

    ROUND(
      CAST(taxa_alfabetizacao_observada AS NUMERIC),
      2
    ) AS resultado_alfabetizacao,

    ROUND(
      CAST(percentual_participacao AS NUMERIC),
      2
    ) AS percentual_participacao,

    CASE ano
      WHEN 2024 THEN meta_alfabetizacao_2024
      WHEN 2025 THEN meta_alfabetizacao_2025
      WHEN 2026 THEN meta_alfabetizacao_2026
      WHEN 2027 THEN meta_alfabetizacao_2027
      WHEN 2028 THEN meta_alfabetizacao_2028
      WHEN 2029 THEN meta_alfabetizacao_2029
      WHEN 2030 THEN meta_alfabetizacao_2030
      ELSE NULL
    END AS meta_alfabetizacao_ano,

    taxa_observada_disponivel,
    participacao_disponivel,
    serie_metas_completa,
    status_serie_metas

  FROM
    `macro-coil-475920-k5.silver.meta_alfabetizacao_brasil`
),

metricas AS (
  SELECT
    chave_ano_rede,
    ano,
    rede,
    resultado_alfabetizacao,
    percentual_participacao,

    ROUND(
      CAST(meta_alfabetizacao_ano AS NUMERIC),
      2
    ) AS meta_alfabetizacao_ano,

    taxa_observada_disponivel,
    participacao_disponivel,
    serie_metas_completa,
    status_serie_metas

  FROM
    metas_alinhadas
)

SELECT
  chave_ano_rede,
  ano,
  rede,
  resultado_alfabetizacao,
  meta_alfabetizacao_ano,

  CASE
    WHEN
      resultado_alfabetizacao IS NOT NULL
      AND meta_alfabetizacao_ano IS NOT NULL
    THEN ROUND(
      resultado_alfabetizacao
      - meta_alfabetizacao_ano,
      2
    )

    ELSE NULL
  END AS diferenca_resultado_meta,

  CASE
    WHEN
      resultado_alfabetizacao IS NOT NULL
      AND meta_alfabetizacao_ano IS NOT NULL
    THEN ROUND(
      GREATEST(
        meta_alfabetizacao_ano
        - resultado_alfabetizacao,
        0
      ),
      2
    )

    ELSE NULL
  END AS gap_para_meta,

  CASE
    WHEN
      resultado_alfabetizacao IS NOT NULL
      AND meta_alfabetizacao_ano IS NOT NULL
    THEN ROUND(
      GREATEST(
        resultado_alfabetizacao
        - meta_alfabetizacao_ano,
        0
      ),
      2
    )

    ELSE NULL
  END AS excedente_acima_meta,

  CASE
    WHEN resultado_alfabetizacao IS NULL
      THEN 'resultado_indisponivel'

    WHEN meta_alfabetizacao_ano IS NULL
      THEN 'meta_indisponivel_para_o_ano'

    WHEN resultado_alfabetizacao >= meta_alfabetizacao_ano
      THEN 'meta_atingida'

    ELSE 'meta_nao_atingida'
  END AS status_meta,

  percentual_participacao,
  taxa_observada_disponivel,
  participacao_disponivel,
  serie_metas_completa,
  status_serie_metas,
  CURRENT_TIMESTAMP() AS processado_em

FROM
  metricas