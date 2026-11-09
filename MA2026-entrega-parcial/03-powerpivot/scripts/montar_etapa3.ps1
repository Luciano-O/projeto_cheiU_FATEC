# Monta MA2026-entrega-parcial/03-powerpivot/cheiU_03_PowerPivot.xlsx do zero:
# consultas (scripts_m/*.pq) que leem a Etapa 2, Modelo de Dados, relações, medidas (dax/medidas_preliminares.dax)
# e as abas Validacao (tabelas dinâmicas) e Conferencia.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-parcial\03-powerpivot\scripts\montar_etapa3.ps1
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1') -Force
$dir = Join-Path $repo 'MA2026-entrega-parcial\03-powerpivot'
$saida = Join-Path $dir 'cheiU_03_PowerPivot.xlsx'
function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }

$tabelas = @('Dim_Calendario', 'Dim_Grupo', 'Dim_Transporte', 'Fato_Transporte', 'Fato_Referencia_Mensal', 'Rejeitados', 'Conf_Etapa2')
$relacoes = @(
    @('Fato_Transporte', 'data', 'Dim_Calendario', 'data'),
    @('Fato_Transporte', 'id_linha', 'Dim_Transporte', 'id_linha'),
    @('Dim_Transporte', 'grupo', 'Dim_Grupo', 'grupo'),
    @('Fato_Referencia_Mensal', 'mes_inicio', 'Dim_Calendario', 'data'),
    @('Fato_Referencia_Mensal', 'grupo', 'Dim_Grupo', 'grupo'))

function Esperar-Excel($xl) {
    # Depois de mexer em dinâmicas o Excel recusa chamadas (RPC_E_CALL_REJECTED) até terminar o que está fazendo.
    for ($k = 0; $k -lt 120; $k++) {
        try { if ($xl.Ready) { return } } catch {}
        Start-Sleep -Milliseconds 500
    }
}
function Add-Dinamica($wb, $ws, [string]$celula, [string]$nome) {
    $pc = $wb.PivotCaches().Create(2, $wb.Connections.Item('ThisWorkbookDataModel'), 6)
    return $pc.CreatePivotTable($ws.Range($celula), $nome)
}
function Add-Campo($pt, [string]$campo, [int]$orientacao) { $pt.CubeFields.Item($campo).Orientation = $orientacao }
function Add-Valor($pt, [string]$medida) { [void]$pt.AddDataField($pt.CubeFields.Item("[Measures].[$medida]")) }

