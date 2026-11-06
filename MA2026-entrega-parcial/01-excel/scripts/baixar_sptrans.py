"""Baixa os arquivos de passageiros transportados da SPTrans de 2024.

Saídas (relativas a 01-excel/dados-brutos/):
  sptrans/2024/diario/      um arquivo por dia, com o nome original da publicação
  sptrans/2024/mensal/      os 12 consolidados mensais
  sptrans/referencia/       página HTML com os totais mensais publicados por grupo
  manifesto.csv             fonte, url, arquivo, tamanho_bytes, sha256, baixado_em, data_ref

Idempotente: um arquivo que já existe não é baixado de novo (o sha256 é recalculado).
No fim, lista os dias de 2024 sem arquivo e as datas com mais de um arquivo.

Uso: .venv\\Scripts\\python MA2026-entrega-parcial\\01-excel\\scripts\\baixar_sptrans.py
"""
from __future__ import annotations

import csv
import datetime as dt
import hashlib
import re
import sys
import urllib.parse
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import requests
from bs4 import BeautifulSoup

PAGINA_2024 = "https://capital.sp.gov.br/web/mobilidade/w/institucional/sptrans/acesso_a_informacao/362878"
PAGINA_TOTAIS = "https://prefeitura.sp.gov.br/web/mobilidade/w/institucional/sptrans/acesso_a_informacao/245234"
BASE = "https://capital.sp.gov.br"
UA = {"User-Agent": "cheiU-FATEC/1.0 (projeto academico ILP590)"}

RAIZ = Path(__file__).resolve().parents[1] / "dados-brutos"
PASTA_DIARIO = RAIZ / "sptrans" / "2024" / "diario"
PASTA_MENSAL = RAIZ / "sptrans" / "2024" / "mensal"
PASTA_REF = RAIZ / "sptrans" / "referencia"
MANIFESTO = RAIZ / "manifesto.csv"
CAMPOS = ["fonte", "url", "arquivo", "tamanho_bytes", "sha256", "baixado_em", "data_ref"]

MESES = {"jan": 1, "fev": 2, "mar": 3, "abr": 4, "mai": 5, "jun": 6, "jul": 7,
         "ul": 7,  # grafia publicada com erro: "22ul2024-xlsx"
         "ago": 8, "set": 9, "out": 10, "nov": 11, "dez": 12}
MESES_EXTENSO = {"janeiro": 1, "fevereiro": 2, "marco": 3, "março": 3, "abril": 4, "maio": 5, "junho": 6,
                 "julho": 7, "agosto": 8, "setembro": 9, "outubro": 10, "novembro": 11, "dezembro": 12}


def nome_local(url: str) -> str:
    """Nome do arquivo local: o último trecho da URL; '-xlsx'/'-xls' sem ponto viram extensão."""
    nome = urllib.parse.unquote(url.rstrip("/").split("/")[-1])
    m = re.match(r"^(.*?)-(xlsx|xls)$", nome, re.I)
    if m:
        nome = f"{m.group(1)}.{m.group(2).lower()}"
    return nome


def data_do_nome(nome: str) -> dt.date | None:
    m = re.search(r"(\d{1,2})\s*([a-zç]{2,3})\s*2024", nome, re.I)
    if not m:
        return None
    mes = MESES.get(m.group(2).lower())
    return dt.date(2024, mes, int(m.group(1))) if mes else None


def mes_do_consolidado(nome: str) -> int | None:
    n = nome.lower()
    for chave, mes in MESES_EXTENSO.items():
        if chave in n:
            return mes
    return None


def sha256(caminho: Path) -> str:
    h = hashlib.sha256()
    with caminho.open("rb") as f:
        for bloco in iter(lambda: f.read(1 << 20), b""):
            h.update(bloco)
    return h.hexdigest()


def baixar(url: str, destino: Path) -> tuple[Path, bool]:
    if destino.exists() and destino.stat().st_size > 0:
        return destino, False
    destino.parent.mkdir(parents=True, exist_ok=True)
    r = requests.get(url, headers=UA, timeout=120)
    r.raise_for_status()
    tmp = destino.with_suffix(destino.suffix + ".part")
    tmp.write_bytes(r.content)
    tmp.replace(destino)
    return destino, True


