from collections.abc import Sequence

import pandas as pd
from google.api_core.exceptions import Forbidden, NotFound
from google.cloud import bigquery


def validar_bronze(
    client: bigquery.Client,
    source_project: str,
    source_dataset: str,
    project_id: str,
    bronze_dataset: str,
    bronze_tables: Sequence[str],
) -> tuple[pd.DataFrame, bool]:
    colunas = [
        "tabela",
        "origem_existe",
        "bronze_existe",
        "linhas_origem",
        "linhas_bronze",
        "contagem_confere",
        "mb_origem",
        "mb_bronze",
    ]

    resultados = []

    for table_name in bronze_tables:
        source_table_id = (
            f"{source_project}.{source_dataset}.{table_name}"
        )

        destination_table_id = (
            f"{project_id}.{bronze_dataset}.{table_name}"
        )

        try:
            source_table = client.get_table(source_table_id)
            origem_existe = True
            linhas_origem = source_table.num_rows
            bytes_origem = source_table.num_bytes
        except (NotFound, Forbidden):
            origem_existe = False
            linhas_origem = None
            bytes_origem = None

        try:
            destination_table = client.get_table(
                destination_table_id
            )
            bronze_existe = True
            linhas_bronze = destination_table.num_rows
            bytes_bronze = destination_table.num_bytes
        except (NotFound, Forbidden):
            bronze_existe = False
            linhas_bronze = None
            bytes_bronze = None

        contagem_confere = (
            origem_existe
            and bronze_existe
            and linhas_origem == linhas_bronze
        )

        resultados.append(
            {
                "tabela": table_name,
                "origem_existe": origem_existe,
                "bronze_existe": bronze_existe,
                "linhas_origem": linhas_origem,
                "linhas_bronze": linhas_bronze,
                "contagem_confere": contagem_confere,
                "mb_origem": (
                    round(bytes_origem / 1024**2, 2)
                    if bytes_origem is not None
                    else None
                ),
                "mb_bronze": (
                    round(bytes_bronze / 1024**2, 2)
                    if bytes_bronze is not None
                    else None
                ),
            }
        )

    resultados_df = pd.DataFrame(
        resultados,
        columns=colunas,
    )

    quality_gate_aprovado = bool(
        not resultados_df.empty
        and resultados_df["origem_existe"].all()
        and resultados_df["bronze_existe"].all()
        and resultados_df["contagem_confere"].all()
        and len(resultados_df) == len(bronze_tables)
    )

    return resultados_df, quality_gate_aprovado
