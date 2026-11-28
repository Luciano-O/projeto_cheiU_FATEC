Attribute VB_Name = "modConfig"
Option Explicit
' Configuração da Etapa 4.
' Config("CaminhoRepo") lê a célula nomeada CaminhoRepo (aba Parametros), que se deriva do caminho do arquivo.
' Qualquer outra chave é lida do .env da raiz do repositório (segredos não são gravados no log).

Public Function Config(ByVal chave As String) As String
    Dim v As String
    If chave = "CaminhoRepo" Then
        v = CStr(ThisWorkbook.Names("CaminhoRepo").RefersToRange.Value)
        If Right$(v, 1) <> "\" Then v = v & "\"
        Config = v
    Else
        Config = LerEnv(chave)
    End If
End Function

Public Function PastaEtapa4() As String
    PastaEtapa4 = ThisWorkbook.Path & "\"
End Function

Public Function PastaCarga() As String
    PastaCarga = Config("CaminhoRepo") & "MA2026-entrega-final\02-bancodedados-sql\carga\"
End Function

Private Function LerEnv(ByVal chave As String) As String
    Dim arq As String, st As Object, texto As String, linhas() As String, i As Long, p As Long
    arq = Config("CaminhoRepo") & ".env"
    If Dir$(arq) = "" Then Exit Function
    Set st = CreateObject("ADODB.Stream")
    st.Type = 2
    st.Charset = "utf-8"
    st.Open
    st.LoadFromFile arq
    texto = st.ReadText
    st.Close
    linhas = Split(Replace(texto, vbCr, ""), vbLf)
    For i = LBound(linhas) To UBound(linhas)
        p = InStr(1, linhas(i), "=")
        If p > 1 Then
            If Trim$(Left$(linhas(i), p - 1)) = chave Then
                LerEnv = Trim$(Mid$(linhas(i), p + 1))
                Exit Function
            End If
        End If
    Next i
End Function
