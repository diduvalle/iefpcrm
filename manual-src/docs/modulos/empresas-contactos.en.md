# Companies & Contacts

Professional **Account / Contact** model (B2B): **Companies** are the legal entities; **Contacts** are the people linked to those companies. They are two separate menus in the sidebar.

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/clientes.png"><source src="/manual/assets/videos/contactos-en.mp4" type="video/mp4"></video>

*The Contacts tab — full record and 360° view of each client.*

---

## Companies

### The screen
- **Date filter** + **KPIs** (number of companies, associated value).
- **Search**, **pagination** and the **+ Company** button.
- Click a **row** to open the **360° profile**.

### Create / edit — field by field
- **Name** (legal name) *required*.
- **NIPC** — validated (check digit). *Blocks saving if invalid.*
- **CAE** and **Sector**.
- **Size** — Micro / SME / Large Enterprise.
- **Tax address**, **Postal code**, **City**.
- **Region** — Mainland / Madeira / Azores (affects the VAT on its contacts' proposals).
- **Website**, **Phone**, **Email**, **Notes**.

### 360° profile
Shows the **tax data**, the company's **contact list** and a summary of **proposals / won / value**.

---

## Contacts

The people (the former "customers").

### The screen
Same as companies: date filter, KPIs (number of contacts, average value — may appear 🔒), search, pagination, **+ Contact**. Click a row → **360° profile**.

### Create / edit — field by field
- **First name** and **Last name** *(name required)*.
- **Company** — pick from the Companies list; **Job title** at the company.
- **Email**, **Phone**.
- **NIF** — validated (PT check digit).
- **City** and **Region** — the region sets the **VAT rate** applicable on proposals.
- **Segment** — Lead / Micro / SME / Large Enterprise.
- **Source** — acquisition channel (editable list in Settings): Website, Referral, Trade fair, Email Campaign…
- **Loyalty** — Bronze / Silver / Gold (recalculated by purchase volume; gives a **discount** on proposals).
- **Notes**.

### 360° profile
Full data, **loyalty level**, the contact's **proposals** and history.

---

## Bulk import (CSV)

Both **Contacts** and **Products** have **Import** + **Template**:

1. Download the CSV **template**.
2. Fill it in (one row per record).
3. **Import** → the records are created; duplicates are ignored.

!!! tip "Generate sample data"
    In **Settings → Sample data generator** you can quickly create realistic companies, contacts and proposals (valid PT names/NIF) to practice without starting from scratch.

!!! note "Pedagogy (UFCD 10868)"
    You practice modeling the data of a real CRM (entity vs person), **data quality** (NIF/NIPC validation), **segmentation** and **loyalty** — the basis of customer analysis.

## Related

<div class="grid cards" markdown>

-   <svg class="icon" viewBox="0 0 24 24"><path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="M3 8l9 5 9-5M12 13v8"/></svg> __Products__

    ---
    Create the catalog before making proposals to these customers.

    [:octicons-arrow-right-24: Open](produtos.md)

-   <svg class="icon" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M9 13h6M9 17h6"/></svg> __Proposals__

    ---
    Create proposals for the contacts you registered.

    [:octicons-arrow-right-24: Open](propostas/index.md)

</div>
