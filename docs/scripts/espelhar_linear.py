"""Espelha o projeto cheiU do Linear como issues do repositório do grupo no GitHub (decisão 0011).

O Linear é a fonte do status. A tabela ISSUES abaixo é uma cópia dele: antes de rodar,
atualize status, labels e títulos a partir do Linear e troque DATA.

Uso: .venv/Scripts/python.exe docs/scripts/espelhar_linear.py [--executar]
Sem --executar, só gera os corpos na pasta temporária e imprime as checagens (simulação).
Com --executar: cria o que falta (labels, milestones, issues), atualiza corpo e labels das issues
que já existem e fecha como concluídas as que estão em Done. Não reabre issue fechada.
Requer o `gh` autenticado com permissão de escrita em REPO.
"""
import json
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
REPO = "Ve3e3/projeto_cheiU_FATEC"
RAIZ = Path(__file__).resolve().parents[2]
SAIDA = Path(tempfile.gettempdir()) / "cheiU_espelho_linear"
DATA = "21/11/2026"
LIN = "https://linear.app/trabalho-microinformatica/issue/"
EXECUTAR = "--executar" in sys.argv

MARCOS = [  # chave, nome, descrição (do Linear)
    ("E0", "Etapa 0 — Ambiente", "Repositório, documentação para agentes, integrações, Python e automação do Excel via COM. Plano: docs/plano/etapa-0-ambiente.md"),
    ("E1", "Etapa 1 — Excel", "Aulas 2–3. Dados brutos de 2024 baixados, dicionário, catálogo de defeitos e ficha do projeto; cheiU_01_Excel.xlsx com amostra de um mês auditável (Bruto, Tratado, Cadastros, Auditoria). Plano: docs/plano/etapa-1-excel.md"),
    ("E2", "Etapa 2 — Power Query", "Aulas 4–5. cheiU_02_PowerQuery.xlsx lê os brutos de 2024 e os cadastros da Etapa 1: staging por fonte, fatos e dimensões, Rejeitados e reconciliação com diferença 0; scripts_m, dados_limpos, evidências. Plano: docs/plano/etapa-2-powerquery.md"),
    ("E3", "Etapa 3 — Power Pivot e DAX", "Aulas 6–7. cheiU_03_PowerPivot.xlsx lê a Etapa 2: calendário e horário, constelação de fatos, medidas DAX de demanda e lotação, alternativas de percurso, abas Validacao e Conferencia (diferenças 0). Plano: docs/plano/etapa-3-powerpivot-dax.md"),
    ("P1", "Parcial 1", "Aula 8. Exigências do professor: base bruta documentada, base tratada (Excel + Power Query), modelo estrela com ≥5 medidas DAX e ficha do projeto. Defesa oral de 10–15 min, relatório parcial e tag parcial-1. Plano: docs/plano/entregas-academicas.md"),
    ("E4", "Etapa 4 — VBA", "Aulas 10–11. Macros de atualização, QA automatizado, resumo diário em PDF e exportação para o SQL, com módulos .bas versionados. Plano: docs/plano/etapa-4-vba.md"),
    ("E5", "Etapa 5 — SQL", "Aulas 12–13. SQL Server Express em Docker como fonte da verdade: DDL, carga, consultas analíticas, views e reconciliação com o DAX. Plano: docs/plano/etapa-5-sql.md"),
    ("E6", "Etapa 6 — API/Web", "Aulas 14–15. Open-Meteo e BrasilAPI via Power Query integrados ao modelo; Olho Vivo via VBA; carga das APIs no SQL e documentação. Plano: docs/plano/etapa-6-api-web.md"),
    ("P2", "Parcial 2", "Aula 16. Exigências do professor: macro VBA funcionando, banco com DDL e ≥4 consultas de análise, fonte externa (API) integrada ao modelo. Registrar o feedback. Plano: docs/plano/entregas-academicas.md"),
    ("E7", "Etapa 7 — Power BI", "Aula 18. Dashboard interativo (.pbix, com projeto .pbip versionado), exportação em PDF e relatório final. Plano: docs/plano/etapa-7-powerbi.md"),
    ("F", "Entrega Final", "Aula 20. Demonstração ao vivo de todas as ferramentas e repositório congelado (tag final). Plano: docs/plano/entregas-academicas.md"),
]
NOME_MARCO = {k: n for k, n, _ in MARCOS}

