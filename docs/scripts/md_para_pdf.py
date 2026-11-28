r"""Converte um Markdown do projeto em PDF pelo Edge (headless).

Uso: .venv\Scripts\python docs\scripts\md_para_pdf.py <arquivo.md> [saida.pdf]
"""
import subprocess
import sys
import tempfile
from pathlib import Path

import markdown

EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
CSS = """body{font-family:'Segoe UI',sans-serif;font-size:10.5pt;line-height:1.45;color:#1F2933;margin:0 8mm}
h1{color:#0B6E4F;font-size:20pt;margin-bottom:4pt}h2{color:#0B6E4F;font-size:13.5pt;border-bottom:1px solid #ccc;padding-bottom:2pt;margin-top:16pt}
table{border-collapse:collapse;margin:6pt 0;font-size:9.5pt}th,td{border:1px solid #ccc;padding:3pt 6pt;text-align:left}th{background:#EEF5F1}
code{background:#f3f3f3;padding:0 2pt;font-size:9pt}tr{page-break-inside:avoid}"""


def main() -> None:
    md = Path(sys.argv[1]).resolve()
    pdf = Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else md.with_suffix(".pdf")
    corpo = markdown.markdown(md.read_text(encoding="utf-8"), extensions=["tables"])
    html = f"<!doctype html><html lang='pt-BR'><head><meta charset='utf-8'><title>{md.stem}</title><style>{CSS}</style></head><body>{corpo}</body></html>"
    with tempfile.TemporaryDirectory() as tmp:
        h = Path(tmp) / "doc.html"
        h.write_text(html, encoding="utf-8")
        subprocess.run([EDGE, "--headless", "--disable-gpu", "--no-pdf-header-footer", f"--user-data-dir={tmp}",
                        f"--print-to-pdf={pdf}", h.as_uri()], check=True, capture_output=True, timeout=120)
    print(pdf, pdf.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
