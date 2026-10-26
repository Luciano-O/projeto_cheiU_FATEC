# Plano alinhado às 7 etapas e aos guias do professor

Em 2026-10-26 o professor publicou o Projeto Modelo CaféData v2.0 e os Guias Práticos das Etapas 1–3 (`docs/professor/`). O plano anterior juntava Excel e Power Query numa etapa só e não tinha várias exigências dos guias. O Luciano decidiu:

- **Renumerar** para as 7 etapas do curso: 1 Excel, 2 Power Query, 3 Power Pivot, 4 VBA, 5 SQL, 6 API, 7 Power BI. A aula 16 passa a ser a **Parcial 2**. Os IDs e as issues foram renumerados (tabela abaixo), em vez de manter uma tabela de tradução permanente, porque nenhuma issue da Etapa 1 tinha começado.
- **Amostra de um mês na Etapa 1**: como no guia, a Etapa 1 transforma um arquivo bruto real (consolidado SPTrans ou Metrô de jan/2024) numa base auditável com fórmulas (`Bruto`, `Tratado`, `Cadastros`, `Auditoria`). O ano inteiro só entra no Power Query.
- **Linhagem entre arquivos**: um arquivo por etapa (`cheiU_0N_<Ferramenta>`), cada um lendo o anterior por parâmetro derivado de `CaminhoRepo`. Substitui o `cheiU_modelo.xlsx` copiado do arquivo de tratamento.
- **Rastreabilidade**: `Rejeitados` com motivo e `Conf_*` com diferença 0 na Etapa 2; aba `Conferencia` na Etapa 3.
- **Commits por integrante**: os guias dizem que o histórico é avaliado e que cada um deve ter commits próprios. Nas issues de Nicolly, Maryele e Victor, o agente prepara o trabalho e o próprio integrante commita e abre o PR (E0.9 dá o acesso).

Riscos assumidos:
- se uma tabela da Etapa 2 passar do limite de linhas de uma planilha, a Etapa 3 lê o CSV de `dados_limpos/` em vez da planilha;
- se um CSV passar de 25 MB, ele fica fora do Git e versiona-se a consulta que o gera, com uma nota no README.

## Correspondência dos IDs

| Antigo | Novo | Issue |
|---|---|---|
| E1.0–E1.5 | E1.0–E1.5 | TRA-12–17 |
| — | E0.8, E0.9 | TRA-70, 71 (novas) |
| — | E1.6, E1.7 | TRA-72, 73 (novas) |
| — | E2.0, E2.1 | TRA-74, 75 (novas) |
| E1.6, E1.7, E1.8, E1.9 | E2.2, E2.3, E2.4, E2.5 | TRA-18–21 |
| E2.2, E2.3, E2.4 | E2.6, E2.7, E2.8 | TRA-27–29 |
| E1.10, E1.11, E1.12 | E2.9, E2.10, E2.11 | TRA-22–24 |
| E2.0, E2.1 | E3.0, E3.1 | TRA-25, 26 |
| E2.5–E2.10 | E3.2–E3.7 | TRA-30–35 |
| E3.x | E4.x | TRA-39–45 |
| E4.x | E5.x | TRA-46–51 |
| E5.x | E6.x | TRA-52–57 |
| C.1 | P2.1 | TRA-58 |
| E6.x | E7.x | TRA-59–66 |
