# Gerir a turma

Tudo o que toca aos **acessos dos formandos** está em **Definições → Formandos da turma**. Os acessos vivem *online* (ligados à tua turma); os **dados de trabalho** ficam na *sandbox* de cada formando.

## Importar formandos (Excel/CSV)

A via mais rápida para uma turma inteira.

1. Clica em **Modelo Excel/CSV** e abre o ficheiro.
2. Preenche uma linha por formando. Colunas **obrigatórias**:

    | Coluna | Obrigatória | Notas |
    |---|---|---|
    | `nome` | ✅ | Primeiro nome |
    | `apelido` | ✅ | |
    | `email` | ✅ | Email **IEFP** do formando (é o que aparece nas entregas) |
    | `username` | ✅ | O login (ex.: `joao.silva`) |
    | `password` | ✅ | Pode ficar vazia → usa a *palavra-passe inicial* |
    | `papel` | — | `Formando` (predefinido) ou `Formador` |

3. Clica **Importar lista** e escolhe o ficheiro.
4. Aparece uma **pré-visualização**: cada linha marcada como **OK** ou com o **erro** (campo em falta, email inválido, utilizador repetido, já existente).
5. Confirma em **Importar N válido(s)** — só entram as linhas corretas.

!!! warning "Passwords no Excel"
    Se preferires não pôr passwords no ficheiro, **deixa a coluna vazia** e define a *palavra-passe inicial* (campo por baixo dos botões) — igual para todos. Cada formando muda-a depois no perfil.

## Adicionar um formando individual

No formulário **Adicionar individualmente**: nome, apelido, email, utilizador (gerado automaticamente se vazio), palavra-passe e papel → **Adicionar à turma**.

## Repor a palavra-passe de um formando

Na lista de formandos, no formando pretendido, clica **Repor palavra-passe** e define uma nova. Comunica-a ao formando.

## Remover um formando

Botão **✕** na linha do formando. O acesso deixa de funcionar; **os dados locais no computador dele não são afetados**.

!!! tip "Cada formando só vê a sua turma"
    Um acesso está ligado a **uma** turma. O mesmo formando noutra turma precisa de outro acesso.
