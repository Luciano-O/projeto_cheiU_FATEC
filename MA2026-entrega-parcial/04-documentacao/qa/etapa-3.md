# QA da Etapa 3 — Power Pivot e DAX

Conferência de `MA2026-entrega-parcial/03-powerpivot/cheiU_03_PowerPivot.xlsx`, conforme a tabela do Guia Prático da Etapa 3. Responsável pelo QA: Maryele Naara Freitas Meira.

Conferência por script, preparada por Luciano. Revisão da Maryele: pendente.

| # | Item | Resultado esperado | Como verificar | Obtido | Status |
|---|---|---|---|---|---|
| 1 | Só lê a Etapa 2 | nenhuma tabela digitada ou colada | consultas `cad_Etapa2` | ok | Concluído |
| 2 | Calendário | 366 dias, feriados marcados | `Dim_Calendario` | 366 linhas | Concluído |
| 3 | Estrela | 1:N, ativas, direção única | `scripts/verificar_etapa3.ps1` | 5 relações ativas | Concluído |
| 4 | `Rejeitados` fora da estrela | sem relação | `scripts/verificar_etapa3.ps1` | sem relação | Concluído |
| 5 | Mínimo de cinco medidas | ≥ 5 | `dax/medidas_preliminares.dax` | 11 de análise, 16 de conferência | Concluído |
| 6 | Valor preservado | modelo = Etapa 2 | aba `Conferencia` | 2.124.704.175 nos dois | Concluído |
| 7 | Linhas preservadas | modelo = Etapa 2 | aba `Conferencia` | 461.839 e 6.672 | Concluído |
| 8 | Órfãs, PK e grão | 0 | aba `Conferencia` | 0 | Concluído |
| 9 | Validação | só dinâmicas, com segmentações em todas | `scripts/verificar_etapa3.ps1` | 5 dinâmicas, 3 segmentações ligadas a todas | Concluído |
| 10 | Gêmeos em texto | `.pq` e `.dax` = pasta | `scripts/verificar_etapa3.ps1` | 10 × 10 e 27 × 27, 0 diferenças | Concluído |
| 11 | Linhagem | mudança na Etapa 2 aparece e volta | `scripts/verificar_etapa3.ps1`, numa cópia em outra pasta | +1.000 apareceu e voltou | Concluído |
| 12 | Escopo respeitado | sem gráficos de painel | aba `Validacao` | nenhum gráfico | Concluído |
| 13 | Tabela de Datas, hierarquia, chaves ocultas | marcadas no Power Pivot | Power Pivot | exigem a interface do Excel. Ação: fazer no Power Pivot | Pendente de esclarecimento |
| 14 | Diagrama e prints | `docs/diagrama_modelo.png`, `evidencias/` | abrir as pastas | exigem a interface do Excel. Ação: fazer no Excel | Pendente de esclarecimento |
