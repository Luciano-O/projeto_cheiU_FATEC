// Rejeitados
// Toda linha lida que não entrou no fato, com o motivo e os valores originais.
let
    Fonte = Table.SelectRows(stg_sptrans_linhas, each [motivo] <> null),
    Fonte2 = Table.AddColumn(Fonte, "fonte", each "SPTrans diário", type text),
    Original = Table.AddColumn(Fonte2, "valor_original", each Text.Combine(List.Transform({[grupo], [lote], [empresa], [linha], [passageiros_total]}, each Text.From(_) ?? ""), " | "), type text),
    Colunas = {"fonte", "arquivo", "linha_origem", "motivo", "data", "valor_original"},
    FinalOni = Table.SelectColumns(Original, Colunas),
    Cptm = Table.SelectRows(stg_cptm_linhas, each [motivo] <> null),
    FonteCptm = Table.AddColumn(Cptm, "fonte", each "CPTM embarcados", type text),
    DataCptm = Table.AddColumn(FonteCptm, "data", each [mes_inicio], type nullable date),
    OrigCptm = Table.AddColumn(DataCptm, "valor_original", each Text.Combine(List.Transform({[linha_fonte], [texto_b], [entradas]}, each Text.From(_) ?? ""), " | "), type text),
    FinalCptm = Table.SelectColumns(OrigCptm, Colunas),
    Uniao = Table.Combine({FinalOni, FinalCptm})
in
    Uniao
