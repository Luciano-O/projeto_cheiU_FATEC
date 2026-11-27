// Conf_Reconciliacao
// Por fonte: lidas − aceitas − rejeitadas = 0, e a soma de passageiros aceitos = soma no fato.
// SPTrans complemento: as linhas do consolidado de julho complementadas em 08/07 (Conf_Complemento_Jul).
// CPTM: as linhas lidas são as de estação (as de título, cabeçalho, subtotal e rodapé estão em Conf_Etapas);
// a soma aceita é a mensal por estação, e a do fato é a estimativa diária (decisão 0012).
let
    Linhas = stg_sptrans_linhas,
    AceitasOni = Table.SelectRows(Linhas, each [motivo] = null),
    FatoOni = Table.SelectRows(Fato_Transporte, each [modalidade] = "Ônibus" and [origem_dado] = "real"),
    // Complemento de 08/07/2024 (D24): linhas do consolidado de julho que faltavam no diário.
    Complemento = Table.SelectRows(Conf_Complemento_Jul, each [complementada]),
    FatoComp = Table.SelectRows(Fato_Transporte, each [modalidade] = "Ônibus" and [origem_dado] = "estimado"),
    EstacoesCptm = Table.SelectRows(stg_cptm_linhas, each [tipo_registro] = "estacao"),
    AceitasCptm = Table.SelectRows(EstacoesCptm, each [motivo] = null),
    FatoTrem = Table.SelectRows(Fato_Transporte, each [modalidade] = "Trem"),
    RejeitadasDe = (f as text) => Table.RowCount(Table.SelectRows(Rejeitados, each [fonte] = f)),
    Linha = (fonte as text, lidas as number, aceitas as number, rejeitadas as number, fato as table, somaAceitas as number) =>
        {fonte, lidas, aceitas, rejeitadas, lidas - aceitas - rejeitadas, Table.RowCount(fato), somaAceitas, List.Sum(fato[passageiros]), somaAceitas - List.Sum(fato[passageiros])},
    Tabela = #table(
        type table [fonte = text, linhas_lidas = Int64.Type, linhas_aceitas = Int64.Type, linhas_rejeitadas = Int64.Type, diferenca_linhas = Int64.Type,
            linhas_no_fato = Int64.Type, passageiros_aceitos = number, passageiros_no_fato = number, diferenca_passageiros = number],
        {Linha("SPTrans diário", Table.RowCount(Linhas), Table.RowCount(AceitasOni), RejeitadasDe("SPTrans diário"), FatoOni, List.Sum(AceitasOni[passageiros_total])),
         Linha("SPTrans complemento 08/07", Table.RowCount(Complemento), Table.RowCount(Complemento), 0, FatoComp, List.Sum(Complemento[diferenca])),
         Linha("CPTM embarcados", Table.RowCount(EstacoesCptm), Table.RowCount(AceitasCptm), RejeitadasDe("CPTM embarcados"), FatoTrem, List.Sum(AceitasCptm[entradas]))})
in
    Tabela
