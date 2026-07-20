-- IEFP CRM — Migração: proposta online (link rastreável + adjudicação).
-- Correr UMA vez no Supabase → SQL Editor. Idempotente.
-- A leitura/abertura/adjudicação são feitas pela Edge Function "proposta"
-- (usa a service_role key, por isso NÃO se abre RLS ao público).

create table if not exists public.propostas_publicas(
  token             text primary key,
  turma             text,                      -- nº da turma (informativo)
  numero            text,
  titulo            text,
  entidade          text,
  cliente           text,
  html              text not null,             -- documento da proposta pré-renderizado
  aberturas         int  not null default 0,
  primeira_abertura timestamptz,
  ultima_abertura   timestamptz,
  adjudicada_em     timestamptz,
  adjudicante       text,
  criado_em         timestamptz not null default now(),
  atualizado_em     timestamptz not null default now()
);

-- RLS ligado e SEM políticas públicas: só a service_role (Edge Function) toca na tabela.
alter table public.propostas_publicas enable row level security;
