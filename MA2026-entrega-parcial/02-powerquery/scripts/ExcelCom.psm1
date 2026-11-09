# ExcelCom.psm1 — automação do Excel via COM para o cheiU (E0.7).
# As pastas de trabalho são montadas a partir dos gêmeos em texto (.pq, .dax).
# Receita e limites: memories/automacao-excel.md.
#
# Uso:
#   Import-Module .\MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1 -Force
#   $xl = Start-ExcelCom
#   ...
#   Stop-ExcelCom $xl

Set-StrictMode -Version 2

function Start-ExcelCom {
    param([switch]$Visible)
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = [bool]$Visible
    $xl.DisplayAlerts = $false
    $xl.ScreenUpdating = [bool]$Visible
    $xl.AskToUpdateLinks = $false
    return $xl
}

function Stop-ExcelCom {
    param($Excel)
    try { foreach ($wb in @($Excel.Workbooks)) { $wb.Close($false) } } catch {}
    $Excel.Quit()
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($Excel)
    [GC]::Collect(); [GC]::WaitForPendingFinalizers()
}

function New-Pasta {
    # Cria uma pasta de trabalho com uma única planilha chamada $PrimeiraAba.
    param($Excel, [string]$PrimeiraAba = 'Planilha1')
    $wb = $Excel.Workbooks.Add()
    while ($wb.Worksheets.Count -gt 1) { $wb.Worksheets.Item($wb.Worksheets.Count).Delete() }
    $wb.Worksheets.Item(1).Name = $PrimeiraAba
    return $wb
}

function Save-Pasta {
    # 51 = xlOpenXMLWorkbook (.xlsx), 52 = .xlsm
    param($Workbook, [string]$Caminho, [int]$Formato = 51)
    if (Test-Path $Caminho) { Remove-Item $Caminho -Force }
    $Workbook.SaveAs($Caminho, $Formato)
}

function Add-Aba {
    param($Workbook, [string]$Nome)
    $ws = $Workbook.Worksheets.Add([Type]::Missing, $Workbook.Worksheets.Item($Workbook.Worksheets.Count))
    $ws.Name = $Nome
    return $ws
}

function Set-NomeDefinido {
    # Cria (ou recria) um nome definido no nível da pasta. $RefersTo em notação A1 inglesa, ex. "=Cadastros!$B$2".
    param($Workbook, [string]$Nome, [string]$RefersTo)
    try { $Workbook.Names.Item($Nome).Delete() } catch {}
    [void]$Workbook.Names.Add($Nome, $RefersTo)
}

function Set-Valores {
    # Range.Value2 = matriz 2D.
    param($Range, $Matriz)
    # Matriz e elementos chegam embrulhados em PSObject ao passar por parâmetro; o COM só aceita o objeto base.
    $m = $Matriz.psobject.BaseObject
    $Range.Value2 = $m
}

function Write-Tabela {
    # Escreve um array de linhas (a primeira é o cabeçalho) a partir de $Celula e transforma em ListObject.
    # $Linhas: [object[][]]. Devolve o ListObject.
    param($Worksheet, [string]$Celula, [string]$Nome, [object[]]$Linhas, [string]$Estilo = 'TableStyleLight9')
    $nl = $Linhas.Count; $nc = $Linhas[0].Count
    $arr = New-Object 'object[,]' $nl, $nc
    for ($i = 0; $i -lt $nl; $i++) { for ($j = 0; $j -lt $nc; $j++) { $v = $Linhas[$i][$j]; if ($null -ne $v -and $v -is [psobject]) { $v = $v.psobject.BaseObject }; $arr[$i, $j] = $v } }
    $ini = $Worksheet.Range($Celula)
    $rng = $ini.Resize($nl, $nc)
    Set-Valores $rng $arr
    $lo = $Worksheet.ListObjects.Add(1, $rng, $null, 1)   # xlSrcRange, xlYes
    $lo.Name = $Nome
    $lo.TableStyle = $Estilo
    return $lo
}

