// cad_Etapa1
// Todas as tabelas (ListObjects) do arquivo da Etapa 1. Os cadastros são lidos daqui, nunca redigitados.
let
    Fonte = Excel.Workbook(File.Contents(pArquivoEtapa1), null, true),
    Tabelas = Table.SelectRows(Fonte, each [Kind] = "Table")
in
    Tabelas
