# Pulso

A bolha verde no canto inferior direito, presente em **todos os módulos**. Escreve uma pergunta sobre os teus dados e ele responde com o número - e com o botão que abre a vista real.

## Porque é que se chama Pulso

De **"tomar o pulso ao negócio"** - um número rápido sobre como as coisas estão, sem opinião nenhuma pelo meio.

É um nome de **ferramenta**, não de pessoa, e isso é de propósito. Quase todos os chatbots se chamam Íris, Sofia ou Nova: querem que se fale com eles como se fosse alguém. Aqui o objetivo é o contrário - um nome humano desfazia em três letras o que a mensagem de abertura constrói.

## A primeira coisa que ele diz

> **Não sou inteligência artificial.** O Pulso responde com regras fixas aos dados desta sandbox. Não altera nada.

Isto não é modéstia nem um aviso legal escondido no rodapé: é a **primeira mensagem** que aparece, antes de qualquer pergunta. E se lhe perguntares diretamente *"és uma IA?"* - ou *"chamas-te Pulso porquê?"* - ele tem resposta própria:

> Sou um conjunto de regras fixas: reconheço algumas frases e vou buscar o número aos teus dados. Não aprendo, não invento e não escrevo nada que não esteja aqui.
>
> Se fosse IA, o **artigo 50.º do AI Act** obrigaria à mesma declaração - a diferença é que aí eu poderia enganar-me com confiança.

!!! info "Porque é que isto está aqui"
    O **artigo 50.º** do Regulamento (UE) 2024/1689 (*AI Act*) obriga a que quem interage com um sistema de IA **saiba que está a falar com uma máquina**. Um chatbot de reservas num site é o exemplo clássico de **risco limitado**: não está proibido nem exige avaliação de conformidade - basta a **transparência**.

    O Pulso **não é** um sistema de IA, e por isso o artigo 50.º nem se lhe aplica. Declara-o na mesma, por duas razões: porque um assistente que se deixasse confundir com IA ensinaria exatamente o contrário do que a UFCD diz, e porque é mais fácil perceber a obrigação a vê-la cumprida do que a lê-la num diploma.

## Duas coisas, não uma

O Pulso responde a **números** e a **como se faz**.

| | Exemplo | O que devolve |
|---|---|---|
| **Números** | *"quantas propostas tenho em aberto"* | o valor, a lista, e o botão que abre a vista |
| **Como se faz** | *"como crio uma proposta"* | os passos em duas linhas, o botão do módulo e o botão que abre **a página certa do manual** |

As respostas de instruções trazem o selo **Como se faz**, para não haver dúvida sobre o que se está a ler.

!!! tip "Porque é que isto existe"
    O manual tem 96 páginas. Quem está a meio de uma proposta não vai procurar num índice - vai perguntar ao formador. O Pulso responde ali, e o botão leva à página certa em vez de à porta do manual.

    As respostas são **escritas à mão**, como tudo o resto: o Pulso não resume o manual nem o lê. **Aponta** para ele.

### Como se faz - o que está coberto

Vinte e duas perguntas, ao longo do percurso todo:

- **Registos** - criar empresa, contacto, produto
- **Propostas** - criar, pôr linhas do catálogo, exportar PDF, enviar (proposta online), mudar o estado no Kanban
- **Modelos** - construtor da proposta, modelos de email e as tags
- **Marketing** - campanhas e automações
- **RGPD** - registar consentimento, responder a um pedido de titular
- **Dados** - importar CSV, gerador de exemplos, fundir duplicados, campos personalizados
- **Definições** - marca e aparência, metas de vendas
- **Formando** - submeter o trabalho, recuperar a palavra-passe

Se escrever *"como…"* e ele não reconhecer, manda-o na mesma ao **manual** em vez de encolher os ombros. Já uma pergunta fora do âmbito - *"qual a capital da Austrália"* - continua a dar só *"não sei"*: o manual não serve de desculpa.

!!! note "Escreva à vontade"
    Não é preciso acertar no verbo. *"como crio"*, *"como se cria"*, *"como faço"* e *"criar"* dão todos a mesma resposta - a correspondência corta a terminação dos verbos dos dois lados.

---

## O que sabe responder

