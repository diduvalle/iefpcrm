# Campanhas & Email

Dois menus: **Campanhas** (planeamento de marketing) e **Email/Comunicação** (envio e acompanhamento).

---

## Campanhas

### O ecrã
Filtro temporal + lista de campanhas (nome, canal, segmento, estado, métricas) + **+ Campanha** e **✨ Gerar de persona**.

### Criar — campo a campo
- **Nome**, **Canal** (Email / SMS / Redes Sociais).
- **Segmento**-alvo (Todos / Micro / PME / Grande Empresa).
- **Estado** (Planeada / Ativa…), **Início** e **Fim**.
- **Template** de email associado.

### Gerador por persona (✨)
1. Clica **Gerar de persona**.
2. Escolhe uma **persona** (ex.: Zé Miguel — hoteleiro; Sofia — diretora comercial; António — comerciante).
3. Define **Objetivo** (Aquisição/Fidelização/Reativação/Lançamento) e **Canal**.
4. A app mostra a **audiência estimada** no segmento e uma **mensagem sugerida** → **Gerar**.

### Enviar
**Enviar** dispara para os contactos do segmento e regista os envios no **Histórico** (com origem "Campanha").

---

## Email / Comunicação

### Separadores
- **Histórico de envios** — tabela rica; clica num envio para ver a pré-visualização e reenviar.
- **Templates** — modelos de email.
- **Automações** — regras automáticas.
- **Agendados** — fila de envios futuros.

### Compositor (módulo Email)
- **Cliente** — por **pesquisa** (não dropdown gigante).
- **Template** — pré-preenche assunto + mensagem.
- **CC / BCC**, **Assunto**, **Mensagem** (textarea).
- **Pré-visualização ao vivo** + **chip de modo** (real/simulado).
- **Sugerir com IA** *(simulado)* — gera um rascunho personalizado.
- A **assinatura** do utilizador entra automaticamente no fim.

### Templates de email — campo a campo
Nome, assunto, cor, mostrar logótipo, saudação, corpo, texto/​link do botão, assinatura. Usa **tags** (`{{cliente.nome}}`, `{{entidade.nome}}`).

### Automações (marketing automation)
Regras **gatilho → email**:

- **Gatilho:** novo cliente / proposta criada / proposta enviada / proposta ganha.
- **Condição de segmento** (Todos / Micro / PME / Grande).
- **Passos** em sequência, cada um com **atraso (dias)** → vão para **Agendados**.
- Toggle **Ativa/Inativa** + contador de disparos.

### Métricas
Taxa de **abertura** e **cliques** por envio e agregadas.

!!! warning "Envio real vs simulado · rastreio"
    Os **formandos** enviam sempre em **simulado** (seguro). As métricas de abertura/clique no ambiente pedagógico são **simuladas** — a app explica que o rastreio real exige pixel + servidor.

## Relacionado

<div class="grid cards" markdown>

-   <svg class="icon" viewBox="0 0 24 24"><circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2M16 3.1A4 4 0 0 1 16 11M21 21v-2a4 4 0 0 0-3-3.8"/></svg> __Contactos__

    ---
    A base de clientes que vais segmentar nas campanhas.

    [:octicons-arrow-right-24: Abrir](empresas-contactos.md)

-   <svg class="icon" viewBox="0 0 24 24"><path d="M3 3v18h18"/><path d="M7 15l4-5 3 3 5-7"/></svg> __Analytics__

    ---
    Mede o impacto das campanhas (aberturas, cliques, conversão).

    [:octicons-arrow-right-24: Abrir](analytics.md)

</div>