LABELS = {  # nome: (cor, descrição)
    "Setup": ("6B6F76", ""), "QA": ("BB87FC", ""), "Docs": ("95A2B3", ""), "Dados": ("4EA7FC", ""),
    "Python": ("3776AB", ""), "Power BI": ("F2C811", ""), "API": ("F2994A", ""), "SQL": ("CC2927", ""),
    "VBA": ("5E6AD2", ""), "DAX": ("0F9D58", ""), "Power Query": ("1E8E3E", ""), "Excel": ("21A366", ""),
    "Resp: Grupo": ("95A2B3", "Trabalho conjunto do grupo"),
    "Resp: Maryele": ("BB87FC", "QA, automação VBA"),
    "Resp: Victor": ("F2994A", "Gerente do projeto, API"),
    "Resp: Luciano": ("F2C94C", "Engenharia de dados, Power Query"),
    "Humano": ("EB5757", "Exige ação de uma pessoa (conta, autorização, instalação com interface, apresentação)"),
    "Em andamento": ("FBCA04", "In Progress no Linear"),
}

# TRA | status | marco | labels | slug da URL | título (como no Linear)
ISSUES = """
5|Done|E0|Setup;Docs;Resp: Luciano|e01-estrutura-do-repositorio-e-documentacao-para-agentes|[E0.1] Estrutura do repositório e documentação para agentes
6|Done|E0|Setup;Resp: Luciano|e02-repositorio-github-e-projeto-no-linear|[E0.2] Repositório GitHub e projeto no Linear
7|Todo|E0|Setup;Resp: Luciano;Humano|e03-integracao-github-linear|[E0.3] Integração GitHub ↔ Linear
8|Done|E0|Setup;Resp: Victor;Humano|e04-repositorio-do-grupo-como-remote-grupo|[E0.4] Repositório do grupo como remote `grupo`
9|Todo|E0|API;Resp: Victor;Humano|e05-cadastro-no-devplace-da-sptrans-token-olho-vivo-e-gtfs|[E0.5] Cadastro no DevPlace da SPTrans (token Olho Vivo e GTFS)
10|Done|E0|Setup;Python;Resp: Luciano|e06-python-e-ambiente-virtual|[E0.6] Python e ambiente virtual
11|In Progress|E0|Setup;Power Query;Excel;Resp: Luciano|e07-prova-de-conceito-automacao-do-excel-via-com|[E0.7] Prova de conceito: automação do Excel via COM
12|Done|E1|Docs;Resp: Luciano|e10-refinar-o-plano-da-etapa-1|[E1.0] Refinar o plano da Etapa 1
13|Done|E1|Dados;Python;Resp: Luciano|e11-baixar-passageiros-transportados-da-sptrans-2024|[E1.1] Baixar passageiros transportados da SPTrans (2024)
14|Todo|E1|Dados;Python;Resp: Luciano|e12-baixar-metro-e-cptm-2024|[E1.2] Baixar Metrô e CPTM (2024)
15|Backlog|E1|Dados;Python;Resp: Luciano|e13-baixar-e-converter-a-pesquisa-od-2023|[E1.3] Baixar e converter a Pesquisa OD 2023
16|Done|E1|Docs;Dados;Resp: Luciano|e14-inventario-dicionario-catalogo-de-defeitos-e-ficha-do-projeto|[E1.4] Inventário, dicionário, catálogo de defeitos e ficha do projeto
17|Done|E1|Excel;Resp: Luciano|e15-aba-cadastros-cadastros-de-para-e-parametros|[E1.5] Aba `Cadastros`: cadastros, de-para e parâmetros
18|In Progress|E2|Power Query;Resp: Luciano|e22-sptrans-diario|[E2.2] SPTrans diário
19|Backlog|E2|Power Query;Resp: Luciano|e23-metro|[E2.3] Metrô
20|Backlog|E2|Power Query;Resp: Luciano|e24-cptm-com-estimativa-diaria|[E2.4] CPTM com estimativa diária
21|Backlog|E2|Power Query;Resp: Luciano|e25-viagens-da-od-2023|[E2.5] Viagens da OD 2023
22|Done|E2|Power Query;Resp: Luciano|e29-consolidacao-rejeitados-e-conferencia|[E2.9] Consolidação, `Rejeitados` e conferência
23|Done|E2|QA;Resp: Maryele|e210-qa-da-etapa-2|[E2.10] QA da Etapa 2
24|In Progress|E2|Docs;Power Query;Resp: Luciano|e211-publicacao-da-etapa-2|[E2.11] Publicação da Etapa 2
25|Done|E3|Docs;Resp: Luciano|e30-refinar-o-plano-da-etapa-3|[E3.0] Refinar o plano da Etapa 3
26|Done|E3|DAX;Power Query;Resp: Luciano|e31-arquivo-da-etapa-3-dim-calendario-e-dim-horario|[E3.1] Arquivo da Etapa 3, `Dim_Calendario` e `Dim_Horario`
27|Backlog|E2|Dados;Power Query;Resp: Luciano|e26-fato-perfil-horario|[E2.6] `Fato_Perfil_Horario`
28|Backlog|E2|Power Query;Resp: Luciano|e27-fato-viagem-od-e-dim-cadeia-modal|[E2.7] `Fato_Viagem_OD` e `Dim_Cadeia_Modal`
29|Backlog|E2|Dados;Power Query;Resp: Luciano|e28-fato-oferta|[E2.8] `Fato_Oferta`
30|In Progress|E3|DAX;Resp: Luciano|e32-modelo-no-power-pivot|[E3.2] Modelo no Power Pivot
31|Done|E3|DAX;Resp: Luciano|e33-medidas-dax-de-demanda|[E3.3] Medidas DAX de demanda
32|Backlog|E3|DAX;Resp: Luciano|e34-medidas-dax-por-hora-e-de-lotacao|[E3.4] Medidas DAX por hora e de lotação
33|Backlog|E3|DAX;Excel;Resp: Luciano|e35-alternativas-de-percurso-nos-corredores|[E3.5] Alternativas de percurso nos corredores
34|Done|E3|DAX;Excel;Resp: Luciano|e36-abas-validacao-e-conferencia|[E3.6] Abas `Validacao` e `Conferencia`
35|Done|E3|QA;Docs;Resp: Maryele|e37-qa-e-publicacao-da-etapa-3|[E3.7] QA e publicação da Etapa 3
36|Done|P1|Docs;Resp: Victor|p11-relatorio-parcial|[P1.1] Relatório parcial
37|Done|P1|Docs;Resp: Victor;Humano|p12-apresentacao-da-parcial-1|[P1.2] Apresentação da Parcial 1
38|Done|P1|Setup;Resp: Luciano|p13-congelar-o-repositorio-da-parcial-1-tag-parcial-1|[P1.3] Congelar o repositório da Parcial 1 (tag parcial-1)
39|Backlog|E4|Docs;Resp: Maryele|e40-refinar-o-plano-da-etapa-4|[E4.0] Refinar o plano da Etapa 4
40|Backlog|E4|VBA;Resp: Maryele|e41-base-do-xlsm-e-modulos-utilitarios|[E4.1] Base do `.xlsm` e módulos utilitários
41|Backlog|E4|VBA;Resp: Maryele|e42-macro-de-atualizacao-completa|[E4.2] Macro de atualização completa
42|Backlog|E4|QA;VBA;Resp: Maryele|e43-macro-de-qa-automatizado|[E4.3] Macro de QA automatizado
43|Backlog|E4|VBA;Resp: Maryele|e44-macro-de-resumo-diario|[E4.4] Macro de resumo diário
44|Backlog|E4|SQL;VBA;Resp: Maryele|e45-macro-de-exportacao-para-a-carga-no-sql|[E4.5] Macro de exportação para a carga no SQL
45|Backlog|E4|Docs;VBA;Resp: Maryele|e46-painel-de-controle-e-fechamento-da-etapa-4|[E4.6] Painel de controle e fechamento da Etapa 4
46|Backlog|E5|Docs;Resp: Luciano|e50-refinar-o-plano-da-etapa-5|[E5.0] Refinar o plano da Etapa 5
47|Backlog|E5|Setup;SQL;Resp: Luciano|e51-sql-server-em-docker|[E5.1] SQL Server em Docker
48|Backlog|E5|SQL;Resp: Luciano|e52-ddl-do-modelo-dimensional|[E5.2] DDL do modelo dimensional
49|Backlog|E5|SQL;Resp: Luciano|e53-carga|[E5.3] Carga
50|Backlog|E5|SQL;Resp: Luciano|e54-consultas-analiticas-dml-e-views|[E5.4] Consultas analíticas (DML) e views
51|Backlog|E5|QA;SQL;Resp: Maryele|e55-reconciliacao-sql-dax-e-fechamento|[E5.5] Reconciliação SQL × DAX e fechamento
52|Backlog|E6|Docs;Resp: Victor|e60-refinar-o-plano-da-etapa-6|[E6.0] Refinar o plano da Etapa 6
53|Backlog|E6|API;Power Query;Resp: Victor|e61-clima-horario-open-meteo-no-power-query|[E6.1] Clima horário (Open-Meteo) no Power Query
54|Backlog|E6|API;Power Query;Resp: Victor|e62-feriados-brasilapi-no-power-query|[E6.2] Feriados (BrasilAPI) no Power Query
55|Backlog|E6|API;VBA;Resp: Victor|e63-olho-vivo-autenticacao-e-dados-estaticos-vba|[E6.3] Olho Vivo: autenticação e dados estáticos (VBA)
56|Backlog|E6|API;VBA;Resp: Victor|e64-extra-coletor-agendado-de-posicao-e-previsao|[E6.4] [Extra] Coletor agendado de posição e previsão
57|Backlog|E6|Docs;API;SQL;Resp: Victor|e65-carga-das-apis-no-sql-e-documentacao|[E6.5] Carga das APIs no SQL e documentação
58|Backlog|P2|Docs;Resp: Victor;Humano|p21-apresentar-a-parcial-2-e-registrar-o-feedback|[P2.1] Apresentar a Parcial 2 e registrar o feedback
59|Backlog|E7|Setup;Power BI;Resp: Luciano|e70-refinar-o-plano-e-instalar-o-power-bi-desktop|[E7.0] Refinar o plano e instalar o Power BI Desktop
60|Backlog|E7|Power BI;DAX;Resp: Luciano|e71-conexao-ao-sql-e-modelo-semantico|[E7.1] Conexão ao SQL e modelo semântico
61|Backlog|E7|Power BI;Resp: Grupo|e72-pagina-visao-geral|[E7.2] Página "Visão geral"
62|Backlog|E7|Power BI;Resp: Grupo|e73-pagina-padroes-horarios|[E7.3] Página "Padrões horários"
63|Backlog|E7|Power BI;Resp: Grupo|e74-pagina-linhas-e-regioes|[E7.4] Página "Linhas e regiões"
64|Backlog|E7|Power BI;Resp: Grupo|e75-pagina-alternativas-de-percurso|[E7.5] Página "Alternativas de percurso"
65|Backlog|E7|QA;Power BI;Resp: Maryele|e76-navegacao-tema-sobre-os-dados-e-qa|[E7.6] Navegação, tema, "Sobre os dados" e QA
66|Backlog|E7|Docs;Resp: Grupo|e77-relatorio-final|[E7.7] Relatório final
67|Backlog|F|Docs;Resp: Victor;Humano|f1-roteiro-da-demonstracao-ao-vivo-e-plano-b|[F.1] Roteiro da demonstração ao vivo e plano B
68|Backlog|F|Docs;Resp: Victor;Humano|f2-apresentacao-final-e-ensaio|[F.2] Apresentação final e ensaio
69|Backlog|F|Setup;Resp: Luciano|f3-congelar-a-entrega-final-tag-final|[F.3] Congelar a entrega final (tag final)
70|Done|E0|Docs;Resp: Luciano|e08-alinhar-o-plano-aos-guias-do-professor|[E0.8] Alinhar o plano aos guias do professor
71|Todo|E0|Setup;Resp: Victor;Humano|e09-commits-proprios-de-cada-integrante|[E0.9] Commits próprios de cada integrante
72|In Progress|E1|Excel;Resp: Luciano|e16-base-auditavel-da-amostra-bruto-tratado-auditoria|[E1.6] Base auditável da amostra (Bruto, Tratado, Auditoria)
73|Done|E1|QA;Docs;Resp: Maryele|e17-qa-e-fechamento-da-etapa-1|[E1.7] QA e fechamento da Etapa 1
74|Done|E2|Docs;Resp: Luciano|e20-refinar-o-plano-da-etapa-2|[E2.0] Refinar o plano da Etapa 2
75|Done|E2|Power Query;Resp: Luciano|e21-parametros-e-cadastros-da-etapa-1|[E2.1] Parâmetros e cadastros da Etapa 1
"""

