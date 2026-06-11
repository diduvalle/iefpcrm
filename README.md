# IEFP CRM — Plataforma de Formação

Aplicação web pedagógica (ficheiro único) de **CRM** e **Proteção de Dados (RGPD)**, criada para as UFCD **10868 — CRM Analytics** e **10870 — Administração de CRM** do IEFP.

🔗 **Site:** https://iefpcrm.cr0x.org

## Características

- **Single-file**: toda a app vive em [`index.html`](index.html) — sem dependências, abre com duplo-clique ou via web.
- **Módulos**: Dashboard, Empresas & Contactos, Produtos, Propostas (Kanban + PDF A4), Campanhas, Comunicação (email/automação), Analytics, Agenda, RGPD (consentimentos, pedidos de titulares, RoPA, violações), Modelos, Definições.
- **Multi-turma**: ambientes isolados por turma via `?t=12345678`.
- **Portal do Titular** (RGPD) público em `#portal`.
- Tema claro/escuro, PT/EN, dados demo realistas portugueses.

## Alojamento

Servido por **GitHub Pages** a partir da branch `main` (pasta raiz). O domínio personalizado é definido pelo ficheiro [`CNAME`](CNAME). Cada `git push` para `main` publica automaticamente.

## Estrutura

| Ficheiro | Função |
|---|---|
| `index.html` | A aplicação completa (fonte única) |
| `IEFPnormal.png`, `favicon.png` | Logótipo / ícone |
| `background.jpg` | Fundo do ecrã de login |
| `og-image.png` | Imagem de partilha (Open Graph) |
| `perfil.png` | Avatar do administrador |
| `bases/` | Sementes de dados opcionais por turma (`<turma>.json`) |

---

Criado por [Diogo du Valle](https://www.linkedin.com/in/ldvale/).
