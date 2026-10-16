# Python só para obter dados; o tratamento é 100% Power Query

A disciplina avalia ferramentas Microsoft (Excel, Power Query, Power Pivot, VBA, SQL, Power BI), mas duas tarefas de aquisição são impraticáveis nelas:

- baixar ~366 arquivos diários da SPTrans, cujos nomes não seguem padrão;
- converter os microdados da OD 2023 de `.dbf`/`.sav`.

Python entra só como ferramenta auxiliar para **obter** dados brutos (scripts em `MA2026-entrega-parcial/01-excel/scripts/`, ambiente em `.venv`). Toda limpeza, transformação e consolidação acontece no Power Query, de modo que o pipeline avaliado continua no Office.