ARQ_PLANO = {"E0": "etapa-0-ambiente.md", "E1": "etapa-1-excel.md", "E2": "etapa-2-powerquery.md",
             "E3": "etapa-3-powerpivot-dax.md", "E4": "etapa-4-vba.md", "E5": "etapa-5-sql.md",
             "E6": "etapa-6-api-web.md", "E7": "etapa-7-powerbi.md", "P": "entregas-academicas.md",
             "F": "entregas-academicas.md"}


def slug_github(texto):
    t = texto.strip().lower()
    t = re.sub(r"[^\w\- ]", "", t)  # \w é unicode: mantém acentos
    return t.replace(" ", "-")


def secao(passo):
    chave = passo[:2] if passo[0] == "E" else passo[0]
    arq = ARQ_PLANO[chave]
    linhas = (RAIZ / "docs" / "plano" / arq).read_text(encoding="utf-8").splitlines()
    for i, l in enumerate(linhas):
        if re.match(rf"^### {re.escape(passo)} — ", l):
            fim = next((j for j in range(i + 1, len(linhas)) if re.match(r"^#{1,3} ", linhas[j])), len(linhas))
            corpo = "\n".join(linhas[i + 1:fim]).strip()
            return arq, l[4:].strip(), corpo
    raise SystemExit(f"seção {passo} não encontrada em {arq}")


