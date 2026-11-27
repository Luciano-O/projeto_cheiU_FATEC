// stg_sptrans_complemento
// Linhas de ônibus que faltam no diário de 08/07/2024 (D24): o valor do dia é a diferença entre o consolidado
// de julho (2ª versão) e a soma dos diários da linha. origem_dado = estimado (decisão 0014).
let
    Fonte = Table.SelectRows(Conf_Complemento_Jul, each [complementada]),
    Data = Table.AddColumn(Fonte, "data", each #date(2024, 7, 8), type date),
    Final = Table.SelectColumns(Table.RenameColumns(Data, {{"linha", "codigo_linha"}, {"diferenca", "passageiros"},
        {"dif_pagantes", "pagantes"}, {"dif_integracao", "integracao"}, {"dif_gratuidades", "gratuidades"}}),
        {"data", "codigo_linha", "passageiros", "pagantes", "integracao", "gratuidades"})
in
    Final
