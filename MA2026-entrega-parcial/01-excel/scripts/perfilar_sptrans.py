"""Perfila o layout de cada arquivo SPTrans baixado (diários e consolidados).

Para cada arquivo: formato real (pelos bytes, não pela extensão), abas, linha do cabeçalho,
colunas, número de linhas, datas encontradas e linhas que não são de dados.
Saída: dados-brutos/sptrans/2024/perfil_layout.csv e um resumo no terminal.

Uso: .venv\\Scripts\\python MA2026-entrega-parcial\\01-excel\\scripts\\perfilar_sptrans.py
"""
from __future__ import annotations

import csv
import io
import datetime as dt
import sys
from collections import Counter
from pathlib import Path

import openpyxl
import xlrd

RAIZ = Path(__file__).resolve().parents[1] / "dados-brutos" / "sptrans" / "2024"
SAIDA = RAIZ / "perfil_layout.csv"


def formato_real(p: Path) -> str:
    cab = p.read_bytes()[:8]
    if cab.startswith(b"PK"):
        return "xlsx"
    if cab.startswith(b"\xd0\xcf\x11\xe0"):
        return "xls"
    return "desconhecido"


def linhas_planilha(p: Path, fmt: str):
    """Devolve [(nome_aba, [linhas como listas de valores])]."""
    if fmt == "xlsx":
        wb = openpyxl.load_workbook(io.BytesIO(p.read_bytes()), read_only=True, data_only=True)  # a extensão pode mentir
        out = [(ws.title, [list(r) for r in ws.iter_rows(values_only=True)]) for ws in wb.worksheets]
        wb.close()
        return out
    wb = xlrd.open_workbook(p)
    out = []
    for sh in wb.sheets():
        rows = []
        for i in range(sh.nrows):
            row = []
            for c in sh.row(i):
                if c.ctype == xlrd.XL_CELL_DATE:
                    row.append(xlrd.xldate_as_datetime(c.value, wb.datemode))
                else:
                    row.append(c.value)
            rows.append(row)
        out.append((sh.name, rows))
    return out


def norm(v) -> str:
    return "" if v is None else str(v).strip()


def perfilar(p: Path) -> dict:
    fmt = formato_real(p)
    abas = linhas_planilha(p, fmt)
    nome_aba, rows = abas[0]
    cab = next((i for i, r in enumerate(rows[:60]) if r and norm(r[0]).lower() in ("data", "grupo")), None)
    colunas = [norm(c) for c in rows[cab]] if cab is not None else []
    while colunas and colunas[-1] == "":
        colunas.pop()
    dados = rows[cab + 1:] if cab is not None else []
    tipos = Counter()
    datas = Counter()
    for r in dados:
        a = norm(r[0]) if r else ""
        if not any(norm(v) for v in r):
            tipos["vazia"] += 1
        elif a.upper().startswith("RELAT"):
            tipos["cabecalho_pagina"] += 1
        elif a.lower() in ("data", "grupo"):
            tipos["cabecalho_coluna"] += 1
        elif a.lower().startswith("total"):
            tipos["total"] += 1
        else:
            tipos["dado"] += 1
            v = r[0]
            if isinstance(v, dt.datetime):
                datas[v.date().isoformat()] += 1
            else:
                datas[a] += 1
    return {
        "arquivo": p.relative_to(RAIZ).as_posix(),
        "extensao": p.suffix.lower().lstrip("."),
        "formato_real": fmt,
        "abas": " | ".join(a for a, _ in abas),
        "aba_lida": nome_aba,
        "linha_cabecalho": (cab + 1) if cab is not None else "",
        "n_colunas": len(colunas),
        "colunas": " | ".join(colunas),
        "linhas_dado": tipos["dado"],
        "linhas_cabecalho_pagina": tipos["cabecalho_pagina"],
        "linhas_cabecalho_coluna": tipos["cabecalho_coluna"],
        "linhas_total": tipos["total"],
        "linhas_vazias": tipos["vazia"],
        "datas": " | ".join(sorted(datas))[:200],
        "n_datas": len(datas),
    }


def main() -> int:
    arquivos = sorted((RAIZ / "diario").iterdir()) + sorted((RAIZ / "mensal").iterdir())
    perfis = []
    for p in arquivos:
        try:
            perfis.append(perfilar(p))
        except Exception as e:  # noqa: BLE001
            perfis.append({"arquivo": p.relative_to(RAIZ).as_posix(), "formato_real": f"ERRO: {e}"})
    campos = list(perfis[0].keys())
    with SAIDA.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=campos, lineterminator="\n")
        w.writeheader()
        w.writerows(perfis)

    diarios = [p for p in perfis if p["arquivo"].startswith("diario/")]
    print(f"arquivos: {len(perfis)} (diários {len(diarios)})")
    print("extensão × formato real:", Counter((p.get("extensao"), p.get("formato_real")) for p in perfis))
    print("linha do cabeçalho (diários):", Counter(p.get("linha_cabecalho") for p in diarios))
    print("nº de colunas (diários):", Counter(p.get("n_colunas") for p in diarios))
    layouts = Counter(p.get("colunas") for p in diarios)
    print(f"layouts de colunas distintos (diários): {len(layouts)}")
    for cols, n in layouts.most_common():
        print(f"  {n:3d} × {cols}")
    print("nº de datas por arquivo diário:", Counter(p.get("n_datas") for p in diarios))
    print("linhas de dado (diários): min", min(p.get("linhas_dado", 0) for p in diarios),
          "max", max(p.get("linhas_dado", 0) for p in diarios),
          "soma", sum(p.get("linhas_dado", 0) for p in diarios))
    for k in ("linhas_cabecalho_pagina", "linhas_cabecalho_coluna", "linhas_total", "linhas_vazias"):
        print(f"{k} (diários): {sum(p.get(k, 0) for p in diarios)}")
    print("consolidados:")
    for p in perfis:
        if p["arquivo"].startswith("mensal/"):
            print(f"  {p['arquivo']}: {p.get('formato_real')} cab={p.get('linha_cabecalho')} "
                  f"cols={p.get('n_colunas')} dados={p.get('linhas_dado')} datas={p.get('n_datas')} "
                  f"pag={p.get('linhas_cabecalho_pagina')}")
    erros = [p for p in perfis if str(p.get("formato_real", "")).startswith("ERRO")]
    for p in erros:
        print("ERRO", p["arquivo"], p["formato_real"])
    return 1 if erros else 0


if __name__ == "__main__":
    sys.exit(main())
