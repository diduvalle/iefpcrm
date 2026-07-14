-- =====================================================================
--  IEFP CRM — REPOSITÓRIO de sessões (publicação + aviso + leitura)
-- =====================================================================
--  O que é: uma camada em cima do Google Drive. Os PDFs continuam no
--  Drive e o link partilhado continua a ser o bitly. Isto só serve para
--    1) guardar o bitly de cada módulo/sessão num sítio próprio,
--    2) avisar a turma por email quando publicas algo,
--    3) saber QUEM clicou (cada formando recebe um link com token seu).
--
--  Reaproveita o backend de identidade que já existe:
--    turmas / utilizadores / sessoes  +  _user_from_token(p_token)
--  Nada aqui altera essas tabelas. É só acrescentar.
--
--  COMO USAR: Supabase → SQL Editor → colar tudo → Run. É idempotente.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tabelas
-- ---------------------------------------------------------------------

-- Um módulo = uma UFCD dentro de uma turma. Guarda a pasta do Drive e o
-- bitly "mestre" dessa pasta (o link que partilhas em aula).
create table if not exists public.repo_modulos (
  id         uuid primary key default gen_random_uuid(),
  turma_id   uuid not null references public.turmas(id) on delete cascade,
  ufcd       text not null,                  -- '10868'
  nome       text not null default '',       -- 'CRM analytics'
  drive_url  text default '',                -- pasta do Google Drive
  bitly_url  text default '',                -- shortlink da pasta
  criado_em  timestamptz not null default now(),
  unique (turma_id, ufcd)
);
create index if not exists ix_repo_mod_turma on public.repo_modulos(turma_id);

-- Uma publicação = "carreguei o PDF da sessão X, aqui vai o aviso".
-- O ficheiro NÃO vive aqui; vive no Drive, atrás do `link`.
create table if not exists public.repo_publicacoes (
  id         uuid primary key default gen_random_uuid(),
  turma_id   uuid not null references public.turmas(id) on delete cascade,
  modulo_id  uuid not null references public.repo_modulos(id) on delete cascade,
  titulo     text not null,
  texto      text not null default '',       -- a mensagem que escreves na caixa
  link       text not null,                  -- o bitly desta sessão
  criado_por uuid references public.utilizadores(id) on delete set null,
  criado_em  timestamptz not null default now(),
  enviado_em timestamptz                     -- null = ainda é rascunho
);
create index if not exists ix_repo_pub_turma  on public.repo_publicacoes(turma_id);
create index if not exists ix_repo_pub_modulo on public.repo_publicacoes(modulo_id);

-- A peça central: uma linha por FORMANDO por PUBLICAÇÃO, com um token
-- só dele. O token identifica ao mesmo tempo a pessoa e a publicação,
-- por isso o link do email é apenas .../r/<token>.
create table if not exists public.repo_envios (
  id              uuid primary key default gen_random_uuid(),
  publicacao_id   uuid not null references public.repo_publicacoes(id) on delete cascade,
  user_id         uuid not null references public.utilizadores(id) on delete cascade,
  token           uuid not null unique default gen_random_uuid(),
  email           text not null,
  enviado_em      timestamptz,               -- null = ainda por enviar
  erro            text,                      -- mensagem do Resend, se falhou
  primeiro_clique timestamptz,               -- <- o que te interessa saber
  ultimo_clique   timestamptz,
  cliques         int not null default 0,
  unique (publicacao_id, user_id)
);
create index if not exists ix_repo_env_pub   on public.repo_envios(publicacao_id);
create index if not exists ix_repo_env_user  on public.repo_envios(user_id);
create index if not exists ix_repo_env_token on public.repo_envios(token);

-- Tudo fechado. O acesso é só pelas funções abaixo (security definer).
alter table public.repo_modulos     enable row level security;
alter table public.repo_publicacoes enable row level security;
alter table public.repo_envios      enable row level security;

-- ---------------------------------------------------------------------
-- Helper interno: exige sessão válida DE FORMADOR
-- ---------------------------------------------------------------------
create or replace function public._repo_formador(p_token uuid)
returns public.utilizadores
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  if caller.papel not in ('Formador','Administrador') then raise exception 'SEM_PERMISSAO'; end if;
  return caller;
end $$;

-- ---------------------------------------------------------------------
-- Módulos
-- ---------------------------------------------------------------------

