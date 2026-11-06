# Monta MA2026-entrega-parcial/01-excel/cheiU_01_Excel.xlsx do zero (E1.5 e E1.6).
# Este script é o gêmeo em texto da pasta de trabalho: cadastros, fórmulas, validações,
# formatação condicional e auditoria saem daqui.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-parcial\01-excel\scripts\montar_etapa1.ps1
param([string]$Amostra = 'Consolidado 01-Janeiro-2024.xls')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
Import-Module (Join-Path $repo 'MA2026-entrega-parcial\02-powerquery\scripts\ExcelCom.psm1') -Force
$dirEtapa = Join-Path $repo 'MA2026-entrega-parcial\01-excel'
$saida = Join-Path $dirEtapa 'cheiU_01_Excel.xlsx'
$origem = Join-Path $dirEtapa "dados-brutos\sptrans\2024\mensal\$Amostra"

# O consolidado tem extensão .xls mas é .xlsx por dentro (D5): abrir pela extensão errada mostra um aviso.
$tmp = Join-Path $env:TEMP 'cheiU_amostra_etapa1.xlsx'
Copy-Item $origem $tmp -Force

function Log($m) { Write-Host ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }

$xl = Start-ExcelCom
try {
    $wb = New-Pasta $xl 'Tmp'
    $xl.Calculation = -4135   # manual durante a montagem (exige uma pasta aberta)

    # ---------- Cadastros ----------
    $cad = $wb.Worksheets.Item('Tmp')
    $cad.Name = 'Cadastros'
    $col = 1
    function Próxima-Tabela($nome, $titulo, $linhas) {
        $c = $cad.Cells.Item(1, $script:col)
        $c.Formula = $titulo
        $c.Font.Bold = $true
        try { $lo = Write-Tabela $cad ($c.Offset(1, 0).Address($false, $false)) $nome $linhas } catch { throw "tabela ${nome}: $_ | $($_.InvocationInfo.PositionMessage) | $($_.ScriptStackTrace)" }
        $script:col += $linhas[0].Count + 1
        return $lo
    }

    $loCam = Próxima-Tabela 'Tab_Configuracao' 'Configuração' @(
        ,@('parametro', 'valor', 'observacao')
        ,@('CaminhoRepo', '', 'raiz do repositório, derivada do caminho deste arquivo; lida pelo Power Query (pCaminhoRepo)')
    )
    $cCam = $loCam.DataBodyRange.Cells.Item(1, 2)
    $cCam.Formula2 = '=LEFT(CELL("filename",$A$1),FIND("MA2026-entrega-parcial",CELL("filename",$A$1))-1)'
    Set-NomeDefinido $wb 'CaminhoRepo' ("=Cadastros!" + $cCam.Address())

    [void](Próxima-Tabela 'Cad_DePara_Grupo' 'De-para de grupo (grafias confirmadas)' @(
        ,@('grafia_fonte', 'grupo', 'modalidade', 'observacao')
        ,@('GRUPO ESTRUTURAL', 'Estrutural', 'Ônibus', 'grafia oficial')
        ,@('GRUPO ARTICULAÇÃO', 'Local de Articulação Regional', 'Ônibus', 'grafia oficial')
        ,@('GRUPO ARTICULACAO', 'Local de Articulação Regional', 'Ônibus', 'sem acento (D8), confirmada pelo lote AR')
        ,@('GRUPO DE DISTRIBUIÇÃO', 'Local de Distribuição', 'Ônibus', 'grafia oficial')
        ,@('GRUPO DE DISTRIBUICAO', 'Local de Distribuição', 'Ônibus', 'sem acento (D8), confirmada pelo lote D')
        ,@('OUTRO PC', 'Outros', 'Ônibus', 'fora dos três grupos oficiais (D9): pendente de esclarecimento')
    ))

    $padrao = @(
        @('Data', 'data'), @('Grupo', 'grupo'), @('Lote', 'lote'), @('Empresa', 'empresa'), @('Linha', 'linha'),
        @('Passageiros Pagtes Em Dinheiro', 'pag_dinheiro'), @('Passageiros Comum e VT', 'pag_comum_vt'),
        @('Passageiros Comum E Vt', 'pag_comum_vt'), @('Passageiros Pgts Bu Comum M', 'pag_bu_comum_mensal'),
        @('Passageiros Pagtes Estudante', 'pag_estudante'), @('Passageiros Pgts Bu Est Mensal', 'pag_bu_est_mensal'),
        @('Passageiros Pgts Bu Vt Mensal', 'pag_bu_vt_mensal'), @('Passageiros Pagantes', 'pagantes'),
        @('Passageiros Int Ônibus->Ônibus', 'integracao_onibus'), @('Passageiros Int ÔNibus->ÔNibus', 'integracao_onibus'),
        @('Passageiros Com Gratuidade', 'gratuidade'), @('Passageiros Com Gratuidade Est', 'gratuidade_estudante'),
        @('Tot Passageiros Transportados', 'passageiros_total')
    )
    $linhasCol = @(,@('grafia_fonte', 'coluna_padrao'))
    foreach ($p in $padrao) { $linhasCol += ,@($p[0], $p[1]) }
    [void](Próxima-Tabela 'Cad_DePara_Coluna' 'De-para de colunas entre layouts (D4)' $linhasCol)

    $fer = @(
        @('2024-01-01', 'Confraternização Universal', 'nacional'), @('2024-01-25', 'Aniversário de São Paulo', 'municipal'),
        @('2024-02-12', 'Carnaval', 'ponto facultativo'), @('2024-02-13', 'Carnaval', 'ponto facultativo'),
        @('2024-03-29', 'Sexta-feira Santa', 'nacional'), @('2024-04-21', 'Tiradentes', 'nacional'),
        @('2024-05-01', 'Dia do Trabalho', 'nacional'), @('2024-05-30', 'Corpus Christi', 'ponto facultativo'),
        @('2024-07-09', 'Revolução Constitucionalista', 'estadual'), @('2024-09-07', 'Independência', 'nacional'),
        @('2024-10-12', 'Nossa Senhora Aparecida', 'nacional'), @('2024-11-02', 'Finados', 'nacional'),
        @('2024-11-15', 'Proclamação da República', 'nacional'), @('2024-11-20', 'Consciência Negra', 'nacional'),
        @('2024-12-25', 'Natal', 'nacional')
    )
    $linhasFer = @(,@('data', 'feriado', 'abrangencia'))
    foreach ($f in $fer) { $linhasFer += ,@(([datetime]$f[0]).ToOADate(), $f[1], $f[2]) }
    $loFer = Próxima-Tabela 'Cad_Feriados_2024' 'Feriados de 2024 (provisório até a BrasilAPI, Etapa 6)' $linhasFer
    $loFer.ListColumns.Item('data').DataBodyRange.NumberFormat = 'dd/mm/yyyy'

    $loPar = Próxima-Tabela 'Param_Limites' 'Parâmetros' @(
        ,@('parametro', 'valor', 'unidade', 'fonte')
        ,@('limite_max_passageiros_dia_linha', 30000, 'passageiros/dia', 'premissa: jan/2024 tem máximo de 33.411 e percentil 99,9 de 22.473; acima disso a linha é conferida')
    )
    Set-NomeDefinido $wb 'Param_Limite_Max' ("=Cadastros!" + $loPar.DataBodyRange.Cells.Item(1, 2).Address())

    [void](Próxima-Tabela 'Param_Pesos_Tipo_Dia' 'Pesos por tipo de dia (CPTM mensal → diário)' @(
        ,@('tipo_dia', 'peso', 'fonte')
        ,@('Útil', 1, 'premissa: referência')
        ,@('Sábado', 0.6, 'premissa até haver as razões MSA/MDU do Metrô (E2.4)')
        ,@('Domingo', 0.4, 'premissa até haver as razões MDO/MDU do Metrô (E2.4)')
        ,@('Feriado', 0.4, 'premissa: feriado conta como domingo')
    ))

    $listas = [ordered]@{
        'Lista_Grupo'         = @('grupo', 'Estrutural', 'Local de Articulação Regional', 'Local de Distribuição', 'Outros')
        'Lista_Modalidade'    = @('modalidade', 'Ônibus', 'Metrô', 'Trem')
        'Lista_Tipo_Dia'      = @('tipo_dia', 'Útil', 'Sábado', 'Domingo', 'Feriado')
        'Lista_Tipo_Problema' = @('tipo_problema', 'Vazio ou zero', 'Empresa como código', 'Grupo fora dos oficiais', 'Grupo não cadastrado', 'Acima do limite', 'Data inválida')
        'Lista_Situacao'      = @('situacao', 'Tratar na Etapa 2', 'Pendente de esclarecimento', 'Aceito como está')
    }
    foreach ($k in $listas.Keys) {
        $v = $listas[$k]
        $linhas = @(,@($v[0]))
        for ($i = 1; $i -lt $v.Count; $i++) { $linhas += ,@($v[$i]) }
        $lo = Próxima-Tabela ($k -replace '^Lista_', 'Tab_') "Valores válidos: $($v[0])" $linhas
        Set-NomeDefinido $wb $k ("=" + $lo.Name + "[" + $v[0] + "]")
    }
    # Validação em lista na própria coluna de destino dos de-para.
    $wb.Worksheets.Item('Cadastros').ListObjects.Item('Cad_DePara_Grupo').ListColumns.Item('grupo').DataBodyRange.Validation.Add(3, 1, 1, '=Lista_Grupo')
    $wb.Worksheets.Item('Cadastros').ListObjects.Item('Cad_DePara_Grupo').ListColumns.Item('modalidade').DataBodyRange.Validation.Add(3, 1, 1, '=Lista_Modalidade')
    $cad.Columns.AutoFit() | Out-Null
    Log 'Cadastros prontos'

    # ---------- Bruto: cópia fiel por Mover ou Copiar ----------
    $src = $xl.Workbooks.Open($tmp, 0, $true)
    $src.Worksheets.Item(1).Copy($wb.Worksheets.Item(1), [Type]::Missing)
    $src.Close($false)
    $bruto = $wb.Worksheets.Item(1)
    $bruto.Name = 'Bruto'
    $bruto.Visible = -1   # no arquivo original a aba vem oculta (D16); o conteúdo não muda
    $ultima = $bruto.UsedRange.Row + $bruto.UsedRange.Rows.Count - 1
    $linCab = 3
    Log "Bruto copiado: linhas 1..$ultima (cabeçalho na linha $linCab)"

    # ---------- Tratado ----------
    $trat = Add-Aba $wb 'Tratado'
    $trat.Move([Type]::Missing, $bruto)
    $nl = $ultima - $linCab
    $orig = $bruto.Range($bruto.Cells.Item($linCab + 1, 1), $bruto.Cells.Item($ultima, 16)).Value2
    $cabs = $bruto.Range($bruto.Cells.Item($linCab, 1), $bruto.Cells.Item($linCab, 16)).Value2
    $arr = New-Object 'object[,]' ($nl + 1), 17
    $arr[0, 0] = 'Linha_Origem'
    for ($j = 1; $j -le 16; $j++) { $arr[0, $j] = $cabs[1, $j] }
    for ($i = 1; $i -le $nl; $i++) {
        $arr[$i, 0] = $linCab + $i      # valor fixo: a linha da aba Bruto (nunca =LIN())
        for ($j = 1; $j -le 16; $j++) { $arr[$i, $j] = $orig[$i, $j] }
    }
    $rng = $trat.Range('A1').Resize($nl + 1, 17)
    $rng.NumberFormat = '@'          # texto: preserva os valores originais como vieram (datas em texto, D6)
    $trat.Range('G2').Resize($nl, 11).NumberFormat = 'General'
    $trat.Range('A2').Resize($nl, 1).NumberFormat = 'General'
    Set-Valores $rng $arr
    $lo = $trat.ListObjects.Add(1, $rng, $null, 1)
    $lo.Name = 'Tab_Transporte'
    $lo.TableStyle = 'TableStyleLight1'
    Log ("Tab_Transporte com $nl linhas; colunas: " + ((@($lo.ListColumns) | ForEach-Object { $_.Name }) -join ' | '))

    $tot = '[@[Tot Passageiros Transportados]]'
    $calc = [ordered]@{
        'Data_Trat'            = '=LET(d,[@[Data]],IF(ISNUMBER(d),d,IFERROR(LET(p,--TEXTSPLIT(TRIM(d),"/"),dt,DATE(INDEX(p,3),INDEX(p,2),INDEX(p,1)),IF(AND(DAY(dt)=INDEX(p,1),MONTH(dt)=INDEX(p,2)),dt,"Data inválida")),"Data inválida")))'
        'Mes'                  = '=IF(ISNUMBER([@[Data_Trat]]),MONTH([@[Data_Trat]]),"")'
        'Dia_Semana'           = '=IF(ISNUMBER([@[Data_Trat]]),CHOOSE(WEEKDAY([@[Data_Trat]]),"Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"),"")'
        'Tipo_Dia'             = '=IF(NOT(ISNUMBER([@[Data_Trat]])),"",IF(ISNUMBER(XMATCH([@[Data_Trat]],Cad_Feriados_2024[[data]])),"Feriado",CHOOSE(WEEKDAY([@[Data_Trat]],2),"Útil","Útil","Útil","Útil","Útil","Sábado","Domingo")))'
        'Grupo_Trat'           = '=XLOOKUP(TRIM([@[Grupo]]),Cad_DePara_Grupo[[grafia_fonte]],Cad_DePara_Grupo[[grupo]],"Não cadastrado")'
        'Codigo_Linha_Trat'    = '=LET(c,TRIM(TEXTBEFORE([@[Linha]]," - ",,,,[@[Linha]])),IF(AND(LEN(c)>2,ISNUMBER(--RIGHT(c,2))),LEFT(c,LEN(c)-2)&"-"&RIGHT(c,2),c))'
        'Nome_Linha_Trat'      = '=PROPER(TRIM(TEXTAFTER([@[Linha]]," - ",,,,"")))'
        'Status_Vazio_Zero'    = "=IF(OR($tot=`"`",$tot=0),`"Vazio ou zero`",`"OK`")"
        'Status_Empresa'       = '=IF(ISNUMBER(--TRIM([@[Empresa]])),"Empresa como código","OK")'
        'Status_Grupo'         = '=IF([@[Grupo_Trat]]="Não cadastrado","Grupo não cadastrado",IF([@[Grupo_Trat]]="Outros","Grupo fora dos oficiais","OK"))'
        'Status_Fora_Limite'   = "=IF(N($tot)>Param_Limite_Max,`"Acima do limite`",`"OK`")"
        'Status_Data'          = '=IF([@[Data_Trat]]="Data inválida","Data inválida","OK")'
        'Problemas'            = '=LET(t,TEXTJOIN("; ",TRUE,IF([@[Status_Vazio_Zero]]="OK","",[@[Status_Vazio_Zero]]),IF([@[Status_Empresa]]="OK","",[@[Status_Empresa]]),IF([@[Status_Grupo]]="OK","",[@[Status_Grupo]]),IF([@[Status_Fora_Limite]]="OK","",[@[Status_Fora_Limite]]),IF([@[Status_Data]]="OK","",[@[Status_Data]])),IF(t="","Sem problemas",t))'
    }
    foreach ($nome in $calc.Keys) {
        $c = $lo.ListColumns.Add()
        $c.Range.Cells.Item(1, 1).Formula = $nome   # .Name = texto falha em silêncio pelo binder COM
        $c.DataBodyRange.NumberFormat = 'General'
        try { $c.DataBodyRange.Cells.Item(1, 1).Formula2 = $calc[$nome] } catch { ((@($lo.ListColumns) | ForEach-Object { $_.Name }) -join "`n") + "`nf=" + $calc[$nome] | Set-Content "$env:TEMP\cheiU_dbg.txt" -Encoding UTF8; throw ("coluna ${nome}: $_ | colunas: " + ((@($lo.ListColumns) | ForEach-Object { $_.Name }) -join ","  ) + " | f=" + $calc[$nome]) }
    }
    $lo.ListColumns.Item('Data_Trat').DataBodyRange.NumberFormat = 'dd/mm/yyyy'
    $xl.Calculate()
    Log 'Colunas calculadas'

    # Formatação condicional
    $dTot = $lo.ListColumns.Item('Tot Passageiros Transportados').DataBodyRange
    $a = $dTot.Cells.Item(1, 1).Address($false, $false)
    $fc = $dTot.FormatConditions.Add(2, 0, "=OR($a=`"`",$a=0)"); $fc.Interior.Color = 0x9999FF        # vazio/zero: vermelho
    $fc = $dTot.FormatConditions.Add(1, 5, '=Param_Limite_Max'); $fc.Interior.Color = 0x66CCFF          # acima do limite: laranja
    $dProb = $lo.ListColumns.Item('Problemas').DataBodyRange
    $a = $dProb.Cells.Item(1, 1).Address($false, $false)
    $fc = $dProb.FormatConditions.Add(2, 0, "=$a<>`"Sem problemas`""); $fc.Interior.Color = 0x99FFFF   # linha com problema: amarelo
    $trat.Range('A1').CurrentRegion.Columns.AutoFit() | Out-Null
    $trat.Activate(); $xl.ActiveWindow.SplitRow = 1; $xl.ActiveWindow.FreezePanes = $true

    # ---------- Auditoria ----------
    $aud = Add-Aba $wb 'Auditoria'
    $statusCols = @('Status_Vazio_Zero', 'Status_Empresa', 'Status_Grupo', 'Status_Fora_Limite', 'Status_Data')
    $campo = @{ 'Status_Vazio_Zero' = 'Tot Passageiros Transportados'; 'Status_Empresa' = 'Empresa'; 'Status_Grupo' = 'Grupo'; 'Status_Fora_Limite' = 'Tot Passageiros Transportados'; 'Status_Data' = 'Data' }
    $acao = @{
        'Vazio ou zero'           = @('Manter: linha sem passageiros no dia é plausível; a Etapa 2 mantém o registro com 0', 'Aceito como está')
        'Empresa como código'     = @('Confirmar com a SPTrans o nome da operadora do código; a empresa não entra no modelo', 'Pendente de esclarecimento')
        'Grupo fora dos oficiais' = @('Confirmar a que grupo pertence "OUTRO PC"; até lá, grupo "Outros" na Etapa 2', 'Pendente de esclarecimento')
        'Grupo não cadastrado'    = @('Incluir a grafia em Cad_DePara_Grupo depois de confirmada', 'Pendente de esclarecimento')
        'Acima do limite'         = @('Conferir com a média da linha no mês; valor mantido', 'Pendente de esclarecimento')
        'Data inválida'           = @('Corrigir na origem ou rejeitar na Etapa 2', 'Tratar na Etapa 2')
    }
    $vals = @{}
    foreach ($s in $statusCols + @('Linha_Origem', 'Data', 'Codigo_Linha_Trat', 'Empresa', 'Grupo', 'Tot Passageiros Transportados')) {
        $vals[$s] = $lo.ListColumns.Item($s).DataBodyRange.Value2
    }
    $reg = @(,@('Linha_Origem', 'Chave', 'Campo', 'Valor_Encontrado', 'Tipo_Problema', 'Acao_Necessaria', 'Situacao', 'Observacao'))
    for ($i = 1; $i -le $nl; $i++) {
        foreach ($s in $statusCols) {
            $t = $vals[$s][$i, 1]
            if ($t -ne 'OK') {
                $cp = $campo[$s]
                $reg += ,@($vals['Linha_Origem'][$i, 1], ("{0}|{1}" -f $vals['Data'][$i, 1], $vals['Codigo_Linha_Trat'][$i, 1]), $cp, [string]$vals[$cp][$i, 1], $t, $acao[$t][0], $acao[$t][1], 'registrado pelo script montar_etapa1.ps1 a partir das colunas Status_*')
            }
        }
    }
    $aud.Range('A1').Formula = 'Registro de problemas (Tab_Auditoria)'; $aud.Range('A1').Font.Bold = $true
    $loA = Write-Tabela $aud 'A2' 'Tab_Auditoria' $reg
    $loA.ListColumns.Item('Tipo_Problema').DataBodyRange.Validation.Add(3, 1, 1, '=Lista_Tipo_Problema')
    $loA.ListColumns.Item('Situacao').DataBodyRange.Validation.Add(3, 1, 1, '=Lista_Situacao')
    Log "Tab_Auditoria com $($reg.Count - 1) registros"

    # Painel Tipo × Detectado × Registrado × Diferença
    $tipos = $listas['Lista_Tipo_Problema'] | Select-Object -Skip 1
    $statusDoTipo = @{ 'Vazio ou zero' = 'Status_Vazio_Zero'; 'Empresa como código' = 'Status_Empresa'; 'Grupo fora dos oficiais' = 'Status_Grupo'; 'Grupo não cadastrado' = 'Status_Grupo'; 'Acima do limite' = 'Status_Fora_Limite'; 'Data inválida' = 'Status_Data' }
    $painel = @(,@('Tipo_Problema', 'Detectado', 'Registrado', 'Diferenca'))
    foreach ($t in $tipos) { $painel += ,@($t, 0, 0, 0) }
    $painel += ,@('Total', 0, 0, 0)
    $aud.Range('K1').Formula = 'Painel de conferência'; $aud.Range('K1').Font.Bold = $true
    $loP = Write-Tabela $aud 'K2' 'Tab_Painel' $painel 'TableStyleMedium2'
    for ($i = 1; $i -le $tipos.Count; $i++) {
        $t = $tipos[$i - 1]
        $loP.DataBodyRange.Cells.Item($i, 2).Formula2 = "=COUNTIF(Tab_Transporte[$($statusDoTipo[$t])],`"$t`")"
        $loP.DataBodyRange.Cells.Item($i, 3).Formula2 = "=COUNTIFS(Tab_Auditoria[[Tipo_Problema]],`"$t`")"
        $loP.DataBodyRange.Cells.Item($i, 4).Formula2 = '=[@[Detectado]]-[@[Registrado]]'
    }
    $n = $tipos.Count + 1
    $loP.DataBodyRange.Cells.Item($n, 2).Formula2 = "=SUM(L3:L$($n + 1))"
    $loP.DataBodyRange.Cells.Item($n, 3).Formula2 = "=SUM(M3:M$($n + 1))"
    $loP.DataBodyRange.Cells.Item($n, 4).Formula2 = '=[@[Detectado]]-[@[Registrado]]'
    $r0 = $n + 4
    $aud.Cells.Item($r0, 11).Formula = 'Erros de fórmula em Tab_Transporte'
    $aud.Cells.Item($r0, 12).Formula2 = '=SUMPRODUCT(--ISERROR(Tab_Transporte))'
    $aud.Cells.Item($r0 + 1, 11).Formula = 'Linhas no Bruto (dados) × Tab_Transporte'
    $aud.Cells.Item($r0 + 1, 12).Formula2 = "=COUNTA(Bruto!A$($linCab + 1):A$ultima)-ROWS(Tab_Transporte)"
    $aud.Cells.Item($r0 + 2, 11).Formula = 'Soma do total: Bruto − Tab_Transporte'
    $aud.Cells.Item($r0 + 2, 12).Formula2 = "=SUM(Bruto!P$($linCab + 1):P$ultima)-SUM(Tab_Transporte[Tot Passageiros Transportados])"
    $aud.Cells.Item($r0 + 3, 11).Formula = 'Originais diferentes do Bruto (células)'
    $aud.Cells.Item($r0 + 3, 12).Formula2 = "=SUMPRODUCT(--(Bruto!A$($linCab + 1):P$ultima<>Tab_Transporte[[Data]:[Tot Passageiros Transportados]]))"
    $aud.Cells.Item($r0 + 4, 11).Formula = 'Linhas sem problemas'
    $aud.Cells.Item($r0 + 4, 12).Formula2 = '=COUNTIF(Tab_Transporte[[Problemas]],"Sem problemas")'
    $fd = $loP.ListColumns.Item('Diferenca').DataBodyRange
    $fc = $fd.FormatConditions.Add(1, 4, '=0'); $fc.Interior.Color = 0x9999FF
    $aud.Columns.AutoFit() | Out-Null

    $wb.Worksheets.Item('Bruto').Move($wb.Worksheets.Item(1))
    $wb.Worksheets.Item('Tratado').Move([Type]::Missing, $wb.Worksheets.Item('Bruto'))
    $wb.Worksheets.Item('Cadastros').Move([Type]::Missing, $wb.Worksheets.Item('Tratado'))
    $wb.Worksheets.Item('Auditoria').Move([Type]::Missing, $wb.Worksheets.Item('Cadastros'))
    $xl.Calculation = -4105   # automático
    $xl.CalculateFull()
    Save-Pasta $wb $saida
    $xl.CalculateFull()

    Log ("abas: " + ((@($wb.Worksheets) | ForEach-Object { $_.Name }) -join ', '))
    Log "CaminhoRepo = $($cCam.Text)"
    for ($i = 1; $i -le $n; $i++) {
        $r = $loP.DataBodyRange.Rows.Item($i)
        Log ("painel {0}: detectado {1}, registrado {2}, diferença {3}" -f $r.Cells.Item(1, 1).Text, $r.Cells.Item(1, 2).Value2, $r.Cells.Item(1, 3).Value2, $r.Cells.Item(1, 4).Value2)
    }
    for ($k = 0; $k -le 4; $k++) { Log ("{0}: {1}" -f $aud.Cells.Item($r0 + $k, 11).Text, $aud.Cells.Item($r0 + $k, 12).Value2) }
    $wb.Save()
    $wb.Close($false)
} finally {
    Stop-ExcelCom $xl
    Remove-Item $tmp -ErrorAction SilentlyContinue
}
