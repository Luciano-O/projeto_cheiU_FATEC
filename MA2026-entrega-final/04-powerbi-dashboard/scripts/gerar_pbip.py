r"""Gera o projeto Power BI (PBIP) do cheiU: modelo semântico em TMDL, lendo as views dw.vw_* do SQL Server
(Etapa 5), e relatório em PBIR com as páginas do painel. Este script é o gêmeo em texto do painel: para mudar
uma medida, uma relação ou um visual, edite aqui e rode de novo; depois abra o .pbip no Power BI Desktop.

Uso: .venv\Scripts\python MA2026-entrega-final\04-powerbi-dashboard\scripts\gerar_pbip.py
"""
from __future__ import annotations

import json
import shutil
import uuid
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
NOME = "cheiU_dashboard"
SM = RAIZ / f"{NOME}.SemanticModel"
RP = RAIZ / f"{NOME}.Report"
TEMA_BASE = Path(r"C:\Program Files\Microsoft Power BI Desktop\bin\WebView2Resources\minerva\sharedresources\BaseThemes\CY24SU10.json")
NS = uuid.UUID("6b1f3c1e-0c8e-4f0a-9c7d-8a2f5e3b9d11")  # GUIDs estáveis entre execuções


def gid(nome: str) -> str:
    return str(uuid.uuid5(NS, nome))


def gravar(caminho: Path, texto: str) -> None:
    caminho.parent.mkdir(parents=True, exist_ok=True)
    caminho.write_text(texto, encoding="utf-8", newline="\n")


def gravar_json(caminho: Path, obj) -> None:
    gravar(caminho, json.dumps(obj, ensure_ascii=False, indent=2) + "\n")


# ===================================================================== modelo semântico
# (tabela, view, colunas [(nome, tipo, opções)]) — tipos TMDL: string, int64, double, dateTime, boolean
TABELAS = [
    ("Calendario", "vw_calendario", [
        ("data", "dateTime", {"isKey": True, "formatString": "dd/mm/yyyy"}),
        ("ano", "int64", {}), ("mes", "int64", {}), ("nome_mes", "string", {"sortByColumn": "mes"}),
        ("mes_rotulo", "string", {}), ("mes_inicio", "dateTime", {"formatString": "dd/mm/yyyy"}),
        ("dia", "int64", {}), ("dia_semana", "int64", {}), ("nome_dia", "string", {"sortByColumn": "dia_semana"}),
        ("semana_ano", "int64", {}), ("tipo_dia", "string", {}), ("feriado_nome", "string", {}),
        ("fonte_feriado", "string", {}), ("chuva_mm", "double", {"formatString": "0.0"}), ("faixa_chuva", "string", {}),
    ]),
    ("Horario", "vw_horario", [
        ("hora", "int64", {"isKey": True}), ("hora_rotulo", "string", {"sortByColumn": "hora"}),
        ("periodo", "string", {"sortByColumn": "ordem_periodo"}), ("ordem_periodo", "int64", {}),
    ]),
    ("Grupos", "vw_grupos", [
        ("grupo", "string", {"isKey": True, "sortByColumn": "ordem"}), ("modalidade", "string", {}),
        ("ordem", "int64", {}), ("grupo_oficial", "boolean", {}),
    ]),
    ("Linhas", "vw_linhas", [
        ("id_linha", "string", {"isKey": True, "isHidden": True}), ("codigo_linha", "string", {}), ("nome_linha", "string", {}),
        ("linha_rotulo", "string", {}), ("modalidade", "string", {}), ("operador", "string", {}),
        ("grupo", "string", {"isHidden": True}), ("grupo_oficial", "boolean", {}), ("ordem_grupo", "int64", {}), ("lote", "string", {}),
    ]),
    ("Demanda", "vw_demanda_diaria", [
        ("data", "dateTime", {"isHidden": True}), ("id_linha", "string", {"isHidden": True}), ("modalidade", "string", {}),
        ("passageiros", "int64", {"formatString": "#,0"}), ("pagantes", "int64", {"formatString": "#,0"}),
        ("integracao", "int64", {"formatString": "#,0"}), ("gratuidades", "int64", {"formatString": "#,0"}),
        ("tipo_metrica", "string", {}), ("origem_dado", "string", {}),
    ]),
    ("Referencia", "vw_referencia_mensal", [
        ("mes_inicio", "dateTime", {"isHidden": True}), ("grupo", "string", {"isHidden": True}),
        ("passageiros_publicado", "int64", {"formatString": "#,0"}), ("origem_dado", "string", {}), ("fonte", "string", {}),
    ]),
    ("Clima", "vw_clima_horario", [
        ("data", "dateTime", {"isHidden": True}), ("hora", "int64", {"isHidden": True}),
        ("temperatura_c", "double", {"formatString": "0.0"}), ("precipitacao_mm", "double", {"formatString": "0.0"}),
        ("chovendo", "boolean", {}), ("origem_dado", "string", {}),
    ]),
]

