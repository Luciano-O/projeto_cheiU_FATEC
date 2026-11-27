// stg_cptm_mensal_linha
// Total mensal de cada linha da CPTM = soma das estações aceitas.
let
    Fonte = stg_cptm_mensal_estacao,
    Grupo = Table.Group(Fonte, {"mes_inicio", "id_linha"}, {
        {"entradas", each List.Sum([entradas]), Int64.Type},
        {"estacoes", each Table.RowCount(_), Int64.Type}})
in
    Grupo
