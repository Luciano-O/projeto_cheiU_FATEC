Attribute VB_Name = "modExportacao"
Option Explicit
' E4.5: exporta as tabelas do Modelo de Dados para a carga do SQL (Etapa 5), em
' MA2026-entrega-final\02-bancodedados-sql\carga\<Tabela>.csv: UTF-8, separador ",", decimal ".",
' datas ISO (aaaa-mm-dd), lógicos 1/0, cabeçalho na 1ª linha, fim de linha LF.
' Lê cada tabela com EVALUATE na conexão ADO do modelo e confere o número de linhas contra COUNTROWS.

Private Const TABELAS As String = "Dim_Calendario,Dim_Grupo,Dim_Transporte,Dim_Horario,Fato_Transporte,Fato_Referencia_Mensal,Fato_Clima_Horario,Rejeitados"
Private Const BLOCO As Long = 20000

Public Function ExportarParaCarga() As Long
    Dim inicio As Double, nomes() As String, i As Long, n As Long, esperado As Variant, falhas As Long
    inicio = Timer
    On Error GoTo Falha
    If Dir$(PastaCarga(), vbDirectory) = "" Then MkDir PastaCarga()
    nomes = Split(TABELAS, ",")
    For i = LBound(nomes) To UBound(nomes)
        n = ExportarTabela(nomes(i))
        esperado = ValorDax("EVALUATE ROW(""n"", COUNTROWS('" & nomes(i) & "'))")
        If CLng(esperado) = n Then
            RegistrarLog "ExportarParaCarga", "OK", nomes(i) & ".csv: " & n & " linhas = modelo", 0
        Else
            RegistrarLog "ExportarParaCarga", "FALHA", nomes(i) & ".csv: " & n & " linhas, modelo " & esperado, 0
            falhas = falhas + 1
        End If
    Next i
    RegistrarLog "ExportarParaCarga", IIf(falhas = 0, "OK", "FALHA"), (UBound(nomes) + 1) & " tabelas em " & PastaCarga(), Decorrido(inicio)
    ExportarParaCarga = falhas
    Exit Function
Falha:
    RegistrarFalha "ExportarParaCarga", inicio
    ExportarParaCarga = -1
End Function

Private Function ExportarTabela(ByVal tabela As String) As Long
    Dim t As Double, rs As Object, st As Object, nc As Long, j As Long, k As Long, cab() As String
    Dim dados As Variant, linhas() As String, campos() As String, nl As Long, total As Long
    t = Timer
    Set rs = ConsultaDax("EVALUATE '" & tabela & "'")
    nc = rs.Fields.Count
    ReDim cab(0 To nc - 1)
    For j = 0 To nc - 1
        cab(j) = NomeColuna(rs.Fields(j).Name)
    Next j
    Set st = CreateObject("ADODB.Stream")
    st.Type = 2
    st.Charset = "utf-8"
    st.Open
    st.WriteText Join(cab, ",") & vbLf
    ReDim campos(0 To nc - 1)
    Do While Not rs.EOF
        dados = rs.GetRows(BLOCO)
        nl = UBound(dados, 2) + 1
        ReDim linhas(0 To nl - 1)
        For k = 0 To nl - 1
            For j = 0 To nc - 1
                campos(j) = Campo(dados(j, k))
            Next j
            linhas(k) = Join(campos, ",")
        Next k
        st.WriteText Join(linhas, vbLf) & vbLf
        total = total + nl
    Loop
    rs.Close
    st.SaveToFile PastaCarga() & tabela & ".csv", 2
    st.Close
    RegistrarLog "ExportarParaCarga", "OK", tabela & " lida e gravada", Decorrido(t)
    ExportarTabela = total
End Function

' "Tabela[coluna]" -> "coluna"
Private Function NomeColuna(ByVal s As String) As String
    Dim p As Long
    p = InStr(1, s, "[")
    If p > 0 Then s = Mid$(s, p + 1, Len(s) - p - 1)
    NomeColuna = s
End Function

Private Function Campo(ByVal v As Variant) As String
    Dim s As String
    If IsNull(v) Or IsEmpty(v) Then
        Campo = ""
    ElseIf VarType(v) = vbDate Then
        If v = Int(v) Then Campo = Format(v, "yyyy-mm-dd") Else Campo = Format(v, "yyyy-mm-dd hh:nn:ss")
    ElseIf VarType(v) = vbBoolean Then
        Campo = IIf(v, "1", "0")
    ElseIf IsNumeric(v) And VarType(v) <> vbString Then
        Campo = Trim$(Str$(v))
    Else
        s = CStr(v)
        If InStr(1, s, ",") > 0 Or InStr(1, s, """") > 0 Or InStr(1, s, vbLf) > 0 Or InStr(1, s, vbCr) > 0 Then
            s = """" & Replace(s, """", """""") & """"
        End If
        Campo = s
    End If
End Function
