// Fato_Referencia_Mensal
// O "esperado" do projeto (papel do fMetas no CaféData): total mensal publicado pela SPTrans por grupo, ligado por mes_inicio.
let
    Fonte = stg_sptrans_referencia,
    Origem = Table.AddColumn(Fonte, "origem_dado", each "real", type text),
    Fonte2 = Table.AddColumn(Origem, "fonte", each "SPTrans - totais mensais publicados", type text),
    Tipos = Table.TransformColumnTypes(Fonte2, {{"mes_inicio", type date}, {"passageiros_publicado", Int64.Type}})
in
    Tipos
