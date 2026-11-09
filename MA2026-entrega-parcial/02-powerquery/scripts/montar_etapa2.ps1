# Monta MA2026-entrega-parcial/02-powerquery/cheiU_02_PowerQuery.xlsx do zero a partir de scripts_m/*.pq.
# As consultas são a fonte da verdade; este script só cria a pasta, injeta as consultas e carrega as saídas.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-parcial\02-powerquery\scripts\montar_etapa2.ps1
param([string[]]$Saidas = @(
    'Fato_Referencia_Mensal', 'Conf_Colunas', 'Dim_Grupo', 'Ref_Feriados', 'Fato_Transporte', 'Dim_Transporte',
    'Rejeitados', 'Conf_Reconciliacao', 'Conf_Motivos', 'Conf_Etapas', 'Conf_Publicado'))
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $PSScriptRoot 'ExcelCom.psm1') -Force
$dir = Join-Path $repo 'MA2026-entrega-parcial\02-powerquery'
$saida = Join-Path $dir 'cheiU_02_PowerQuery.xlsx'
function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }

$xl = Start-ExcelCom
try {
    $wb = New-Pasta $xl 'Parametros'
    $ws = $wb.Worksheets.Item('Parametros')
    $ws.Range('A1').Formula = 'CaminhoRepo'
    $ws.Range('B1').Formula2 = '=LEFT(CELL("filename",$A$1),FIND("MA2026-entrega-parcial",CELL("filename",$A$1))-1)'
    $ws.Range('C1').Formula = 'Raiz do repositório, derivada do caminho deste arquivo. Lida pela consulta pCaminhoRepo.'
    Set-NomeDefinido $wb 'CaminhoRepo' '=Parametros!$B$1'
    $ws.Range('A3').Formula = 'Grupos de consultas (Editor do Power Query):'
    $grupos = @(
        @('01_Parametros', 'pCaminhoRepo, pArquivoEtapa1, pPastaSPTrans, pPastaSPTransConvertido, pArquivoTotaisSPTrans'),
        @('02_Origem', 'stg_SPTrans_Bruto, fnLerSPTrans'),
        @('03_Cadastros', 'cad_Etapa1, cad_DePara_Grupo, cad_DePara_Coluna, cad_Feriados, lst_Grupo'),
        @('04_Tratamento', 'stg_sptrans_linhas, stg_sptrans_diario, stg_sptrans_referencia'),
        @('05_Saida', 'Fato_Transporte, Fato_Referencia_Mensal, Dim_Transporte, Dim_Grupo, Ref_Feriados, Rejeitados'),
        @('06_Conferencia', 'Conf_Reconciliacao, Conf_Motivos, Conf_Colunas, Conf_Etapas, Conf_Publicado'))
    for ($i = 0; $i -lt $grupos.Count; $i++) { $ws.Cells.Item(4 + $i, 1).Formula = $grupos[$i][0]; $ws.Cells.Item(4 + $i, 2).Formula = $grupos[$i][1] }
    Save-Pasta $wb $saida            # CÉL("nomearquivo") só funciona depois de salvo
    $xl.CalculateFull()
    Log "CaminhoRepo = $($ws.Range('B1').Text)"

    $wb.Queries.FastCombine = $true  # Ignorar níveis de privacidade: todas as origens são arquivos da equipe
    $n = Import-PastaPq $wb (Join-Path $dir 'scripts_m')
    Log "$n consultas importadas"

    foreach ($q in $Saidas) {
        $t0 = Get-Date
        $lo = Add-CargaPlanilha $wb $q $q
        Log ("{0}: {1} linhas ({2:N0} s)" -f $q, $lo.ListRows.Count, ((Get-Date) - $t0).TotalSeconds)
        $wb.Save()
    }
    $wb.Worksheets.Item('Parametros').Activate()
    $wb.Save()

    foreach ($q in @('Conf_Reconciliacao', 'Conf_Etapas', 'Conf_Motivos', 'Conf_Colunas', 'Conf_Publicado')) {
        if (-not ($Saidas -contains $q)) { continue }
        $lo = $wb.Worksheets.Item($q).ListObjects.Item(1)
        Log "--- $q"
        $h = ($lo.HeaderRowRange.Value2 | ForEach-Object { $_ }) -join ' | '
        Write-Host "    $h"
        if ($lo.ListRows.Count -gt 0) {
            foreach ($r in @($lo.DataBodyRange.Rows)) { Write-Host ("    " + ((@($r.Cells) | ForEach-Object { $_.Text }) -join ' | ')) }
        }
    }
    $wb.Close($false)
} finally {
    Stop-ExcelCom $xl
}
