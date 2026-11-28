"""Gera apresentacao-final.pptx (F.2). Gêmeo em texto da apresentação: para mudar um slide, edite aqui e rode de novo.

Uso: .venv\\Scripts\\python MA2026-entrega-final\\04-powerbi-dashboard\\scripts\\gerar_apresentacao.py
Os números vêm do painel e do SQL (relatorio-final.md); confira-os antes de apresentar.
"""
from pathlib import Path

from pptx import Presentation
from pptx.chart.data import CategoryChartData
from pptx.dml.color import RGBColor
from pptx.enum.chart import XL_CHART_TYPE, XL_LEGEND_POSITION
from pptx.enum.text import PP_ALIGN
from pptx.util import Emu, Pt

SAIDA = Path(__file__).resolve().parents[1] / "apresentacao-final.pptx"
VERDE, LARANJA, TINTA, CINZA = RGBColor(0x0B, 0x6E, 0x4F), RGBColor(0xE0, 0x7A, 0x1F), RGBColor(0x1F, 0x29, 0x33), RGBColor(0x5B, 0x66, 0x70)
W, H = Emu(12192000), Emu(6858000)  # 16:9
CM = 360000

prs = Presentation()
prs.slide_width, prs.slide_height = W, H
VAZIO = prs.slide_layouts[6]


def caixa(slide, x, y, w, h, linhas, tam=20, cor=TINTA, negrito=False, alinhar=PP_ALIGN.LEFT):
    tf = slide.shapes.add_textbox(Emu(x * CM), Emu(y * CM), Emu(w * CM), Emu(h * CM)).text_frame
    tf.word_wrap = True
    for i, linha in enumerate([linhas] if isinstance(linhas, str) else linhas):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.alignment = alinhar
        p.space_after = Pt(8)
        r = p.add_run()
        r.text = linha
        r.font.size, r.font.color.rgb, r.font.bold, r.font.name = Pt(tam), cor, negrito, "Segoe UI"
    return tf


def slide(titulo, fala, quem):
    s = prs.slides.add_slide(VAZIO)
    barra = s.shapes.add_shape(1, 0, 0, Emu(int(0.35 * CM)), H)
    barra.fill.solid(); barra.fill.fore_color.rgb = VERDE; barra.line.fill.background()
    caixa(s, 1.5, 0.9, 30, 2, titulo, 30, VERDE, True)
    caixa(s, 26, 17.6, 7.5, 1, quem, 12, CINZA, alinhar=PP_ALIGN.RIGHT)
    s.notes_slide.notes_text_frame.text = f"[{quem}] {fala}"
    return s


def topicos(s, itens, y=3.4, tam=20, w=30):
    caixa(s, 1.5, y, w, 14, ["•  " + i for i in itens], tam)


def numero(s, x, y, valor, rotulo):
    caixa(s, x, y, 9.5, 1.6, valor, 34, VERDE, True)
    caixa(s, x, y + 1.7, 9.5, 1.4, rotulo, 14, CINZA)


def grafico(s, tipo, x, y, w, h, categorias, series, legenda=True, rotulos=None):
    dados = CategoryChartData()
    dados.categories = categorias
    for nome, valores in series:
        dados.add_series(nome, valores)
    g = s.shapes.add_chart(tipo, Emu(x * CM), Emu(y * CM), Emu(w * CM), Emu(h * CM), dados).chart
    g.plots[0].vary_by_categories = False
    g.has_title = False
    g.has_legend = legenda
    if legenda:
        g.legend.position, g.legend.include_in_layout = XL_LEGEND_POSITION.TOP, False
        g.legend.font.size = Pt(12)
    g.font.size, g.font.name = Pt(12), "Segoe UI"
    for serie, cor in zip(g.series, (VERDE, LARANJA)):
        fmt = serie.format
        if tipo == XL_CHART_TYPE.LINE_MARKERS:
            fmt.line.color.rgb = cor; fmt.line.width = Pt(3)
            serie.marker.format.fill.solid(); serie.marker.format.fill.fore_color.rgb = cor
            serie.marker.format.line.color.rgb = cor
        else:
            fmt.fill.solid(); fmt.fill.fore_color.rgb = cor
    if rotulos:
        pl = g.plots[0]
        pl.has_data_labels = True
        pl.data_labels.font.size = Pt(11)
        pl.data_labels.number_format, pl.data_labels.number_format_is_linked = rotulos, False
    g.value_axis.has_major_gridlines = False
    return g


