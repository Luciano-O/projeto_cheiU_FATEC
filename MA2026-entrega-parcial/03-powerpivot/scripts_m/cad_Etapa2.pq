// cad_Etapa2
// Tabelas de saída da Etapa 2. Esta etapa não limpa nada: só lê o arquivo anterior.
let
    Fonte = Excel.Workbook(File.Contents(pArquivoEtapa2), null, true),
    Tabelas = Table.SelectRows(Fonte, each [Kind] = "Table")
in
    Tabelas
