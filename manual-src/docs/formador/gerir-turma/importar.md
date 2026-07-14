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
    | `email` | ✅ | Email **IEFP** do formando (o principal; gera o utilizador e a palavra-passe) |
    | `email_pessoal` | - | Email pessoal (opcional) - o **convite vai para os dois** |
    | `username` | ✅ | O login (ex.: `joao.silva`) |
    | `password` | - | Pode ficar vazia → usa a *palavra-passe inicial* |
    | `papel` | - | `Formando` (predefinido) ou `Formador` |

3. **Importar lista** → escolhe o ficheiro.
4. Aparece a **pré-visualização**: cada linha **OK** (verde) ou com o **erro** (campo em falta, email inválido, utilizador repetido, já existente).
5. **Importar N válido(s)** - só entram as linhas corretas.

!!! info "Os convites **não** são enviados na importação"
    Importar **cria as contas**, mas **não envia** nenhum email. Ficas com a turma carregada e decides depois quando enviar: na lista, cada formando mostra o estado do **Convite** (*Por enviar* / *Enviado em…*), e no topo aparece **"Enviar N convite(s)"** para os mandar **todos de uma vez**. Também podes enviar **um a um** com o botão **Enviar convite** de cada linha.

!!! warning "Palavras-passe no Excel"
    Para não pôr palavras-passe no ficheiro, **deixa a coluna vazia** e define a *palavra-passe inicial* (campo por baixo dos botões) - igual para todos. Cada formando muda-a depois.

!!! tip "Os erros não bloqueiam"
    As linhas com erro **não são importadas**; corriges o ficheiro e voltas a importar só essas. As válidas já ficaram criadas.

➡️ A seguir: **[Adicionar individual](adicionar.md)** · voltar a **[Gerir a turma](index.md)**.
