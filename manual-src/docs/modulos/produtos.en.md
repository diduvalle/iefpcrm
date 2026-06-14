# Products

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/produtos.png"><source src="/manual/assets/videos/produtos-en.webm" type="video/webm"><source src="/manual/assets/videos/produtos-en.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/produtos-en.vtt" srclang="en" label="English" default></video>

*The catalog by family, subfamily and item.*

The catalog that feeds the **proposal lines**. It is organized into three levels: **Family → Subfamily → Item**.

## The structure

| Level | Example | What it is for |
|---|---|---|
| **Family** | "Software" | Groups large areas |
| **Subfamily** | "CRM Licenses" | Subdivides the family |
| **Item** | "CRM Pro License" | The sellable product/service |

The **codes** are generated automatically; you don't have to invent them.

## Create step by step

1. Open **Products** (Main group).
2. **+ Family** → give it a name → save.
3. **+ Subfamily** → choose the family → name → save.
4. **+ Item** → fill in:
    - **Name**, **family** and **subfamily**.
    - **Type** (Product / Service) and **model** (e.g.: Annual).
    - **Price** and **VAT** (chosen from the list of rates by region).
    - **Status** (Available / Unavailable) — *Unavailable* ones do not appear in proposals.

## Bulk import (CSV)

**Import** button → download the **template** (columns `nome;familia;subfamilia;tipo;modelo;preco;iva;estado`) → fill it in → import. Missing families/subfamilies are created automatically.

!!! tip "VAT by region"
    The item stores the **rate type** (Standard/Intermediate/Reduced). When you use it in a proposal, the VAT adjusts to the **customer's region** (Mainland 23/13/6, Madeira 22/12/5, Azores 16/9/4).

!!! note "Link to proposals"
    In proposals, the lines are chosen **from this catalog** — description, price and VAT fill in by themselves. See **[Proposals](propostas/index.md)**.
