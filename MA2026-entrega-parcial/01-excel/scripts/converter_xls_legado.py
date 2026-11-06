"""Converte para .xlsx os arquivos diários .xls que o Power Query não consegue abrir.

O Excel.Workbook do Power Query devolve zero abas para alguns .xls antigos da SPTrans (o Excel e o
xlrd abrem normalmente). Este script copia, valor por valor e sem nenhum tratamento, a primeira aba
de cada um para dados-brutos/sptrans/2024/diario_convertido/<nome>.xlsx. Os originais ficam intactos
em diario/, e a consulta stg_SPTrans_Bruto usa a cópia só quando o original vem vazio.

A lista de arquivos vem do diagnóstico feito no Power Query em 06/11/2026 (catálogo de defeitos, D17).
Uso: .venv\\Scripts\\python MA2026-entrega-parcial\\01-excel\\scripts\\converter_xls_legado.py
"""
from __future__ import annotations

import sys
from pathlib import Path

import openpyxl
import xlrd

RAIZ = Path(__file__).resolve().parents[1] / "dados-brutos" / "sptrans" / "2024"
ORIGEM = RAIZ / "diario"
DESTINO = RAIZ / "diario_convertido"
ILEGIVEIS_NO_POWER_QUERY = [
    "01JAN2024(1).xls", "07JAN2024(1).xls", "14JAN2024(2).xls", "28JAN2024(1).xls",
    "02MAI2024.xls", "03MAI2024.xls",
]


def main() -> int:
    DESTINO.mkdir(parents=True, exist_ok=True)
    for nome in ILEGIVEIS_NO_POWER_QUERY:
        livro = xlrd.open_workbook(ORIGEM / nome)
        aba = livro.sheet_by_index(0)
        novo = openpyxl.Workbook()
        ws = novo.active
        ws.title = aba.name[:31]
        for i in range(aba.nrows):
            linha = []
            for c in aba.row(i):
                v = c.value
                if c.ctype == xlrd.XL_CELL_EMPTY:
                    v = None
                elif c.ctype == xlrd.XL_CELL_NUMBER and float(v).is_integer():
                    v = int(v)
                linha.append(v)
            ws.append(linha)
        saida = DESTINO / (nome + "x")
        novo.save(saida)
        print(f"{nome}: {aba.nrows} linhas × {aba.ncols} colunas -> {saida.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
