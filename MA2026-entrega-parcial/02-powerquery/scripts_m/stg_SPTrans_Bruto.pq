// stg_SPTrans_Bruto
// Todos os arquivos diários da pasta, lidos pela fnLerSPTrans e empilhados. A pasta só pode ter os diários.
// D17: alguns .xls antigos abrem vazios no Power Query; para eles vale a cópia .xlsx de diario_convertido
// (gerada por converter_xls_legado.py, valor por valor).
let
    Fonte = Folder.Files(pPastaSPTrans),
    Planilhas = Table.SelectRows(Fonte, each List.Contains({".xls", ".xlsx"}, Text.Lower([Extension]))),
    Legivel = Table.AddColumn(Planilhas, "conteudo_lido", each
        if Table.IsEmpty(Excel.Workbook([Content], null, true))
        then File.Contents(pPastaSPTransConvertido & [Name] & "x")
        else [Content]),
    Origem = Table.AddColumn(Legivel, "lido_da_copia", each Table.IsEmpty(Excel.Workbook([Content], null, true)), type logical),
    Lidos = Table.AddColumn(Origem, "Tabela", each Table.AddColumn(fnLerSPTrans([conteudo_lido], [Name]), "lido_da_copia", (r) => [lido_da_copia], type logical)),
    Pilha = Table.Combine(Lidos[Tabela])
in
    Pilha
