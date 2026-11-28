Attribute VB_Name = "modRelatorio"
Option Explicit
' E4.4: resumo diário. Pede uma data, confere se ela existe em Dim_Calendario e tem demanda, monta a aba
' Resumo_dd-mm-aaaa (total por modalidade, tipo de dia, top 3 linhas) e exporta em PDF para relatorios\.
' O % da demanda no pico e a faixa de lotação dependem do perfil horário da OD (E3.4) e entram quando ele existir.

Public Function GerarResumoDiario(Optional ByVal dataTexto As String = "") As String
    Dim inicio As Double, d As Date, total As Variant, tipoDia As Variant, ws As Worksheet, nome As String
    Dim rs As Object, lin As Long, filtro As String, pdf As String
    inicio = Timer
    On Error GoTo Falha
    If dataTexto = "" Then dataTexto = InputBox("Data do resumo (dd/mm/aaaa):", "Resumo diário", "15/03/2024")
    If dataTexto = "" Then Exit Function
    If Not EhData(dataTexto, d) Then
        Avisar "GerarResumoDiario", "Data inválida: " & dataTexto
        Exit Function
    End If
    filtro = "FILTER(ALL(Dim_Calendario[data]), Dim_Calendario[data] = " & DataDax(d) & ")"
    tipoDia = ValorDax("EVALUATE ROW(""t"", CALCULATE(MAX(Dim_Calendario[tipo_dia]), " & filtro & "))")
    total = ValorDax("EVALUATE ROW(""p"", CALCULATE([Total de Passageiros], " & filtro & "))")
    ' O Or do VBA avalia os dois lados: CStr(Null) daria erro, por isso os testes são separados.
    If IsEmpty(tipoDia) Or IsNull(tipoDia) Then tipoDia = ""
    If CStr(tipoDia) = "" Then
        Avisar "GerarResumoDiario", "A data " & Format(d, "dd/mm/yyyy") & " não está em Dim_Calendario."
        Exit Function
    End If
    If IsEmpty(total) Or IsNull(total) Then
        Avisar "GerarResumoDiario", "A data " & Format(d, "dd/mm/yyyy") & " não tem demanda no modelo."
        Exit Function
    End If

    nome = "Resumo_" & Format(d, "dd-mm-yyyy")
    Application.DisplayAlerts = False
    On Error Resume Next
    ThisWorkbook.Worksheets(nome).Delete
    On Error GoTo Falha
    Application.DisplayAlerts = True
    Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
    ws.Name = nome

    ws.Range("A1").Value = "Resumo diário de demanda: " & Format(d, "dd/mm/yyyy") & " (" & tipoDia & ")"
    ws.Range("A1").Font.Bold = True
    ws.Range("A1").Font.Size = 14
    ws.Range("A3").Value = "Total de passageiros"
    ws.Range("B3").Value = total
    ws.Range("A5").Value = "Modalidade"
    ws.Range("B5").Value = "Passageiros"
    ws.Range("C5").Value = "Origem do dado"
    Set rs = ConsultaDax("EVALUATE SUMMARIZECOLUMNS(Dim_Transporte[modalidade], Fato_Transporte[origem_dado], " & filtro & ", ""p"", [Total de Passageiros]) ORDER BY [p] DESC")
    lin = 6
    Do While Not rs.EOF
        ws.Cells(lin, 1).Value = rs.Fields(0).Value
        ws.Cells(lin, 3).Value = rs.Fields(1).Value
        ws.Cells(lin, 2).Value = rs.Fields(2).Value
        lin = lin + 1
        rs.MoveNext
    Loop
    rs.Close

    lin = lin + 1
    ws.Cells(lin, 1).Value = "Top 3 linhas do dia"
    ws.Cells(lin, 1).Font.Bold = True
    lin = lin + 1
    ws.Cells(lin, 1).Value = "Linha"
    ws.Cells(lin, 2).Value = "Passageiros"
    ws.Cells(lin, 3).Value = "Modalidade"
    Set rs = ConsultaDax("EVALUATE TOPN(3, SUMMARIZECOLUMNS(Dim_Transporte[linha_rotulo], Dim_Transporte[modalidade], " & filtro & ", ""p"", [Total de Passageiros]), [p], DESC) ORDER BY [p] DESC")
    Do While Not rs.EOF
        lin = lin + 1
        ws.Cells(lin, 1).Value = rs.Fields(0).Value
        ws.Cells(lin, 3).Value = rs.Fields(1).Value
        ws.Cells(lin, 2).Value = rs.Fields(2).Value
        rs.MoveNext
    Loop
    rs.Close

    lin = lin + 2
    ws.Cells(lin, 1).Value = "% da demanda no pico e faixa de lotação: pendentes do perfil horário da OD (E3.4)."
    ws.Cells(lin + 1, 1).Value = "Trem: embarcados estimados por dia a partir do mensal (decisão 0012)."
    ws.Columns("A:C").AutoFit
    ws.Range("B3").NumberFormat = "#,##0"
    ws.Range("B6:B" & lin).NumberFormat = "#,##0"
    ws.Range("A5:C5").Font.Bold = True

    pdf = PastaEtapa4() & "relatorios\resumo_" & Format(d, "yyyy-mm-dd") & ".pdf"
    ws.ExportAsFixedFormat Type:=xlTypePDF, Filename:=pdf, Quality:=xlQualityStandard, OpenAfterPublish:=False
    RegistrarLog "GerarResumoDiario", "OK", nome & " e " & Mid$(pdf, Len(PastaEtapa4()) + 1), Decorrido(inicio)
    GerarResumoDiario = nome
    Exit Function
Falha:
    Application.DisplayAlerts = True
    RegistrarFalha "GerarResumoDiario", inicio
End Function

' Aceita só dd/mm/aaaa com data existente (31/02/2024 é inválida).
Private Function EhData(ByVal s As String, ByRef d As Date) As Boolean
    Dim p() As String
    p = Split(Trim$(s), "/")
    If UBound(p) <> 2 Then Exit Function
    If Not (IsNumeric(p(0)) And IsNumeric(p(1)) And IsNumeric(p(2))) Then Exit Function
    If CLng(p(1)) < 1 Or CLng(p(1)) > 12 Or CLng(p(0)) < 1 Then Exit Function
    d = DateSerial(CLng(p(2)), CLng(p(1)), CLng(p(0)))
    EhData = (Day(d) = CLng(p(0)) And Month(d) = CLng(p(1)))
End Function
