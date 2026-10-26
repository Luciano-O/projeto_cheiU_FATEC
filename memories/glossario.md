# Glossário — cheiU

Demanda e utilização do transporte público coletivo da cidade de São Paulo: ônibus municipais (SPTrans), Metrô e CPTM.

## Medição de demanda

**Demanda**:
Quantidade de passageiros que usam o transporte coletivo num recorte de período, linha, região ou modalidade.
_Evite_: movimento, fluxo, uso

**Passageiros transportados**:
Medida publicada pela SPTrans: passageiros que embarcaram numa linha de ônibus no dia, incluindo integrações e gratuidades.

**Entradas**:
Medida publicada pelo Metrô: passageiros que passaram pelas catracas de uma estação; transferências entre linhas dentro do sistema não contam.

**Embarcados**:
Medida publicada pela CPTM: passageiros que embarcaram numa estação, incluindo os que chegaram por transferência.

**Demanda estimada por hora**:
Demanda diária real distribuída pelas horas do dia segundo o perfil horário da modalidade.
_Evite_: demanda horária real, demanda por hora (sem "estimada")

**Perfil horário**:
Participação de cada hora do dia no total de viagens de uma modalidade, para um tipo de dia.

**Origem do dado**:
Classificação de cada valor: **real** (publicado pela fonte), **estimado** (derivado de dado real por regra documentada) ou **simulado** (depende de premissa sem medição).

## Oferta e lotação

**Capacidade ofertada**:
Lugares disponíveis numa linha numa hora: viagens programadas na hora × capacidade do veículo.

**Lotação**:
Razão entre a demanda estimada por hora e a capacidade ofertada na mesma hora e linha; neste projeto é sempre simulada.
_Evite_: ocupação, superlotação

**Faixa de lotação**:
Classe da lotação — Baixa, Média, Alta ou Muito alta (pico) — segundo limites parametrizados.

**Frequência**:
Partidas de uma linha por hora.

**Headway**:
Intervalo, em minutos, entre partidas consecutivas de uma linha.
_Evite_: frequência (quando o valor está em minutos)

## Rede

**Modalidade**:
Tipo de transporte coletivo: Ônibus, Metrô ou Trem. O monotrilho (L15) conta como Metrô.
_Evite_: modal, modo (exceto ao citar códigos da Pesquisa OD)

**Linha**:
Serviço identificado por código: no ônibus, o letreiro (ex. 917M-10); nos trilhos, L1 a L15.

**Estação**:
Ponto de embarque de Metrô ou CPTM.

**Parada**:
Ponto de embarque de ônibus.
_Evite_: ponto, estação (para ônibus)

**Operador**:
Empresa responsável por operar uma linha (concessionárias da SPTrans, Metrô, CPTM).

**Região**:
Centro, Norte, Sul, Leste, Oeste ou Outros municípios; atribuída a partir do distrito.
_Evite_: zona (reservado à zona OD)

**Zona OD**:
Unidade espacial da Pesquisa Origem-Destino; cada zona pertence a um distrito e a um município.

## Tempo

**Tipo de dia**:
Útil, Sábado ou Domingo/Feriado.

**Faixa horária**:
Agrupamento de horas do dia: Madrugada, Pico manhã, Entrepico, Pico tarde, Noite.

**Pico**:
O conjunto das faixas Pico manhã e Pico tarde.
_Evite_: rush, horário de ponta

## Deslocamento

**Viagem**:
Deslocamento de uma pessoa de uma origem a um destino, registrado na Pesquisa OD; pode ter várias etapas e modalidades.

**Cadeia modal**:
Sequência das modalidades coletivas usadas numa viagem, ex. Ônibus → Metrô.

**Corredor**:
Par região de origem → região de destino em que comparamos alternativas de percurso (Leste → Centro, Norte → Centro).
_Evite_: corredor de ônibus (faixa exclusiva), que chamamos **corredor viário**

**Alternativa de percurso**:
Cadeia modal possível dentro de um corredor, com sua linha tronco (ex. Ônibus → Metrô pela L3).
_Evite_: rota, opção de trajeto

**Linha tronco**:
Linha de trilhos principal de uma alternativa de percurso.

**Peso de expansão**:
Fator da Pesquisa OD que converte uma viagem da amostra no total de viagens que ela representa na população.

## Qualidade e rastreabilidade

**Catálogo de defeitos**:
Lista numerada (D1..Dn) dos problemas encontrados nos dados brutos, com exemplo real e a etapa que trata cada um.

**Amostra**:
Arquivo bruto real de um mês em que a Etapa 1 é feita com fórmulas, antes de o Power Query tratar o ano inteiro.
_Evite_: base de teste, dados simulados (simulado é outra coisa: ver Origem do dado)

**Regra de ouro**:
Garantia que cada etapa precisa provar: na Etapa 1, nenhum valor original é sobrescrito; na Etapa 2, nenhuma linha some sem explicação; na Etapa 3, o modelo não cria nem perde valor.

**Rejeitados**:
Linhas lidas dos brutos que não entram nas tabelas tratadas, cada uma com fonte, linha de origem e motivo.
_Evite_: linhas descartadas, lixo

**Reconciliação**:
Conferência de que linhas lidas − aceitas − rejeitadas = 0, ou de que um total calculado é igual ao publicado pela fonte ou pela etapa anterior.
_Evite_: validação (quando se trata de bater números)

**Tabela de conferência**:
Lista de itens com resultado esperado, como verificar e status (Não iniciado, Em andamento, Concluído, Pendente de esclarecimento) que fecha cada etapa.

**Ficha do projeto**:
Resumo do projeto nos 9 campos definidos pelo professor (contexto, pergunta central, fontes, dados, KPIs, API, VBA, SQL, Power BI).
