# 04-powerbi-dashboard — Etapa 7

Painel do cheiU no Power BI, lendo o SQL Server da Etapa 5.

| Arquivo | O que é |
|---|---|
| `cheiU_dashboard.pbix` | a entrega: painel com os dados importados |
| `cheiU_dashboard.pdf` | as 5 páginas exportadas |
| `cheiU_dashboard.pbip` + pastas `.Report` e `.SemanticModel` | o gêmeo em texto: modelo em TMDL, relatório em PBIR |
| `scripts/gerar_pbip.py` | gera o projeto `.pbip`: tabelas, relações, medidas e visuais |
| `scripts/conferir_kpis.ps1` | compara 8 KPIs do painel aberto com o `05_kpis.sql` |
| `tema-cheiU.json` | tema único do relatório |
| `evidencias/` | conferência dos KPIs e tempo das consultas |
| `relatorio-final.md` | relatório final do projeto (E7.7) |

## Páginas

1. **Visão geral**: total de passageiros, média de dia útil, diferença contra o publicado e a linha mensal por modalidade.
2. **Padrões por dia**: dia da semana e tipo de dia (útil, sábado, domingo, feriado).
3. **Linhas e grupos**: as 10 linhas mais usadas, a participação de cada grupo e quanto da demanda é real ou estimada.
4. **Chuva**: dia útil com chuva × seco e a chuva de cada mês.
5. **Sobre os dados**: fontes, premissas e o que ficou de fora.

As segmentações de mês e modalidade são sincronizadas entre as páginas. Os gráficos mostram a média diária e o % estimado na dica de ferramenta.

## Como reproduzir

1. Suba o SQL Server e carregue o banco (`02-bancodedados-sql/README.md`).
2. Gere o projeto:

   ```powershell
   .venv\Scripts\python MA2026-entrega-final\04-powerbi-dashboard\scripts\gerar_pbip.py
   ```

3. Abra `cheiU_dashboard.pbip` no Power BI Desktop e clique em **Refresh**. Na primeira vez, informe a credencial do SQL Server: **Database**, usuário `sa` e a senha do `.env`.
4. Confira os KPIs com o painel aberto:

   ```powershell
   powershell -File MA2026-entrega-final\04-powerbi-dashboard\scripts\conferir_kpis.ps1
   ```

5. Para a entrega: **File › Save as** em `.pbix` e **File › Export › Export to PDF**.

O servidor e o banco são parâmetros do modelo (`Servidor` e `Banco`, em Transform data › Edit parameters). O Desktop reescreve os arquivos PBIR ao salvar; o `gerar_pbip.py` continua sendo a fonte para mudar medidas, relações e visuais.
