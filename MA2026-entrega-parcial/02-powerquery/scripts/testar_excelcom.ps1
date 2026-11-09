# Prova de conceito do E0.7: cria do zero uma pasta de trabalho com célula nomeada, consulta Power Query
# que lê um CSV pelo caminho da célula, carga em planilha e no modelo, relação, medida, atualização e exportação.
# Uso: powershell -File MA2026-entrega-parcial\02-powerquery\scripts\testar_excelcom.ps1 -Pasta <pasta temporária>
param([Parameter(Mandatory)][string]$Pasta, [switch]$Visible)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ExcelCom.psm1') -Force

New-Item -ItemType Directory -Force $Pasta | Out-Null
$csvF = Join-Path $Pasta 'fato.csv'
$csvD = Join-Path $Pasta 'dim.csv'
"id;valor`n1;10,5`n2;20`n1;4,5" | Set-Content $csvF -Encoding utf8
"id;nome`n1;Ônibus`n2;Metrô" | Set-Content $csvD -Encoding utf8
$arq = Join-Path $Pasta 'teste_excelcom.xlsx'

$xl = Start-ExcelCom -Visible:$Visible
try {
    $wb = New-Pasta $xl 'Parametros'
    $ws = $wb.Worksheets.Item('Parametros')
    $ws.Range('A1').Value2 = 'CaminhoRepo'
    $ws.Range('B1').Value2 = $Pasta + '\'
    Set-NomeDefinido $wb 'CaminhoRepo' '=Parametros!$B$1'
    $wb.Queries.FastCombine = $true

    $m1 = @'
// pCaminho
let Fonte = Excel.CurrentWorkbook(){[Name = "CaminhoRepo"]}[Content]{0}[Column1] in Fonte
'@
    $m2 = @'
// tFato
let
    Fonte = Csv.Document(File.Contents(pCaminho & "fato.csv"), [Delimiter = ";", Encoding = 65001]),
    Cab = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(Cab, {{"id", Int64.Type}, {"valor", type number}}, "pt-BR")
in
    Tipos
'@
    $m3 = @'
// tDim
let
    Fonte = Csv.Document(File.Contents(pCaminho & "dim.csv"), [Delimiter = ";", Encoding = 65001]),
    Cab = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(Cab, {{"id", Int64.Type}, {"nome", type text}}, "pt-BR")
in
    Tipos
'@
    [void](Set-Consulta $wb 'pCaminho' $m1)
    [void](Set-Consulta $wb 'tFato' $m2)
    [void](Set-Consulta $wb 'tDim' $m3)
    Write-Host "consultas criadas"
    $lo = Add-CargaPlanilha $wb 'tDim' 'Dim'
    Write-Host "carga em planilha ok"
    [void](Add-CargaModelo $wb 'tFato')
    [void](Add-CargaModelo $wb 'tDim')
    Write-Host "conexoes do modelo ok"
    Update-Tudo $wb
    "linhas tDim na planilha: $($lo.ListRows.Count)"
    "tabelas no modelo: " + ((@($wb.Model.ModelTables) | ForEach-Object { $_.Name + '(' + $_.RecordCount + ')' }) -join ', ')
    [void](Add-Relacao $wb 'tFato' 'id' 'tDim' 'id')
    "relações: $($wb.Model.ModelRelationships.Count)"
    [void](Set-Medida $wb 'Total Valor' 'tFato' 'SUM(tFato[valor])' 'decimal' 'teste')
    [void](Set-Medida $wb 'Total Ônibus' 'tFato' 'CALCULATE([Total Valor], tDim[nome] = "Ônibus")' 'decimal' 'teste')
    "medida Total Valor = " + (Get-ValorMedida $wb 'Total Valor' 'Parametros')
    "medida Total Ônibus = " + (Get-ValorMedida $wb 'Total Ônibus' 'Parametros')
    Save-Pasta $wb $arq
    $n = Export-PastaPq $wb (Join-Path $Pasta 'pq')
    "pq exportados: $n; diferenças: " + ((Compare-PastaPq $wb (Join-Path $Pasta 'pq')) -join '; ')
    $wb.Close($false)
} finally {
    Stop-ExcelCom $xl
}