# ---------- Power Query ----------

function Read-Pq {
    # Lê um .pq (UTF-8) e devolve @{Nome; Formula}. A primeira linha "// <Nome>" fica no texto.
    param([string]$Caminho)
    $txt = [IO.File]::ReadAllText($Caminho, [Text.Encoding]::UTF8)
    $txt = $txt -replace "`r`n", "`n"
    $nome = [IO.Path]::GetFileNameWithoutExtension($Caminho)
    return @{ Nome = $nome; Formula = $txt }
}

function Set-Consulta {
    # Cria ou substitui a consulta. Devolve o WorkbookQuery.
    param($Workbook, [string]$Nome, [string]$Formula, [string]$Descricao = '')
    $q = $null
    try { $q = $Workbook.Queries.Item($Nome) } catch {}
    if ($q) { $q.Formula = $Formula; if ($Descricao) { $q.Description = $Descricao }; return $q }
    return $Workbook.Queries.Add($Nome, $Formula, $Descricao)
}

function Import-PastaPq {
    # Injeta todos os .pq de uma pasta. A ordem não importa: o M resolve as referências na avaliação.
    param($Workbook, [string]$Pasta)
    $n = 0
    foreach ($f in Get-ChildItem $Pasta -Filter *.pq | Sort-Object Name) {
        $pq = Read-Pq $f.FullName
        [void](Set-Consulta $Workbook $pq.Nome $pq.Formula)
        $n++
    }
    return $n
}

function Get-ConnStringMashup {
    param([string]$Consulta)
    return "OLEDB;Provider=Microsoft.Mashup.OleDb.1;Data Source=`$Workbook`$;Location=$Consulta;Extended Properties=`"`""
}

function Add-CargaPlanilha {
    # Carrega a consulta numa tabela de planilha (ListObject com QueryTable). Devolve o ListObject.
    param($Workbook, [string]$Consulta, [string]$Aba, [string]$Celula = 'A1')
    $ws = $null
    try { $ws = $Workbook.Worksheets.Item($Aba) } catch { $ws = Add-Aba $Workbook $Aba }
    $lo = $ws.ListObjects.Add(0, (Get-ConnStringMashup $Consulta), $true, 1, $ws.Range($Celula))  # xlSrcExternal
    $lo.Name = $Consulta
    $qt = $lo.QueryTable
    $qt.CommandType = 2      # xlCmdSql
    $qt.CommandText = "SELECT * FROM [$Consulta]"
    $qt.BackgroundQuery = $false
    $qt.RefreshStyle = 1     # xlInsertDeleteCells
    $qt.AdjustColumnWidth = $true
    $qt.PreserveColumnInfo = $true
    $qt.Refresh($false) | Out-Null
    try { $Workbook.Connections.Item("Consulta - $Consulta").Name = "Consulta - $Consulta" } catch {}
    return $lo
}

function Add-CargaModelo {
    # Carrega a consulta só no Modelo de Dados. Devolve a WorkbookConnection.
    param($Workbook, [string]$Consulta)
    $cn = $Workbook.Connections.Add2("Consulta - $Consulta", "Conexão com a consulta '$Consulta' na pasta de trabalho.",
        (Get-ConnStringMashup $Consulta), "`"$Consulta`"", 6, $true, $false)   # 6 = xlCmdTableCollection, como o gravador de macros
    return $cn
}

function Update-Tudo {
    # RefreshAll síncrono: desliga o refresh em segundo plano das conexões OLEDB e espera o cálculo.
    param($Workbook)
    foreach ($c in @($Workbook.Connections)) {
        try { if ($c.Type -eq 1) { $c.OLEDBConnection.BackgroundQuery = $false } } catch {}
    }
    $Workbook.RefreshAll()
    $Workbook.Application.CalculateUntilAsyncQueriesDone()
    $Workbook.Application.CalculateFull()
}

