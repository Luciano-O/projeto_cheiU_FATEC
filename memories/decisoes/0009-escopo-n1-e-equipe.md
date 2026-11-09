# Escopo da N1, saída da Nicolly e uma branch por etapa

Em 06/11/2026 o professor confirmou que a nota N1 é o conjunto das Etapas 1 (Excel), 2 (Power Query) e 3 (Power Pivot/DAX), com entrega parcial em **07/11/2026**. Nenhum passo dessas etapas tinha começado. O Luciano decidiu:

- **Escopo MVP de demanda.** A SPTrans 2024 inteira (366 arquivos diários) é a espinha da entrega. Metrô e CPTM entram se os dados chegarem a tempo: em 06/11 o portal do Metrô estava "Em manutenção" (HTTP 503, inclusive a Pesquisa OD 2023), e a CPTM bloqueia download automático. OD 2023, oferta (GTFS), lotação, perfil horário e corredores ficam para depois da N1: E1.3, E2.5–E2.8, E3.4 e E3.5 voltam ao Backlog.
- **Segunda fato = totais mensais publicados pela SPTrans** (`Fato_Referencia_Mensal`, mês × grupo), tirados da tabela larga da página 245234 e despivotados. Ela faz o papel do `fMetas` do CaféData: o "esperado" contra o qual se compara o realizado, ligado por `mes_inicio`.
- **Nicolly saiu do projeto.** As tarefas dela passam para o Luciano (E1.5, E1.6, E3.6 e a Etapa 5). A equipe passa a ter três integrantes.
- **Commits híbridos.** O Luciano commita os passos técnicos. O agente prepara os passos curtos da Maryele (QA de cada etapa) e do Victor (relatório parcial), e cada um commita pelo GitHub web com a própria conta. Se não der até 07/11 às 14h, o Luciano commita com uma nota no PR.
- **Uma branch e um PR por etapa** durante a N1, com um commit `TRA-<n>: <resumo>` por passo e `Closes` de todas as issues da etapa. Os passos de uma etapa dependem uns dos outros, e 20 PRs empilhados não cabiam no prazo. Depois da N1 volta o fluxo de uma branch por issue.
- **Dados brutos da SPTrans no Git.** Os 378 arquivos somam ~117 MB, todos abaixo de 25 MB, e ficam versionados com o `manifesto.csv`, para quem clonar atualizar sem baixar nada.

Plano detalhado: `docs/plano/etapa-1-excel.md`, `etapa-2-powerquery.md` e `etapa-3-powerpivot-dax.md`, nas seções "Escopo da N1".
