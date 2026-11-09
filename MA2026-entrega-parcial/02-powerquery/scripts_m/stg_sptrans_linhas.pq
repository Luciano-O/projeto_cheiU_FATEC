// stg_sptrans_linhas
// Uma linha por registro lido, já tipado, com o motivo de rejeição (null = aceita).
let
    Fonte = stg_SPTrans_Bruto,
    Numericas = {"pag_dinheiro", "pag_comum_vt", "pag_bu_comum_mensal", "pag_estudante", "pag_bu_est_mensal",
        "pag_bu_vt_mensal", "pagantes", "integracao_onibus", "gratuidade", "gratuidade_estudante", "passageiros_total"},
    Campos = {"data", "grupo", "lote", "empresa", "linha"} & Numericas,
    Vazia = Table.AddColumn(Fonte, "vazia", each List.IsEmpty(List.Select(Record.FieldValues(Record.SelectFields(_, Campos, MissingField.UseNull)), each _ <> null and Text.Trim(Text.From(_)) <> "")), type logical),
    // D6: Data como data (.xlsx), número serial (.xls de dezembro) ou texto dd/mm/aaaa (demais .xls)
    DataTipada = Table.AddColumn(Vazia, "data_t", each
        let v = [data],
            t = Text.Trim(Text.From(v ?? "")),
            br = try Date.FromText(t, [Format = "dd/MM/yyyy", Culture = "pt-BR"]) otherwise null,
            us = try Date.FromText(t, [Format = "M/d/yyyy", Culture = "en-US"]) otherwise null
        in
        if v is date then v
        else if v is datetime then Date.From(v)
        else if v is number then Date.From(v)
        else if br <> null and (br = [data_referencia] or [data_referencia] = null) then br
        else if us <> null and us = [data_referencia] then us
        else br, type nullable date),
    NumTipados = Table.TransformColumns(DataTipada, List.Transform(Numericas, (c) => {c, each try Number.From(_, "pt-BR") otherwise null, type nullable number})),
    // D7: código e nome na mesma célula; código no formato do letreiro (917M10 -> 917M-10)
    Codigo = Table.AddColumn(NumTipados, "codigo_linha", each
        let t = Text.Trim(Text.From([linha] ?? "")),
            c = Text.Trim(Text.BeforeDelimiter(t, " - ")),
            fim = Text.End(c, 2)
        in if c = "" then null
           else if Text.Length(c) > 2 and List.AllTrue(List.Transform(Text.ToList(fim), each Text.Contains("0123456789", _)))
           then Text.Start(c, Text.Length(c) - 2) & "-" & fim else c, type nullable text),
    Nome = Table.AddColumn(Codigo, "nome_linha", each Text.Proper(Text.Trim(Text.AfterDelimiter(Text.From([linha] ?? ""), " - "))), type text),
    // D8/D9: grupo pelo de-para da Etapa 1
    GrupoChave = Table.AddColumn(Nome, "grupo_chave", each Text.Upper(Text.Trim(Text.From([grupo] ?? ""))), type text),
    Mescla = Table.NestedJoin(GrupoChave, {"grupo_chave"}, cad_DePara_Grupo, {"grafia_fonte"}, "dp", JoinKind.LeftOuter),
    Grupo = Table.ExpandTableColumn(Mescla, "dp", {"grupo", "modalidade"}, {"grupo_padrao", "modalidade"}),
    // Arquivo duplicado: a mesma data em mais de um arquivo; vale o de menor nome
    PorData = Table.Group(Table.SelectRows(Grupo, each [data_t] <> null), {"data_t"}, {{"arquivo_valido", each List.Min([arquivo]), type text}}),
    ComValido = Table.NestedJoin(Grupo, {"data_t"}, PorData, {"data_t"}, "pd", JoinKind.LeftOuter),
    Valido = Table.ExpandTableColumn(ComValido, "pd", {"arquivo_valido"}),
    Motivo = Table.AddColumn(Valido, "motivo", each
        if [vazia] then "Linha vazia"
        else if [data_t] = null then "Data inválida"
        else if [data_referencia] <> null and [data_t] <> [data_referencia] then "Data diferente da data de referência do arquivo"
        else if [arquivo] <> [arquivo_valido] then "Arquivo duplicado (data já lida em outro arquivo)"
        else if [codigo_linha] = null then "Linha sem código"
        else if [grupo_padrao] = null then "Grupo não cadastrado"
        else if [passageiros_total] = null then "Total não numérico"
        else null, type nullable text),
    Final = Table.SelectColumns(Motivo, {"arquivo", "linha_origem", "linhas_titulo", "data_referencia", "data_t", "grupo", "grupo_padrao", "modalidade", "lote", "empresa", "linha", "codigo_linha", "nome_linha"} & Numericas & {"motivo"}),
    Renomeado = Table.RenameColumns(Final, {{"data_t", "data"}}),
    Buffer = Table.Buffer(Renomeado)
in
    Buffer