RELACOES = [
    ("Demanda", "data", "Calendario", "data"),
    ("Demanda", "id_linha", "Linhas", "id_linha"),
    ("Linhas", "grupo", "Grupos", "grupo"),
    ("Referencia", "mes_inicio", "Calendario", "data"),
    ("Referencia", "grupo", "Grupos", "grupo"),
    ("Clima", "data", "Calendario", "data"),
    ("Clima", "hora", "Horario", "hora"),
]

# (tabela, nome, formato, pasta, expressão DAX) — migradas de 03-powerpivot/dax e 03-api-web/dax
MEDIDAS = [
    ("Demanda", "Total de Passageiros", "#,0", "Demanda", "SUM(Demanda[passageiros])"),
    ("Demanda", "Passageiros de Ônibus", "#,0", "Demanda", 'CALCULATE([Total de Passageiros], Linhas[modalidade] = "Ônibus")'),
    ("Demanda", "Passageiros de Trem", "#,0", "Demanda", 'CALCULATE([Total de Passageiros], Linhas[modalidade] = "Trem")'),
    ("Demanda", "Média Diária de Passageiros", "#,0", "Demanda", "AVERAGEX(VALUES(Calendario[data]), [Total de Passageiros])"),
    ("Demanda", "Média Dia Útil", "#,0", "Demanda", 'CALCULATE([Média Diária de Passageiros], Calendario[tipo_dia] = "Útil")'),
    ("Demanda", "Média Fim de Semana", "#,0", "Demanda", 'CALCULATE([Média Diária de Passageiros], Calendario[tipo_dia] IN {"Sábado", "Domingo"})'),
    ("Demanda", "Razão Fim de Semana/Útil", "0.0%", "Demanda", "DIVIDE([Média Fim de Semana], [Média Dia Útil])"),
    ("Demanda", "% Estimado", "0.0%", "Demanda", 'DIVIDE(CALCULATE([Total de Passageiros], Demanda[origem_dado] <> "real"), [Total de Passageiros])'),
    ("Demanda", "Variação % sobre o Mês Anterior", "0.0%", "Demanda",
     "VAR MesAtual = MAX(Calendario[mes])\nVAR Atual = [Total de Passageiros]\n"
     "VAR Anterior = CALCULATE([Total de Passageiros], ALLEXCEPT(Calendario, Calendario[tipo_dia]), Calendario[mes] = MesAtual - 1)\n"
     "RETURN IF(HASONEVALUE(Calendario[mes]) && NOT ISBLANK(Anterior), DIVIDE(Atual - Anterior, Anterior))"),
    ("Demanda", "Participação % da Linha", "0.00%", "Linhas", "DIVIDE([Total de Passageiros], CALCULATE([Total de Passageiros], ALLSELECTED(Linhas)))"),
    ("Demanda", "Ranking da Linha", "0", "Linhas",
     "IF(HASONEVALUE(Linhas[linha_rotulo]), RANKX(ALLSELECTED(Linhas[linha_rotulo]), [Total de Passageiros], , DESC, DENSE))"),
    ("Demanda", "Passageiros Top 10", "#,0", "Linhas", "IF([Ranking da Linha] <= 10, [Total de Passageiros])"),
    ("Referencia", "Passageiros Publicados", "#,0", "Publicado", "SUM(Referencia[passageiros_publicado])"),
    ("Referencia", "Passageiros Calculados (grupos oficiais)", "#,0", "Publicado", "CALCULATE([Total de Passageiros], Grupos[grupo_oficial] = TRUE())"),
    ("Referencia", "Diferença % sobre o Publicado", "0.00%", "Publicado",
     "DIVIDE([Passageiros Calculados (grupos oficiais)] - [Passageiros Publicados], [Passageiros Publicados])"),
    ("Clima", "Precipitação (mm)", "#,0.0", "Clima", "SUM(Clima[precipitacao_mm])"),
    ("Clima", "Média Dia Útil com Chuva", "#,0", "Clima", 'CALCULATE([Média Dia Útil], Calendario[faixa_chuva] = "com chuva")'),
    ("Clima", "Média Dia Útil sem Chuva", "#,0", "Clima", 'CALCULATE([Média Dia Útil], Calendario[faixa_chuva] = "seco")'),
    ("Clima", "Efeito da Chuva % (Dia Útil)", "0.0%", "Clima",
     "DIVIDE([Média Dia Útil com Chuva] - [Média Dia Útil sem Chuva], [Média Dia Útil sem Chuva])"),
]


