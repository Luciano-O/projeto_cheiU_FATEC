# Etapa 6: integra as APIs ao modelo da pasta da Etapa 4 (MA2026-entrega-final/01-vba/cheiU_04_VBA.xlsm).
# Injeta 03-api-web/scripts_m/*.pq (clima do Open-Meteo, feriados da BrasilAPI, Dim_Horario e a versão da Etapa 6 de
# Dim_Calendario), carrega Fato_Clima_Horario e Dim_Horario no Modelo de Dados, cria as relações com Dim_Calendario e
# Dim_Horario, importa dax/medidas_clima.dax, carrega Conf_Feriados numa aba e atualiza o modelo. Idempotente.
# Não precisa de acesso ao projeto VBA. Uso:
#   powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-final\03-api-web\scripts\integrar_apis.ps1
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1') -Force
$dir = Join-Path $repo 'MA2026-entrega-final\03-api-web'
$arq = Join-Path $repo 'MA2026-entrega-final\01-vba\cheiU_04_VBA.xlsm'
function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }
function Esperar-Excel($xl) { for ($k = 0; $k -lt 120; $k++) { try { if ($xl.Ready) { return } } catch {}; Start-Sleep -Milliseconds 500 } }

$xl = Start-ExcelCom -Visible
try {
    $xl.AutomationSecurity = 3   # abre sem rodar macros
    $wb = $xl.Workbooks.Open($arq)
    Esperar-Excel $xl
    $wb.Queries.FastCombine = $true
    $n = Import-PastaPq $wb (Join-Path $dir 'scripts_m')
    Log "$n consultas da Etapa 6 injetadas"
    $existentes = @($wb.Connections | ForEach-Object { $_.Name })
    foreach ($t in 'Fato_Clima_Horario', 'Dim_Horario') {
        if ($existentes -notcontains "Consulta - $t") { [void](Add-CargaModelo $wb $t); Log "modelo: $t" }
    }
    if (-not (@($wb.Worksheets | ForEach-Object { $_.Name }) -contains 'Conf_Feriados')) {
        [void](Add-CargaPlanilha $wb 'Conf_Feriados' 'Conf_Feriados'); Log 'aba Conf_Feriados'
    }
    Esperar-Excel $xl
    Update-Tudo $wb
    Esperar-Excel $xl
    $rels = @($wb.Model.ModelRelationships | ForEach-Object { "$($_.ForeignKeyTable.Name)[$($_.ForeignKeyColumn.Name)]" })
    foreach ($r in @(@('Fato_Clima_Horario', 'data', 'Dim_Calendario', 'data'), @('Fato_Clima_Horario', 'hora', 'Dim_Horario', 'hora'))) {
        if ($rels -notcontains "$($r[0])[$($r[1])]") { [void](Add-Relacao $wb $r[0] $r[1] $r[2] $r[3]); Log "relação $($r[0])[$($r[1])] -> $($r[2])" }
    }
    $nm = Import-Dax $wb (Join-Path $dir 'dax\medidas_clima.dax')
    Log "medidas de clima: $nm"
    Log ('tabelas no modelo: ' + ((@($wb.Model.ModelTables) | ForEach-Object { "$($_.Name)($($_.RecordCount))" }) -join ', '))
    foreach ($m in 'Conf Linhas Fato_Clima_Horario', 'Precipitação (mm)', 'Média Dia Útil com Chuva', 'Média Dia Útil sem Chuva', 'Efeito da Chuva % (Dia Útil)') {
        Log ("{0} = {1}" -f $m, (Get-ValorMedida $wb $m 'Controle'))
    }
    $lo = $wb.Worksheets.Item('Conf_Feriados').ListObjects.Item(1)
    foreach ($r in @($lo.DataBodyRange.Rows)) { Write-Host ('    ' + ((@($r.Cells) | ForEach-Object { $_.Text }) -join ' | ')) }
    $wb.Worksheets.Item('Controle').Activate()
    $wb.Save()
    $wb.Close($false)
} catch {
    Log "ERRO: $_ | $($_.InvocationInfo.PositionMessage)"
    throw
} finally {
    try { Stop-ExcelCom $xl } catch { Log "aviso ao fechar o Excel: $_" }
}