def main() -> int:
    html = requests.get(PAGINA_2024, headers=UA, timeout=60).text
    soup = BeautifulSoup(html, "html.parser")
    urls = []
    for a in soup.find_all("a", href=True):
        href = a["href"].strip()
        if "/documents/d/mobilidade/" in href or "/secretarias/upload/" in href:
            if "favicon" in href:
                continue
            # A página publica alguns links malformados: "https://https://www…" e "www…" sem esquema.
            href = re.sub(r"^(https?://)+", "https://", href)
            if href.startswith("www."):
                href = "https://" + href
            url = urllib.parse.urljoin(BASE, href)
            url = urllib.parse.quote(url, safe=":/()%?=&")
            if url not in urls:
                urls.append(url)

    tarefas = []
    for url in urls:
        nome = nome_local(url)
        if "consolidado" in nome.lower():
            mes = mes_do_consolidado(nome)
            tarefas.append(("sptrans_consolidado", url, PASTA_MENSAL / nome, f"2024-{mes:02d}" if mes else ""))
        else:
            d = data_do_nome(nome)
            tarefas.append(("sptrans_diario", url, PASTA_DIARIO / nome, d.isoformat() if d else ""))
    tarefas.append(("sptrans_totais_mensais", PAGINA_TOTAIS, PASTA_REF / "totais_mensais.html", "2013-2026"))

    agora = dt.datetime.now().isoformat(timespec="seconds")
    linhas, erros, novos = [], [], 0

    def executar(t):
        fonte, url, destino, data_ref = t
        try:
            caminho, novo = baixar(url, destino)
            return (fonte, url, caminho, data_ref, novo, None)
        except Exception as e:  # noqa: BLE001 - registra e segue
            return (fonte, url, destino, data_ref, False, str(e))

    with ThreadPoolExecutor(max_workers=6) as pool:
        for fonte, url, caminho, data_ref, novo, erro in pool.map(executar, tarefas):
            if erro:
                erros.append((url, erro))
                continue
            novos += novo
            linhas.append({
                "fonte": fonte, "url": url,
                "arquivo": caminho.relative_to(RAIZ).as_posix(),
                "tamanho_bytes": caminho.stat().st_size, "sha256": sha256(caminho),
                "baixado_em": agora, "data_ref": data_ref,
            })

    # Mantém no manifesto as linhas de outras fontes e substitui as da SPTrans.
    antigas = []
    if MANIFESTO.exists():
        with MANIFESTO.open(encoding="utf-8", newline="") as f:
            antigas = [r for r in csv.DictReader(f) if not r["fonte"].startswith("sptrans")]
    with MANIFESTO.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CAMPOS, lineterminator="\n")
        w.writeheader()
        for r in sorted(antigas + linhas, key=lambda r: (r["fonte"], r["data_ref"], r["arquivo"])):
            w.writerow({k: r.get(k, "") for k in CAMPOS})

    diarios = [r for r in linhas if r["fonte"] == "sptrans_diario"]
    por_data: dict[str, list[str]] = {}
    for r in diarios:
        por_data.setdefault(r["data_ref"], []).append(r["arquivo"])
    todos = {(dt.date(2024, 1, 1) + dt.timedelta(days=i)).isoformat() for i in range(366)}
    faltantes = sorted(todos - set(por_data))
    repetidas = {d: a for d, a in por_data.items() if len(a) > 1}
    sem_data = por_data.get("", [])

    total_mb = sum(int(r["tamanho_bytes"]) for r in linhas) / 1e6
    print(f"links: {len(urls)}  baixados agora: {novos}  no manifesto: {len(linhas)}  ({total_mb:.1f} MB)")
    print(f"diários: {len(diarios)}  datas distintas: {len(set(por_data) - {''})}")
    print(f"{len(faltantes)} dias faltantes" + (f": {faltantes}" if faltantes else ""))
    print(f"datas com mais de um arquivo: {len(repetidas)}")
    for d, a in sorted(repetidas.items()):
        print(f"  {d}: {a}")
    if sem_data:
        print(f"arquivos sem data no nome: {sem_data}")
    for url, erro in erros:
        print(f"ERRO {url}: {erro}")
    return 1 if erros else 0


if __name__ == "__main__":
    sys.exit(main())
