Attribute VB_Name = "modUtil"
Option Explicit
' Utilitários: consultas DAX ao Modelo de Dados (ADO), avisos e o padrão de erro.
' Padrão de erro de toda rotina pública:
'     inicio = Timer
'     On Error GoTo Falha
'     ...
'     RegistrarLog "<Rotina>", "OK", "<mensagem>", Decorrido(inicio)
'     Exit Sub
' Falha:
'     RegistrarFalha "<Rotina>", inicio

Private mSilencioso As Boolean

' Modo silencioso: avisos vão só para o log (usado pelos scripts de verificação, sem caixas de diálogo).
Public Sub DefinirModoSilencioso(ByVal ligado As Boolean)
    mSilencioso = ligado
End Sub

Public Function ModoSilencioso() As Boolean
    ModoSilencioso = mSilencioso
End Function

Public Sub Avisar(ByVal rotina As String, ByVal mensagem As String)
    RegistrarLog rotina, "AVISO", mensagem
    If Not mSilencioso Then MsgBox mensagem, vbExclamation, "cheiU"
End Sub

Public Function ConexaoModelo() As Object
    ThisWorkbook.Model.Initialize
    Set ConexaoModelo = ThisWorkbook.Model.DataModelConnection.ModelConnection.ADOConnection
End Function

Public Function ConsultaDax(ByVal dax As String) As Object
    Dim rs As Object
    Set rs = CreateObject("ADODB.Recordset")
    rs.Open dax, ConexaoModelo()
    Set ConsultaDax = rs
End Function

' Primeiro valor da primeira linha de uma consulta DAX (Empty se não houver linha).
Public Function ValorDax(ByVal dax As String) As Variant
    Dim rs As Object
    Set rs = ConsultaDax(dax)
    If Not rs.EOF Then ValorDax = rs.Fields(0).Value
    rs.Close
End Function

Public Function ValorMedida(ByVal medida As String) As Variant
    ValorMedida = ValorDax("EVALUATE ROW(""v"", [" & medida & "])")
End Function

Public Function DataDax(ByVal d As Date) As String
    DataDax = "DATE(" & Year(d) & ", " & Month(d) & ", " & Day(d) & ")"
End Function

' Rotina de teste do E4.1: grava uma linha OK e uma linha FALHA no log.
Public Sub TestarLog()
    Dim inicio As Double
    inicio = Timer
    On Error GoTo Falha
    RegistrarLog "TestarLog", "OK", "CaminhoRepo = " & Config("CaminhoRepo"), Decorrido(inicio)
    Err.Raise vbObjectError + 513, "TestarLog", "falha proposital para testar o log"
    Exit Sub
Falha:
    RegistrarFalha "TestarLog", inicio
End Sub
