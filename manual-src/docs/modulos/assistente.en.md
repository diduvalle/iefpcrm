# Pulso

The green bubble in the bottom-right corner, present in **every module**. Type a question about your data and it answers with the number - and with the button that opens the real view.

## Why it is called Pulso

From the Portuguese **"tomar o pulso ao negócio"** - to take the business's pulse: a quick number on how things stand, with no opinion in between.

It is a **tool**'s name, not a person's, and that is deliberate. Almost every chatbot is called Iris, Sophia or Nova: they want you to talk to them as if they were someone. Here the aim is the opposite - a human name would undo in three letters what the opening message builds.

## The first thing it says

> **I am not artificial intelligence.** Pulso answers with fixed rules over this sandbox's data. It changes nothing.

This is not modesty, nor a legal notice buried in a footer: it is the **first message** shown, before any question. And if you ask it directly *"are you an AI?"* - or *"why are you called Pulso?"* - it has its own answer:

> I am a set of fixed rules: I recognise a few phrases and fetch the number from your data. I do not learn, I do not invent and I write nothing that is not already here.
>
> If I were AI, **Article 50 of the AI Act** would require the same declaration - the difference is that then I could be confidently wrong.

!!! info "Why this is here"
    **Article 50** of Regulation (EU) 2024/1689 (*AI Act*) requires that anyone interacting with an AI system **knows they are talking to a machine**. A booking chatbot on a website is the textbook case of **limited risk**: it is neither prohibited nor subject to a conformity assessment - **transparency** is enough.

    Pulso **is not** an AI system, so Article 50 does not even apply to it. It declares itself anyway, for two reasons: because an assistant that let itself be mistaken for AI would teach the exact opposite of what the course says, and because the obligation is easier to grasp when you see it met than when you read it in a statute.

## What it can answer

| Area | Example questions |
|---|---|
| **Proposals** | *"how many proposals are open"* · *"how much did I sell this month"* · *"what is my conversion rate"* · *"which proposals are expiring"* |
| **Analysis** | *"why do we lose deals"* · *"why do we win"* |
| **Companies** | *"how many companies do I have"* · *"which companies have no proposal yet"* · *"who are the best customers"* |
| **Calendar** | *"what do I have today"* · *"do I have overdue tasks"* |
| **Service** | *"how are the support cases"* · *"any cases past SLA"* |
| **GDPR** | *"any data subject requests pending"* |
| **Retention** | *"any contracts at risk"* |

Below the conversation there are **clickable suggestions** - the questions it is guaranteed to recognise. If you are starting out, start there.

### Yours, not everyone's
Writing **"my"** or **"I"** narrows the answer to your user:

- *"open proposals"* → all of them in the base.
- *"my open proposals"* → only the ones you **[own](empresas-contactos.md#owner)**.

The same applies to *"how much did I sell this month"*, which compares against your **[individual quota](definicoes.md#sales-targets)** instead of the team target.

## The three rules

=== "It never invents"

    If it does not recognise the question, it says so - and says **why**: *"I only recognise the phrases I was programmed for"*. It does not guess, does not return an approximate number and does not change the subject.

    This is deliberate. An assistant that always answers something is friendlier and far more dangerous: a wrong number delivered with confidence enters decisions without anyone questioning it.

=== "It only reads"

    It **changes no record whatsoever**. It does not create, delete or move statuses. At most it opens the right view - every answer ends in a button (*See proposals*, *See calendar*) that takes you to the module with the filter already applied.

    That makes it a **navigation shortcut**, not a parallel truth: the number it states and the number on screen come from the same place.

=== "It respects permissions"

    It only answers about modules you **can access**. If your user group cannot see the Helpdesk, asking about cases returns *"I don't know how to answer that"* - and the suggestion does not even appear in the list.

## What sets it apart from the Dashboard

At first glance it is redundant: *"how many open proposals"* is already on the Dashboard. The difference lies in the questions that have **no screen**:

- *"which companies have no proposal yet"* - it exists nowhere in the app; it is the cross between the company list and the proposal list.
- *"do I have overdue tasks"* - the Calendar shows the calendar, not the list of what is past due.

The Dashboard shows the numbers **somebody decided to show**. A CRM always has more useful combinations than it has screens to hold them.

!!! note "Pedagogy (UFCD 10868 · 10870)"
    It is worth using this assistant as a three-part exercise:

    1. **Ask it questions it cannot answer.** It is the fastest way to see that an assistant only reaches as far as the **data** reaches - and that the limit is almost always in the record keeping, not in the engine.
    2. **Compare it with a real chatbot.** An LLM would answer *"what is the capital of Australia"*; this one will not. It would also invent a sales figure if the data were missing - and this one will not. Discuss which of the two behaviours you want in a CRM.
    3. **Connect it to the AI Act.** If this assistant were swapped for one with AI behind it, what would change? It would become **limited risk** (Art. 50); it would still have to declare itself; and **[AI literacy](../glossario.md)** (Art. 4, in force since February 2025) would require whoever operates it to understand its limits.

## Related

<div class="grid cards" markdown>

-   <svg class="icon" viewBox="0 0 24 24"><path d="M3 3v18h18"/><path d="m19 9-5 5-4-4-3 3"/></svg> __Dashboard & Calendar__

    ---
    Where the numbers it fetches actually live.

    [:octicons-arrow-right-24: Open](dashboard-agenda.md)

-   <svg class="icon" viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg> __GDPR__

    ---
    The other regulation the same conversation triggers.

    [:octicons-arrow-right-24: Open](../rgpd/index.md)

</div>
