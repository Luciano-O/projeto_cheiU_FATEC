# 03-powerpivot — Etapa 3 (Power Pivot e DAX)

`cheiU_03_PowerPivot.xlsx` lê só o arquivo da Etapa 2 (`cad_Etapa2`), monta o modelo em estrela e cria as medidas. Regra de ouro: o modelo não cria nem perde valor, e a aba `Conferencia` prova isso. Esta etapa não limpa dados.

Plano: `docs/plano/etapa-3-powerpivot-dax.md`. Tabelas, grão e relacionamentos R1..R5: `docs/modelo_relacional.md`.

## Como abrir e atualizar

Abra o arquivo e use Dados › Atualizar Tudo (menos de 1 minuto). `CaminhoRepo` (aba `Parametros`) se deriva do caminho do arquivo. Para reconstruir do zero:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File MA2026-entrega-parcial/03-powerpivot/scripts/montar_etapa3.ps1
```

| Pasta ou arquivo | Conteúdo |
|---|---|
| `scripts_m/` | 10 consultas (fonte da verdade) |
| `dax/medidas_preliminares.dax` | 27 medidas: 11 de análise e 16 de conferência, com a pergunta e o formato (separador vírgula) |
| `scripts/montar_etapa3.ps1` | monta modelo, relações, medidas, `Validacao` e `Conferencia` |
| `scripts/verificar_etapa3.ps1` | compara `.pq` e `.dax` com a pasta e faz o teste de linhagem |

## Medidas de análise

| Medida | Pergunta | Valor em 2024 |
|---|---|---|
| Total de Passageiros | quantos passageiros o sistema transportou? | 2.124.704.175 |
| Média Diária de Passageiros | qual é o volume típico de um dia? | 5.805.203 |
| Média Dia Útil | quanto transporta num dia útil típico? | 6.894.203 |
| Média Fim de Semana | quanto transporta num sábado ou domingo típico? | 3.505.315 |
| Razão Fim de Semana/Útil | quanto da demanda do dia útil sobra no fim de semana? | 50,84% |
| Participação % da Linha | quanto cada linha representa? | maior: 607C-10, 0,48% |
| Participação % do Grupo | quanto cada grupo representa? | Distribuição 42,14%; Estrutural 32,91%; Articulação 24,80%; Outros 0,15% |
| Variação % sobre o Mês Anterior | a demanda subiu ou caiu? | maior alta: ago (+10,69%); maior queda: nov (−8,61%) |
| Ranking da Linha | quais são as linhas mais usadas? | 1º 607C-10 (10.117.677); 2º 6000-10 (9.333.802) |
| Passageiros Publicados | qual é o total oficial? | 2.160.850.434 |
| Diferença % sobre o Publicado | os dados tratados batem com o oficial? | −1,82% no ano (detalhe no README da Etapa 2) |

## Conferência

| Verificação | Etapa 2 | Modelo | Diferença |
|---|---|---|---|
| Linhas de `Fato_Transporte` | 461.839 | 461.839 | 0 |
| Passageiros (soma) | 2.124.704.175 | 2.124.704.175 | 0 |
| Linhas de `Rejeitados` | 6.672 | 6.672 | 0 |
| Órfãs nas 5 relações | 0 | 0 | 0 |
| PK duplicada nas 3 dimensões | 0 | 0 | 0 |
| Grão duplicado em `Fato_Transporte` | 0 | 0 | 0 |

Verificado em 08/11/2026:
- `.pq` 10 × 10 e `.dax` 27 × 27, 0 diferenças;
- 5 relações ativas, 1:N, sem vínculo externo;
- as 3 segmentações (mês, tipo de dia, grupo) ligadas às 5 tabelas dinâmicas;
- teste de linhagem numa cópia em outra pasta: somar 1.000 a um valor da Etapa 2 levou `Passageiros Publicados` de 2.160.850.434 a 2.160.851.434, e voltou ao desfazer.

## Pendências

- Exigem a interface do Power Pivot: marcar `Dim_Calendario` como Tabela de Datas, hierarquia Ano › Mês › Dia, ocultar chaves técnicas e `docs/diagrama_modelo.png`.
- Prints em `evidencias/` (diagrama, gerenciar relações, gerenciar medidas, validação, conferência).
- Herdadas da Etapa 2: só Ônibus; diferença contra o publicado de jan a jul.
- Depois da N1: `Dim_Horario`, medidas por hora e de lotação (E3.4) e corredores (E3.5).

Escopo respeitado: a aba `Validacao` só tem tabelas dinâmicas.
