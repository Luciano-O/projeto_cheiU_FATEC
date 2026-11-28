# QA da Etapa 6 — APIs e dados da web

Conferência da integração de APIs no modelo da Etapa 4 e no SQL. Feito por script em 28/11/2026 (`03-api-web/scripts/integrar_apis.ps1` e a aba `QA` do `.xlsm`), com os commits na conta do Luciano (decisão `0015`).

| # | Item | Resultado esperado | Como verificar | Obtido | Status |
|---|---|---|---|---|---|
| 1 | Fonte externa no modelo | uma API integrada (Parcial 2) | `api_brasilapi_feriados`, ao vivo no Power Query | 14 feriados nacionais | Concluído |
| 2 | Clima horário | 8.784 linhas, sem nulos, fuso de São Paulo | `ValidarDados` | 8.784; 0 sem temperatura; `America/Sao_Paulo` | Concluído |
| 3 | Relações do clima | sem órfãs | `[Conf Órfãs Fato_Clima_Horario → Dim_Calendario]` | 0 | Concluído |
| 4 | Feriados | API = lista manual, ou diferenças explicadas | aba `Conf_Feriados` | 13 nas duas; Páscoa só na API; 25/01 e 09/07 só na manual; 16 no calendário | Concluído |
| 5 | Efeito da chuva | medida no modelo e consulta no SQL iguais | `[Efeito da Chuva % (Dia Útil)]`, consulta 12 | −5,0% (8.069.711 × 8.496.127) nos dois | Concluído |
| 6 | Carga no SQL | clima e horário no `dw` | `dw.vw_conf_carga` | 8.784 e 24 linhas | Concluído |
| 7 | Exemplos de resposta | salvos | `03-api-web/exemplos/` | BrasilAPI e Open-Meteo | Concluído |
| 8 | Open-Meteo ao vivo no Power Query | `Web.Contents` | consulta direta | falha nesta máquina; aquisição por Python e leitura do JSON (decisão `0016`) | Concluído |
| 9 | Olho Vivo | autenticação e dados estáticos | E6.3 | sem token (E0.5 exige criar conta no DevPlace). Ação: alguém do grupo cria a conta | Pendente de esclarecimento |
