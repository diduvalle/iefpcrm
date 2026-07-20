# Create the proposal

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/criar-proposta.png"><source src="/manual/assets/videos/criar-proposta-en.webm" type="video/webm"><source src="/manual/assets/videos/criar-proposta-en.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/criar-proposta-en.vtt" srclang="en" label="English" default></video>

*Creating a proposal, from client to totals.*

Click **+ Proposal** (or an existing card to edit). The modal opens with the proposal header.

## Field by field

| Field | Notes |
|---|---|
| **Number** | Automatic (`PROP-{year}-{no.}`), read-only - resets each year. |
| **Company (buyer)** | The **company** you are selling to - the **anchor of the sale**. Value, loyalty and discount live here. Search by name or NIPC. *(A sale to an individual has no company.)* |
| **Contact (who you negotiate with)** | The person at the company you talk to. Choosing the contact **auto-fills the company**. It is informative: if the person **changes company**, the sale **does not follow them** - it stays with the company. |
| **Loyalty months** | Duration of the **recurring SaaS** commitment; it feeds the total contract value (TCV). |
| **Title** | Name of the proposal (e.g. *CRM Licensing*). |
| **Validity** | Date up to which the proposal is valid. |
| **Status** | **Created / Sent / Negotiation / Won / Lost.** Moving to *Lost* records the **loss reason**. |

**VAT** uses the **company's region** and the **discount** comes from the **company's loyalty tier** (or the contact's, for an individual) - see [Companies & Contacts](../empresas-contactos.md).

## Step by step

1. **Proposals → + Proposal**.
2. Choose the **Company** (the anchor of the sale) and the **Contact** you negotiate with.
3. Set the **loyalty months** (SaaS), the **title** and the **validity**.
4. Add the **[catalogue lines](linhas.md)** (each is One-off or Monthly/Annual/recurring).
5. **Save**.

## Customer interest level

Each proposal has an **Interest level** field - how interested the customer is in *this* deal, based on their feedback:

| Level | Colour |
|---|---|
| Unclassified | grey (neutral) |
| Cold | blue |
| Warm | orange |
| Hot | red |

In the **[Pipeline](pipeline.md)**, proposals in play (Sent / Negotiation) stop being white and get **tinted** with the level colour (left bar + subtle background), so you read each deal's "temperature" at a glance. In addition, the **Won** column gets a **green** tone and the **Lost** column a **red** tone (with a red total), so the terminal states read instantly.

!!! tip "Audit trail"
    The proposal records **who created/changed it and when** - visible in the modal footer.

➡️ Next: **[Lines & catalogue](linhas.md)** · back to **[Proposals](index.md)**.
