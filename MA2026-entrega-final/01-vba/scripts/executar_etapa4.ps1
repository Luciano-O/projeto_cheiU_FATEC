# Roda a sequência completa da Etapa 4 em modo silencioso no cheiU_04_VBA.xlsm já montado e com os módulos:
# TestarLog, AtualizarTudo, ValidarDados, três resumos (um válido, uma data inexistente e uma fora do calendário)
# e ExportarParaCarga. Salva a pasta com o Log e a aba QA preenchidos.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-final\01-vba\scripts\executar_etapa4.ps1
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1') -Force
$saida = Join-Path $repo 'MA2026-entrega-final\01-vba\cheiU_04_VBA.xlsm'
function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }
function Esperar-Excel($xl) { for ($k = 0; $k -lt 120; $k++) { try { if ($xl.Ready) { return } } catch {}; Start-Sleep -Milliseconds 500 } }
$SemExecutar = $false
# Excel visível: oculto, ele cai em GerarResumoDiario depois de AtualizarTudo (RPC 0x800706BE).
$xl = Start-ExcelCom -Visible
try {
    $xl.AutomationSecurity = 1
    $wb = $xl.Workbooks.Open($saida)
    Esperar-Excel $xl
    [void]$xl.Run('LimparLog')
    if (-not $SemExecutar) {
        [void]$xl.Run('DefinirModoSilencioso', $true)
        [void]$xl.Run('TestarLog')
        $t0 = Get-Date
        [void]$xl.Run('AtualizarTudo'); Esperar-Excel $xl
        Log ("AtualizarTudo ({0:N0} s)" -f ((Get-Date) - $t0).TotalSeconds)
        $f = $xl.Run('ValidarDados'); Log "ValidarDados: $f falha(s)"
        foreach ($d in '15/03/2024', '31/02/2024', '01/01/2025') { $n = $xl.Run('GerarResumoDiario', $d); Log "GerarResumoDiario $d -> '$n'" }
        $t0 = Get-Date
        $f = $xl.Run('ExportarParaCarga'); Log ("ExportarParaCarga: $f falha(s) ({0:N0} s)" -f ((Get-Date) - $t0).TotalSeconds)
        [void]$xl.Run('DefinirModoSilencioso', $false)
        $wb.Worksheets.Item('Controle').Activate()
        $wb.Save()
        Log '--- Log'
        foreach ($r in @($wb.Worksheets.Item('Log').ListObjects.Item(1).DataBodyRange.Rows)) { Write-Host ('    ' + ((@($r.Cells) | ForEach-Object { $_.Text }) -join ' | ')) }
        Log '--- QA'
        foreach ($r in @($wb.Worksheets.Item('QA').ListObjects.Item(1).DataBodyRange.Rows)) { Write-Host ('    ' + ((@($r.Cells) | ForEach-Object { $_.Text }) -join ' | ')) }
    }
    $wb.Close($true)
} catch {
    Log "ERRO: $_ | $($_.InvocationInfo.PositionMessage)"
    throw
} finally {
    try { Stop-ExcelCom $xl } catch { Log "aviso ao fechar o Excel: $_" }
}
