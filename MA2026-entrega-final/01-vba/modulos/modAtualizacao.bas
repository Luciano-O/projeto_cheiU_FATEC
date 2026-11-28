Attribute VB_Name = "modAtualizacao"
Option Explicit
' E4.2: atualização completa, sem intervenção. Cada consulta é atualizada em primeiro plano e cronometrada;
' depois o Modelo de Dados e as tabelas dinâmicas. Uma linha no Log por consulta.

Public Sub AtualizarTudo()
    Dim inicio As Double, t As Double, c As WorkbookConnection, pc As PivotCache, n As Long
    inicio = Timer
    On Error GoTo Falha
    Application.ScreenUpdating = False
    For Each c In ThisWorkbook.Connections
        If c.Type = xlConnectionTypeOLEDB Then c.OLEDBConnection.BackgroundQuery = False
    Next c
    For Each c In ThisWorkbook.Connections
        If c.Name <> "ThisWorkbookDataModel" Then
            t = Timer
            c.Refresh
            RegistrarLog "AtualizarTudo", "OK", "consulta " & c.Name, Decorrido(t)
            n = n + 1
        End If
    Next c
    Application.CalculateUntilAsyncQueriesDone
    t = Timer
    ThisWorkbook.Model.Refresh
    RegistrarLog "AtualizarTudo", "OK", "Modelo de Dados", Decorrido(t)
    t = Timer
    ' Os caches das dinâmicas sobre o Modelo de Dados (OLAP) já foram atualizados pelo Model.Refresh;
    ' chamar Refresh neles dá erro 1004.
    For Each pc In ThisWorkbook.PivotCaches
        If Not pc.OLAP Then pc.Refresh
    Next pc
    Application.Calculate
    RegistrarLog "AtualizarTudo", "OK", "tabelas dinâmicas e fórmulas", Decorrido(t)
    Application.ScreenUpdating = True
    RegistrarLog "AtualizarTudo", "OK", n & " consultas atualizadas", Decorrido(inicio)
    Exit Sub
Falha:
    Application.ScreenUpdating = True
    RegistrarFalha "AtualizarTudo", inicio
End Sub
