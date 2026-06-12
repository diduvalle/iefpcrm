# Produtos

O catálogo que alimenta as **linhas das propostas**. Está organizado em três níveis: **Família → Subfamília → Artigo**.

## A estrutura

| Nível | Exemplo | Para que serve |
|---|---|---|
| **Família** | "Software" | Agrupa grandes áreas |
| **Subfamília** | "Licenças CRM" | Subdivide a família |
| **Artigo** | "Licença CRM Pro" | O produto/serviço vendável |

Os **códigos** são gerados automaticamente; não tens de os inventar.

## Criar passo a passo

1. Abre **Produtos** (grupo Principal).
2. **+ Família** → dá um nome → guardar.
3. **+ Subfamília** → escolhe a família → nome → guardar.
4. **+ Artigo** → preenche:
    - **Nome**, **família** e **subfamília**.
    - **Tipo** (Produto / Serviço) e **modelo** (ex.: Anual).
    - **Preço** e **IVA** (escolhido da lista de taxas por região).
    - **Estado** (Disponível / Indisponível) — os *Indisponíveis* não aparecem nas propostas.

## Importar em massa (CSV)

Botão **Importar** → descarrega o **modelo** (colunas `nome;familia;subfamilia;tipo;modelo;preco;iva;estado`) → preenche → importa. Famílias/subfamílias em falta são criadas automaticamente.

!!! tip "IVA por região"
    O artigo guarda o **tipo de taxa** (Normal/Intermédia/Reduzida). Ao usá-lo numa proposta, o IVA ajusta-se à **região do cliente** (Continente 23/13/6, Madeira 22/12/5, Açores 16/9/4).

!!! note "Ligação às propostas"
    Nas propostas, as linhas escolhem-se **deste catálogo** — descrição, preço e IVA preenchem-se sozinhos. Vê **[Propostas](propostas.md)**.