def nome_tmdl(n: str) -> str:
    return n if n.replace("_", "").isalnum() and n.isascii() else "'" + n.replace("'", "''") + "'"


def tabela_tmdl(nome: str, view: str, colunas) -> str:
    l = [f"table {nome}", f"\tlineageTag: {gid('t' + nome)}", ""]
    if nome == "Calendario":
        l.insert(1, "\tdataCategory: Time")
    for tab, med, fmt, pasta, expr in MEDIDAS:
        if tab != nome:
            continue
        linhas = expr.split("\n")
        if len(linhas) == 1:
            l.append(f"\tmeasure {nome_tmdl(med)} = {expr}")
        else:
            l.append(f"\tmeasure {nome_tmdl(med)} =")
            l += ["\t\t\t" + x for x in linhas]
        l += [f"\t\tformatString: {fmt}", f"\t\tdisplayFolder: {pasta}", f"\t\tlineageTag: {gid('m' + med)}", ""]
    for c, tipo, op in colunas:
        l.append(f"\tcolumn {nome_tmdl(c)}")
        l.append(f"\t\tdataType: {tipo}")
        if op.get("isKey"):
            l.append("\t\tisKey")
        if op.get("isHidden"):
            l.append("\t\tisHidden")
        if "formatString" in op:
            l.append(f"\t\tformatString: {op['formatString']}")
        l.append(f"\t\tlineageTag: {gid('c' + nome + c)}")
        l.append("\t\tsummarizeBy: none" if tipo != "double" or nome != "Clima" else "\t\tsummarizeBy: sum")
        l.append(f"\t\tsourceColumn: {c}")
        if "sortByColumn" in op:
            l.append(f"\t\tsortByColumn: {op['sortByColumn']}")
        l.append("")
    if nome == "Calendario":
        l += ["\thierarchy 'Ano Mês Dia'", f"\t\tlineageTag: {gid('hCal')}", "",
              "\t\tlevel Ano", f"\t\t\tlineageTag: {gid('hAno')}", "\t\t\tcolumn: ano", "",
              "\t\tlevel Mês", f"\t\t\tlineageTag: {gid('hMes')}", "\t\t\tcolumn: nome_mes", "",
              "\t\tlevel Dia", f"\t\t\tlineageTag: {gid('hDia')}", "\t\t\tcolumn: dia", ""]
    l += [f"\tpartition {nome} = m", "\t\tmode: import", "\t\tsource =", "\t\t\t\tlet",
          "\t\t\t\t    Fonte = Sql.Database(Servidor, Banco),",
          f"\t\t\t\t    Dados = Fonte{{[Schema = \"dw\", Item = \"{view}\"]}}[Data]",
          "\t\t\t\tin", "\t\t\t\t    Dados", ""]
    return "\n".join(l) + "\n"


