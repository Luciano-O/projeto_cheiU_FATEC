# Estratégia de dados híbrida: real, estimado e simulado

A proposta promete comparar demanda e lotação por hora entre modalidades, mas nenhuma fonte pública traz demanda por hora. Decidimos combinar três camadas, cada registro marcado em `origem_dado`:

- **real**: demanda diária por linha (SPTrans, Metrô) e mensal por estação (CPTM);
- **estimado**: demanda por hora = total diário real × perfil horário da Pesquisa OD 2023; CPTM diário = total mensal distribuído pelos pesos dia útil/sábado/domingo do Metrô;
- **simulado**: lotação = demanda estimada por hora ÷ capacidade ofertada (viagens/h do GTFS × capacidade do veículo em `Param_Capacidade`), classificada pelas faixas de `Param_Faixas_Lotacao`.

Período 2024, o único ano em que as três fontes saem em tabela (a CPTM só publica PDF a partir de 2025). Cobertura: todas as linhas SPTrans, Metrô L1/L2/L3/L15 e CPTM L7/L10/L11/L12/L13. As linhas 4, 5, 8 e 9 (concessionárias privadas) não publicam dados e ficam registradas como limitação.

## Opções consideradas

- **Tudo simulado** (como o projeto-modelo CaféData): controle total, mas não responde à pergunta central com dados reais.
- **Só dados reais**: impede qualquer análise por hora ou de lotação.