# 1 — capa
s = prs.slides.add_slide(VAZIO)
fundo = s.shapes.add_shape(1, 0, 0, W, H)
fundo.fill.solid(); fundo.fill.fore_color.rgb = VERDE; fundo.line.fill.background()
caixa(s, 2, 4.5, 30, 3, "cheiU", 66, RGBColor(0xFF, 0xFF, 0xFF), True)
caixa(s, 2, 7.6, 30, 2, "O que os dados do transporte público de São Paulo mostram sobre a demanda em 2024", 24, RGBColor(0xFF, 0xFF, 0xFF))
caixa(s, 2, 13, 30, 4, ["Microinformática Aplicada (ILP590) · FATEC São Paulo · Prof. Veríssimo · 2º/2026",
                         "Grupo 10 · Victor Lima Conceição · Maryele Naara Freitas Meira · Luciano Oliveira Gomes"], 16, RGBColor(0xDD, 0xEE, 0xE6))
s.notes_slide.notes_text_frame.text = "[Victor] Apresentar o grupo e o tema: Mobilidade Urbana."

# 2 — pergunta
s = slide("A pergunta", "Ler a pergunta central e dizer que vamos responder com os dados de 2024 que conseguimos obter.", "Victor")
caixa(s, 1.5, 4, 30, 5, "Como os dados do transporte público de São Paulo revelam padrões de demanda, lotação e utilização e apoiam a comparação de alternativas de deslocamento?", 28, TINTA)
caixa(s, 1.5, 11, 30, 4, ["Recorte: ônibus municipais (SPTrans) e trens (CPTM), todos os dias de 2024.",
                          "Metrô e Pesquisa OD 2023 ficaram fora: o portal do Metrô esteve em manutenção durante o projeto."], 18, CINZA)

# 3 — fontes
s = slide("De onde vêm os dados", "Cada registro diz se é real, estimado ou simulado (origem_dado). O trem é estimado porque a CPTM só publica totais mensais.", "Victor")
topicos(s, ["SPTrans: 366 arquivos diários, 1.437 linhas de ônibus (real)",
            "SPTrans: total mensal publicado, usado como referência (real)",
            "CPTM: entradas mensais por estação, divididas pelos dias com pesos por tipo de dia (estimado)",
            "Open-Meteo (API): chuva por hora, 8.784 horas (estimado, reanálise)",
            "BrasilAPI (API): feriados de 2024, ao vivo no Power Query (real)"])

# 4 — pipeline
s = slide("Sete etapas, cada uma lê a anterior", "Passar rápido pelas etapas; o ponto é que cada número confere com a etapa anterior.", "Luciano")
etapas = [("1 Excel", "base auditável"), ("2 Power Query", "39 consultas"), ("3 Power Pivot", "28 medidas DAX"), ("4 VBA", "atualiza, valida, exporta"),
          ("5 SQL Server", "13 consultas, 11 views"), ("6 APIs", "feriados e clima"), ("7 Power BI", "painel de 5 páginas")]
for i, (nome, txt) in enumerate(etapas):
    x = 1.5 + i * 4.4
    q = s.shapes.add_shape(1, Emu(int(x * CM)), Emu(5 * CM), Emu(int(4.1 * CM)), Emu(4 * CM))
    q.fill.solid(); q.fill.fore_color.rgb = VERDE if i % 2 == 0 else RGBColor(0x2E, 0x86, 0x6B); q.line.fill.background()
    tf = q.text_frame; tf.word_wrap = True
    tf.paragraphs[0].text = nome
    tf.paragraphs[0].runs[0].font.size, tf.paragraphs[0].runs[0].font.bold = Pt(16), True
    p = tf.add_paragraph(); p.text = txt; p.runs[0].font.size = Pt(12)
caixa(s, 1.5, 11, 30, 5, ["Todo binário tem um gêmeo em texto (.pq, .dax, .bas, .sql, TMDL, PBIR) versionado no GitHub.",
                          "Nenhuma linha some sem explicação: rejeitados com motivo e conferências com diferença 0."], 18, CINZA)

# 5 — qualidade
s = slide("Os números conferem em todas as etapas", "Mostrar que o mesmo total aparece no Excel, no SQL e no Power BI.", "Maryele")
numero(s, 1.5, 3.6, "25", "defeitos reais das fontes catalogados e tratados")
numero(s, 11.5, 3.6, "24/24", "checagens da macro de QA aprovadas")
numero(s, 21.5, 3.6, "0", "diferença em 8 KPIs: DAX × SQL × Power BI")
topicos(s, ["Total de passageiros: 2.564.533.459 no modelo, no banco e no painel",
            "Diferença contra o total publicado pela SPTrans: −1,77% (a fonte reprocessou o 1º semestre)",
            "17,15% da demanda é estimada (trem e um dia de julho), e o painel mostra essa parte"], y=9.6, tam=18)

