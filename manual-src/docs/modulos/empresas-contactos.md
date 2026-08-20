# Empresas & Contactos

Modelo profissional **Account / Contact** (B2B): as **Empresas** são as entidades legais; os **Contactos** são as pessoas ligadas a essas empresas. São dois menus distintos na barra lateral.

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/clientes.png"><source src="/manual/assets/videos/contactos-pt.webm" type="video/webm"><source src="/manual/assets/videos/contactos-pt.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/contactos-pt.vtt" srclang="pt" label="Português" default></video>

*O separador Contactos - ficha completa e visão 360° de cada cliente.*

---

## Empresas

A **empresa é a conta comercial**: é aqui que vive a venda, o valor, o loyalty e a **gestão de leads**.

### O ecrã
- **KPIs**: nº de empresas, **Leads quentes** (score ≥ 70), **Clientes** (fase = Cliente) e **valor ganho**.
- **Filtro por Fase do lead** (chips: Todas / Lead / MQL / SQL / Cliente / Perdido) e, em cada linha, o **selo de score** (Quente / Morno / Frio).
- **Pesquisa**, **paginação** e **+ Empresa**. Clica numa **linha** → **ficha 360°**.

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/clientes.png"><source src="/manual/assets/videos/gestao-leads-pt.webm" type="video/webm"><source src="/manual/assets/videos/gestao-leads-pt.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/gestao-leads-pt.vtt" srclang="pt" label="Português" default></video>

*Gestão de leads na empresa: fase do ciclo de vida, lead score, filtro por fase e o funil de aquisição.*

### Criar / editar - campo a campo
- **Nome** (razão social) *obrigatório*.
- **NIPC** - validado (dígito de controlo). Ao escrever, mostra em tempo real se é válido e o **tipo de entidade** (empresa, pessoa singular, ENI…). O botão **Procurar** preenche automaticamente os dados da empresa (nome, morada, CAE, contactos) pelo NIPC. *Bloqueia gravar se inválido.*
- **CAE** e **Setor**.
- **Dimensão (segmento)** - Micro / PME / Grande Empresa.
- **Fase (ciclo de vida)** - **Lead** → **MQL** (*Marketing Qualified Lead*, uma das suas pessoas demonstrou interesse) → **SQL** (*Sales Qualified Lead*, oportunidade real com proposta) → **Cliente** / **Perdido**. A app **infere** a fase e **avança-a** sozinha: *engagement* de email → MQL, proposta → SQL, ganha → Cliente.
- **Origem (aquisição)** - canal por onde a empresa chegou (Website, Recomendação, Feira, Campanha Email…) - base do **funil de aquisição** e do **ROI por origem** no Analytics. Ao escolher **Outro**, abre uma caixa para **especificar qual** (ver abaixo).
- **Morada fiscal**, **Código postal**, **Cidade**.
- **Região** - Continente / Madeira / Açores (influencia o IVA das propostas).
- **Website**, **Telefone**, **Email**, **Notas**.

### Ficha 360°
Mostra a **fase de lead** e o **lead score** da empresa (que **agrega o engagement de todas as suas pessoas**), a **origem**, o **loyalty**, os **dados fiscais**, a **lista de pessoas** e um resumo de **propostas / ganhas / valor ganho**.

!!! note "A gestão de leads e o valor são da **Empresa**, não do contacto"
    A venda (proposta), o **valor**, o **loyalty**, o **segmento** (dimensão) e a **fase de lead** são todos da **empresa**. Uma pessoa pode **mudar de empresa** e o histórico **não vai com ela** - fica na conta onde o negócio aconteceu. O **lead score** da empresa sobe quando **qualquer uma das suas pessoas** abre/clica emails; quem **fecha** a venda é um contacto (fica registado na proposta), mas o negócio é da empresa. Para um cliente em **nome individual (ENI)**, cria-se a **empresa a partir do contacto** (botão na ficha, um clique) - continua a ser uma empresa. Um contacto **sem empresa** é apenas uma entrada no **diretório**, sem venda, fase nem valor.

---

## Contactos

As pessoas - um **diretório**, como as **páginas amarelas**. O contacto **não tem** venda, valor, loyalty nem segmento próprios (isso é da empresa); guarda a **identidade**, a **empresa atual**, o **cargo/função** e o **histórico de mudanças de empresa**.

### O ecrã
- **KPIs**: total de contactos, **ligados a empresa**, **particulares** e **empresas distintas**.
- **Pesquisa**, **paginação** e **+ Contacto**. Clica numa linha → **ficha 360°**.
- Cada linha mostra a **empresa** (com a **fase de lead da empresa**, como referência), o **cargo/função** e o telefone.

