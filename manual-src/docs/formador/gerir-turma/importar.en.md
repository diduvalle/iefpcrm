# Importing trainees (Excel/CSV)

The fastest route for a whole class.

## Step by step

1. **Settings → Class trainees → Excel/CSV template** and open the file.
2. Fill in **one row per trainee**. **Required** columns:

    | Column | Required | Notes |
    |---|---|---|
    | `nome` | ✅ | First name |
    | `apelido` | ✅ | |
    | `email` | ✅ | The trainee's **IEFP** email (appears in submissions) |
    | `username` | ✅ | The login (e.g.: `joao.silva`) |
    | `password` | — | Can be left empty → uses the *initial password* |
    | `papel` | — | `Formando` (default) or `Formador` |

3. **Import list** → choose the file.
4. The **preview** appears: each row is either **OK** (green) or has an **error** (missing field, invalid email, duplicate username, already existing).
5. **Import N valid** — only the correct rows are added.

!!! warning "Passwords in Excel"
    To avoid putting passwords in the file, **leave the column empty** and set the *initial password* (field below the buttons) — the same for everyone. Each trainee changes it afterwards.

!!! tip "Errors don't block"
    Rows with errors **are not imported**; you fix the file and re-import just those. The valid ones have already been created.

➡️ Next: **[Add individually](adicionar.md)** · back to **[Managing the class](index.md)**.
