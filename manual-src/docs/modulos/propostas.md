# Propostas

O coração comercial do CRM: do *lead* à proposta ganha, com **pipeline Kanban**, **modelos por blocos** e **exportação em PDF A4**. Esta página explica o ecrã **botão a botão**.

## O ecrã de Propostas

No topo:

- **Filtro temporal** — limita as propostas a um período (Tudo / 30 dias / Trimestre / Este mês / Este ano, ou datas De–Até). Tudo na página respeita este filtro.
- **KPIs** — número de propostas, valor do pipeline, taxa de conversão e ticket médio (os valores podem aparecer com 🔒 para papéis sem permissão financeira).
- **Vista Lista / Kanban** e o botão **+ Proposta**.

## O pipeline (Kanban)

As propostas estão em colunas por **estado**:

`Lead → Qualificação → Negociação → Ganha → Perdida`

- **Arrastar** um cartão entre colunas muda o estado (e regista quem/quando).
- Cada coluna mostra o **total** ao fundo.
- Ao largar em **Perdida**, a app pede o **motivo da perda** (ver abaixo).
- Propostas **Ganha/Perdida** ficam **bloqueadas** (linhas só leitura) — usa **Reabrir** para voltar a Negociação.

## Criar / editar uma proposta — campo a campo

Clica **+ Proposta** (ou num cartão para editar). O modal tem:

### Cabeçalho
- **Número** — automático (`PROP-{ano}-{nº}`), só leitura.
- **Cliente** — escolhe da lista de contactos. Define o **IVA por região** e o **desconto de loyalty**.
- **Título** — nome da proposta.
- **Validade** — data até à qual é válida.
- **Estado** — Lead / Qualificação / Negociação / Ganha / Perdida.

### Linhas (artigos)
Cada linha:

- **Artigo** — escolhido do **catálogo** (agrupado por família › subfamília). Ao escolher, preenche **descrição** (travada), **preço** e **IVA**.
- **Quantidade**.
- **IVA** — ajusta-se à **região do cliente**; se uma linha tiver IVA de outra região, aparece um aviso com **“Corrigir para {região}”**.
- **➕** adiciona linha, **🗑️** remove.

!!! warning "Linhas têm de vir do catálogo"
    Não há descrição livre: cada linha aponta para um **produto** (garante consistência de preços). Cria primeiro os artigos em **[Produtos](produtos.md)**.

### Totais
Calculados automaticamente: **subtotal**, **desconto de loyalty** (do nível do cliente), **IVA** (recalculado proporcionalmente) e **total**.

### Motivo da perda *(só quando Estado = Perdida)*
- **Motivo** — Preço / Concorrência / Timing / Sem orçamento / Sem resposta / Necessidade mudou / Funcionalidades / Outro.
- **Nota** livre. Alimenta a **Análise de perdas** em [Analytics](analytics.md).

### Rodapé do modal — barra de ações
- **Pré-visualizar** — abre a folha como vai sair no PDF.
- **Descarregar PDF** — gera o documento A4 (ver abaixo).
- **Enviar por email** — abre a janela de envio com o template e o PDF como referência.
- **Guardar**.

## Exportar em PDF (A4)

**Descarregar PDF** abre a janela de impressão do browser → escolhe **Guardar como PDF**. O documento usa o **modelo** da proposta (cabeçalho, logótipo, cotação, totais, condições, assinatura) e os **dados do cliente**. O rodapé fica fixo no fundo da página.

!!! tip "Modelo de proposta"
    O aspeto do PDF define-se em **[Modelos de Proposta](modelos.md)** (construtor por blocos). Cada proposta pode usar um modelo diferente.

## Auditoria

Cada proposta guarda **quem criou/alterou e quando** — visível no rodapé do modal.

!!! note "Permissões"
    Os **formandos** criam e exportam propostas. Valores financeiros podem estar ocultos (🔒) para papéis configurados sem acesso financeiro, sem bloquear o trabalho no editor.

## Relacionado

<div class="grid cards" markdown>

-   <svg class="icon" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg> __Modelos de Proposta__

    ---
    Desenha o aspeto do PDF (blocos, logótipo, condições).

    [:octicons-arrow-right-24: Abrir](modelos.md)

-   <svg class="icon" viewBox="0 0 24 24"><path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="M3 8l9 5 9-5M12 13v8"/></svg> __Produtos__

    ---
    O catálogo que alimenta as linhas da proposta.

    [:octicons-arrow-right-24: Abrir](produtos.md)

-   <svg class="icon" viewBox="0 0 24 24"><path d="M3 3v18h18"/><path d="M7 15l4-5 3 3 5-7"/></svg> __Analytics__

    ---
    Vê as tuas propostas refletidas nos KPIs e no funil.

    [:octicons-arrow-right-24: Abrir](analytics.md)

</div>