def gh(args, payload=None):
    r = subprocess.run(["gh", *args], input=json.dumps(payload) if payload is not None else None,
                       capture_output=True, text=True, encoding="utf-8")
    if r.returncode:
        raise SystemExit(f"gh {' '.join(args)} falhou: {r.stderr.strip()}")
    return json.loads(r.stdout) if r.stdout.strip() else None


def paginado(caminho):
    return gh(["api", "--paginate", "--slurp", caminho])


def montar():
    itens = []
    for linha in ISSUES.strip().splitlines():
        tra, status, marco, labels, slug, titulo = linha.split("|", 5)
        passo = re.match(r"\[([EPF][\d.]*\d)\]", titulo).group(1)
        arq, cab, corpo = secao(passo)
        url = f"{LIN}TRA-{tra}/{slug}"
        plano = f"https://github.com/{REPO}/blob/main/docs/plano/{arq}#{slug_github(cab)}"
        texto = (
            f"**Linear:** [TRA-{tra}]({url}) · **Status no Linear:** {status} · **Marco:** {NOME_MARCO[marco]}\n\n"
            f"**Plano:** [`docs/plano/{arq}` › {passo}]({plano})\n\n"
            f"> Espelho da issue do Linear, onde o status é mantido (cópia de {DATA}). "
            f"A descrição abaixo vem do plano do projeto.\n\n{corpo}\n"
        )
        lbl = labels.split(";") + (["Em andamento"] if status == "In Progress" else [])
        itens.append(dict(tra=int(tra), status=status, marco=marco, labels=lbl, titulo=titulo, corpo=texto))
    return itens