# 6 — dia útil
s = slide("O dia útil concentra a demanda", "Sábado leva 60% do dia útil, domingo e feriado 42%. A quinta é o pico da semana.", "Luciano")
grafico(s, XL_CHART_TYPE.COLUMN_CLUSTERED, 1.5, 3.2, 19, 13.5, ["Útil", "Sábado", "Domingo", "Feriado"],
        [("Média de passageiros por dia (milhões)", (8.33, 4.98, 3.49, 3.48))], legenda=False, rotulos="0.0")
caixa(s, 1.5, 2.6, 19, 1, "Média de passageiros por dia, em milhões", 14, CINZA)
numero(s, 22, 4, "8,3 mi", "passageiros num dia útil médio")
numero(s, 22, 9, "50,7%", "do dia útil sobra no fim de semana")

# 7 — ano
s = slide("O ano tem dois vales: janeiro e dezembro", "Férias escolares derrubam janeiro; o pico é outubro, com 237 milhões.", "Luciano")
meses = ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"]
grafico(s, XL_CHART_TYPE.LINE_MARKERS, 1.5, 3.2, 30, 13.8, meses,
        [("Ônibus (milhões)", (149.8, 163.0, 179.4, 182.8, 180.2, 175.9, 174.4, 192.0, 186.1, 196.5, 179.6, 165.7)),
         ("Trem (milhões)", (32.4, 33.4, 36.0, 37.4, 36.9, 36.4, 36.9, 38.8, 37.5, 40.1, 37.4, 35.7))])

# 8 — linhas e chuva
s = slide("Trens carregam muito; a chuva tira 5% do dia útil", "As 4 maiores linhas da CPTM superam qualquer linha de ônibus em mais de 6 vezes. Chuva: associação, não causa.", "Maryele")
grafico(s, XL_CHART_TYPE.BAR_CLUSTERED, 1.5, 3.2, 16, 13.5, ["607C-10 (ônibus)", "L12 Safira", "L10 Turquesa", "L7 Rubi", "L11 Coral"],
        [("Passageiros em 2024 (milhões)", (10, 68, 97, 124, 144))], legenda=False, rotulos="0")
caixa(s, 1.5, 2.6, 16, 1, "Passageiros em 2024, em milhões", 14, CINZA)
numero(s, 19, 4, "−5,0%", "dia útil com chuva (≥ 5 mm) contra dia seco")
numero(s, 19, 9, "35%", "de todos os passageiros vão em linhas de ônibus locais de distribuição")

# 9 — demonstração
s = slide("Demonstração ao vivo", "Seguir roteiro-demo.md. Plano B: PDFs e evidências salvos.", "Todos")
topicos(s, ["SQL Server no Docker", "Excel: botão Atualizar e macro de QA", "Resumo diário em PDF", "Consulta SQL com os KPIs",
            "API da BrasilAPI ao vivo", "Power BI: navegação, filtros sincronizados e dicas"])

# 10 — resposta
s = slide("A resposta", "Dizer a resposta em voz alta, explicitamente.", "Victor")
caixa(s, 1.5, 3.6, 30, 12, [
    "Os dados mostram um padrão de demanda claro: o dia útil leva 8,3 milhões de passageiros, o fim de semana metade disso, e o ano tem vales em janeiro e dezembro.",
    "Os trens da CPTM levam 17% dos passageiros com só 5 linhas, e a chuva reduz a demanda do dia útil em 5%.",
    "Lotação e comparação de alternativas de percurso dependem do Metrô e da Pesquisa OD 2023, que não estavam disponíveis: o modelo está pronto para recebê-los."], 22)

# 11 — limitações e próximos passos
s = slide("Limitações e próximos passos", "Fechar com o que falta e agradecer.", "Victor")
topicos(s, ["Sem Metrô e OD 2023: sem perfil horário, lotação, mapa e alternativas de percurso",
            "Trem estimado com pesos provisórios; clima de reanálise",
            "Próximo: carregar Metrô e OD, páginas \"Padrões horários\" e \"Alternativas de percurso\"",
            "Próximo: token do Olho Vivo para medir a pontualidade dos ônibus",
            "Repositório: github.com/Ve3e3/projeto_cheiU_FATEC"])
caixa(s, 1.5, 15.2, 30, 1.5, "Obrigado!", 28, VERDE, True)

prs.save(SAIDA)
print(SAIDA, len(prs.slides), "slides")
