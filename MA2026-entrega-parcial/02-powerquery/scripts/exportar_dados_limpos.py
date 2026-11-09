"""Exporta as tabelas de saída e de conferência de cheiU_02_PowerQuery.xlsx para dados_limpos/*.csv (UTF-8).

Só copia os valores que o Power Query gravou nas planilhas, sem transformar nada. Tabela que passaria de
25 MB num arquivo só é dividida por semestre da coluna `data` (regra de tamanho do repositório, decisão 0008).

Uso: .venv\\Scripts\\python MA2026-entrega-parcial\\02-powerquery\\scripts\\exportar_dados_limpos.py
"""
from __future__ import annotations

import csv
import datetime as dt
import sys
from pathlib import Path

import openpyxl

DIR = Path(__file__).resolve().parents[1]
ARQ = DIR / "cheiU_02_PowerQuery.xlsx"
SAIDA = DIR / "dados_limpos"
TABELAS = ["Fato_Transporte", "Fato_Referencia_Mensal", "Dim_Transporte", "Dim_Grupo", "Ref_Feriados", "Rejeitados",
           "Conf_Reconciliacao", "Conf_Motivos", "Conf_Colunas", "Conf_Etapas", "Conf_Publicado"]
POR_SEMESTRE = {"Fato_Transporte"}


def valor(v):
    if isinstance(v, dt.datetime):
        return v.date().isoformat() if v.time() == dt.time(0) else v.isoformat()
    if isinstance(v, float) and v.is_integer():
        return int(v)
    return "" if v is None else v


def main() -> int:
    SAIDA.mkdir(exist_ok=True)
    wb = openpyxl.load_workbook(ARQ, read_only=True, data_only=True)
    for nome in TABELAS:
        linhas = wb[nome].iter_rows(values_only=True)
        cab = [c for c in next(linhas) if c is not None]
        n = len(cab)
        dados = [[valor(v) for v in r[:n]] for r in linhas if any(v is not None for v in r[:n])]
        if nome in POR_SEMESTRE:
            i = cab.index("data")
            partes = {"S1": [r for r in dados if str(r[i])[5:7] <= "06"], "S2": [r for r in dados if str(r[i])[5:7] > "06"]}
        else:
            partes = {"": dados}
        for suf, rows in partes.items():
            arq = SAIDA / (f"{nome}_2024_{suf}.csv" if suf else f"{nome}.csv")
            with arq.open("w", encoding="utf-8", newline="") as f:
                w = csv.writer(f, lineterminator="\n")
                w.writerow(cab)
                w.writerows(rows)
            print(f"{arq.name}: {len(rows)} linhas, {arq.stat().st_size / 1e6:.1f} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