-- Qualquer membro da turma pode LISTAR os módulos (o formando também
-- precisa deles se um dia mostrarmos o repositório dentro da app).
create or replace function public.repo_modulos_listar(p_token uuid)
returns table(id uuid, ufcd text, nome text, drive_url text, bitly_url text,
              publicacoes bigint)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  return query
    select m.id, m.ufcd, m.nome, m.drive_url, m.bitly_url,
           (select count(*) from repo_publicacoes p where p.modulo_id = m.id)
    from repo_modulos m
    where m.turma_id = caller.turma_id
    order by m.ufcd;
end $$;

-- Criar OU editar um módulo (p_id null = criar).
create or replace function public.repo_modulo_guardar(
  p_token uuid, p_id uuid, p_ufcd text, p_nome text,
  p_drive_url text default '', p_bitly_url text default ''
) returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; v_id uuid;
begin
  caller := _repo_formador(p_token);
  if coalesce(trim(p_ufcd),'') = '' then raise exception 'DADOS_EM_FALTA'; end if;

  if p_id is null then
    insert into repo_modulos(turma_id, ufcd, nome, drive_url, bitly_url)
      values (caller.turma_id, trim(p_ufcd), coalesce(p_nome,''),
              coalesce(p_drive_url,''), coalesce(p_bitly_url,''))
      returning id into v_id;
  else
    update repo_modulos
       set ufcd = trim(p_ufcd), nome = coalesce(p_nome,''),
           drive_url = coalesce(p_drive_url,''), bitly_url = coalesce(p_bitly_url,'')
     where id = p_id and turma_id = caller.turma_id
     returning id into v_id;
    if v_id is null then raise exception 'NAO_ENCONTRADO'; end if;
  end if;

  return json_build_object('id', v_id);
end $$;

create or replace function public.repo_modulo_remover(p_token uuid, p_id uuid)
returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; n int;
begin
  caller := _repo_formador(p_token);
  delete from repo_modulos where id = p_id and turma_id = caller.turma_id;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'NAO_ENCONTRADO'; end if;
  return json_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- Publicar
-- ---------------------------------------------------------------------

-- Cria a publicação E gera um envio (com token) para cada FORMANDO da
-- turma que tenha email. Não envia nada — isso é a Edge Function.
-- Devolve quantos destinatários apanhou e quantos ficaram de fora por
-- não terem email, para poderes avisar no ecrã antes de disparar.
create or replace function public.repo_publicar(
  p_token uuid, p_modulo_id uuid, p_titulo text, p_texto text, p_link text
) returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; v_pub uuid; v_dest int; v_sem int;
begin
  caller := _repo_formador(p_token);
  if coalesce(trim(p_titulo),'') = '' or coalesce(trim(p_link),'') = '' then
    raise exception 'DADOS_EM_FALTA';
  end if;
  if not exists (select 1 from repo_modulos
                 where id = p_modulo_id and turma_id = caller.turma_id) then
    raise exception 'NAO_ENCONTRADO';
  end if;

  insert into repo_publicacoes(turma_id, modulo_id, titulo, texto, link, criado_por)
    values (caller.turma_id, p_modulo_id, trim(p_titulo),
            coalesce(p_texto,''), trim(p_link), caller.id)
    returning id into v_pub;

  -- Um envio por formando com email. O email principal é o do IEFP; se
  -- estiver vazio, cai para o pessoal (email2).
  insert into repo_envios(publicacao_id, user_id, email)
    select v_pub, u.id, lower(trim(coalesce(nullif(trim(u.email),''), u.email2)))
      from utilizadores u
     where u.turma_id = caller.turma_id
       and u.papel = 'Formando'
       and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is not null;
  get diagnostics v_dest = row_count;

  select count(*) into v_sem
    from utilizadores u
   where u.turma_id = caller.turma_id
     and u.papel = 'Formando'
     and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is null;

  return json_build_object('id', v_pub, 'destinatarios', v_dest, 'sem_email', v_sem);
end $$;

-- Destinatários ainda por enviar (chamada pela Edge Function repo-enviar).
-- Devolve o token de cada um — é com ele que se monta o link do email.
create or replace function public.repo_envios_pendentes(p_token uuid, p_publicacao uuid)
returns table(envio_id uuid, email text, nome text, envio_token uuid,
              titulo text, texto text, ufcd text, turma text)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  return query
    select e.id, e.email,
           trim(coalesce(u.nome,'') || ' ' || coalesce(u.apelido,'')),
           e.token, p.titulo, p.texto, m.ufcd, t.codigo
      from repo_envios e
      join repo_publicacoes p on p.id = e.publicacao_id
      join repo_modulos m     on m.id = p.modulo_id
      join turmas t           on t.id = p.turma_id
      join utilizadores u     on u.id = e.user_id
     where e.publicacao_id = p_publicacao
       and p.turma_id = caller.turma_id
       and e.enviado_em is null;
