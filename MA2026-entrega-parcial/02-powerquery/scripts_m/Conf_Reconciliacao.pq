// Conf_Reconciliacao
// Lidas − aceitas − rejeitadas = 0 por fonte, e a soma de passageiros aceitos = soma no fato.
let
    Linhas = stg_sptrans_linhas,
    Lidas = Table.RowCount(Linhas),
    Aceitas = Table.RowCount(Table.SelectRows(Linhas, each [motivo] = null)),
    Rejeitadas = Table.RowCount(Rejeitados),
    SomaAceitas = List.Sum(Table.SelectRows(Linhas, each [motivo] = null)[passageiros_total]),
    SomaFato = List.Sum(Fato_Transporte[passageiros]),
    Tabela = #table(
        type table [fonte = text, linhas_lidas = Int64.Type, linhas_aceitas = Int64.Type, linhas_rejeitadas = Int64.Type, diferenca_linhas = Int64.Type,
            linhas_no_fato = Int64.Type, passageiros_aceitos = number, passageiros_no_fato = number, diferenca_passageiros = number],
        {{"SPTrans diário", Lidas, Aceitas, Rejeitadas, Lidas - Aceitas - Rejeitadas, Table.RowCount(Fato_Transporte), SomaAceitas, SomaFato, SomaAceitas - SomaFato}})
in
    Tabela
