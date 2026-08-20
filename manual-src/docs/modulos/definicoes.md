# Definições

<video class="iefp-video" controls preload="metadata" playsinline poster="/manual/assets/screens/definicoes.png"><source src="/manual/assets/videos/definicoes-pt.webm" type="video/webm"><source src="/manual/assets/videos/definicoes-pt.mp4" type="video/mp4"><track kind="subtitles" src="/manual/assets/videos/definicoes-pt.vtt" srclang="pt" label="Português" default></video>

*As Definições, com cartões colapsáveis (vários só de administrador).*

A **configuração do sistema** (grupo Sistema). Os cartões são **colapsáveis** - clica no título para abrir/fechar; na primeira visita estão recolhidos para a página ficar compacta. Vários cartões são **só para administradores** (selo *Admin*).

## Cartões disponíveis

### Entidade
Dados usados em propostas e comunicações: **nome da entidade**, **NIF/NIPC**, **telefone**, **email** (é o *reply-to* dos emails), **cidade**, **EPD** (Encarregado de Proteção de Dados).

### Dados & backup
**Exportar** / **Importar** o JSON completo do CRM (backup ou migração). É também aqui que **repões os dados de exemplo**.

### Gerador de dados de exemplo
Cria rapidamente **empresas, contactos e propostas** realistas (PT) - acrescenta aos dados existentes.

### Marca & Aparência *(Admin)*
*White-label*: **nome**, **cor principal** (deriva a paleta), **logótipo**, **fundo do login**. **Aplicar** / **Repor IEFP**. → [Email & Marca](../formador/email-marca.md).

### Envio de email real (EmailJS) *(Admin)*
As **chaves** estão **fixas** (🔒); geres só o **modo** (real/simulado) + **Enviar teste**. → [Email & Marca](../formador/email-marca.md).

**Convite e reposição de password** - escolhes se o email vai para o **endereço do IEFP + o pessoal** (2 envios por pessoa) ou **só para o do IEFP** (1 envio). Cada endereço conta como um envio no plano: numa turma de 13, é a diferença entre **26** e **13** envios de cada vez que convidas a turma.

**Consumo do plano** - o botão **Consultar consumo** vai ao **histórico real do EmailJS** e mostra quantos envios já foram feitos **neste ciclo**, a barra de progresso (laranja aos 70%, vermelha aos 90%) e a data em que repõe. Em **Teto e dia do ciclo** escreves os dois valores do teu plano no formato `200/4` (200 envios, repõe dia 4) - o painel do EmailJS diz *"Resets on…"*.

!!! note "Porque é que o ciclo não é o mês"
    O EmailJS repõe a quota no **dia de aniversário do plano**, não no dia 1. Contar por mês de calendário daria números diferentes dos dele **precisamente no início de cada mês**, que é quando a informação interessa.

!!! warning "O que gasta envios"
    **Convites e reposições de password** (1 ou 2 por pessoa), o **aviso de cada entrega** de trabalho, os **emails do CRM** enviados pelo formador e o **email de teste**. Os formandos ficam em **modo simulado** no CRM - as únicas mensagens reais que eles provocam são os avisos de entrega. O **Repositório de sessões** usa outro serviço e **não** conta para este plano.

### Grupos de Utilizadores *(Admin)*
Matriz **papéis × módulos**: define o que cada grupo vê (Administrador/Formador = tudo; Formando limitado). Inclui a opção **ocultar valores financeiros** por grupo.

### Modelos de Proposta
Atalho para o construtor de modelos. → [Modelos de Proposta](modelos.md).

### Segmentos
Lista editável da **dimensão da empresa** (Micro / PME / Grande Empresa, de origem). Alimenta o campo **Segmento (dimensão)** da ficha da empresa, o **alvo das campanhas**, a **condição das automações** e o gráfico de **Segmentação**.

Escreve o nome e **+ Adicionar**; o **✕** remove. Remover **não altera** as empresas que já o têm - deixa apenas de estar disponível para escolher.

!!! warning "Segmento não é nível de fidelização"
    São **dois conceitos diferentes** e, até agosto de 2026, partilhavam o mesmo campo - por isso a lista de alvo das campanhas misturava *Micro/PME/Grande Empresa* com *Bronze/Prata/Ouro*. Agora estão separados: o **segmento** é a **dimensão** da empresa (não muda sozinho); o **nível** é calculado do **volume ganho**. Campanhas e automações têm os **dois filtros em separado** e podem cruzá-los ("PME **e** Bronze"), o que antes era impossível. A app recusa criar um segmento com o nome de um nível, para não voltar a baralhar.

### Outras referências
**Níveis de loyalty**, **Taxas de IVA** (por região), **Origens de cliente** (lista editável) e **[Campos personalizados do contacto](empresas-contactos.md#campos-personalizados)** - campos que crias tu e que ficam disponíveis como tag nos modelos.

## Em modo turma (online)

Numa turma, as Definições ganham dois cartões centrais:

- **Formandos da turma** - gestão de acessos (importar, individual, repor palavra-passe). → [Gerir a turma](../formador/gerir-turma/index.md).
- **Entrega & validação de trabalhos** - receber e avaliar entregas. → [Entrega & validação](../formador/entregas.md).

!!! note "Quem vê as Definições"
    Os **formandos não acedem** às Definições. É um espaço de **formador/administrador**.