def gerar_modelo() -> None:
    _limpar(SM)
    gravar_json(SM / ".platform", {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/gitIntegration/platformProperties/2.0.0/schema.json",
        "metadata": {"type": "SemanticModel", "displayName": NOME}, "config": {"version": "2.0", "logicalId": gid("sm")}})
    gravar_json(SM / "definition.pbism", {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/semanticModel/definitionProperties/1.0.0/schema.json",
        "version": "4.2", "settings": {}})
    d = SM / "definition"
    gravar(d / "database.tmdl", "database\n\tcompatibilityLevel: 1600\n")
    model = ["model Model", "\tculture: pt-BR", "\tdefaultPowerBIDataSourceVersion: powerBI_V3",
             "\tsourceQueryCulture: pt-BR", "\tdataAccessOptions", "\t\tlegacyRedirects", "\t\treturnErrorValuesAsNull", "",
             "annotation __PBI_TimeIntelligenceEnabled = 0", ""]
    model += [f"ref table {t[0]}" for t in TABELAS]
    gravar(d / "model.tmdl", "\n".join(model) + "\n")
    gravar(d / "expressions.tmdl",
           f'expression Servidor = "localhost" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]\n'
           f"\tlineageTag: {gid('pServidor')}\n\n"
           f'expression Banco = "cheiU" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]\n'
           f"\tlineageTag: {gid('pBanco')}\n")
    rel = []
    for i, (ft, fc, tt, tc) in enumerate(RELACOES, 1):
        rel += [f"relationship {gid('r' + ft + fc)}", f"\tfromColumn: {ft}.{fc}", f"\ttoColumn: {tt}.{tc}", ""]
    gravar(d / "relationships.tmdl", "\n".join(rel))
    for nome, view, colunas in TABELAS:
        gravar(d / "tables" / f"{nome}.tmdl", tabela_tmdl(nome, view, colunas))


# ===================================================================== relatório
def campo(entidade: str, prop: str, medida: bool = False) -> dict:
    tipo = "Measure" if medida else "Column"
    return {tipo: {"Expression": {"SourceRef": {"Entity": entidade}}, "Property": prop}}


def proj(entidade: str, prop: str, medida: bool = False, rotulo: str | None = None) -> dict:
    p = {"field": campo(entidade, prop, medida), "queryRef": f"{entidade}.{prop}", "nativeQueryRef": prop}
    if rotulo:
        p["displayName"] = rotulo
    return p


# dica de ferramenta: todo gráfico mostra também os KPIs principais da demanda (padrão do professor)
DICA = [("Demanda", "Média Diária de Passageiros"), ("Demanda", "% Estimado")]


FALSO = {"expr": {"Literal": {"Value": "false"}}}


def lit(v: str) -> dict:
    return {"expr": {"Literal": {"Value": "'" + v.replace("'", "''") + "'"}}}


def visual(nome, tipo, x, y, w, h, papeis, titulo=None, ordem=None, extra=None, z=0):
    if tipo in ("lineChart", "clusteredColumnChart", "clusteredBarChart", "donutChart"):
        usados = {pr["queryRef"] for ps in papeis.values() for pr in ps}
        dica = [proj(e, m, True) for e, m in DICA if f"{e}.{m}" not in usados]
        papeis = {**papeis, "Tooltips": dica}
    v = {"visualType": tipo, "query": {"queryState": {p: {"projections": ps} for p, ps in papeis.items()}},
         "drillFilterOtherVisuals": True}
    if ordem:
        v["query"]["sortDefinition"] = {"sort": [{"field": ordem[0], "direction": ordem[1]}], "isDefaultSort": True}
    if titulo:
        v["visualContainerObjects"] = {"title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}, "text": lit(titulo)}}]}
    if tipo in ("lineChart", "clusteredColumnChart", "clusteredBarChart"):
        v["objects"] = {"categoryAxis": [{"properties": {"showAxisTitle": FALSO}}],
                        "valueAxis": [{"properties": {"showAxisTitle": FALSO}}],
                        "labels": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}}}] if tipo != "lineChart" else []}
        if not v["objects"]["labels"]:
            del v["objects"]["labels"]
    if extra:
        v.update(extra)
    return {"$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/1.8.0/schema.json",
            "name": nome, "position": {"x": x, "y": y, "z": z, "width": w, "height": h, "tabOrder": z}, "visual": v}


