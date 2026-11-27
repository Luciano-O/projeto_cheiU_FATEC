# CPTM diária estimada com pesos provisórios

Em 2026-11-27 a CPTM de 2024 foi baixada (E1.2). O portal do Metrô, porém, continuava em manutenção. O plano da E2.4 calcula os pesos por tipo de dia a partir das razões MSA/MDU e MDO/MDU do Metrô, e esses dados não existem ainda. O Luciano escolheu fazer a E2.4 assim mesmo, com os pesos que já estavam na Etapa 1.

- **Pesos**: `Param_Pesos_Tipo_Dia` da Etapa 1, sem mudança: Útil 1, Sábado 0,6, Domingo 0,4 e Feriado 0,4. É uma premissa. Quando o Metrô voltar (E2.3), as razões medidas substituem esses valores **na Etapa 1**, e "Atualizar Tudo" propaga a troca.
- **Tipo de dia**: o mesmo da `Dim_Calendario` da Etapa 3. Feriado ou ponto facultativo de `Cad_Feriados_2024` conta como Feriado; senão, Sábado, Domingo ou Útil.
- **Total distribuído**: `Total Entradas` de cada estação, somado por linha e mês. Ela fecha com a soma das quatro tarifas nos 768 registros do ano. A coluna `Total` só difere em Palmeiras-Barra Funda (D22) e fica para conferência.
- **Arredondamento acumulado**: o dia k recebe arred(total × pesos até k ÷ soma) − arred(total × pesos até k−1 ÷ soma). Assim, a soma dos dias de cada mês é o total mensal exato.
- **No fato**: `modalidade = Trem`, `tipo_metrica = embarcados` e `origem_dado = estimado`. `pagantes`, `integracao` e `gratuidades` ficam vazias, porque só o total é distribuído por dia.
- **No modelo**: as linhas de trem entram em `Dim_Transporte` com o grupo "CPTM". "CPTM" também entra em `Dim_Grupo`, com `grupo_oficial = falso`. Assim, a comparação com o total publicado da SPTrans continua só com ônibus.

Alternativas descartadas:

- **Esperar o Metrô**: a Etapa 2 ficaria sem trem por tempo indeterminado (o portal estava fora do ar desde 06/11).
- **Distribuir por igual entre os dias**: ignora a queda de demanda no fim de semana, que é a premissa mais conhecida do transporte sobre trilhos.
- **Guardar só o mensal**: quebraria o grão data × linha de `Fato_Transporte` e as medidas diárias da Etapa 3.

Risco assumido: os valores diários da CPTM são uma estimativa e dependem da premissa de pesos. A média de dia útil e a razão fim de semana/útil do trem refletem os pesos, não uma medição. Mitigação: `origem_dado = estimado` em toda linha, e a troca pelos pesos medidos fica registrada como pendência da E2.3. Os totais mensais por linha continuam sendo os publicados pela CPTM.
