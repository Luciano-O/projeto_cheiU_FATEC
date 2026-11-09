# Verificações de publicação e QA da Etapa 3 (E3.6 e E3.7). Não altera os arquivos entregues.
# 1. .pq e .dax idênticos ao que está na pasta de trabalho;
# 2. segmentações ligadas a todas as tabelas dinâmicas;
# 3. teste de linhagem numa cópia temporária: uma mudança na Etapa 2 aparece aqui depois de atualizar e volta ao desfazer.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-parcial\03-powerpivot\scripts\verificar_etapa3.ps1 -PastaTemp <pasta>
param([Parameter(Mandatory)][string]$PastaTemp)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1') -Force
$dir = Join-Path $repo 'MA2026-entrega-parcial\03-powerpivot'
function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }

# Cópia com a mesma estrutura de pastas: CaminhoRepo se deriva sozinho para a pasta temporária.
$e2t = Join-Path $PastaTemp 'MA2026-entrega-parcial\02-powerquery'
$e3t = Join-Path $PastaTemp 'MA2026-entrega-parcial\03-powerpivot'
New-Item -ItemType Directory -Force $e2t, $e3t | Out-Null
Copy-Item (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\cheiU_02_PowerQuery.xlsx') $e2t -Force
Copy-Item (Join-Path $dir 'cheiU_03_PowerPivot.xlsx') $e3t -Force
$arqE2 = Join-Path $e2t 'cheiU_02_PowerQuery.xlsx'
$arqE3 = Join-Path $e3t 'cheiU_03_PowerPivot.xlsx'

function Alterar-E2($xl, [int]$delta) {
    $w = $xl.Workbooks.Open($arqE2)
    $c = $w.Worksheets.Item('Fato_Referencia_Mensal').ListObjects.Item(1).ListColumns.Item('passageiros_publicado').DataBodyRange.Cells.Item(1, 1)
    $c.Formula = [string]([double]$c.Value2 + $delta)
    $w.Save(); $w.Close($false)
}
function Ler-E3($xl, [string]$rotulo) {
    $w = $xl.Workbooks.Open($arqE3)
    Update-Tudo $w
    Log ("$rotulo Passageiros Publicados = " + (Get-ValorMedida $w 'Passageiros Publicados' 'Parametros') + "; CaminhoRepo = " + $w.Worksheets.Item('Parametros').Range('B1').Text)
    $w.Close($false)
}

$xl = Start-ExcelCom
try {
    $wb = $xl.Workbooks.Open((Join-Path $dir 'cheiU_03_PowerPivot.xlsx'))
    $d1 = Compare-PastaPq $wb (Join-Path $dir 'scripts_m')
    $d2 = Compare-Dax $wb (Join-Path $dir 'dax\medidas_preliminares.dax')
    Log ("consultas: {0}; diferenças .pq: {1}" -f $wb.Queries.Count, @($d1).Count); foreach ($d in $d1) { Log "  $d" }
    Log ("medidas: {0}; diferenças .dax: {1}" -f $wb.Model.ModelMeasures.Count, @($d2).Count); foreach ($d in $d2) { Log "  $d" }
    Log ("relações: " + ((@($wb.Model.ModelRelationships) | ForEach-Object { "$($_.ForeignKeyTable.Name)[$($_.ForeignKeyColumn.Name)]->$($_.PrimaryKeyTable.Name)[$($_.PrimaryKeyColumn.Name)] ativa=$($_.Active)" }) -join '; '))
    foreach ($sc in @($wb.SlicerCaches)) { Log ("segmentação {0}: {1} dinâmicas" -f $sc.Name, $sc.PivotTables.Count) }
    Log ("vínculos externos: " + [string]($null -ne $wb.LinkSources(1)))
    $wb.Close($false)

    Ler-E3 $xl 'ANTES'
    Alterar-E2 $xl 1000
    Ler-E3 $xl 'COM +1000 NA ETAPA 2'
    Alterar-E2 $xl -1000
    Ler-E3 $xl 'DEPOIS DE DESFAZER'
} finally {
    Stop-ExcelCom $xl
}
