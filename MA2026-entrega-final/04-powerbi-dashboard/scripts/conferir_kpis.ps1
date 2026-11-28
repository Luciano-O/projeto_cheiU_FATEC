# Confere os KPIs do painel (modelo aberto no Power BI Desktop) contra o SQL Server (05_kpis.sql).
# Uso: com o cheiU_dashboard.pbip aberto e atualizado, rode
#   powershell -File MA2026-entrega-final\04-powerbi-dashboard\scripts\conferir_kpis.ps1
param([string]$Saida)

$ErrorActionPreference = 'Stop'
$raiz = Resolve-Path (Join-Path $PSScriptRoot '..\..\..')
$null = [Reflection.Assembly]::LoadFrom('C:\Program Files\Microsoft Power BI Desktop\bin\Microsoft.PowerBI.AdomdClient.dll')  # Add-Type falha no PowerShell 5.1

# instância local do Power BI: a pasta de workspace mais recente que responde
$porta = $null
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Power BI Desktop\AnalysisServicesWorkspaces" -Directory |
    Sort-Object LastWriteTime -Descending | ForEach-Object {
        $f = Join-Path $_.FullName 'Data\msmdsrv.port.txt'
        if (-not $porta -and (Test-Path $f)) {
            $p = [IO.File]::ReadAllText($f, [Text.Encoding]::Unicode).Trim()
            try { $c = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection "Data Source=localhost:$p"; $c.Open(); $c.Close(); $porta = $p } catch {}
        }
    }
if (-not $porta) { throw 'Power BI Desktop com o painel aberto não encontrado.' }
$con = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection "Data Source=localhost:$porta"
$con.Open()

$dax = @'
EVALUATE ROW(
  "total_passageiros", [Total de Passageiros],
  "passageiros_onibus", [Passageiros de Ônibus],
  "linhas_fato", COUNTROWS(Demanda),
  "passageiros_publicados", [Passageiros Publicados],
  "media_dia_util", ROUND([Média Dia Útil], 0),
  "media_fim_de_semana", ROUND([Média Fim de Semana], 0),
  "media_util_com_chuva", ROUND([Média Dia Útil com Chuva], 0),
  "media_util_seco", ROUND([Média Dia Útil sem Chuva], 0))
'@
$cmd = $con.CreateCommand(); $cmd.CommandText = $dax
$r = $cmd.ExecuteReader(); $null = $r.Read()
$pbi = @{}
for ($i = 0; $i -lt $r.FieldCount; $i++) { $pbi[($r.GetName($i) -replace '^\[|\]$', '')] = [decimal]$r.GetValue($i) }
$r.Close(); $con.Close()

# SQL: 05_kpis.sql devolve kpi|valor
$env_ = Get-Content (Join-Path $raiz '.env') | Where-Object { $_ -match '^MSSQL_SA_PASSWORD=' }
$senha = ($env_ -split '=', 2)[1]
$sql = docker exec cheiu-sql /opt/mssql-tools18/bin/sqlcmd -C -f 65001 -S localhost -U sa -P $senha -d cheiU -h -1 -W -s '|' -i /scripts/05_kpis.sql
$sqlv = @(foreach ($l in $sql) { if ($l -match '\|(-?[\d.]+)\s*$') { [math]::Round([decimal]$Matches[1], 0) } })  # na ordem do 05_kpis.sql

$kpis = 'total_passageiros','passageiros_onibus','linhas_fato','passageiros_publicados','media_dia_util','media_fim_de_semana','media_util_com_chuva','media_util_seco'
$linhas = for ($i = 0; $i -lt $kpis.Count; $i++) {
    $k = $kpis[$i]; $a = $pbi[$k]; $b = $sqlv[$i]
    [pscustomobject]@{ kpi = $k; power_bi = $a; sql = $b; diferenca = if ($null -ne $b) { $a - $b } else { 'sem SQL' } }
}
$txt = ($linhas | Format-Table -AutoSize | Out-String).TrimEnd()
$txt
if ($Saida) { Set-Content -Path $Saida -Value $txt -Encoding utf8 }