itens = montar()
SAIDA.mkdir(exist_ok=True)
for it in itens:
    (SAIDA / f"TRA-{it['tra']:02d}.md").write_text(f"# {it['titulo']}\n\n{it['corpo']}", encoding="utf-8")
print("issues:", len(itens), "| Done:", sum(i["status"] == "Done" for i in itens),
      "| In Progress:", sum(i["status"] == "In Progress" for i in itens))
print("TRA contíguos 5..75:", [i["tra"] for i in itens] == list(range(5, 76)))
print("labels sem definição:", sorted({l for i in itens for l in i["labels"]} - LABELS.keys()))
print("arrobas fora de código:", [i["tra"] for i in itens if re.search(r"(^|[^`\w@])@\w", re.sub(r"`[^`]*`", "", i["corpo"]))])
print("maior corpo (chars):", max(len(i["corpo"]) for i in itens))
if not EXECUTAR:
    sys.exit(0)

# ---- execução real ----
existentes = {l["name"] for p in paginado(f"repos/{REPO}/labels?per_page=100") for l in p}
for nome, (cor, desc) in LABELS.items():
    if nome not in existentes:
        gh(["api", "-X", "POST", f"repos/{REPO}/labels", "--input", "-"], {"name": nome, "color": cor, "description": desc})
        print("label criada:", nome); time.sleep(1)

