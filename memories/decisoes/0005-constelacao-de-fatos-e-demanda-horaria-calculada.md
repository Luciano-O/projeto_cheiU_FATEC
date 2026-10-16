# Constelação de fatos com demanda por hora calculada em medida

As fontes têm grãos diferentes (dia × linha, mês × estação, viagem individual), então uma tabela fato única misturaria granularidades. O modelo usa uma constelação:

| Tabela | Grão |
|---|---|
| `Fato_Transporte` (principal) | dia × linha × modalidade |
| `Fato_Perfil_Horario` | hora × modalidade × tipo de dia |
| `Fato_Viagem_OD` | hora de saída × cadeia modal × região de origem × região de destino |
| `Fato_Oferta` | hora × linha × tipo de dia |
| `Fato_Clima_Horario` | data × hora |

As dimensões, compartilhadas, são `Dim_Calendario`, `Dim_Horario`, `Dim_Transporte`, `Dim_Localizacao` e `Dim_Cadeia_Modal`.

A demanda estimada por hora e a lotação são **medidas** (DAX e views SQL), calculadas no momento da consulta. Gravá-las em tabela daria ~12 milhões de linhas (366 dias × 24 h × ~1.350 linhas), pesado demais para o modelo de dados do Excel.

Cada fonte mede uma coisa diferente — SPTrans *transportados*, Metrô *entradas*, CPTM *embarcados* (ver glossário) — e `Fato_Transporte` guarda isso na coluna `tipo_metrica`.
