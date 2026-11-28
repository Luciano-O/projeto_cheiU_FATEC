Attribute VB_Name = "modControle"
Option Explicit
' E4.6: ações dos quatro botões da aba Controle.

Public Sub BotaoAtualizar()
    AtualizarTudo
    ThisWorkbook.Worksheets("Log").Activate
End Sub

Public Sub BotaoValidar()
    Dim f As Long
    f = ValidarDados()
    ThisWorkbook.Worksheets("QA").Activate
    If Not ModoSilencioso() Then
        If f = 0 Then
            MsgBox "Todas as checagens deram OK.", vbInformation, "cheiU"
        Else
            MsgBox f & " checagem(ns) com FALHA. Veja a aba QA.", vbExclamation, "cheiU"
        End If
    End If
End Sub

Public Sub BotaoResumo()
    Dim nome As String
    nome = GerarResumoDiario()
    If nome <> "" Then ThisWorkbook.Worksheets(nome).Activate
End Sub

Public Sub BotaoExportar()
    Dim f As Long
    f = ExportarParaCarga()
    ThisWorkbook.Worksheets("Log").Activate
    If Not ModoSilencioso() Then
        If f = 0 Then
            MsgBox "CSVs gravados em " & PastaCarga(), vbInformation, "cheiU"
        Else
            MsgBox "A exportação teve falhas. Veja a aba Log.", vbExclamation, "cheiU"
        End If
    End If
End Sub
