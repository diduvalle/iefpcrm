# Empresas & Contactos

Modelo profissional **Account / Contact** (B2B): as **Empresas** são as entidades legais; os **Contactos** são as pessoas ligadas a essas empresas. São dois menus distintos na barra lateral.

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/clientes.png"><source src="/manual/assets/videos/contactos-pt.webm" type="video/webm"><source src="/manual/assets/videos/contactos-pt.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/contactos-pt.vtt" srclang="pt" label="Português" default></video>

*O separador Contactos - ficha completa e visão 360° de cada cliente.*

---

## Empresas

### O ecrã
- **Filtro temporal** + **KPIs** (nº de empresas, valor associado).
- **Pesquisa**, **paginação** e o botão **+ Empresa**.
- Clica numa **linha** para abrir a **ficha 360°**.

### Criar / editar - campo a campo
- **Nome** (razão social) *obrigatório*.
- **NIPC** - validado (dígito de controlo). *Bloqueia gravar se inválido.*
- **CAE** e **Setor**.
- **Dimensão** - Micro / PME / Grande Empresa.
- **Morada fiscal**, **Código postal**, **Cidade**.
- **Região** - Continente / Madeira / Açores (influencia o IVA das propostas dos seus contactos).
- **Website**, **Telefone**, **Email**, **Notas**.

### Ficha 360°
Mostra os **dados fiscais**, a **lista de contactos** da empresa, o **nível de loyalty** da empresa e um resumo de **propostas / ganhas / valor ganho**. É aqui que vive o histórico comercial - porque **a venda pertence à empresa**, não à pessoa.

!!! note "As vendas e o loyalty são da **Empresa**, não do contacto"
    A venda (proposta) e o valor ficam ancorados à **empresa**: uma pessoa pode **mudar de empresa** e o histórico **não vai com ela** - fica na conta onde o negócio aconteceu. O **loyalty** (Bronze/Prata/Ouro) também é da **empresa**, calculado pelo **volume de compras da empresa**; cada contacto **herda** o nível da sua empresa. Um contacto **sem empresa** (particular) usa o **seu próprio** volume. O **desconto** da proposta vem sempre do nível da **conta** (empresa ou, no particular, do contacto).

---

## Contactos

As pessoas (os antigos "clientes").

### O ecrã
Igual ao das empresas: filtro temporal, KPIs (nº de contactos, valor médio - pode aparecer 🔒, **Leads quentes** com score ≥ 70), pesquisa, paginação, **+ Contacto**. Clica numa linha → **ficha 360°**.

Há ainda um **filtro por Fase do lead** (chips: Todas / Lead / MQL / SQL / Cliente / Perdido) e cada linha mostra o **selo de score** (Quente / Morno / Frio) ao lado do nome - para priorizares o esforço comercial de relance.

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/clientes.png"><source src="/manual/assets/videos/gestao-leads-pt.webm" type="video/webm"><source src="/manual/assets/videos/gestao-leads-pt.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/gestao-leads-pt.vtt" srclang="pt" label="Português" default></video>

*Gestão de leads: fase do ciclo de vida, lead scoring, filtro por fase e o funil de aquisição no Analytics.*

### Criar / editar - campo a campo
- **Nome** e **Apelido** *(nome obrigatório)*.
- **Empresa** - escolhe da lista de Empresas; **Cargo** na empresa.
- **Email**, **Telefone**.
- **NIF** - validado (dígito de controlo PT).
- **Cidade** e **Região** - a região define a **taxa de IVA** aplicável nas propostas.
- **Segmento** - Lead / Micro / PME / Grande Empresa.
- **Fase (ciclo de vida)** - **Lead** → **MQL** (*Marketing Qualified Lead*, já demonstrou interesse) → **SQL** (*Sales Qualified Lead*, oportunidade real com proposta) → **Cliente** / **Perdido**. Qualificar o lead diz qual é o **próximo passo**. A app **infere** a fase inicial a partir das propostas e do *engagement* de email.
- **Origem** - canal de aquisição (lista editável em Definições): Website, Recomendação, Feira, Campanha Email… - base do **funil de aquisição** e do **ROI por origem** no Analytics.
- **Notas**.

O **loyalty não se edita aqui**: é **herdado da empresa** (calculado automaticamente pelo volume de compras da empresa). Ver a caixa acima.

### Ficha 360°
Dados completos, o **nível de loyalty herdado da empresa**, as **propostas** negociadas com o contacto e o histórico.

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