function Export-PastaPq {
    # Grava cada consulta como <Pasta>\<Nome>.pq (UTF-8 sem BOM, LF). Devolve o número de arquivos.
    param($Workbook, [string]$Pasta)
    New-Item -ItemType Directory -Force $Pasta | Out-Null
    $utf8 = New-Object Text.UTF8Encoding($false)
    $n = 0
    foreach ($q in @($Workbook.Queries)) {
        $txt = ($q.Formula -replace "`r`n", "`n")
        if (-not $txt.EndsWith("`n")) { $txt += "`n" }
        [IO.File]::WriteAllText((Join-Path $Pasta "$($q.Name).pq"), $txt, $utf8)
        $n++
    }
    return $n
}

function Compare-PastaPq {
    # Compara os .pq da pasta com as consultas da pasta de trabalho. Devolve a lista de diferenças (vazia = ok).
    param($Workbook, [string]$Pasta)
    $dif = @()
    $nomes = @{}
    foreach ($q in @($Workbook.Queries)) {
        $nomes[$q.Name] = 1
        $arq = Join-Path $Pasta "$($q.Name).pq"
        if (-not (Test-Path $arq)) { $dif += "falta arquivo: $($q.Name).pq"; continue }
        $a = ([IO.File]::ReadAllText($arq, [Text.Encoding]::UTF8) -replace "`r`n", "`n").TrimEnd("`n")
        $b = ($q.Formula -replace "`r`n", "`n").TrimEnd("`n")
        if ($a -ne $b) { $dif += "texto diferente: $($q.Name)" }
    }
    foreach ($f in Get-ChildItem $Pasta -Filter *.pq) {
        if (-not $nomes.ContainsKey($f.BaseName)) { $dif += "consulta ausente na pasta de trabalho: $($f.BaseName)" }
    }
    return ,$dif
}

# ---------- Modelo de Dados ----------

function Get-ColunaModelo {
    param($Workbook, [string]$Tabela, [string]$Coluna)
    return $Workbook.Model.ModelTables.Item($Tabela).ModelTableColumns.Item($Coluna)
}

function Add-Relacao {
    # Relação 1:N ativa: $TabelaFato[$ColunaFato] → $TabelaDim[$ColunaDim].
    param($Workbook, [string]$TabelaFato, [string]$ColunaFato, [string]$TabelaDim, [string]$ColunaDim)
    $fk = Get-ColunaModelo $Workbook $TabelaFato $ColunaFato
    $pk = Get-ColunaModelo $Workbook $TabelaDim $ColunaDim
    return $Workbook.Model.ModelRelationships.Add($fk, $pk)
}

function Get-FormatoModelo {
    # Formatos: 'inteiro', 'decimal', 'percentual', 'geral'.
    param($Workbook, [string]$Formato)
    $m = $Workbook.Model
    switch ($Formato) {
        'inteiro'    { return $m.ModelFormatWholeNumber($true) }
        'decimal'    { return $m.ModelFormatDecimalNumber($true, 2) }
        'percentual' { return $m.ModelFormatPercentageNumber($true, 2) }
        default      { return $m.ModelFormatGeneral }
    }
}

function Set-Medida {
    # Cria ou substitui uma medida. $Formula com separador vírgula (a API COM usa a sintaxe invariante).
    param($Workbook, [string]$Nome, [string]$Tabela, [string]$Formula, [string]$Formato = 'geral', [string]$Descricao = '')
    foreach ($ms in @($Workbook.Model.ModelMeasures)) { if ($ms.Name -eq $Nome) { $ms.Delete(); break } }
    $t = $Workbook.Model.ModelTables.Item($Tabela)
    return $Workbook.Model.ModelMeasures.Add($Nome, $t, $Formula, (Get-FormatoModelo $Workbook $Formato), $Descricao)
}

