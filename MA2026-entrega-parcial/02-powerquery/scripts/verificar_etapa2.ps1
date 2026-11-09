# Verificações de publicação e QA da Etapa 2 (E2.10 e E2.11). Não salva a pasta de trabalho.
# 1. os .pq de scripts_m são idênticos às consultas da pasta;
# 2. teste de reenvio: um arquivo extra na pasta muda as contagens, e elas voltam ao retirá-lo.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-parcial\02-powerquery\scripts\verificar_etapa2.ps1
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $PSScriptRoot 'ExcelCom.psm1') -Force
$dir = Join-Path $repo 'MA2026-entrega-parcial\02-powerquery'
$pasta = Join-Path $repo 'MA2026-entrega-parcial\01-excel\dados-brutos\sptrans\2024\diario'
$extra = Join-Path $pasta 'zz_teste_reenvio.xlsx'
function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }

function Ler-Conf($wb, [string]$rotulo) {
    foreach ($q in 'Conf_Reconciliacao', 'Conf_Motivos') {
        $lo = $wb.Worksheets.Item($q).ListObjects.Item(1)
        $lo.QueryTable.Refresh($false) | Out-Null
        foreach ($r in @($lo.DataBodyRange.Rows)) { Log ("$rotulo $q : " + ((@($r.Cells) | ForEach-Object { $_.Text }) -join ' | ')) }
    }
}

$xl = Start-ExcelCom
try {
    $wb = $xl.Workbooks.Open((Join-Path $dir 'cheiU_02_PowerQuery.xlsx'))
    $dif = Compare-PastaPq $wb (Join-Path $dir 'scripts_m')
    Log ("consultas na pasta: {0}; arquivos .pq: {1}; diferenças: {2}" -f $wb.Queries.Count, @(Get-ChildItem (Join-Path $dir 'scripts_m') -Filter *.pq).Count, @($dif).Count)
    foreach ($d in $dif) { Log "  $d" }
    Log ("vínculos externos: " + [string]($null -ne $wb.LinkSources(1)))

    Ler-Conf $wb 'ANTES'
    Copy-Item (Join-Path $pasta '01ago2024.xlsx') $extra
    try { Ler-Conf $wb 'COM EXTRA' } finally { Remove-Item $extra -Force }
    Ler-Conf $wb 'DEPOIS'
    $wb.Close($false)
} finally {
    if (Test-Path $extra) { Remove-Item $extra -Force }
    Stop-ExcelCom $xl
}