$xl = Start-ExcelCom
try {
    $wb = New-Pasta $xl 'Parametros'
    $ws = $wb.Worksheets.Item('Parametros')
    $ws.Range('A1').Formula = 'CaminhoRepo'
    $ws.Range('B1').Formula2 = '=LEFT(CELL("filename",$A$1),FIND("MA2026-entrega-parcial",CELL("filename",$A$1))-1)'
    $ws.Range('C1').Formula = 'Raiz do repositório, derivada do caminho deste arquivo. Lida pela consulta pCaminhoRepo.'
    Set-NomeDefinido $wb 'CaminhoRepo' '=Parametros!$B$1'
    Save-Pasta $wb $saida
    $xl.CalculateFull()
    Log "CaminhoRepo = $($ws.Range('B1').Text)"

    $wb.Queries.FastCombine = $true
    $n = Import-PastaPq $wb (Join-Path $dir 'scripts_m')
    Log "$n consultas importadas"
    foreach ($t in $tabelas) {
        $t0 = Get-Date
        [void](Add-CargaModelo $wb $t)
        Log ("modelo: {0} ({1:N0} s)" -f $t, ((Get-Date) - $t0).TotalSeconds)
    }
    Update-Tudo $wb
    Log ('tabelas no modelo: ' + ((@($wb.Model.ModelTables) | ForEach-Object { "$($_.Name)($($_.RecordCount))" }) -join ', '))

    foreach ($r in $relacoes) { [void](Add-Relacao $wb $r[0] $r[1] $r[2] $r[3]) }
    Log "relações: $($wb.Model.ModelRelationships.Count)"
    $nm = Import-Dax $wb (Join-Path $dir 'dax\medidas_preliminares.dax')
    Log "medidas: $nm"
    $wb.Save()

    # ---------- Validacao: só tabelas dinâmicas ----------
    $val = Add-Aba $wb 'Validacao'
    $val.Range('A1').Formula = 'Validação do modelo: tabelas dinâmicas sobre o Modelo de Dados (sem gráficos; gráficos são da Etapa 7).'
    $pt1 = Add-Dinamica $wb $val 'A4' 'PT_Demanda_Mensal'
    Add-Campo $pt1 '[Dim_Calendario].[mes_rotulo]' 1
    Add-Campo $pt1 '[Dim_Grupo].[grupo]' 2
    Add-Valor $pt1 'Total de Passageiros'
    $pt2 = Add-Dinamica $wb $val 'A22' 'PT_Realizado_Publicado'
    Add-Campo $pt2 '[Dim_Calendario].[mes_rotulo]' 1
    foreach ($m in 'Total de Passageiros', 'Passageiros Publicados', 'Diferença % sobre o Publicado', 'Variação % sobre o Mês Anterior') { Add-Valor $pt2 $m }
    $pt3 = Add-Dinamica $wb $val 'A40' 'PT_Tipo_Dia'
    Add-Campo $pt3 '[Dim_Calendario].[tipo_dia]' 1
    foreach ($m in 'Média Diária de Passageiros', 'Total de Passageiros') { Add-Valor $pt3 $m }
    $pt4 = Add-Dinamica $wb $val 'H40' 'PT_Resumo_Fim_Semana'
    foreach ($m in 'Média Dia Útil', 'Média Fim de Semana', 'Razão Fim de Semana/Útil') { Add-Valor $pt4 $m }
    $pt5 = Add-Dinamica $wb $val 'A50' 'PT_Top10_Linhas'
    Add-Campo $pt5 '[Dim_Transporte].[linha_rotulo]' 1
    foreach ($m in 'Total de Passageiros', 'Participação % da Linha', 'Ranking da Linha') { Add-Valor $pt5 $m }
    try {
        $pf = $pt5.PivotFields('[Dim_Transporte].[linha_rotulo].[linha_rotulo]')
        [void]$pf.PivotFilters.Add2(1, $pt5.CubeFields.Item('[Measures].[Total de Passageiros]'), 10)   # xlTopCount
        $pf.AutoSort(2, 'Total de Passageiros')                                                       # decrescente
    } catch { Log "aviso: filtro top 10 não aplicado ($_)" }
    $pts = @($pt1, $pt2, $pt3, $pt4, $pt5)
    $topo = 4
    foreach ($s in @(@('[Dim_Calendario].[mes_rotulo]', 'Mês'), @('[Dim_Calendario].[tipo_dia]', 'Tipo de dia'), @('[Dim_Grupo].[grupo]', 'Grupo'))) {
        $sc = $wb.SlicerCaches.Add2($pt1, $s[0])
        [void]$sc.Slicers.Add($val, [Type]::Missing, ('S_' + ($s[1] -replace '\W', '_')), $s[1], $topo, 1000, 160, 150)
        foreach ($p in $pts[1..4]) {
            # O modelo às vezes ainda está ocupado com a ligação anterior: tenta de novo antes de desistir.
            $ok = $false
            for ($k = 0; $k -lt 5 -and -not $ok; $k++) {
                try { $sc.PivotTables.AddPivotTable($p); $ok = $true } catch { $ultimoErro = "$_"; $xl.CalculateUntilAsyncQueriesDone(); Start-Sleep -Seconds 2 }
            }
            if (-not $ok) { Log "aviso: segmentação $($s[1]) sem $($p.Name): $ultimoErro" }
        }
        $topo += 160
    }
    Log 'Validacao pronta'

    # ---------- Conferencia ----------
    Esperar-Excel $xl
    $cf = Add-Aba $wb 'Conferencia'
    $cf.Range('A1').Formula = 'Conferência: o modelo não cria nem perde valor em relação à Etapa 2.'
    $linhas = @(
        @('Linhas de Fato_Transporte', 'E2 Linhas no Fato', 'Conf Linhas Fato_Transporte'),
        @('Passageiros (soma)', 'E2 Passageiros no Fato', 'Total de Passageiros'),
        @('Linhas de Rejeitados', 'E2 Linhas Rejeitadas', 'Conf Linhas Rejeitados'),
        @('Órfãs Fato_Transporte → Dim_Transporte', '', 'Conf Órfãs Fato_Transporte → Dim_Transporte'),
        @('Órfãs Fato_Transporte → Dim_Calendario', '', 'Conf Órfãs Fato_Transporte → Dim_Calendario'),
        @('Órfãs Fato_Referencia_Mensal → Dim_Calendario', '', 'Conf Órfãs Fato_Referencia_Mensal → Dim_Calendario'),
        @('Órfãs Fato_Referencia_Mensal → Dim_Grupo', '', 'Conf Órfãs Fato_Referencia_Mensal → Dim_Grupo'),
        @('Órfãs Dim_Transporte → Dim_Grupo', '', 'Conf Órfãs Dim_Transporte → Dim_Grupo'),
        @('PK duplicada Dim_Transporte', '', 'Conf PK Duplicada Dim_Transporte'),
        @('PK duplicada Dim_Calendario', '', 'Conf PK Duplicada Dim_Calendario'),
        @('PK duplicada Dim_Grupo', '', 'Conf PK Duplicada Dim_Grupo'),
        @('Grão duplicado Fato_Transporte (data × linha)', '', 'Conf Grão Duplicado Fato_Transporte'))
    $cab = @('Item', 'Etapa 2', 'Modelo', 'Diferença', 'Esperado')
    for ($j = 0; $j -lt 5; $j++) { $cf.Cells.Item(3, $j + 1).Formula = $cab[$j] }
    for ($i = 0; $i -lt $linhas.Count; $i++) {
        $r = 4 + $i
        $cf.Cells.Item($r, 1).Formula = $linhas[$i][0]
        if ($linhas[$i][1]) { $cf.Cells.Item($r, 2).Formula2 = "=CUBEVALUE(`"ThisWorkbookDataModel`",`"[Measures].[$($linhas[$i][1])]`")" }
        else { $cf.Cells.Item($r, 2).Formula = '0' }
        $cf.Cells.Item($r, 3).Formula2 = "=IFERROR(CUBEVALUE(`"ThisWorkbookDataModel`",`"[Measures].[$($linhas[$i][2])]`"),0)"
        $cf.Cells.Item($r, 4).Formula2 = "=N(C$r)-N(B$r)"
        $cf.Cells.Item($r, 5).Formula = '0'
    }
    $ult = 3 + $linhas.Count
    Esperar-Excel $xl
    $tab = $cf.ListObjects.Add(1, $cf.Range("A3:E$ult"), $null, 1)
    Esperar-Excel $xl
    $tab.Name = 'Tab_Conferencia'
    $tab.TableStyle = 'TableStyleMedium2'
    $cf.Range("B4:D$ult").NumberFormat = '#,##0'
    $r = $ult + 2
    $cf.Cells.Item($r, 1).Formula = 'Itens com diferença diferente de 0'
    $cf.Cells.Item($r, 3).Formula2 = "=COUNTIF(D4:D$ult,`"<>0`")"
    $fc = $cf.Range("D4:D$ult").FormatConditions.Add(1, 4, '=0'); $fc.Interior.Color = 0x9999FF
    $cf.Columns.AutoFit() | Out-Null

    $wb.Worksheets.Item('Parametros').Move($wb.Worksheets.Item(1))
    Update-Tudo $wb
    $wb.Save()
    Log '--- Conferencia'
    for ($i = 4; $i -le $r; $i++) { Write-Host ("    {0} | {1} | {2} | {3}" -f $cf.Cells.Item($i, 1).Text, $cf.Cells.Item($i, 2).Text, $cf.Cells.Item($i, 3).Text, $cf.Cells.Item($i, 4).Text) }
    Log '--- Validacao (demanda mensal, primeiras linhas)'
    for ($i = 4; $i -le 18; $i++) { Write-Host ("    " + ((1..6 | ForEach-Object { $val.Cells.Item($i, $_).Text }) -join ' | ')) }
    foreach ($bloco in @(@(22, 37, 1, 5), @(40, 46, 1, 3), @(40, 42, 8, 10), @(50, 62, 1, 4))) {
        Log "--- Validacao, linhas $($bloco[0])-$($bloco[1])"
        for ($i = $bloco[0]; $i -le $bloco[1]; $i++) { Write-Host ("    " + (($bloco[2]..$bloco[3] | ForEach-Object { $val.Cells.Item($i, $_).Text }) -join ' | ')) }
    }
    $wb.Close($false)
} finally {
    Stop-ExcelCom $xl
}