| Área | Exemplos de pergunta |
|---|---|
| **Propostas** | *"quantas propostas tenho em aberto"* · *"quanto vendi este mês"* · *"qual a taxa de conversão"* · *"que propostas estão a expirar"* |
| **Análise** | *"porque perdemos negócios"* · *"porque ganhamos"* |
| **Empresas** | *"quantas empresas tenho"* · *"que empresas ainda não têm proposta"* · *"quais são os melhores clientes"* |
| **Agenda** | *"o que tenho para hoje"* · *"tenho tarefas atrasadas"* |
| **Serviço** | *"como estão os casos de suporte"* · *"há casos fora de SLA"* |
| **RGPD** | *"há pedidos RGPD por responder"* |
| **Retenção** | *"há contratos em risco"* |

Debaixo da conversa há **sugestões clicáveis** - as perguntas que ele garantidamente reconhece. Se estás a começar, é por aí.

### As tuas, não as de todos
Escrever **"as minhas"**, **"eu"** ou **"meu"** restringe a resposta ao teu utilizador:

- *"propostas em aberto"* → todas as da base.
- *"as minhas propostas em aberto"* → só aquelas de que és **[responsável](empresas-contactos.md#responsavel)**.

O mesmo vale para *"quanto vendi eu este mês"*, que compara com a tua **[quota individual](definicoes.md#metas-de-vendas)** em vez da meta da equipa.

## As três regras

=== "Nunca inventa"

    Se não reconhecer a pergunta, diz que não reconhece - e diz **porquê**: *"só reconheço as frases para que fui programado"*. Não tenta adivinhar, não devolve um número aproximado e não muda de assunto.

    Isto é de propósito. Um assistente que responde sempre alguma coisa é mais agradável e muito mais perigoso: um número errado apresentado com confiança entra nas decisões sem ninguém o questionar.

=== "Só consulta"

    Ele **não altera um único registo**. Não cria, não apaga, não muda estados. No máximo abre a vista certa - cada resposta acaba num botão (*Ver propostas*, *Ver agenda*) que te leva ao módulo com o filtro já aplicado.

    Por isso é um **atalho de navegação**, não uma verdade paralela: o número que ele diz e o número do ecrã vêm do mesmo sítio - e o texto que ele dá é o mesmo que está no manual.

=== "Respeita as permissões"

    Só responde sobre módulos a que **tens acesso**. Se o teu grupo de utilizadores não vê o Helpdesk, perguntar pelos casos dá *"não sei responder"* - e a sugestão nem sequer aparece na lista.

## O que o distingue do Dashboard

À primeira vista é redundante: *"quantas propostas em aberto"* já está no Dashboard. A diferença está nas perguntas que **não têm ecrã**:

- *"que empresas ainda não têm proposta"* - não existe em lado nenhum da app; é o cruzamento entre a lista de empresas e a lista de propostas.
- *"tenho tarefas atrasadas"* - a Agenda mostra o calendário, não a lista do que passou do prazo.

O Dashboard mostra os números que **alguém decidiu mostrar**. Um CRM tem sempre mais combinações úteis do que ecrãs para as arrumar.

!!! note "Pedagogia (UFCD 10868 · 10870)"
    Vale a pena usar este assistente como exercício em três tempos:

    1. **Fazer-lhe perguntas que ele não sabe responder.** É a forma mais rápida de perceber que um assistente só chega onde os **dados** chegam - e que a limitação está quase sempre no registo, não no motor.
    2. **Comparar com um chatbot a sério.** Um LLM responderia a *"qual a capital da Austrália"*; este não. Também inventaria um número de vendas se lhe faltasse o dado - e este não. Discutir qual dos dois comportamentos se quer num CRM.
    3. **Ligar ao AI Act.** Se este assistente fosse trocado por um com IA por trás, o que mudava? Passava a ser **risco limitado** (art. 50.º); teria de continuar a declarar-se; e a **[literacia em IA](../glossario.md)** (art. 4.º, em vigor desde fevereiro de 2025) obrigaria a que quem o opera percebesse os seus limites.

## Relacionado

<div class="grid cards" markdown>

-   <svg class="icon" viewBox="0 0 24 24"><path d="M3 3v18h18"/><path d="m19 9-5 5-4-4-3 3"/></svg> __Dashboard & Agenda__

    ---
    Onde estão os números que ele vai buscar.

    [:octicons-arrow-right-24: Abrir](dashboard-agenda.md)

-   <svg class="icon" viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg> __RGPD__

    ---
    O outro regulamento que a mesma conversa aciona.

    [:octicons-arrow-right-24: Abrir](../rgpd/index.md)

</div>
