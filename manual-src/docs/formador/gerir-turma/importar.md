# Importar formandos (Excel/CSV)

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/importar.png"><source src="/manual/assets/videos/importar-pt.webm" type="video/webm"><source src="/manual/assets/videos/importar-pt.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/importar-pt.vtt" srclang="pt" label="Português" default></video>

*Importar formandos com pré-visualização e validação.*

A via mais rápida para uma turma inteira.

## Passo a passo

1. **Definições → Formandos da turma → Modelo Excel/CSV** e abre o ficheiro.
2. Preenche **uma linha por formando**. Colunas **obrigatórias**:

    | Coluna | Obrigatória | Notas |
    |---|---|---|
    | `nome` | ✅ | Primeiro nome |
    | `apelido` | ✅ | |
    | `email` | ✅ | Email **IEFP** do formando (aparece nas entregas) |
    | `username` | ✅ | O login (ex.: `joao.silva`) |
    | `password` | — | Pode ficar vazia → usa a *palavra-passe inicial* |
    | `papel` | — | `Formando` (predefinido) ou `Formador` |

3. **Importar lista** → escolhe o ficheiro.
4. Aparece a **pré-visualização**: cada linha **OK** (verde) ou com o **erro** (campo em falta, email inválido, utilizador repetido, já existente).
5. **Importar N válido(s)** — só entram as linhas corretas.

!!! warning "Palavras-passe no Excel"
    Para não pôr palavras-passe no ficheiro, **deixa a coluna vazia** e define a *palavra-passe inicial* (campo por baixo dos botões) — igual para todos. Cada formando muda-a depois.

!!! tip "Os erros não bloqueiam"
    As linhas com erro **não são importadas**; corriges o ficheiro e voltas a importar só essas. As válidas já ficaram criadas.

➡️ A seguir: **[Adicionar individual](adicionar.md)** · voltar a **[Gerir a turma](index.md)**.
