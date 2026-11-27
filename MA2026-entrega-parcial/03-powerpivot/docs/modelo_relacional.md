# Modelo relacional — Etapa 3

Modelo de Dados de `cheiU_03_PowerPivot.xlsx`. Todas as tabelas vêm de `cheiU_02_PowerQuery.xlsx` por `cad_Etapa2`, sem limpeza; só `Dim_Calendario` é gerada aqui. Estrela com duas fatos (constelação), como na decisão 0005, no recorte da N1 (decisão 0009).

## Tabelas

| Tabela | Tipo | Grão | Chave | Linhas | Origem |
|---|---|---|---|---|---|
| `Fato_Transporte` | fato | data × linha (ônibus e trem) | `data` + `id_linha` | 463.876 | `Fato_Transporte` da Etapa 2: SPTrans diário (461.839, `origem_dado = real`), complemento de 08/07/2024 (207, `estimado`, decisão `0014`) e CPTM estimada por dia (1.830, `estimado`, decisão `0012`) |
| `Fato_Referencia_Mensal` | fato ("esperado") | mês × grupo | `mes_inicio` + `grupo` | 36 | totais mensais publicados pela SPTrans |
| `Dim_Calendario` | dimensão | data | `data` | 366 | gerada no Power Query (2024 contínuo, feriados de `Ref_Feriados`) |
| `Dim_Transporte` | dimensão | linha (ônibus ou trem) | `id_linha` | 1.442 | `Dim_Transporte` da Etapa 2: 1.437 de ônibus e 5 da CPTM |
| `Dim_Grupo` | dimensão | grupo (SPTrans ou CPTM) | `grupo` | 5 | `Dim_Grupo` da Etapa 2; `grupo_oficial` marca os três grupos oficiais da SPTrans |
| `Rejeitados` | fora da estrela | linha descartada | — | 6.672 | `Rejeitados` da Etapa 2; só para contagens |
| `Conf_Etapa2` | fora da estrela | fonte | `fonte` | 3 | `Conf_Reconciliacao` da Etapa 2; base da aba `Conferencia` |

Reservado para a Etapa 6: `Fato_Clima_Horario` (data × hora), ligada a `Dim_Calendario`.

## Relacionamentos

Todos 1:N, ativos e em direção única (da dimensão para a fato).

| ID | De (N) | Para (1) | Observação |
|---|---|---|---|
| R1 | `Fato_Transporte[data]` | `Dim_Calendario[data]` | |
| R2 | `Fato_Transporte[id_linha]` | `Dim_Transporte[id_linha]` | |
| R3 | `Dim_Transporte[grupo]` | `Dim_Grupo[grupo]` | o grupo filtra a fato através da linha |
| R4 | `Fato_Referencia_Mensal[mes_inicio]` | `Dim_Calendario[data]` | ligação pelo primeiro dia do mês, como o `Mes_Inicio` do CaféData |
| R5 | `Fato_Referencia_Mensal[grupo]` | `Dim_Grupo[grupo]` | |

Não há caminho ambíguo: `Dim_Grupo` chega a `Fato_Transporte` só por R3 → R2, e a `Fato_Referencia_Mensal` só por R5.

## Colunas de `Dim_Calendario`

`data`, `ano`, `mes`, `nome_mes`, `mes_rotulo` (`01 - Janeiro`, que já ordena certo sem "Classificar por coluna"), `mes_inicio`, `dia`, `dia_semana` (1 = segunda), `nome_dia`, `semana_ano`, `tipo_dia` (Útil, Sábado, Domingo, Feriado) e `feriado_nome`.

## Diagrama

`docs/diagrama_modelo.png`: print da Exibição de Diagrama do Power Pivot (exige a interface do Excel).
