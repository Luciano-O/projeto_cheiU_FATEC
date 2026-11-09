# QA da Etapa 1 — Excel avançado

Conferência independente de `MA2026-entrega-parcial/01-excel/cheiU_01_Excel.xlsx`, conforme a tabela do Guia Prático da Etapa 1. Amostra: consolidado SPTrans de jan/2024 (41.968 registros).

Responsável pelo QA: Maryele Naara Freitas Meira.

Conferência por script, preparada por Luciano. Revisão da Maryele: pendente.

| # | Item | Resultado esperado | Como verificar | Obtido | Status |
|---|---|---|---|---|---|
| 1 | Arquivo com as quatro abas | `Bruto`, `Tratado`, `Cadastros`, `Auditoria`, nessa ordem | abrir o arquivo | as quatro abas, nessa ordem | Concluído |
| 2 | `Bruto` igual ao original | cópia por Mover ou Copiar, sem edição | comparar com `dados-brutos/sptrans/2024/mensal/Consolidado 01-Janeiro-2024.xls` | 41.971 linhas e 16 colunas, iguais à aba `Geral_Consolidado` (que vem oculta no original e foi só reexibida, D16) | Concluído |
| 3 | `Linha_Origem` fixa | valores digitados, nunca `=LIN()` | clicar numa célula de `Linha_Origem` | valores fixos de 4 a 41.971 | Concluído |
| 4 | Nenhum original alterado | 0 células diferentes entre o `Bruto` e as colunas originais do `Tratado` | painel da `Auditoria`, linha "Originais diferentes do Bruto" | 0 | Concluído |
| 5 | Linhas e soma preservadas | linhas do `Bruto` − linhas do `Tratado` = 0; soma do total = 0 | painel da `Auditoria` | 0 e 0 | Concluído |
| 6 | Buscas sem `#N/D` | `PROCX` com retorno "Não cadastrado" | filtrar `Grupo_Trat` | nenhum `#N/D`; 0 "Não cadastrado" | Concluído |
| 7 | Erros de fórmula | `SOMARPRODUTO(--ÉERROS(Tab_Transporte))` = 0 | painel da `Auditoria` | 0 | Concluído |
| 8 | Datas em texto convertidas | `Data_Trat` com `LET`; "Data inválida" para data inexistente | filtrar `Status_Data` | 41.968 datas válidas, 0 inválidas | Concluído |
| 9 | Colunas de tempo | mês, dia da semana e tipo de dia (feriado por busca) | conferir 01/01/2024 e 25/01/2024 | ambos "Feriado"; 06/01/2024 "Sábado" | Concluído |
| 10 | Texto padronizado | `ARRUMAR` e `PRI.MAIUSCULA` no nome da linha; código no formato do letreiro | conferir `Codigo_Linha_Trat` | `917M10` → `917M-10` | Concluído |
| 11 | Validação de dados em lista | listas `Lista_*` nas colunas categóricas | Dados > Validação de Dados em `Tab_Auditoria[Situacao]` | lista `Lista_Situacao` | Concluído |
| 12 | Formatação condicional | vazio/zero, acima do limite e linha com problema | rolar o `Tratado` | vermelho, laranja e amarelo aplicados | Concluído |
| 13 | Coluna-resumo `Problemas` | `UNIRTEXTO` dos status | filtrar `Problemas` | 41.395 "Sem problemas" | Concluído |
| 14 | Painel de auditoria | Detectado − Registrado = 0 em todos os tipos | painel da `Auditoria` | 579 detectados, 579 registrados, diferença 0 | Concluído |
| 15 | Duas linhas sorteadas localizadas no `Bruto` | os valores batem | sorteio com semente 20261106 | `Linha_Origem` 3171 (03/01/2024, `305110`, 486) e 5793 (05/01/2024, `801021`, 100), iguais no `Bruto` | Concluído |
| 16 | De-para só com grafias confirmadas | grafia nova vai para a auditoria como pendente | ler `Cad_DePara_Grupo` | 6 grafias; "OUTRO PC" marcado como pendente | Concluído |
| 17 | Pendências registradas | todo "Pendente de esclarecimento" tem a ação descrita | filtrar `Tab_Auditoria[Situacao]` | 574 pendentes (554 empresa como código, 14 acima do limite, 6 OUTRO PC), todos com ação | Pendente de esclarecimento |
| 18 | Sem vínculo externo | nenhum vínculo no arquivo | pacote do `.xlsx` | nenhum vínculo externo | Concluído |
| 19 | Escopo respeitado | sem Power Query, DAX ou macro | Dados > Consultas e Conexões; Exibir > Macros | nenhuma consulta, modelo ou macro | Concluído |
| 20 | Fontes Metrô e CPTM | dados de 2024 baixados (E1.2) | `dados-brutos/` | portal do Metrô em manutenção (HTTP 503) e CPTM só pelo navegador | Pendente de esclarecimento |

Pendências: os itens 17 e 20 dependem de terceiros (SPTrans, Metrô, CPTM). As ações estão na `Tab_Auditoria` e no `01-excel/README.md`.
