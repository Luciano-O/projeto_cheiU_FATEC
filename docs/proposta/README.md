# Proposta técnica

- `modelo-proposta-professor.pdf`: modelo do Prof. Veríssimo, baseado no projeto-exemplo "CaféData Brasil". Define a estrutura de pastas, o pipeline e o cronograma por aula.
- `proposta-grupo10.pdf`: proposta entregue pelo grupo em setembro de 2026. **Fica só na máquina local**, porque contém RAs; o resumo abaixo substitui o arquivo para quem clona o repositório.

## Resumo da proposta do Grupo 10

- **Tema**: Mobilidade Urbana. **Projeto**: cheiU.
- **Problema**: falta uma visão integrada de demanda e utilização do transporte público (ônibus, metrô, trem) por horário, linha, região e modalidade, o que dificulta enxergar padrões de demanda, períodos de lotação e alternativas de deslocamento.
- **Pergunta central**: como os dados do transporte público podem ser usados para identificar padrões de demanda, lotação e utilização e apoiar a análise de alternativas de deslocamento?
- **Objetivos específicos**:
  1. Estruturar e padronizar os dados.
  2. Consolidar as modalidades.
  3. Tratar no Excel e no Power Query.
  4. Identificar padrões por horário, dia, região, linha e modalidade.
  5. Analisar pico e fora do pico.
  6. Analisar indicadores (passageiros, viagens, frequência, atrasos, tempo de viagem, utilização).
  7. Modelar um banco relacional SQL.
  8. Integrar APIs.
  9. Criar KPIs em SQL e DAX.
  10. Montar um dashboard Power BI filtrável.
  11. Comparar alternativas de deslocamento por horário.
  12. Apoiar a escolha de percurso.
- **Exemplo de saída** que o projeto deve reproduzir: uma tabela Horário × Opção × Demanda × Situação. Exemplos: 07:00 Ônibus → Metrô, Alta; 18:00 Ônibus → Metrô, Muito alta (pico); 10:00 Ônibus → Trem, Baixa.
- **Fontes citadas**: planilhas públicas de mobilidade, passageiros transportados SPTrans, API Olho Vivo, SGBD "a definir", Power BI.
- **Modelo inicial**: `Fato_Transporte`; `Dim Transporte`, `Dim Localização`, `Dim Calendário`, `Dim Horário`.
- **KPIs**: total de passageiros, quantidade de viagens, demanda média por período, demanda por linha e modalidade, tempo médio de viagem, frequência, pico × fora do pico.
- **Repositório citado**: https://github.com/Ve3e3/projeto_cheiU_FATEC.git

## O que mudou em relação à proposta

O que a proposta deixou em aberto ou que os dados reais obrigaram a ajustar está em `memories/decisoes/`:

- **0001**: estratégia de dados híbrida, ano de 2024 e cobertura;
- **0002**: SGBD escolhido, SQL Server;
- **0003**: repositório de trabalho;
- **0005**: modelo em constelação;
- **0006**: escopo das APIs.

A estrutura de pastas segue o modelo do professor (`MA2026-entrega-*` na raiz), e não a raiz `cheiU/` do exemplo da proposta.