function Read-Dax {
    # Lê um .dax no formato do projeto. Cada medida:
    #   // Pergunta: ...
    #   // Formato: inteiro|decimal|percentual|geral   Tabela: <tabela da medida>
    #   [Nome da Medida] =
    #       <expressão em uma ou mais linhas>
    # Separa medidas por linha em branco seguida de comentário. Devolve lista de @{Nome; Tabela; Formato; Descricao; Formula}.
    param([string]$Caminho)
    $txt = [IO.File]::ReadAllText($Caminho, [Text.Encoding]::UTF8) -replace "`r`n", "`n"
    $res = @()
    $atual = $null
    $coment = @()
    foreach ($l in $txt -split "`n") {
        if ($l -match '^\s*//') {
            if ($atual) { $res += $atual; $atual = $null }
            $coment += $l
            continue
        }
        if ($l -match '^\[(.+?)\]\s*=\s*(.*)$') {
            $nomeMedida = $Matches[1]; $inicioExpr = $Matches[2]   # os -match seguintes sobrescrevem $Matches
            if ($atual) { $res += $atual }
            $formato = 'geral'; $tabela = ''; $desc = ''
            foreach ($c in $coment) {
                if ($c -match 'Formato:\s*(\w+)') { $formato = $Matches[1] }
                if ($c -match 'Tabela:\s*(\S+)') { $tabela = $Matches[1] }
                if ($c -match 'Pergunta:\s*(.+)$') { $desc = $Matches[1].Trim() }
            }
            $atual = @{ Nome = $nomeMedida; Tabela = $tabela; Formato = $formato; Descricao = $desc; Formula = $inicioExpr }
            $coment = @()
            continue
        }
        if ($atual -and $l.Trim() -ne '') { $atual.Formula = ($atual.Formula + "`n" + $l).Trim() }
    }
    if ($atual) { $res += $atual }
    foreach ($m in $res) { $m.Formula = $m.Formula.Trim() }
    return $res
}

function Import-Dax {
    param($Workbook, [string]$Caminho)
    $n = 0
    foreach ($m in Read-Dax $Caminho) {
        [void](Set-Medida $Workbook $m.Nome $m.Tabela $m.Formula $m.Formato $m.Descricao)
        $n++
    }
    return $n
}

function Compare-Dax {
    # Compara o .dax com ModelMeasures (nome e expressão, espaços normalizados). Devolve as diferenças.
    param($Workbook, [string]$Caminho)
    $norm = { param($s) (($s -replace '\s+', ' ').Trim()) }
    $arq = @{}; foreach ($m in Read-Dax $Caminho) { $arq[$m.Nome] = & $norm $m.Formula }
    $dif = @()
    $vistos = @{}
    foreach ($ms in @($Workbook.Model.ModelMeasures)) {
        $vistos[$ms.Name] = 1
        if (-not $arq.ContainsKey($ms.Name)) { $dif += "medida fora do .dax: $($ms.Name)"; continue }
        if ($arq[$ms.Name] -ne (& $norm $ms.Formula)) { $dif += "expressão diferente: $($ms.Name)" }
    }
    foreach ($k in $arq.Keys) { if (-not $vistos.ContainsKey($k)) { $dif += "medida ausente no modelo: $k" } }
    return ,$dif
}

function Get-ValorMedida {
    # Lê o valor de uma medida (sem filtro) por CUBEVALUE numa célula temporária.
    param($Workbook, [string]$Medida, [string]$Aba)
    $ws = $Workbook.Worksheets.Item($Aba)
    $c = $ws.Range('XFD1')
    $c.Formula2 = "=CUBEVALUE(`"ThisWorkbookDataModel`",`"[Measures].[$Medida]`")"
    $Workbook.Application.CalculateUntilAsyncQueriesDone()
    $v = $c.Value2
    $c.ClearContents()
    return $v
}

Export-ModuleMember -Function *
