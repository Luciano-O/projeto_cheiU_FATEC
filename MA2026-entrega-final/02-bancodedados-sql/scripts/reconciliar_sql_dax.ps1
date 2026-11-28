# E5.5: compara KPIs entre o SQL Server (dw) e as medidas DAX do modelo da Etapa 4 (cheiU_04_VBA.xlsm).
# SQL: 05_kpis.sql, que devolve "kpi|valor" com os mesmos nomes das medidas. DAX: função VBA ValorMedida
# (Excel visível: oculto ele recusa chamadas). Imprime a tabela em Markdown para o qa/etapa-5.md.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-final\02-bancodedados-sql\scripts\reconciliar_sql_dax.ps1
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1') -Force
$inv = [Globalization.CultureInfo]::InvariantCulture
$br = [Globalization.CultureInfo]::GetCultureInfo('pt-BR')

$kpis = [ordered]@{
    'Total de Passageiros' = 'Total de passageiros'
    'Passageiros de Ônibus' = 'Passageiros de ônibus'
    'Conf Linhas Fato_Transporte' = 'Linhas da fato'
    'Passageiros Publicados' = 'Passageiros publicados'
    'Média Dia Útil' = 'Média de dia útil'
    'Média Fim de Semana' = 'Média de fim de semana'
    'Média Dia Útil com Chuva' = 'Média de dia útil com chuva (5 mm ou mais)'
    'Média Dia Útil sem Chuva' = 'Média de dia útil seco (menos de 1 mm)'
}

$env:MSYS_NO_PATHCONV = '1'
$saida = docker exec cheiu-sql bash -c '/opt/mssql-tools18/bin/sqlcmd -C -f 65001 -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -h -1 -W -i /scripts/05_kpis.sql'
$sql = @{}
foreach ($l in @($saida)) {
    $p = $l.Split('|')
    if ($p.Count -eq 2) { $sql[$p[0].Trim()] = [double]::Parse($p[1].Trim(), $inv) }
}

$xl = Start-ExcelCom -Visible
try {
    $xl.AutomationSecurity = 1
    $wb = $xl.Workbooks.Open((Join-Path $repo 'MA2026-entrega-final\01-vba\cheiU_04_VBA.xlsm'), 0, $true)
    Write-Host '| KPI | DAX (modelo da Etapa 4) | SQL (dw) | Diferença |'
    Write-Host '|---|---|---|---|'
    foreach ($m in $kpis.Keys) {
        $dax = [double]$xl.Run('ValorMedida', $m)
        $s = $sql[$m]
        $dif = [math]::Round($s - $dax, 4)
        Write-Host ("| {0} | {1} | {2} | {3} |" -f $kpis[$m], $dax.ToString('N0', $br), $s.ToString('N0', $br), $dif.ToString('0.####', $br))
    }
    $wb.Close($false)
} finally { try { Stop-ExcelCom $xl } catch {} }