ms = {m["title"]: m["number"] for p in paginado(f"repos/{REPO}/milestones?state=all&per_page=100") for m in p}
for k, nome, desc in MARCOS:
    if nome not in ms:
        m = gh(["api", "-X", "POST", f"repos/{REPO}/milestones", "--input", "-"], {"title": nome, "description": desc})
        ms[nome] = m["number"]; print("marco criado:", nome); time.sleep(1)

ja = {i["title"]: i for p in paginado(f"repos/{REPO}/issues?state=all&per_page=100") for i in p if "pull_request" not in i}
mapa = []
for it in itens:
    if it["titulo"] in ja:
        atual = ja[it["titulo"]]
        num, estado = atual["number"], atual["state"]
        if (atual["body"] or "").strip() != it["corpo"].strip() or sorted(l["name"] for l in atual["labels"]) != sorted(it["labels"]):
            gh(["api", "-X", "PATCH", f"repos/{REPO}/issues/{num}", "--input", "-"], {"body": it["corpo"], "labels": it["labels"]})
            print(f"atualizada: #{num} {it['titulo']}"); time.sleep(1)
    else:
        r = gh(["api", "-X", "POST", f"repos/{REPO}/issues", "--input", "-"],
               {"title": it["titulo"], "body": it["corpo"], "labels": it["labels"], "milestone": ms[NOME_MARCO[it["marco"]]]})
        num, estado = r["number"], r["state"]
        print(f"criada: #{num} TRA-{it['tra']} {it['titulo']}"); time.sleep(2)
    if it["status"] == "Done" and estado == "open":
        gh(["api", "-X", "PATCH", f"repos/{REPO}/issues/{num}", "--input", "-"], {"state": "closed", "state_reason": "completed"})
        estado = "closed"; print(f"  fechada como concluída: #{num}"); time.sleep(1)
    mapa.append((it["tra"], num, estado))
(SAIDA / "mapa.json").write_text(json.dumps(mapa), encoding="utf-8")
print("fim:", len(mapa), "issues;", sum(e == "closed" for *_, e in mapa), "fechadas")