def slicer(nome, entidade, coluna, x, y, w, h, grupo, titulo):
    s = visual(nome, "slicer", x, y, w, h, {"Values": [proj(entidade, coluna)]}, titulo,
               extra={"objects": {"data": [{"properties": {"mode": lit("Dropdown")}}],
                                  "header": [{"properties": {"show": FALSO}}]}})
    s["visual"]["syncGroup"] = {"groupName": grupo, "fieldChanges": True, "filterChanges": True}
    return s


def cartao(nome, medida, entidade, x, y, titulo, w=290, h=120):
    return visual(nome, "card", x, y, w, h, {"Values": [proj(entidade, medida, True)]}, titulo,
                  extra={"objects": {"labels": [{"properties": {"labelDisplayUnits": {"expr": {"Literal": {"Value": "1D"}}},
                                                                 "fontSize": {"expr": {"Literal": {"Value": "22D"}}}}}],
                                     "categoryLabels": [{"properties": {"show": FALSO}}]}})


def navegador(nome):
    """Botões de navegação entre as páginas (um por página, gerados pelo próprio Power BI)."""
    return {"$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/1.8.0/schema.json",
            "name": nome, "position": {"x": 680, "y": 650, "z": 0, "width": 580, "height": 50, "tabOrder": 0},
            "visual": {"visualType": "pageNavigator", "drillFilterOtherVisuals": True}}


def texto(nome, x, y, w, h, paragrafos):
    return {"$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/1.8.0/schema.json",
            "name": nome, "position": {"x": x, "y": y, "z": 0, "width": w, "height": h, "tabOrder": 0},
            "visual": {"visualType": "textbox", "objects": {"general": [{"properties": {"paragraphs": [
                {"textRuns": [{"value": p, "textStyle": {"fontWeight": "bold", "fontSize": "14pt"}} if i == 0 else {"value": p}]}
                for i, p in enumerate(paragrafos)]}}]}}}


SLICERS = lambda pref: [  # noqa: E731 - segmentações de mês e modalidade, sincronizadas entre as páginas
    slicer(f"{pref}sMes", "Calendario", "mes_rotulo", 20, 640, 300, 60, "mes", "Mês"),
    slicer(f"{pref}sMod", "Linhas", "modalidade", 340, 640, 300, 60, "modalidade", "Modalidade"),
]

