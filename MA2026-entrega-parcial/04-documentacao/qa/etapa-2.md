# QA da Etapa 2 — Power Query

Conferência de `MA2026-entrega-parcial/02-powerquery/cheiU_02_PowerQuery.xlsx`, conforme a tabela do Guia Prático da Etapa 2. Responsável pelo QA: Maryele Naara Freitas Meira.

Conferência por script, preparada por Luciano. Revisão da Maryele: pendente.

| # | Item | Resultado esperado | Como verificar | Obtido | Status |
|---|---|---|---|---|---|
| 1 | Reconciliação de linhas | lidas − aceitas − rejeitadas = 0 | aba `Conf_Reconciliacao` | 486.864 − 480.192 − 6.672 = 0 | Concluído |
| 2 | Valor preservado | passageiros aceitos = passageiros na fato | aba `Conf_Reconciliacao` | 2.124.704.175 nos dois | Concluído |
| 3 | Colunas mapeadas | `Conf_Colunas` vazia | aba `Conf_Colunas` | vazia | Concluído |
| 4 | Motivos explicados | todo motivo no README | aba `Conf_Motivos` | só "Linha vazia" (6.672, em 109 arquivos) | Concluído |
| 5 | Cobertura de datas | os 366 dias de 2024 | datas distintas de `Fato_Transporte` | 366 | Concluído |
| 6 | Grão sem duplicata | data × `id_linha` único | contagem na fato | 461.839 linhas, 461.839 pares distintos | Concluído |
| 7 | Chaves | todo `id_linha` em `Dim_Transporte` | medida de órfãs da Etapa 3 | 0 órfãs | Concluído |
| 8 | `origem_dado` preenchido | nunca nulo | contagem na fato | 461.839 `real` | Concluído |
| 9 | Teste de reenvio | arquivo extra muda as contagens, e elas voltam | `scripts/verificar_etapa2.ps1` | com a cópia: 488.200 lidas, 8.008 rejeitadas, diferença 0; sem a cópia: 486.864 | Concluído |
| 10 | Duas linhas sorteadas achadas no bruto | os valores batem | sorteio com semente 20261108 | 12/02/2024, `ONI-3686-21`, 5 passageiros = `12FEV2024(1).xls`, linha 1113; 16/05/2024, `ONI-1759-10`, 6.449 = `16MAI2024(1).xls`, linha 89 | Concluído |
| 11 | Cadastros da Etapa 1 | lidos por `cad_Etapa1`, nada redigitado | consultas `cad_*` | ok | Concluído |
| 12 | Gêmeos em texto | `.pq` = consultas | `scripts/verificar_etapa2.ps1` | 26 × 26, 0 diferenças | Concluído |
| 13 | Dados limpos | CSV UTF-8 em `dados_limpos/` | abrir a pasta | 12 arquivos | Concluído |
| 14 | Escopo respeitado | sem relacionamentos, DAX ou macro | Modelo de Dados e macros | nenhum | Concluído |
| 15 | Soma mensal × total publicado | até 0,5% | aba `Conf_Publicado` | ago–dez até −0,40%; jan–jul de −0,77% a −5,15%. Ação: confirmar a causa com a SPTrans | Pendente de esclarecimento |
| 16 | Metrô e CPTM | fontes tratadas | `dados-brutos/` | sem arquivo. Ação: baixar quando o portal voltar e pelo navegador | Pendente de esclarecimento |
| 17 | Grupos de consultas e prints | `01_Parametros`… e `evidencias/` | Editor do Power Query | exigem a interface do Excel. Ação: fazer no Excel | Pendente de esclarecimento |
