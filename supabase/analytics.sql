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
-- MINI-PAINEL NA APP — função de AGREGADOS (cookieless, sem PII)
-- A app usa a chave pública (role anon) e NÃO consegue ler as linhas (RLS).
-- Esta função devolve apenas CONTAGENS agregadas (nunca dados em bruto) para
-- o painel "Analítica do site" nas Definições. SECURITY DEFINER ignora a RLS
-- só para agregar; as linhas individuais continuam ilegíveis pela API.
-- ============================================================
create or replace function public.analytics_summary()
returns json
language sql
security definer
set search_path = public
as $$
  select json_build_object(
    'manual_visitas', (select count(*) from site_views where site='manual' and kind='pageview'),
    'app_aberturas',  (select count(*) from site_views where site='app'    and kind='open'),
    'video_plays',    (select count(*) from site_views where kind='video'),
    'total',          (select count(*) from site_views where kind in ('pageview','open')),
    'por_dia', (select coalesce(json_agg(json_build_object('d', d, 'm', m, 'a', a) order by d), '[]'::json)
                from (select date_trunc('day', ts)::date d,
                             count(*) filter (where site='manual' and kind='pageview') m,
                             count(*) filter (where site='app'    and kind='open')     a
                      from site_views
                      where kind in ('pageview','open') and ts > now() - interval '14 days'
                      group by 1) t),
    'top_paginas', (select coalesce(json_agg(json_build_object('path', path, 'n', n) order by n desc), '[]'::json)
                    from (select path, count(*) n from site_views
                          where site='manual' and kind='pageview' and coalesce(path,'')<>''
                          group by 1 order by n desc limit 8) t),
    'top_videos', (select coalesce(json_agg(json_build_object('label', label, 'n', n) order by n desc), '[]'::json)
                   from (select label, count(*) n from site_views
                         where kind='video' and coalesce(label,'')<>''
                         group by 1 order by n desc limit 8) t),
    'dispositivo', (select coalesce(json_object_agg(coalesce(nullif(device,''),'?'), n), '{}'::json)
                    from (select device, count(*) n from site_views where kind in ('pageview','open') group by 1) t),
    'idioma', (select coalesce(json_object_agg(coalesce(nullif(lang,''),'?'), n), '{}'::json)
               from (select lang, count(*) n from site_views where kind in ('pageview','open') group by 1) t),
    'origem', (select coalesce(json_agg(json_build_object('ref', ref, 'n', n) order by n desc), '[]'::json)
               from (select coalesce(nullif(ref,''),'(direto)') ref, count(*) n
                     from site_views where kind in ('pageview','open')
                     group by 1 order by n desc limit 6) t)
  );
$$;

-- A app (role anon, chave pública) precisa de poder EXECUTAR a função.
grant execute on function public.analytics_summary() to anon, authenticated;

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
