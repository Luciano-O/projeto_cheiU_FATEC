Attribute VB_Name = "modQA"
Option Explicit
' E4.3: QA automatizado. Repete por DAX (ADO no Modelo de Dados) as checagens dos QAs das Etapas 2 e 3
' e preenche a tabela Tab_QA da aba QA: checagem, esperado, obtido, status (OK/FALHA).

Private mFalhas As Long

Public Function ValidarDados() As Long
    Dim inicio As Double, lo As ListObject
    inicio = Timer
    On Error GoTo Falha
    mFalhas = 0
    Set lo = ThisWorkbook.Worksheets("QA").ListObjects("Tab_QA")
    If lo.ListRows.Count > 0 Then lo.DataBodyRange.Rows.Delete

    Igual lo, "Linhas de Fato_Transporte = Etapa 2", "[E2 Linhas no Fato]", "[Conf Linhas Fato_Transporte]"
    Igual lo, "Passageiros no modelo = Etapa 2", "[E2 Passageiros no Fato]", "CALCULATE([Total de Passageiros], ALL(Fato_Transporte))"
    Igual lo, "Linhas de Rejeitados = Etapa 2", "[E2 Linhas Rejeitadas]", "[Conf Linhas Rejeitados]"
    Zero lo, "Diferença de linhas lidas - aceitas - rejeitadas (Etapa 2)", "SUM(Conf_Etapa2[diferenca_linhas])"
    Zero lo, "Diferença de passageiros aceitos - no fato (Etapa 2)", "SUM(Conf_Etapa2[diferenca_passageiros])"
    Zero lo, Seta("Órfãs Fato_Transporte # Dim_Transporte"), Seta("[Conf Órfãs Fato_Transporte # Dim_Transporte]")
    Zero lo, Seta("Órfãs Fato_Transporte # Dim_Calendario"), Seta("[Conf Órfãs Fato_Transporte # Dim_Calendario]")
    Zero lo, Seta("Órfãs Fato_Referencia_Mensal # Dim_Calendario"), Seta("[Conf Órfãs Fato_Referencia_Mensal # Dim_Calendario]")
    Zero lo, Seta("Órfãs Fato_Referencia_Mensal # Dim_Grupo"), Seta("[Conf Órfãs Fato_Referencia_Mensal # Dim_Grupo]")
    Zero lo, Seta("Órfãs Dim_Transporte # Dim_Grupo"), Seta("[Conf Órfãs Dim_Transporte # Dim_Grupo]")
    Zero lo, "PK duplicada Dim_Transporte", "[Conf PK Duplicada Dim_Transporte]"
    Zero lo, "PK duplicada Dim_Calendario", "[Conf PK Duplicada Dim_Calendario]"
    Zero lo, "PK duplicada Dim_Grupo", "[Conf PK Duplicada Dim_Grupo]"
    Zero lo, "Grão duplicado Fato_Transporte (data × linha)", "[Conf Grão Duplicado Fato_Transporte]"
    Zero lo, "origem_dado vazio em Fato_Transporte", "COUNTROWS(FILTER(Fato_Transporte, ISBLANK(Fato_Transporte[origem_dado])))"
    Zero lo, "origem_dado fora de real/estimado/simulado", "COUNTROWS(FILTER(Fato_Transporte, NOT Fato_Transporte[origem_dado] IN {""real"", ""estimado"", ""simulado""}))"
    Numero lo, "Dias em Dim_Calendario", 366, "COUNTROWS(Dim_Calendario)"
    Numero lo, "Dias com demanda de ônibus", 366, "CALCULATE(DISTINCTCOUNT(Fato_Transporte[data]), Fato_Transporte[modalidade] = ""Ônibus"")"
    Numero lo, "Dias com demanda de trem", 366, "CALCULATE(DISTINCTCOUNT(Fato_Transporte[data]), Fato_Transporte[modalidade] = ""Trem"")"
    Numero lo, "Horas de clima em 2024 (Etapa 6)", 8784, "[Conf Linhas Fato_Clima_Horario]"
    Zero lo, Seta("Órfãs Fato_Clima_Horario # Dim_Calendario"), Seta("[Conf Órfãs Fato_Clima_Horario # Dim_Calendario]")
    Zero lo, "Horas de clima sem temperatura", "COUNTROWS(FILTER(Fato_Clima_Horario, ISBLANK(Fato_Clima_Horario[temperatura_c])))"
    Numero lo, "Feriados no calendário (BrasilAPI + locais)", 16, "CALCULATE(COUNTROWS(Dim_Calendario), NOT ISBLANK(Dim_Calendario[feriado_nome]))"
    Ate lo, "Maior diferença % contra o publicado, jul-dez (aceite 0,5%)", 0.005, _
        "MAXX(FILTER(VALUES(Dim_Calendario[mes]), Dim_Calendario[mes] >= 7), ABS([Diferença % sobre o Publicado]))"

    RegistrarLog "ValidarDados", IIf(mFalhas = 0, "OK", "FALHA"), lo.ListRows.Count & " checagens, " & mFalhas & " com falha", Decorrido(inicio)
    ValidarDados = mFalhas
    Exit Function
Falha:
    RegistrarFalha "ValidarDados", inicio
    ValidarDados = -1
End Function

' Troca # por uma seta (o .bas é Windows-1252, que não tem o caractere).
Private Function Seta(ByVal s As String) As String
    Seta = Replace(s, "#", ChrW(8594))
End Function

Private Sub Gravar(lo As ListObject, ByVal checagem As String, ByVal esperado As Variant, ByVal obtido As Variant, ByVal ok As Boolean)
    Dim r As ListRow
    Set r = lo.ListRows.Add
    r.Range.Cells(1, 1).Value = checagem
    r.Range.Cells(1, 2).Value = esperado
    r.Range.Cells(1, 3).Value = obtido
    r.Range.Cells(1, 4).Value = IIf(ok, "OK", "FALHA")
    If Not ok Then mFalhas = mFalhas + 1
End Sub

Private Function Avaliar(ByVal expr As String) As Variant
    Dim v As Variant
    v = ValorDax("EVALUATE ROW(""v"", " & expr & ")")
    If IsEmpty(v) Or IsNull(v) Then v = 0
    Avaliar = v
End Function

Private Sub Igual(lo As ListObject, ByVal checagem As String, ByVal exprEsperado As String, ByVal exprObtido As String)
    Dim e As Variant, o As Variant
    e = Avaliar(exprEsperado)
    o = Avaliar(exprObtido)
    Gravar lo, checagem, e, o, (CDbl(e) = CDbl(o))
End Sub

Private Sub Zero(lo As ListObject, ByVal checagem As String, ByVal expr As String)
    Dim o As Variant
    o = Avaliar(expr)
    Gravar lo, checagem, 0, o, (CDbl(o) = 0)
End Sub

Private Sub Numero(lo As ListObject, ByVal checagem As String, ByVal esperado As Double, ByVal expr As String)
    Dim o As Variant
    o = Avaliar(expr)
    Gravar lo, checagem, esperado, o, (CDbl(o) = esperado)
End Sub

Private Sub Ate(lo As ListObject, ByVal checagem As String, ByVal limite As Double, ByVal expr As String)
    Dim o As Variant
    o = Avaliar(expr)
    Gravar lo, checagem, ChrW(8804) & " " & Format(limite, "0.0%"), Round(CDbl(o), 6), (CDbl(o) <= limite)
End Sub
