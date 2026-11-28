r"""Converte módulos VBA escritos em UTF-8 para o formato do importador do VBE (Windows-1252, CRLF).

Uso: .venv\Scripts\python MA2026-entrega-final\01-vba\scripts\converter_bas.py <pasta_utf8>
Os .bas de modulos/ são a fonte da verdade; este script só ajuda a editá-los em UTF-8.
"""
import sys
from pathlib import Path

destino = Path(__file__).resolve().parents[1] / "modulos"
for f in sorted(Path(sys.argv[1]).glob("*.bas")):
    texto = f.read_text(encoding="utf-8").replace("\r\n", "\n")
    (destino / f.name).write_bytes(texto.replace("\n", "\r\n").encode("cp1252"))
    print(f.name)
