# Teste negativo do QA automatizado (E4.3), numa cópia mínima do repositório em -PastaTemp:
# soma 1.000 a passageiros_no_fato na Conf_Reconciliacao da Etapa 2 copiada, roda AtualizarTudo e ValidarDados na
# Etapa 4 copiada e espera FALHA em "Passageiros no modelo = Etapa 2". Não altera os arquivos do repositório.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-final\01-vba\scripts\verificar_etapa4.ps1 -PastaTemp <pasta>
param([Parameter(Mandatory)][string]$PastaTemp)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1') -Force
function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }

$copias = @(
    'MA2026-entrega-parcial\02-powerquery\cheiU_02_PowerQuery.xlsx',
    'MA2026-entrega-final\01-vba\cheiU_04_VBA.xlsm',
    'MA2026-entrega-parcial\01-excel\dados-brutos\clima\open_meteo_2024.json')
foreach ($c in $copias) {
    $d = Join-Path $PastaTemp $c
    New-Item -ItemType Directory -Force (Split-Path $d) | Out-Null
    Copy-Item (Join-Path $repo $c) $d -Force
}
New-Item -ItemType Directory -Force (Join-Path $PastaTemp 'MA2026-entrega-final\01-vba\relatorios'), (Join-Path $PastaTemp 'MA2026-entrega-final\02-bancodedados-sql\carga') | Out-Null

$xl = Start-ExcelCom -Visible
try {
    $xl.AutomationSecurity = 1
    $e2 = $xl.Workbooks.Open((Join-Path $PastaTemp 'MA2026-entrega-parcial\02-powerquery\cheiU_02_PowerQuery.xlsx'))
    $lo = $e2.Worksheets.Item('Conf_Reconciliacao').ListObjects.Item(1)
    $col = $lo.ListColumns.Item('passageiros_no_fato').Index
    $cel = $lo.DataBodyRange.Cells.Item(1, $col)
    $antes = $cel.Value2
    $cel.Value2 = $antes + 1000
    Log "Etapa 2 (cópia): passageiros_no_fato da 1ª fonte $antes -> $($cel.Value2)"
    $e2.Save(); $e2.Close($false)

    $e4 = $xl.Workbooks.Open((Join-Path $PastaTemp 'MA2026-entrega-final\01-vba\cheiU_04_VBA.xlsm'))
    Log ("CaminhoRepo da cópia = " + $e4.Worksheets.Item('Parametros').Range('B1').Text)
    [void]$xl.Run('DefinirModoSilencioso', $true)
    [void]$xl.Run('AtualizarTudo')
    $f = $xl.Run('ValidarDados')
    Log "ValidarDados: $f falha(s)"
    foreach ($r in @($e4.Worksheets.Item('QA').ListObjects.Item(1).DataBodyRange.Rows)) {
        $t = (@($r.Cells) | ForEach-Object { $_.Text }) -join ' | '
        if ($t -match 'FALHA') { Write-Host "    $t" }
    }
    $e4.Close($false)
    if ($f -ge 1) { Log 'teste negativo OK: o defeito proposital virou FALHA' } else { Log 'teste negativo FALHOU: nenhuma checagem pegou o defeito' }
} finally { try { Stop-ExcelCom $xl } catch {} }
