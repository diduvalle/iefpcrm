# Settings

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/definicoes.png"><source src="/manual/assets/videos/definicoes-en.webm" type="video/webm"><source src="/manual/assets/videos/definicoes-en.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/definicoes-en.vtt" srclang="en" label="English" default></video>

*Settings, with collapsible cards (several admin-only).*

The **system configuration** (System group). The cards are **collapsible** — click the title to open/close; on the first visit they are collapsed to keep the page compact. Several cards are **administrators only** (*Admin* badge).

## Available cards

### Entity
Data used in proposals and communications: **entity name**, **NIF/NIPC**, **phone**, **email** (the *reply-to* of emails), **city**, **DPO** (Data Protection Officer).

### Data & backup
**Export** / **Import** the full CRM JSON (backup or migration). This is also where you **restore the sample data**.

### Sample data generator
Quickly creates realistic **companies, contacts and proposals** (PT) — adds to the existing data.

### Brand & Appearance *(Admin)*
*White-label*: **name**, **primary color** (derives the palette), **logo**, **login background**. **Apply** / **Reset IEFP**. → [Email & Brand](../formador/email-marca.md).

### Real email sending (EmailJS) *(Admin)*
The **keys** are **fixed** (🔒); you only manage the **mode** (real/simulated) + **Send test**. → [Email & Brand](../formador/email-marca.md).

### User Groups *(Admin)*
**Roles × modules** matrix: defines what each group sees (Administrator/Trainer = everything; Trainee limited). Includes the option to **hide financial values** by group.

### Proposal Templates
Shortcut to the template builder. → [Proposal Templates](modelos.md).

### Other references
**Loyalty levels**, **VAT rates** (by region), **Customer sources** (editable list).

## In class mode (online)

In a class, Settings gain two central cards:

- **Trainees in the class** — access management (import, individual, reset password). → [Manage the class](../formador/gerir-turma/index.md).
- **Submission & validation of work** — receive and grade submissions. → [Submission & validation](../formador/entregas.md).

!!! note "Who sees Settings"
    **Trainees do not access** Settings. It is a **trainer/administrator** space.
