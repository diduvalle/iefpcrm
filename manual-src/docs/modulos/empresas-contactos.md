# Empresas & Contactos

Modelo profissional **Account / Contact** (B2B): as **Empresas** são as entidades legais; os **Contactos** são as pessoas ligadas a essas empresas. São dois menus distintos na barra lateral.

---

## Empresas

### O ecrã
- **Filtro temporal** + **KPIs** (nº de empresas, valor associado).
- **Pesquisa**, **paginação** e o botão **+ Empresa**.
- Clica numa **linha** para abrir a **ficha 360º**.

### Criar / editar — campo a campo
- **Nome** (razão social) *obrigatório*.
- **NIPC** — validado (dígito de controlo). *Bloqueia gravar se inválido.*
- **CAE** e **Setor**.
- **Dimensão** — Micro / PME / Grande Empresa.
- **Morada fiscal**, **Código postal**, **Cidade**.
- **Região** — Continente / Madeira / Açores (influencia o IVA das propostas dos seus contactos).
- **Website**, **Telefone**, **Email**, **Notas**.

### Ficha 360º
Mostra os **dados fiscais**, a **lista de contactos** da empresa e um resumo de **propostas / ganhas / valor**.

---

## Contactos

As pessoas (os antigos "clientes").

### O ecrã
Igual ao das empresas: filtro temporal, KPIs (nº de contactos, valor médio — pode aparecer 🔒), pesquisa, paginação, **+ Contacto**. Clica numa linha → **ficha 360º**.

### Criar / editar — campo a campo
- **Nome** e **Apelido** *(nome obrigatório)*.
- **Empresa** — escolhe da lista de Empresas; **Cargo** na empresa.
- **Email**, **Telefone**.
- **NIF** — validado (dígito de controlo PT).
- **Cidade** e **Região** — a região define a **taxa de IVA** aplicável nas propostas.
- **Segmento** — Lead / Micro / PME / Grande Empresa.
- **Origem** — canal de aquisição (lista editável em Definições): Website, Recomendação, Feira, Campanha Email…
- **Loyalty** — Bronze / Prata / Ouro (recalcula-se pelo volume de compras; dá **desconto** nas propostas).
- **Notas**.

### Ficha 360º
Dados completos, **nível de loyalty**, **propostas** do contacto e histórico.

---

## Importar em massa (CSV)

Tanto em **Contactos** como em **Produtos** há **Importar** + **Modelo**:

1. Descarrega o **modelo** CSV.
2. Preenche (uma linha por registo).
3. **Importar** → os registos são criados; duplicados são ignorados.

!!! tip "Gerar dados de exemplo"
    Em **Definições → Gerador de dados de exemplo** crias rapidamente empresas, contactos e propostas realistas (nomes/NIF PT válidos) para praticares sem partir de zero.

!!! note "Pedagogia (UFCD 10868)"
    Praticas a modelação de dados de um CRM real (entidade vs pessoa), a **qualidade de dados** (validação de NIF/NIPC), a **segmentação** e o **loyalty** — base da análise de clientes.
