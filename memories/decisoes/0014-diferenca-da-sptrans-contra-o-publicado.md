# Diferença da SPTrans contra o total publicado

O aceite da E2.2 (TRA-18) pede que a soma mensal fique a até 0,5% do total publicado pela SPTrans. De janeiro a julho de 2024 a diferença ia de −0,8% a −5,2%. Em 2026-11-27 a causa foi investigada com os 12 consolidados mensais da própria SPTrans.

O que se apurou:

- **Os consolidados fecham com os diários.** Em 11 dos 12 meses, a soma do consolidado mensal é exatamente a soma dos 366 diários tratados. O tratamento da Etapa 2 não perde passageiros.
- **O total publicado não é a soma dos arquivos.** A página de totais avisa que os dados estão "sujeitos à alteração por reprocessamentos da bilhetagem eletrônica". Os arquivos diários e consolidados ficam como foram publicados, e o total da página é refeito depois. Em jan–jun o publicado fica 2–5% acima, nos três grupos.
- **Julho é outro caso (D24).** O consolidado de julho foi publicado numa 2ª versão (`consolidado-julho-2024-2.xlsx`) com 904.616 passageiros a mais que os diários. A diferença está toda em 207 linhas de ônibus que não aparecem no diário de 08/07/2024: a segunda-feira traz 1.115 linhas, contra cerca de 1.320 nos outros dias úteis. Nenhuma das 207 linhas tem outro dia faltando.

Decisões:

1. **Complementar 08/07/2024 pelo consolidado.** Para cada uma das 207 linhas, o valor do dia é consolidado − soma dos diários de julho, também nas aberturas (pagantes, integração, gratuidades). As linhas entram em `Fato_Transporte` com `origem_dado = estimado`. A regra vale só quando a linha tem diferença positiva e não aparece no diário de 08/07. Qualquer outra diferença fica visível como `nao_explicada` em `Conf_Complemento_Jul`.
2. **Aceitar a diferença de jan–jun como limitação da fonte.** Os diários são a melhor fonte por dia e linha. O total publicado continua em `Fato_Referencia_Mensal` como "esperado", e a medida `Diferença % sobre o Publicado` mostra a distância mês a mês. Não se cria fator de ajuste: ele inventaria passageiros por dia e linha sem base.
3. **O grupo da linha é o do dia mais recente (D25).** `Dim_Transporte` guarda um grupo por linha. Linhas que mudaram de grupo no ano somam no grupo atual, e por isso a divisão por grupo de um mês difere um pouco da do consolidado daquele mês, embora o total do mês seja o mesmo. A comparação com o publicado é feita pelo total do mês, não por grupo.

Alternativas descartadas:

- **Usar os consolidados no lugar dos diários**: de julho a dezembro eles só trazem mês × linha, sem o dia (D12).
- **Fator de correção mensal**: distribuiria a diferença do reprocessamento por dias e linhas sem nenhuma informação sobre onde ela está.

Risco assumido: o modelo fica 1,7% abaixo do total publicado no ano (2,5% no 1º semestre). Mitigação: a diferença é medida e explicada, e o complemento de julho é marcado como estimado.
