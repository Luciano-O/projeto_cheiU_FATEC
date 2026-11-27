// stg_cptm_mensal_estacao
// Embarcados aceitos no grão mês × linha × estação (real). entradas = "Total Entradas", que fecha com a
// soma das quatro tarifas; total_coluna_h fica só para conferência (D22).
let
    Fonte = Table.SelectRows(stg_cptm_linhas, each [tipo_registro] = "estacao" and [motivo] = null),
    ComLinha = Table.NestedJoin(Fonte, {"id_linha"}, cad_Linha_Trilho, {"id_linha"}, "l", JoinKind.LeftOuter),
    Exp = Table.ExpandTableColumn(ComLinha, "l", {"codigo_linha"}),
    Origem = Table.AddColumn(Exp, "origem_dado", each "real", type text),
    Final = Table.SelectColumns(Origem, {"mes_inicio", "id_linha", "codigo_linha", "estacao", "grat_sbe", "pagantes", "transferencias",
        "nao_tarifados", "entradas", "total_coluna_h", "origem_dado", "arquivo", "linha_origem"}),
    Tipos = Table.TransformColumnTypes(Final, {{"mes_inicio", type date}, {"grat_sbe", Int64.Type}, {"pagantes", Int64.Type},
        {"transferencias", Int64.Type}, {"nao_tarifados", Int64.Type}, {"entradas", Int64.Type}, {"total_coluna_h", Int64.Type}}),
    Ordenado = Table.Sort(Tipos, {{"mes_inicio", Order.Ascending}, {"id_linha", Order.Ascending}, {"linha_origem", Order.Ascending}})
in
    Ordenado
