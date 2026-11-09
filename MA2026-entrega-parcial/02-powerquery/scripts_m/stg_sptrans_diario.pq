// stg_sptrans_diario
// Registros aceitos agregados no grão data × linha (D11: uma linha por empresa ou lote no mesmo dia).
let
    Fonte = Table.SelectRows(stg_sptrans_linhas, each [motivo] = null),
    Grupo = Table.Group(Fonte, {"data", "codigo_linha"}, {
        {"nome_linha", each List.Max([nome_linha]), type text},
        {"grupo", each List.Max([grupo_padrao]), type text},
        {"lote", each Text.From(List.Max(List.Transform([lote], Text.From))), type text},
        {"passageiros", each List.Sum([passageiros_total]), type number},
        {"pagantes", each List.Sum([pagantes]), type number},
        {"integracao", each List.Sum([integracao_onibus]), type number},
        {"gratuidades", each List.Sum([gratuidade]) + List.Sum([gratuidade_estudante]), type number},
        {"registros_origem", each Table.RowCount(_), Int64.Type}})
in
    Grupo
