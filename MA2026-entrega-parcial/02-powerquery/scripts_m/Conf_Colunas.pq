// Conf_Colunas
// Colunas dos arquivos sem de-para em Cad_DePara_Coluna (esperado: vazia).
let
    Nomes = Table.ColumnNames(stg_SPTrans_Bruto),
    SemDePara = List.Select(Nomes, each Text.StartsWith(_, "?")),
    Tabela = Table.FromList(SemDePara, (c) => {Text.Middle(c, 1)}, type table [coluna_sem_de_para = text])
in
    Tabela