end $$;

-- A Edge Function diz o que correu bem e o que correu mal.
create or replace function public.repo_marcar_enviado(
  p_token uuid, p_envio_id uuid, p_erro text default null
) returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  update repo_envios e
     set enviado_em = case when p_erro is null then now() else null end,
         erro       = p_erro
    from repo_publicacoes p
   where e.id = p_envio_id and p.id = e.publicacao_id and p.turma_id = caller.turma_id;
  update repo_publicacoes
     set enviado_em = coalesce(enviado_em, now())
   where id = (select publicacao_id from repo_envios where id = p_envio_id);
  return json_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- Clique  (o coração do "quem foi ver")
-- ---------------------------------------------------------------------

-- Sem sessão, de propósito: quem clica no email não faz login. O token
-- do envio É a credencial. Devolve o link para onde redirecionar.
-- Chamada pela Edge Function `r`.
create or replace function public.repo_registar_clique(p_envio_token uuid)
returns json
language plpgsql security definer set search_path = public as $$
declare v_link text;
begin
  update repo_envios e
     set cliques         = e.cliques + 1,
         primeiro_clique = coalesce(e.primeiro_clique, now()),
         ultimo_clique   = now()
    from repo_publicacoes p
   where e.token = p_envio_token and p.id = e.publicacao_id
  returning p.link into v_link;

  if v_link is null then return json_build_object('ok', false); end if;
  return json_build_object('ok', true, 'link', v_link);
end $$;

-- ---------------------------------------------------------------------
-- Painel do formador
-- ---------------------------------------------------------------------

-- Lista de publicações da turma, com o contador de leitura à vista.
create or replace function public.repo_publicacoes_listar(p_token uuid, p_modulo uuid default null)
returns table(id uuid, modulo_id uuid, ufcd text, titulo text, texto text, link text,
              criado_em timestamptz, enviado_em timestamptz,
              destinatarios bigint, abriram bigint)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  return query
    select p.id, p.modulo_id, m.ufcd, p.titulo, p.texto, p.link,
           p.criado_em, p.enviado_em,
           (select count(*) from repo_envios e where e.publicacao_id = p.id),
           (select count(*) from repo_envios e where e.publicacao_id = p.id
                                                 and e.primeiro_clique is not null)
      from repo_publicacoes p
      join repo_modulos m on m.id = p.modulo_id
     where p.turma_id = caller.turma_id
       and (p_modulo is null or p.modulo_id = p_modulo)
     order by p.criado_em desc;
end $$;

-- Quem abriu o quê, numa publicação. É esta a vista que te diz a quem falar.
create or replace function public.repo_estado(p_token uuid, p_publicacao uuid)
returns table(nome text, username text, email text, enviado_em timestamptz,
              erro text, primeiro_clique timestamptz, cliques int)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  return query
    select trim(coalesce(u.nome,'') || ' ' || coalesce(u.apelido,'')),
           u.username, e.email, e.enviado_em, e.erro, e.primeiro_clique, e.cliques
      from repo_envios e
      join repo_publicacoes p on p.id = e.publicacao_id
      join utilizadores u     on u.id = e.user_id
     where e.publicacao_id = p_publicacao
       and p.turma_id = caller.turma_id
     order by e.primeiro_clique nulls first, u.nome;
end $$;

-- Vista agregada por formando: quantas publicações abriu, de quantas.
-- Serve para responder à pergunta "quem é que nunca abre nada?".
create or replace function public.repo_resumo_turma(p_token uuid)
returns table(nome text, username text, email text,
              recebidas bigint, abertas bigint, ultimo_acesso timestamptz)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  return query
    select trim(coalesce(u.nome,'') || ' ' || coalesce(u.apelido,'')),
           u.username, u.email,
           count(e.id) filter (where e.enviado_em is not null),
           count(e.id) filter (where e.primeiro_clique is not null),
           max(e.ultimo_clique)
      from utilizadores u
      left join repo_envios e on e.user_id = u.id
     where u.turma_id = caller.turma_id and u.papel = 'Formando'
     group by u.id, u.nome, u.apelido, u.username, u.email
     order by 5 asc, 4 desc;
end $$;

create or replace function public.repo_publicacao_remover(p_token uuid, p_id uuid)
returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; n int;
begin
  caller := _repo_formador(p_token);
  delete from repo_publicacoes where id = p_id and turma_id = caller.turma_id;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'NAO_ENCONTRADO'; end if;
  return json_build_object('ok', true);
end $$;