### Criar / editar - campo a campo
- **Nome** e **Apelido** *(nome obrigatório)*.
- **Empresa** - escolhe da lista de Empresas (pode ficar **sem empresa** - fica só no diretório; para lhe vender, cria a empresa a partir da ficha); **Cargo** e **Função** (a quem recorrer: dono, financeiro…).
- **Email**, **Telefone** (principais - usados nos envios), **NIF (pessoal)** - validado.
- **Contactos adicionais** - lista com quantos emails/telefones quiseres, cada um com **tipo** (Email/Telefone) e **rótulo** (Pessoal / Profissional / Outro). Útil quando a pessoa tem contactos pessoais e profissionais.
- **Cidade** e **Região**.
- **Notas**.

### Ficha 360°
Mostra o cartão **Conta · Empresa** (a fase, o loyalty e o valor **da empresa**, com atalho para a ficha dela), a **ficha da pessoa** (contactos, cargo, função), os **contactos adicionais**, o **histórico de empresa** (moveu-se de A → B) e as **propostas negociadas com esta pessoa**.

!!! tip "Atalhos"
    Clica no **email** da ficha para abrir o compositor do CRM já com o contacto como destinatário; clica no **telefone** para ligar (`tel:`). Na empresa, o botão **Procurar** (no NIPC) preenche a ficha a partir dos registos oficiais.

### "Outro" pede sempre o quê
Nos campos **Função na empresa** (contacto) e **Origem (aquisição)** (empresa), escolher **Outro** abre uma **caixa para especificar**. O que escreveres aparece a seguir ao valor - *"Outro: Formador externo"* - na ficha, na gaveta e nas tabelas.

Escolher outro valor **fecha a caixa e apaga** o texto, para não ficar informação escondida por trás de uma opção que já não está selecionada.

!!! tip "Porque não escrever direto no campo"
    O valor continua a ser **Outro**, e é isso que faz os agrupamentos funcionarem: no funil de aquisição e no ROI por origem, esses casos continuam a somar todos em *Outro*, em vez de se dispersarem em dezenas de rótulos únicos. O texto livre é a **explicação**, não a categoria.

### Campos personalizados
Nenhum CRM adivinha o que o teu negócio precisa de guardar. Se te falta um campo - **Matrícula**, **Nº de sócio**, **Data de renovação** - crias tu:

1. Abre um contacto (ou **+ Novo contacto**) e clica **+ Campo personalizado**, no fim do formulário.
2. Dá-lhe um **título** e escolhe o **tipo**: texto, texto longo, número, data ou lista de opções.
3. **Criar** - o campo aparece logo ali, sem perderes o que já tinhas escrito.

!!! info "O campo é da tua base de dados, não daquele contacto"
    Um campo criado passa a existir em **todos os contactos**. É isso que permite usá-lo como **tag** nos modelos. Geres a lista em **Definições → Campos personalizados**, onde podes **desativar** (esconde o campo mas guarda o que já foi preenchido) ou **apagar** (remove só a definição).

#### Usar nos modelos
Cada campo ganha automaticamente uma tag `{{cliente.<chave>}}` - por exemplo `{{cliente.matricula}}` - que aparece **sozinha** na lista de tags do construtor de **modelos de proposta** e do editor de **modelos de email**. Não há nada a configurar: cria o campo, e a tag está lá.

!!! warning "Um campo personalizado é dado pessoal"
    Tudo o que guardares nestes campos entra no **Relatório de acesso (art. 15.º)** e na **exportação JSON** do titular, tal como os campos de origem. Vale a pena discutir com a turma: *criar um campo é fácil, mas cada campo novo é mais um dado pessoal que passas a ter de justificar, conservar e mostrar a quem o pedir* (minimização - art. 5.º/1 c)).

---

## Importar em massa (CSV)

Tanto em **Contactos** como em **Produtos** há **Importar** + **Modelo**:

1. Descarrega o **modelo** CSV.
2. Preenche (uma linha por registo).
3. **Importar** → os registos são criados; duplicados são ignorados.

!!! tip "Gerar dados de exemplo"
    Em **Definições → Gerador de dados de exemplo** crias rapidamente empresas, contactos e propostas realistas (nomes/NIF PT válidos) para praticares sem partir de zero.

!!! note "Pedagogia (UFCD 10868)"
    Praticas a modelação de dados de um CRM real (entidade vs pessoa), a **qualidade de dados** (validação de NIF/NIPC), a **segmentação**, o **loyalty** e a **gestão de leads** (ciclo de vida Lead → Cliente, *lead scoring*, qualificação) - base da análise de clientes.

## Relacionado

<div class="grid cards" markdown>

-   <svg class="icon" viewBox="0 0 24 24"><path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="M3 8l9 5 9-5M12 13v8"/></svg> __Produtos__

    ---
    Cria o catálogo antes de fazer propostas a estes clientes.

    [:octicons-arrow-right-24: Abrir](produtos.md)

-   <svg class="icon" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M9 13h6M9 17h6"/></svg> __Propostas__

    ---
    Cria propostas para os contactos que registaste.

    [:octicons-arrow-right-24: Abrir](propostas/index.md)

</div>
