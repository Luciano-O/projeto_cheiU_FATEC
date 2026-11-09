// Rejeitados
// Toda linha lida que não entrou no fato, com o motivo e os valores originais.
let
    Fonte = Table.SelectRows(stg_sptrans_linhas, each [motivo] <> null),
    Fonte2 = Table.AddColumn(Fonte, "fonte", each "SPTrans diário", type text),
    Original = Table.AddColumn(Fonte2, "valor_original", each Text.Combine(List.Transform({[grupo], [lote], [empresa], [linha], [passageiros_total]}, each Text.From(_) ?? ""), " | "), type text),
    Final = Table.SelectColumns(Original, {"fonte", "arquivo", "linha_origem", "motivo", "data", "valor_original"})
in
    Final
