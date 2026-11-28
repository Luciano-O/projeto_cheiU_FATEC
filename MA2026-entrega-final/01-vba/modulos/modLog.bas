Attribute VB_Name = "modLog"
Option Explicit
' Registro de execução na aba Log (tabela Tab_Log): data_hora, rotina, status, mensagem, duracao_s.

Public Sub RegistrarLog(ByVal rotina As String, ByVal status As String, ByVal mensagem As String, Optional ByVal duracao As Double = 0)
    Dim lo As ListObject, r As ListRow
    Set lo = ThisWorkbook.Worksheets("Log").ListObjects("Tab_Log")
    Set r = lo.ListRows.Add
    r.Range.Cells(1, 1).Value = Now
    r.Range.Cells(1, 2).Value = rotina
    r.Range.Cells(1, 3).Value = status
    r.Range.Cells(1, 4).Value = mensagem
    r.Range.Cells(1, 5).Value = Round(duracao, 2)
End Sub

Public Sub RegistrarFalha(ByVal rotina As String, ByVal inicio As Double)
    RegistrarLog rotina, "FALHA", Err.Number & " - " & Err.Description, Decorrido(inicio)
End Sub

Public Function Decorrido(ByVal inicio As Double) As Double
    Dim d As Double
    d = Timer - inicio
    If d < 0 Then d = d + 86400#
    Decorrido = d
End Function

Public Sub LimparLog()
    Dim lo As ListObject
    Set lo = ThisWorkbook.Worksheets("Log").ListObjects("Tab_Log")
    If lo.ListRows.Count > 0 Then lo.DataBodyRange.Rows.Delete
End Sub
