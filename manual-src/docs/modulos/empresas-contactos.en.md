# Companies & Contacts

Professional **Account / Contact** model (B2B): **Companies** are the legal entities; **Contacts** are the people linked to those companies. They are two separate menus in the sidebar.

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/clientes.png"><source src="/manual/assets/videos/contactos-en.webm" type="video/webm"><source src="/manual/assets/videos/contactos-en.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/contactos-en.vtt" srclang="en" label="English" default></video>

*The Contacts tab - full record and 360° view of each client.*

---

## Companies

The **company is the commercial account**: this is where the sale, the value, the loyalty and **lead management** live.

### The screen
- **KPIs**: number of companies, **Hot leads** (score ≥ 70), **Customers** (stage = Customer) and **value won**.
- **Lead stage filter** (chips: All / Lead / MQL / SQL / Customer / Lost) and, on each row, the **score badge** (Hot / Warm / Cold).
- **Search**, **pagination** and **+ Company**. Click a **row** → **360° profile**.

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/clientes.png"><source src="/manual/assets/videos/gestao-leads-en.webm" type="video/webm"><source src="/manual/assets/videos/gestao-leads-en.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/gestao-leads-en.vtt" srclang="en" label="English" default></video>

*Lead management on the company: lifecycle stage, lead score, the stage filter and the acquisition funnel.*

### Create / edit - field by field
- **Name** (legal name) *required*.
- **NIPC** - validated (check digit). As you type, it shows in real time whether it is valid and the **entity type** (company, individual, sole trader…). The **Look up** button auto-fills the company's data (name, address, CAE, contacts) from the NIPC. *Blocks saving if invalid.*
- **CAE** and **Sector**.
- **Size (segment)** - Micro / SME / Large Enterprise.
- **Stage (lifecycle)** - **Lead** → **MQL** (*Marketing Qualified Lead*, one of its people has shown interest) → **SQL** (*Sales Qualified Lead*, a real opportunity with a proposal) → **Customer** / **Lost**. The app **infers** the stage and **advances it** on its own: email *engagement* → MQL, proposal → SQL, won → Customer.
- **Source (acquisition)** - the channel the company came through (Website, Referral, Trade fair, Email Campaign…) - the basis of the **acquisition funnel** and **ROI by source** in Analytics.
- **Tax address**, **Postal code**, **City**.
- **Region** - Mainland / Madeira / Azores (affects the VAT on proposals).
- **Website**, **Phone**, **Email**, **Notes**.

### 360° profile
Shows the company's **lead stage** and **lead score** (which **aggregates the engagement of all its people**), the **source**, the **loyalty**, the **tax data**, the **list of people** and a summary of **proposals / won / value won**.

!!! note "Lead management and value belong to the **Company**, not the contact"
    The sale (proposal), the **value**, the **loyalty**, the **segment** (size) and the **lead stage** all belong to the **company**. A person can **change company** and the history **does not follow them** - it stays on the account where the deal happened. The company's **lead score** rises when **any of its people** opens/clicks emails; the one who **closes** the sale is a contact (recorded on the proposal), but the deal is the company's. For a **sole trader (ENI)**, create the **company from the contact** (a one-click button on the profile) - it is still a company. A contact **without a company** is just a **directory** entry, with no sale, stage or value.

---

## Contacts

The people - a **directory**, like the **Yellow Pages**. A contact **has no** sale, value, loyalty or segment of its own (that belongs to the company); it holds the **identity**, the **current company**, the **job title/role** and the **history of company changes**.

### The screen
- **KPIs**: total contacts, **linked to a company**, **individuals** and **distinct companies**.
- **Search**, **pagination** and **+ Contact**. Click a row → **360° profile**.
- Each row shows the **company** (with the **company's lead stage**, as a reference), the **job title/role** and the phone.

### Create / edit - field by field
- **First name** and **Last name** *(name required)*.
- **Company** - pick from the Companies list (can be left **without a company** - it stays in the directory only; to sell to them, create the company from the profile); **Job title** and **Role** (who to turn to: owner, finance…).
- **Email**, **Phone** (primary - used for sending), **NIF (personal)** - validated.
- **Additional contacts** - a list with as many emails/phones as you need, each with a **type** (Email/Phone) and a **label** (Personal / Work / Other). Useful when a person has personal and professional contacts.
- **City** and **Region**.
- **Notes**.

### 360° profile
Shows the **Account · Company** card (the **company's** stage, loyalty and value, with a shortcut to its profile), the **person's details** (contacts, job title, role), the **additional contacts**, the **company history** (moved from A → B) and the **proposals negotiated with this person**.

!!! tip "Shortcuts"
    Click the **email** on the profile to open the CRM composer with the contact already set as recipient; click the **phone** to call (`tel:`). On a company, the **Look up** button (on the NIPC) fills the profile from the official records.

---

## Bulk import (CSV)

Both **Contacts** and **Products** have **Import** + **Template**:

1. Download the CSV **template**.
2. Fill it in (one row per record).
3. **Import** → the records are created; duplicates are ignored.

!!! tip "Generate sample data"
    In **Settings → Sample data generator** you can quickly create realistic companies, contacts and proposals (valid PT names/NIF) to practice without starting from scratch.

!!! note "Pedagogy (UFCD 10868)"
    You practice modeling the data of a real CRM (entity vs person), **data quality** (NIF/NIPC validation), **segmentation**, **loyalty** and **lead management** (Lead → Customer lifecycle, *lead scoring*, qualification) - the basis of customer analysis.

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
