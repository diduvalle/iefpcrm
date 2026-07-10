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
- **NIPC** - validado (dígito de controlo). *Bloqueia gravar se inválido.*
- **CAE** e **Setor**.
- **Dimensão (segmento)** - Micro / PME / Grande Empresa.
- **Fase (ciclo de vida)** - **Lead** → **MQL** (*Marketing Qualified Lead*, uma das suas pessoas demonstrou interesse) → **SQL** (*Sales Qualified Lead*, oportunidade real com proposta) → **Cliente** / **Perdido**. A app **infere** a fase e **avança-a** sozinha: *engagement* de email → MQL, proposta → SQL, ganha → Cliente.
- **Origem (aquisição)** - canal por onde a empresa chegou (Website, Recomendação, Feira, Campanha Email…) - base do **funil de aquisição** e do **ROI por origem** no Analytics.
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
- **Email**, **Telefone**, **NIF (pessoal)** - validado.
- **Cidade** e **Região**.
- **Notas**.

### Ficha 360°
Mostra o cartão **Conta · Empresa** (a fase, o loyalty e o valor **da empresa**, com atalho para a ficha dela), a **ficha da pessoa** (contactos, cargo, função), o **histórico de empresa** (moveu-se de A → B) e as **propostas negociadas com esta pessoa**.

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
