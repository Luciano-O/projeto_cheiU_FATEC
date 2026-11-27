"""Baixa os "Embarcados Acumulados" de 2024 da CPTM e extrai os xlsx mensais.

A CPTM publica um zip anual com um zip por mês dentro; cada zip mensal traz um xlsx
(mês × estação × linha, por tipo de tarifa). Também guarda o PDF "Transportados (MDU)"
de 2024, que serve para reconciliar.

Saídas (relativas a 01-excel/dados-brutos/):
  cptm/2024/_zip/                 zip anual original (fora do Git)
  cptm/2024/embarcados/           os 12 xlsx mensais extraídos
  cptm/referencia/                Transportados (MDU) - 2024.pdf
  manifesto.csv                   linhas das fontes cptm_* substituídas

Idempotente: o zip e o PDF não são baixados de novo se já existirem; os xlsx são
reextraídos do zip local. No fim, lista os meses de 2024 sem arquivo.

Observação: a URL de download (admin.cms.sp.gov.br/dx/api/dam/...) responde 400 a HEAD,
mas 200 a GET.

Uso: .venv\\Scripts\\python MA2026-entrega-parcial\\01-excel\\scripts\\baixar_cptm.py
"""
from __future__ import annotations

import csv
import datetime as dt
import hashlib
import io
import re
import sys
import urllib.parse
import zipfile
from pathlib import Path

import requests
from bs4 import BeautifulSoup

PAGINA = "https://www.cptm.sp.gov.br/cptm/transparencia/operacao"
BASE = "https://www.cptm.sp.gov.br"
UA = {"User-Agent": "cheiU-FATEC/1.0 (projeto academico ILP590)"}
ANO = 2024

RAIZ = Path(__file__).resolve().parents[1] / "dados-brutos"
PASTA_ZIP = RAIZ / "cptm" / str(ANO) / "_zip"
PASTA_EMBARCADOS = RAIZ / "cptm" / str(ANO) / "embarcados"
PASTA_REF = RAIZ / "cptm" / "referencia"
MANIFESTO = RAIZ / "manifesto.csv"
CAMPOS = ["fonte", "url", "arquivo", "tamanho_bytes", "sha256", "baixado_em", "data_ref"]

ALVOS = {
    # texto do link na página -> (fonte no manifesto, pasta de destino)
    f"Embarcados Acumulados - {ANO}.zip": ("cptm_embarcados_zip", PASTA_ZIP),
    f"Transportados (MDU) - {ANO}.pdf": ("cptm_transportados_mdu", PASTA_REF),
}


def sha256_bytes(dados: bytes) -> str:
    return hashlib.sha256(dados).hexdigest()


def links_da_pagina() -> dict[str, str]:
    html = requests.get(PAGINA, headers=UA, timeout=60)
    html.raise_for_status()
    soup = BeautifulSoup(html.text, "html.parser")
    achados = {}
    for a in soup.find_all("a", href=True):
        texto = a.get_text(strip=True)
        if texto in ALVOS and texto not in achados:
            achados[texto] = urllib.parse.urljoin(BASE, a["href"].strip())
    return achados


def baixar(url: str, destino: Path) -> bool:
    if destino.exists() and destino.stat().st_size > 0:
        return False
    destino.parent.mkdir(parents=True, exist_ok=True)
    r = requests.get(url, headers=UA, timeout=180)
    r.raise_for_status()
    tmp = destino.with_suffix(destino.suffix + ".part")
    tmp.write_bytes(r.content)
    tmp.replace(destino)
    return True


def mes_do_nome(nome: str) -> int | None:
    m = re.search(rf"{ANO}\s*-\s*(\d{{2}})", nome)
    return int(m.group(1)) if m else None


def main() -> int:
    agora = dt.datetime.now().isoformat(timespec="seconds")
    links = links_da_pagina()
    faltam_links = sorted(set(ALVOS) - set(links))
    linhas, novos = [], 0

    for texto, url in links.items():
        fonte, pasta = ALVOS[texto]
        destino = pasta / texto
        novos += baixar(url, destino)
        dados = destino.read_bytes()
        linhas.append({
            "fonte": fonte, "url": url, "arquivo": destino.relative_to(RAIZ).as_posix(),
            "tamanho_bytes": len(dados), "sha256": sha256_bytes(dados),
            "baixado_em": agora, "data_ref": str(ANO),
        })

    zip_anual = PASTA_ZIP / f"Embarcados Acumulados - {ANO}.zip"
    meses: dict[int, str] = {}
    if zip_anual.exists():
        PASTA_EMBARCADOS.mkdir(parents=True, exist_ok=True)
        url_zip = links.get(zip_anual.name, "")
        with zipfile.ZipFile(zip_anual) as externo:
            for info in externo.infolist():
                if not info.filename.lower().endswith(".zip"):
                    continue
                with zipfile.ZipFile(io.BytesIO(externo.read(info))) as mensal:
                    for interno in mensal.infolist():
                        if not interno.filename.lower().endswith(".xlsx"):
                            continue
                        nome = Path(interno.filename).name
                        dados = mensal.read(interno)
                        (PASTA_EMBARCADOS / nome).write_bytes(dados)
                        mes = mes_do_nome(nome)
                        if mes:
                            meses[mes] = nome
                        linhas.append({
                            "fonte": "cptm_embarcados",
                            "url": f"{url_zip}#{info.filename}/{interno.filename}",
                            "arquivo": (PASTA_EMBARCADOS / nome).relative_to(RAIZ).as_posix(),
                            "tamanho_bytes": len(dados), "sha256": sha256_bytes(dados),
                            "baixado_em": agora, "data_ref": f"{ANO}-{mes:02d}" if mes else "",
                        })

    antigas = []
    if MANIFESTO.exists():
        with MANIFESTO.open(encoding="utf-8", newline="") as f:
            antigas = [r for r in csv.DictReader(f) if not r["fonte"].startswith("cptm")]
    with MANIFESTO.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CAMPOS, lineterminator="\n")
        w.writeheader()
        for r in sorted(antigas + linhas, key=lambda r: (r["fonte"], r["data_ref"], r["arquivo"])):
            w.writerow({k: r.get(k, "") for k in CAMPOS})

    faltantes = [m for m in range(1, 13) if m not in meses]
    print(f"links achados: {len(links)}/{len(ALVOS)}  baixados agora: {novos}")
    print(f"xlsx mensais extraídos: {len(meses)}")
    print(f"{len(faltantes)} meses faltantes" + (f": {faltantes}" if faltantes else ""))
    for texto in faltam_links:
        print(f"ERRO link não encontrado na página: {texto}")
    return 1 if faltantes or faltam_links else 0


if __name__ == "__main__":
    sys.exit(main())
