# Painel gerado por script (PBIP) e páginas adaptadas aos dados que existem

Em 2026-11-28 a Etapa 7 foi feita. Duas escolhas:

- **Gerar o projeto por script**: `04-powerbi-dashboard/scripts/gerar_pbip.py` escreve o modelo em TMDL e o relatório em PBIR, e o Power BI Desktop só abre, atualiza e salva. Nesta máquina o Desktop não aceita cliques nem teclas por automação, então montar os visuais pela interface dependeria de uma pessoa para cada ajuste. Com o gerador, medidas, relações e visuais ficam em texto revisável (a regra do gêmeo em texto), e a pessoa faz só três passos: Refresh (com a credencial do SQL), salvar o `.pbix` e exportar o PDF.
- **Páginas conforme os dados**: o plano previa "Padrões horários", "Linhas e regiões" (com mapa e detalhe por linha) e "Alternativas de percurso". Todas dependem do Metrô e da Pesquisa OD 2023, que não vieram (portal em manutenção). O painel ficou com Visão geral, Padrões por dia, Linhas e grupos, Chuva e Sobre os dados. As issues TRA-62, 63 e 64 continuam abertas para a parte que depende da OD.

Alternativas descartadas:

- **Montar os visuais à mão pela interface**: o plano original (E7.0) deixava isso ao grupo; trocaria o texto versionado por um binário e exigiria várias sessões com uma pessoa.
- **DirectQuery**: o painel precisaria do container do SQL ligado para abrir. O modo Import guarda os dados no `.pbix`.

Risco assumido: o Desktop reescreve os arquivos PBIR ao salvar, então a versão versionada é a do Desktop, e rodar o gerador de novo descarta ajustes feitos pela interface. Para mudar o painel, edite o gerador.