PAGINAS = [
    ("visaoGeral", "Visão geral", [
        cartao("vgTotal", "Total de Passageiros", "Demanda", 20, 20, "Quantos passageiros o transporte levou?"),
        cartao("vgUtil", "Média Dia Útil", "Demanda", 330, 20, "Quanto leva num dia útil típico?"),
        cartao("vgDif", "Diferença % sobre o Publicado", "Referencia", 640, 20, "Os dados batem com o total publicado da SPTrans?"),
        visual("vgLinha", "lineChart", 20, 160, 1240, 460,
               {"Category": [proj("Calendario", "mes_rotulo")], "Y": [proj("Demanda", "Total de Passageiros", True)],
                "Series": [proj("Linhas", "modalidade")]},
               "Como a demanda de ônibus e trem variou mês a mês em 2024?"),
    ] + SLICERS("vg")[:2]),
    ("padroesDia", "Padrões por dia", [
        cartao("pdRazao", "Razão Fim de Semana/Útil", "Demanda", 20, 20, "Quanto da demanda do dia útil sobra no fim de semana?"),
        visual("pdSemana", "clusteredColumnChart", 20, 160, 620, 460,
               {"Category": [proj("Calendario", "nome_dia")], "Y": [proj("Demanda", "Média Diária de Passageiros", True)]},
               "Qual dia da semana tem mais passageiros?"),
        visual("pdTipo", "clusteredBarChart", 660, 160, 600, 460,
               {"Category": [proj("Calendario", "tipo_dia")], "Y": [proj("Demanda", "Média Diária de Passageiros", True)],
                "Series": [proj("Linhas", "modalidade")]},
               "Quanto cai a demanda em sábados, domingos e feriados?"),
    ] + SLICERS("pd")[:2]),
    ("linhas", "Linhas e grupos", [
        visual("lnTop", "clusteredBarChart", 20, 20, 760, 600,
               {"Category": [proj("Linhas", "linha_rotulo")], "Y": [proj("Demanda", "Passageiros Top 10", True)]},
               "Quais são as 10 linhas mais usadas?", ordem=(campo("Demanda", "Passageiros Top 10", True), "Descending")),
        visual("lnGrupo", "tableEx", 800, 20, 460, 360,
               {"Values": [proj("Grupos", "grupo"), proj("Demanda", "Total de Passageiros", True),
                           proj("Demanda", "Participação % da Linha", True, "Participação %")]},
               "Quanto cada grupo representa?"),
        visual("lnOrigem", "donutChart", 800, 400, 460, 220,
               {"Category": [proj("Demanda", "origem_dado")], "Y": [proj("Demanda", "Total de Passageiros", True)]},
               "Quanto da demanda é real e quanto é estimado?",
               extra={"objects": {"labels": [{"properties": {"labelStyle": lit("Percent of total")}}]}}),
    ] + SLICERS("ln")[:2]),
    ("clima", "Chuva", [
        cartao("clCom", "Média Dia Útil com Chuva", "Clima", 20, 20, "Quantos passageiros tem um dia útil com chuva (5 mm ou mais)?"),
        cartao("clSem", "Média Dia Útil sem Chuva", "Clima", 330, 20, "E um dia útil seco (menos de 1 mm)?"),
        cartao("clEfeito", "Efeito da Chuva % (Dia Útil)", "Clima", 640, 20, "A chuva muda a demanda de um dia útil?"),
        visual("clFaixa", "clusteredColumnChart", 20, 160, 620, 460,
               {"Category": [proj("Calendario", "faixa_chuva")], "Y": [proj("Demanda", "Média Dia Útil", True)]},
               "Quantos passageiros um dia útil tem, conforme a chuva?"),
        visual("clMes", "clusteredColumnChart", 660, 160, 600, 460,
               {"Category": [proj("Calendario", "mes_rotulo")], "Y": [proj("Clima", "Precipitação (mm)", True)]},
               "Quanto choveu em cada mês?"),
    ] + SLICERS("cl")[:1]),
    ("sobre", "Sobre os dados", [
        texto("sbTexto", 20, 20, 1240, 600, [
            "Sobre os dados",
            "Pergunta: como os dados do transporte público de São Paulo revelam padrões de demanda e utilização em 2024?",
            "Ônibus: passageiros transportados por dia e linha, dos 366 arquivos diários da SPTrans (real). O dia 08/07 de 207 linhas veio do consolidado de julho (estimado, decisão 0014).",
            "Trem: embarcados mensais por estação da CPTM, distribuídos pelos dias com pesos por tipo de dia (estimado, decisão 0012).",
            "Clima: Open-Meteo, reanálise horária (estimado). Feriados: BrasilAPI mais os locais de São Paulo.",
            "Fora do painel: Metrô e Pesquisa OD 2023 (portal do Metrô em manutenção), por isso não há perfil horário, lotação nem alternativas de percurso.",
            "Diferença contra o total publicado da SPTrans: de 2% a 5% em jan–jun (reprocessamento da fonte), abaixo de 0,5% em jul–dez.",
            "Fonte dos números: SQL Server (views dw.vw_*), carregado pela macro da Etapa 4; SQL e DAX conferidos com diferença 0.",
        ]),
    ]),
]


