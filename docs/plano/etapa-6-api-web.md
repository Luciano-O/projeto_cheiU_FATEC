# Etapa 6 — API/Web

Etapa do professor: aulas 14–15. Entrega: conexão com API documentada em `03-api-web`, com a fonte externa integrada ao modelo (exigência da Parcial 2). Marco no Linear: **Etapa 6 — API/Web**. O guia desta etapa ainda não saiu; o que a especificação já diz está em `referencia-professor.md`.

Escopo em `memories/decisoes/0006`; endpoints e pegadinhas em `memories/fontes-de-dados.md`. Arquivos em `MA2026-entrega-final/03-api-web/`: `README.md`, `exemplos/*.json` (respostas de exemplo) e, se houver, os `.bas` do coletor.

### E6.0 — Refinar o plano da Etapa 6
- **Resp.** Victor · Docs · **Depende de** E5.5
- **Objetivo**: confirmar o status de E0.5 (token Olho Vivo). Sem token, fazer E6.1 e E6.2 primeiro e deixar E6.3 e E6.4 bloqueados.
- **Aceite**: dependências e ordem desta etapa atualizadas no Linear; o plano foi comparado com o guia da Etapa 6 do professor (se já publicado) e `referencia-professor.md` foi atualizado.

### E6.1 — Clima horário (Open-Meteo) no Power Query
- **Resp.** Victor · API, Power Query · **Depende de** E6.0
- **Saídas**: consulta `api_open_meteo_clima` e `.pq` → `Fato_Clima_Horario` (`data`, `hora`, `temperatura_c`, `precipitacao_mm`, `chovendo`), ligada a `Dim_Calendario` e `Dim_Horario`; medida "Demanda Estimada com Chuva × sem Chuva".
- **Aceite**: 8.784 linhas (366 × 24), sem nulos, fuso `America/Sao_Paulo`. É a fonte externa integrada ao modelo que a Parcial 2 exige.

### E6.2 — Feriados (BrasilAPI) no Power Query
- **Resp.** Victor · API, Power Query · **Depende de** E6.0
- **Saídas**: consulta `api_brasilapi_feriados` e `.pq`, mais os locais (25/01, 09/07) de `Cad_Feriados_2024`. Alimenta `Dim_Calendario.tipo_dia`, e a lista manual passa a ser só reserva.
- **Aceite**: o resultado é igual à lista manual de E1.5, ou as diferenças estão explicadas.

### E6.3 — Olho Vivo: autenticação e dados estáticos (VBA)
- **Resp.** Victor · API, VBA · **Depende de** E0.5, E6.0
- **Saídas**: módulo `modOlhoVivo`, com:
  - `Autenticar()`: um único `WinHttp.WinHttpRequest.5.1` reaproveitado para manter o cookie, token lido do `.env`;
  - `BuscarLinhas(termo)`, `ParadasPorLinha(codigo)`, `Corredores()`, `Empresas()`;
  - tabelas `api_olhovivo_linhas` e `api_olhovivo_paradas`.
- **JSON**: usar a biblioteca VBA-JSON (`JsonConverter.bas`, licença MIT), baixada com o ok do Luciano, ou um parser mínimo próprio.
- **Escopo**: linhas dos corredores e as 50 linhas de maior demanda.
- **Enriquecimento**: `Dim_Transporte` (código Olho Vivo, sentido, terminais) e `Dim_Localizacao` (paradas com latitude e longitude).
- **Aceite**: a autenticação retorna `true`; pelo menos 95% das linhas em escopo casam com `Dim_Transporte`; respostas de exemplo salvas em `exemplos/`.

### E6.4 — [Extra] Coletor agendado de posição e previsão
- **Resp.** Victor · API, VBA · **Depende de** E6.3
- **Objetivo**: medir a operação real nos horários comparados (07h, 10h, 18h).
- **Saídas**: rotina que chama `/Posicao/Linha` e `/Previsao/Linha` para as linhas alimentadoras dos corredores e grava em `Fato_Operacao_Onibus` (`coletado_em`, `codigo_linha`, `veiculo`, `lat`, `lon`, `acessivel`), mais métricas de veículos em operação e espera estimada por faixa.
- **Agendamento**: tarefa no Agendador de Tarefas do Windows, criada com o ok do Luciano.
- **Aceite**: pelo menos 10 dias úteis × 3 faixas coletados, documentados no README.

### E6.5 — Carga das APIs no SQL e documentação
- **Resp.** Victor · API, SQL, Docs · **Depende de** E6.1, E6.2, E6.3
- **Saídas**:
  - tabelas de API exportadas (E4.5) e carregadas no `dw` (E5.3);
  - `03-api-web/README.md` documentando cada API: endpoint, autenticação, parâmetros, exemplo de resposta, limites e tratamento de erro;
  - `MA2026-entrega-parcial/04-documentacao/qa/etapa-6.md`.
- **Aceite**: as views do SQL incluem clima e feriados; o README permite repetir cada chamada do zero.
