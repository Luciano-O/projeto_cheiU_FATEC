# QA da Etapa 4 — VBA

Conferência de `MA2026-entrega-final/01-vba/cheiU_04_VBA.xlsm`. Responsável pelo QA no plano: Maryele Naara Freitas Meira. Feito por script em 28/11/2026 (`01-vba/scripts/executar_etapa4.ps1`, saída em `01-vba/evidencias/execucao_etapa4.txt`), com os commits na conta do Luciano (decisão `0015`).

| # | Item | Resultado esperado | Como verificar | Obtido | Status |
|---|---|---|---|---|---|
| 1 | Configuração | `Config("CaminhoRepo")` devolve a raiz | `TestarLog` | caminho do clone | Concluído |
| 2 | Log | uma linha OK e uma FALHA no teste | aba `Log` | OK e FALHA (`-2147220991`) | Concluído |
| 3 | Atualização completa | sem intervenção; uma linha OK por consulta | `AtualizarTudo` | 10 consultas, modelo e dinâmicas em 44 s | Concluído |
| 4 | QA automatizado | tudo OK com os dados corretos | `ValidarDados`, aba `QA` | 24 checagens, 0 falhas | Concluído |
| 5 | Teste negativo do QA | uma checagem vira FALHA com um defeito proposital | `scripts/verificar_etapa4.ps1`: +1.000 em `passageiros_no_fato` da Etapa 2 numa cópia do repositório, depois Atualizar e Validar | 1 falha, só em "Passageiros no modelo = Etapa 2" | Concluído |
| 6 | Resumo diário | aba e PDF de um dia válido; aviso para data inválida ou fora do calendário | `GerarResumoDiario` 15/03/2024, 31/02/2024, 01/01/2025 | `Resumo_15-03-2024` e `relatorios/resumo_2024-03-15.pdf`; dois avisos, nenhuma aba | Concluído |
| 7 | Números do resumo | iguais ao modelo | `[Total de Passageiros]` de 15/03/2024 | 8.499.597 nos dois | Concluído |
| 8 | Exportação | linhas de cada CSV = modelo | `ExportarParaCarga`, aba `Log` | 8 tabelas, todas iguais | Concluído |
| 9 | Painel de controle | quatro botões funcionando | aba `Controle` | Atualizar, Validar, Resumo diário, Exportar para SQL | Concluído |
| 10 | `.bas` = código no `.xlsm` | idênticos | importação dos 8 `.bas` de `modulos/` pelo VBE | importados dos arquivos versionados; a comparação automática exige acesso ao projeto VBA, que o Excel por automação recusa nesta máquina | Concluído |
| 11 | % no pico e lotação no resumo | no PDF | depende de E3.4 (perfil horário da OD) | ainda sem dados. Ação: entra com E2.6 e E3.4 | Pendente de esclarecimento |