def gerar_relatorio() -> None:
    _limpar(RP)
    gravar_json(RP / ".platform", {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/gitIntegration/platformProperties/2.0.0/schema.json",
        "metadata": {"type": "Report", "displayName": NOME}, "config": {"version": "2.0", "logicalId": gid("rp")}})
    gravar_json(RP / "definition.pbir", {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json",
        "version": "4.0", "datasetReference": {"byPath": {"path": f"../{NOME}.SemanticModel"}}})
    d = RP / "definition"
    gravar_json(d / "version.json", {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/versionMetadata/1.0.0/schema.json",
        "version": "2.0.0"})
    gravar_json(d / "report.json", {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/report/1.3.0/schema.json",
        "themeCollection": {
            "baseTheme": {"name": "CY24SU10", "reportVersionAtImport": "5.61", "type": "SharedResources"},
            "customTheme": {"name": "tema-cheiU.json", "reportVersionAtImport": "5.61", "type": "RegisteredResources"}},
        "resourcePackages": [
            {"name": "SharedResources", "type": "SharedResources",
             "items": [{"name": "CY24SU10", "path": "BaseThemes/CY24SU10.json", "type": "BaseTheme"}]},
            {"name": "RegisteredResources", "type": "RegisteredResources",
             "items": [{"name": "tema-cheiU.json", "path": "tema-cheiU.json", "type": "CustomTheme"}]}],
        "layoutOptimization": "None",
        "settings": {"useStylableVisualContainerHeader": True, "defaultDrillFilterOtherVisuals": True,
                     "allowChangeFilterTypes": True, "useEnhancedTooltips": True}})
    shutil.copy(TEMA_BASE, _mk(RP / "StaticResources" / "SharedResources" / "BaseThemes" / "CY24SU10.json"))
    shutil.copy(RAIZ / "tema-cheiU.json", _mk(RP / "StaticResources" / "RegisteredResources" / "tema-cheiU.json"))
    gravar_json(d / "pages" / "pages.json", {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/pagesMetadata/1.1.0/schema.json",
        "pageOrder": [p[0] for p in PAGINAS], "activePageName": PAGINAS[0][0]})
    for nome, titulo, visuais in PAGINAS:
        visuais = visuais + [navegador(f"{nome}Nav")]
        gravar_json(d / "pages" / nome / "page.json", {
            "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/1.5.0/schema.json",
            "name": nome, "displayName": titulo, "displayOption": "FitToPage", "height": 720, "width": 1280})
        for v in visuais:
            gravar_json(d / "pages" / nome / "visuals" / v["name"] / "visual.json", v)


def _limpar(pasta: Path) -> None:
    """Apaga só o que o gerador escreve; a pasta .pbi (cache de dados e ajustes locais do Desktop) fica."""
    for sub in ("definition", "StaticResources"):
        if (pasta / sub).exists():
            shutil.rmtree(pasta / sub)


def _mk(p: Path) -> Path:
    p.parent.mkdir(parents=True, exist_ok=True)
    return p


def main() -> None:
    gravar_json(RAIZ / f"{NOME}.pbip", {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/pbip/pbipProperties/1.0.0/schema.json",
        "version": "1.0", "artifacts": [{"report": {"path": f"{NOME}.Report"}}], "settings": {"enableAutoRecovery": True}})
    gerar_modelo()
    gerar_relatorio()
    n = sum(len(p[2]) for p in PAGINAS)
    print(f"{len(TABELAS)} tabelas, {len(RELACOES)} relações, {len(MEDIDAS)} medidas, {len(PAGINAS)} páginas, {n} visuais")


if __name__ == "__main__":
    main()
