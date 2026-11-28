"""Baixa o clima horário de 2024 do Open-Meteo (arquivo histórico) para o centro de São Paulo.

Saída (relativa a 01-excel/dados-brutos/): clima/open_meteo_2024.json, com a resposta da API como veio,
e a linha "clima_open_meteo" no manifesto.csv.

Por que Python e não o Power Query direto: nesta máquina o Power Query do Excel falha ao chamar
archive-api.open-meteo.com (a BrasilAPI funciona), sem mensagem de erro aproveitável. A aquisição fica aqui
(decisão 0004) e o Power Query lê o JSON salvo (consulta api_open_meteo_clima, Etapa 6).

Uso: .venv\\Scripts\\python MA2026-entrega-parcial\\01-excel\\scripts\\baixar_clima.py
"""
from __future__ import annotations

import csv
import datetime as dt
import hashlib
import json
import sys
from pathlib import Path

import requests

URL = "https://archive-api.open-meteo.com/v1/archive"
PARAMS = {"latitude": "-23.55", "longitude": "-46.63", "start_date": "2024-01-01", "end_date": "2024-12-31",
          "hourly": "temperature_2m,precipitation,rain", "timezone": "America/Sao_Paulo"}
UA = {"User-Agent": "cheiU-FATEC/1.0 (projeto academico ILP590)"}
RAIZ = Path(__file__).resolve().parents[1] / "dados-brutos"
DESTINO = RAIZ / "clima" / "open_meteo_2024.json"
MANIFESTO = RAIZ / "manifesto.csv"
CAMPOS = ["fonte", "url", "arquivo", "tamanho_bytes", "sha256", "baixado_em", "data_ref"]


def main() -> int:
    r = requests.get(URL, params=PARAMS, headers=UA, timeout=120)
    r.raise_for_status()
    dados = r.json()
    horas = len(dados["hourly"]["time"])
    nulos = sum(v is None for k in ("temperature_2m", "precipitation", "rain") for v in dados["hourly"][k])
    DESTINO.parent.mkdir(parents=True, exist_ok=True)
    DESTINO.write_bytes(r.content)
    linha = {"fonte": "clima_open_meteo", "url": r.url, "arquivo": DESTINO.relative_to(RAIZ).as_posix(),
             "tamanho_bytes": len(r.content), "sha256": hashlib.sha256(r.content).hexdigest(),
             "baixado_em": dt.datetime.now().isoformat(timespec="seconds"), "data_ref": "2024"}
    with MANIFESTO.open(encoding="utf-8", newline="") as f:
        antigas = [x for x in csv.DictReader(f) if x["fonte"] != "clima_open_meteo"]
    with MANIFESTO.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CAMPOS, lineterminator="\n")
        w.writeheader()
        for x in sorted(antigas + [linha], key=lambda x: (x["fonte"], x["data_ref"], x["arquivo"])):
            w.writerow({k: x.get(k, "") for k in CAMPOS})
    print(f"horas: {horas} (esperado 8784)  nulos: {nulos}  fuso: {dados['timezone']}  {len(r.content) / 1e3:.0f} kB")
    return 0 if horas == 8784 and nulos == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
