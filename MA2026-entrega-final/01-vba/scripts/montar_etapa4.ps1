# Monta MA2026-entrega-final/01-vba/cheiU_04_VBA.xlsm a partir do cheiU_03_PowerPivot.xlsx (o arquivo da Etapa 3 salvo
# como .xlsm, com os ajustes de interface do Power Pivot preservados), importa modulos/*.bas, cria as abas Controle, Log
# e QA e roda a sequência completa em modo silencioso: TestarLog, AtualizarTudo, ValidarDados, três resumos (um válido,
# uma data inexistente e uma data fora do calendário) e ExportarParaCarga.
# Exige "Confiar no acesso ao modelo de objeto do projeto do VBA" (registro AccessVBOM = 1).
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-final\01-vba\scripts\montar_etapa4.ps1
param([switch]$SemExecutar)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1') -Force
$dir = Join-Path $repo 'MA2026-entrega-final\01-vba'
$origem = Join-Path $repo 'MA2026-entrega-parcial\03-powerpivot\cheiU_03_PowerPivot.xlsx'
$saida = Join-Path $dir 'cheiU_04_VBA.xlsm'
function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }
function Esperar-Excel($xl) { for ($k = 0; $k -lt 120; $k++) { try { if ($xl.Ready) { return } } catch {}; Start-Sleep -Milliseconds 500 } }
# Excel ocupado (0x800AC472 ou RPC_E_CALL_REJECTED): espera e tenta de novo.
function Tentar([scriptblock]$Acao) {
    for ($k = 1; $k -le 40; $k++) {
        try { return & $Acao } catch { if ($k -eq 40 -or "$_" -notmatch '800AC472|0x80010001|RPC_E_CALL_REJECTED') { throw }; Esperar-Excel $xl; Start-Sleep -Seconds 2 }
    }
}

New-Item -ItemType Directory -Force (Join-Path $dir 'relatorios') | Out-Null
$tmp = Join-Path $env:TEMP 'cheiU_etapa4_base.xlsx'
Copy-Item $origem $tmp -Force

$xl = Start-ExcelCom
try {
    $wb = $xl.Workbooks.Open($tmp)
    # Logo depois de abrir, o Excel ainda carrega o Modelo de Dados e recusa chamadas (0x800AC472): espera e tenta de novo.
    if (Test-Path $saida) { Remove-Item $saida -Force }
    for ($k = 1; $k -le 30; $k++) {
        Esperar-Excel $xl
        try { $wb.SaveAs($saida, 52); break } catch { if ($k -eq 30) { throw }; Start-Sleep -Seconds 2 }
    }
    # A Etapa 4 fica em MA2026-entrega-final: CaminhoRepo procura o prefixo comum das duas pastas de entrega.
    $par = Tentar { $wb.Worksheets.Item('Parametros') }
    Tentar { $par.Range('B1').Formula2 = '=LEFT(CELL("filename",$A$1),FIND("MA2026-entrega-",CELL("filename",$A$1))-1)' }
    $xl.CalculateFull()
    Log "CaminhoRepo = $($par.Range('B1').Text)"

    # ---------- abas Controle, Log e QA ----------
    $ctl = Tentar { $wb.Worksheets.Add($wb.Worksheets.Item(1)) }
    $ctl.Name = 'Controle'
    $ctl.Range('A1').Formula = 'cheiU — painel de controle da Etapa 4'
    $ctl.Range('A1').Font.Bold = $true; $ctl.Range('A1').Font.Size = 16
    $ctl.Range('A2').Formula = 'Habilite as macros ao abrir. Ordem sugerida: Atualizar, Validar, Resumo diário, Exportar para SQL.'
    $botoes = @(
        @('Atualizar', 'BotaoAtualizar', 'Atualiza as consultas, o Modelo de Dados e as dinâmicas; uma linha por consulta na aba Log.'),
        @('Validar', 'BotaoValidar', 'Repete por DAX as checagens dos QAs das Etapas 2 e 3 e preenche a aba QA (OK/FALHA).'),
        @('Resumo diário', 'BotaoResumo', 'Pede uma data, cria a aba Resumo_dd-mm-aaaa e o PDF em relatorios\.'),
        @('Exportar para SQL', 'BotaoExportar', 'Grava as tabelas do modelo em CSV para a carga da Etapa 5 (02-bancodedados-sql\carga\).'))
    for ($i = 0; $i -lt $botoes.Count; $i++) {
        $r = 4 + 3 * $i
        $c = $ctl.Range("A$r")
        $b = $ctl.Buttons().Add($c.Left, $c.Top, 150, 30)
        $b.Caption = $botoes[$i][0]
        $b.OnAction = $botoes[$i][1]
        $ctl.Range("D$r").Formula = $botoes[$i][2]
    }
    $ctl.Columns.Item(1).ColumnWidth = 24

    $lg = Add-Aba $wb 'Log'
    $lo = Write-Tabela $lg 'A1' 'Tab_Log' @(,@('data_hora', 'rotina', 'status', 'mensagem', 'duracao_s'))
    $lg.Range('A:A').NumberFormat = 'dd/mm/yyyy hh:mm:ss'
    $qa = Add-Aba $wb 'QA'
    $loq = Write-Tabela $qa 'A1' 'Tab_QA' @(,@('checagem', 'esperado', 'obtido', 'status'))
    $st = $qa.Range('D:D')
    $fc = $st.FormatConditions.Add(1, 3, '="FALHA"'); $fc.Interior.Color = 0x9999FF
    $fc = $st.FormatConditions.Add(1, 3, '="OK"'); $fc.Interior.Color = 0xCCFFCC
    $lo.ListRows.Count | Out-Null; $loq.ListRows.Count | Out-Null
    # Write-Tabela cria uma linha vazia quando só há cabeçalho: apaga
    foreach ($t in @($lo, $loq)) { if ($t.ListRows.Count -gt 0) { $t.DataBodyRange.Rows.Delete() | Out-Null } }

    # ---------- módulos ----------
    $mods = Get-ChildItem (Join-Path $dir 'modulos') -Filter *.bas | Sort-Object Name
    $proj = $null
    try { $proj = [System.__ComObject].InvokeMember('VBProject', [Reflection.BindingFlags]::GetProperty, $null, $wb, $null) } catch {}
    if ($null -ne $proj) {
        foreach ($m in $mods) { [void]$proj.VBComponents.Import($m.FullName) }
        Log ("módulos importados: " + (($mods | ForEach-Object { $_.BaseName }) -join ', '))
    } else {
        # Nesta máquina o Excel aberto por automação recusa o acesso ao projeto VBA mesmo com AccessVBOM = 1.
        Log ("acesso ao projeto VBA recusado: importe pelo VBE (Alt+F11, Arquivo › Importar) " + (($mods | ForEach-Object { $_.Name }) -join ', ') + " e depois rode executar_etapa4.ps1")
        $SemExecutar = $true
    }
    $ctl.Activate()
    $wb.Save()

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
    Remove-Item $tmp -ErrorAction SilentlyContinue
}
