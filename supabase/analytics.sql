-- ============================================================
-- IEFP CRM — Analítica de primeira-parte (sem cookies, sem PII)
-- Correr UMA vez no Supabase (SQL Editor). Depois o site começa a registar.
-- ============================================================

create table if not exists public.site_views (
  id      bigint generated always as identity primary key,
  ts      timestamptz not null default now(),
  site    text,                                   -- 'manual' | 'app'
  kind    text not null default 'pageview',       -- 'pageview' | 'video' | 'open'
  path    text,                                   -- ex.: /manual/modulos/propostas/
  label   text,                                   -- ex.: nome do vídeo
  ref     text,                                   -- só o HOST de origem (sem URL completo)
  lang    text,                                   -- 'pt' | 'en'
  device  text                                    -- 'mobile' | 'desktop'
);

create index if not exists site_views_ts_idx   on public.site_views (ts);
create index if not exists site_views_path_idx on public.site_views (path);
create index if not exists site_views_kind_idx on public.site_views (kind);

alter table public.site_views enable row level security;

-- Qualquer visitante (anónimo) pode REGISTAR uma visita…
drop policy if exists "anon insert site_views" on public.site_views;
create policy "anon insert site_views" on public.site_views
  for insert to anon, authenticated with check (true);

-- …mas NINGUÉM lê pela API pública (sem policy de SELECT => leitura só no
-- dashboard do Supabase / service role). Os dados não são pessoais.

-- ============================================================
-- CONSULTAS (correr no SQL Editor para ver os resultados)
-- ============================================================
-- 1) Visitas ao manual por dia (últimos 30):
--   select date_trunc('day', ts)::date as dia, count(*) as visitas
--   from public.site_views where site='manual' and kind='pageview'
--   group by 1 order by 1 desc limit 30;
--
-- 2a) Top páginas do manual:
--   select path, count(*) as visitas
--   from public.site_views where kind='pageview'
--   group by 1 order by 2 desc limit 20;
--
-- 2b) Top vídeos (cliques em play):
--   select label, count(*) as plays
--   from public.site_views where kind='video'
--   group by 1 order by 2 desc limit 20;
--
-- Extra) Idioma e dispositivo:
--   select lang, device, count(*) from public.site_views group by 1,2 order by 3 desc;
-- Extra) Origem do tráfego:
--   select coalesce(nullif(ref,''),'(direto)') as origem, count(*)
--   from public.site_views group by 1 order by 2 desc limit 20;
