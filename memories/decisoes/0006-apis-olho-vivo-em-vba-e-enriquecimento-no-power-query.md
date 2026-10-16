# Olho Vivo via VBA; Open-Meteo e BrasilAPI via Power Query

A API Olho Vivo autentica por cookie de sessão (`POST /Login/Autenticar`), e o `Web.Contents` do Power Query não mantém essa sessão. Por isso o cliente da Olho Vivo é escrito em VBA com um único objeto `WinHttp.WinHttpRequest.5.1`, que guarda o cookie entre as chamadas. Isso também mostra consumo de API dentro das ferramentas do curso.

Escopo:

- **base**: dados estáticos (linhas, paradas, corredores, empresas) para enriquecer `Dim_Transporte` e `Dim_Localizacao`;
- **extra**, só se sobrar tempo: um coletor agendado de posição e previsão nas faixas 07h/10h/18h.

Open-Meteo (clima por hora) e BrasilAPI (feriados) não exigem autenticação e entram direto no Power Query. Elas garantem a Etapa 5 mesmo que o cadastro no DevPlace da SPTrans atrase.
