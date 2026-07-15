-- =====================================================================
--  IEFP CRM — REPOSITÓRIO v3: ferramenta privada de UM formador (root)
-- =====================================================================
--  Reset conceptual, pedido a 15/07/2026. O que muda face ao v1/v2:
--    • Entra SÓ o root (password única; nenhum outro formador vê isto).
--    • O root espelha turmas do CRM, uma a uma. Cada turma tem UMA pasta
--      do Drive (pessoal) e envia por SESSÃO.
--    • Cada formando recebe um link único que aponta à pasta e regista
--      quem abriu e quando. Os formandos NÃO usam a app.
--
--  Modelo:  repo_turmas (1 por turma gerida)  ->  repo_sessoes  ->  repo_acessos
--
--  Reusa do CRM: turmas, utilizadores, e a auth de root (login_root /
--  _is_root / sessoes_root), que já existem no schema.sql.
--
--  ANTES DE USAR: definir a password de root UMA vez (se ainda não estiver):
--     select public.set_root_password('A-TUA-PASS-FORTE');
--
--  COMO USAR: Supabase → SQL Editor → colar tudo → Run. Idempotente.
--  As tabelas antigas (repo_modulos/publicacoes/envios) ficam intactas mas
--  deixam de ser usadas.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tabelas
-- ---------------------------------------------------------------------
create table if not exists public.repo_turmas (
  id          uuid primary key default gen_random_uuid(),
  turma_id    uuid not null references public.turmas(id) on delete cascade unique,
  codigo      text not null,                 -- cache p/ mostrar sem outra query
  nome        text default '',
  drive_url   text default '',               -- a pasta pessoal do Drive
  def_assunto   text, def_cabecalho text, def_saudacao text,
  def_botao     text, def_rodape   text,
  criado_em   timestamptz not null default now()
);

create table if not exists public.repo_sessoes (
  id           uuid primary key default gen_random_uuid(),
  repo_turma_id uuid not null references public.repo_turmas(id) on delete cascade,
  turma_id     uuid not null references public.turmas(id) on delete cascade,
  titulo       text not null,
  texto        text default '',
  link         text not null,
  assunto      text, cabecalho text, saudacao text, botao text, rodape text,
  criado_em    timestamptz not null default now(),
  enviado_em   timestamptz
);
create index if not exists ix_repo_sess_turma on public.repo_sessoes(repo_turma_id);

create table if not exists public.repo_acessos (
  id              uuid primary key default gen_random_uuid(),
  sessao_id       uuid not null references public.repo_sessoes(id) on delete cascade,
  user_id         uuid not null references public.utilizadores(id) on delete cascade,
  token           uuid not null unique default gen_random_uuid(),
  email           text, email2 text,
  enviado_em      timestamptz, erro text,
  primeiro_clique timestamptz, ultimo_clique timestamptz, cliques int not null default 0,
  unique (sessao_id, user_id)
);
create index if not exists ix_repo_ac_sessao on public.repo_acessos(sessao_id);
create index if not exists ix_repo_ac_token  on public.repo_acessos(token);

alter table public.repo_turmas  enable row level security;
alter table public.repo_sessoes enable row level security;
alter table public.repo_acessos enable row level security;

-- ---------------------------------------------------------------------
-- Textos de fábrica do email (per-turma, sem UFCD porque a pasta é da turma)
-- ---------------------------------------------------------------------
create or replace function public._repo_omissao(p_campo text)
returns text language sql immutable as $$
  select case p_campo
    when 'assunto'   then 'Novos materiais - {titulo}'
    when 'cabecalho' then 'A pasta da turma tem material novo'
    when 'saudacao'  then 'Olá {nome},'
    when 'botao'     then 'Aceder à pasta'
    when 'rodape'    then '{nome}, este link é pessoal e regista a sua abertura, para o formador saber quem já acedeu.'
  end;
$$;

-- Gate: exige um token de sessão de root válido.
create or replace function public._repo_root(p_token uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not _is_root(p_token) then raise exception 'SEM_PERMISSAO'; end if;
end $$;

-- ---------------------------------------------------------------------
-- Turmas
-- ---------------------------------------------------------------------

-- Todas as turmas do CRM, marcando as que já estão espelhadas no Repo.
create or replace function public.repo_turmas_crm(p_token uuid)
returns table(codigo text, nome text, n_formandos bigint, gerida boolean)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select t.codigo, t.nome,
           (select count(*) from utilizadores u where u.turma_id = t.id and u.papel='Formando'),
           exists (select 1 from repo_turmas rt where rt.turma_id = t.id)
      from turmas t
     order by t.criado_em desc;
end $$;

-- Turmas que EU gero, com contadores para o dashboard.
create or replace function public.repo_geridas(p_token uuid)
returns table(id uuid, codigo text, nome text, drive_url text,
              n_formandos bigint, n_sessoes bigint, ultimo_envio timestamptz,
              def_assunto text, def_cabecalho text, def_saudacao text, def_botao text, def_rodape text)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select rt.id, rt.codigo, rt.nome, rt.drive_url,
           (select count(*) from utilizadores u where u.turma_id = rt.turma_id and u.papel='Formando'),
           (select count(*) from repo_sessoes s where s.repo_turma_id = rt.id),
           (select max(s.enviado_em) from repo_sessoes s where s.repo_turma_id = rt.id),
           coalesce(rt.def_assunto,   _repo_omissao('assunto')),
           coalesce(rt.def_cabecalho, _repo_omissao('cabecalho')),
           coalesce(rt.def_saudacao,  _repo_omissao('saudacao')),
           coalesce(rt.def_botao,     _repo_omissao('botao')),
           coalesce(rt.def_rodape,    _repo_omissao('rodape'))
      from repo_turmas rt
     order by rt.criado_em desc;
end $$;

create or replace function public.repo_turma_adicionar(p_token uuid, p_codigo text, p_drive_url text)
returns json language plpgsql security definer set search_path = public as $$
declare t public.turmas; v_id uuid;
begin
  perform _repo_root(p_token);
  select * into t from turmas where codigo = p_codigo;
  if t.id is null then raise exception 'TURMA_NAO_EXISTE'; end if;
  insert into repo_turmas(turma_id, codigo, nome, drive_url)
    values (t.id, t.codigo, coalesce(t.nome,''), coalesce(p_drive_url,''))
    on conflict (turma_id) do update set drive_url = excluded.drive_url
    returning id into v_id;
  return json_build_object('id', v_id);
end $$;

create or replace function public.repo_turma_guardar(
  p_token uuid, p_id uuid, p_drive_url text,
  p_assunto text, p_cabecalho text, p_saudacao text, p_botao text, p_rodape text
) returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform _repo_root(p_token);
  update repo_turmas set
    drive_url = coalesce(p_drive_url, drive_url),
    def_assunto = p_assunto, def_cabecalho = p_cabecalho, def_saudacao = p_saudacao,
    def_botao = p_botao, def_rodape = p_rodape
   where id = p_id;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'NAO_ENCONTRADO'; end if;
  return json_build_object('ok', true);
end $$;

create or replace function public.repo_turma_remover(p_token uuid, p_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform _repo_root(p_token);
  delete from repo_turmas where id = p_id;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'NAO_ENCONTRADO'; end if;
  return json_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- Sessões
-- ---------------------------------------------------------------------

-- Criar sessão (rascunho): grava o texto e gera um acesso por formando
-- com email. NÃO envia. Guarda os textos como omissão da turma.
create or replace function public.repo_sessao_publicar(
  p_token uuid, p_repo_turma_id uuid, p_titulo text, p_texto text, p_link text,
  p_assunto text, p_cabecalho text, p_saudacao text, p_botao text, p_rodape text
) returns json language plpgsql security definer set search_path = public as $$
declare rt public.repo_turmas; v_sess uuid; v_dest int; v_sem int;
begin
  perform _repo_root(p_token);
  if coalesce(trim(p_titulo),'')='' or coalesce(trim(p_link),'')='' then raise exception 'DADOS_EM_FALTA'; end if;
  select * into rt from repo_turmas where id = p_repo_turma_id;
  if rt.id is null then raise exception 'NAO_ENCONTRADO'; end if;

  insert into repo_sessoes(repo_turma_id, turma_id, titulo, texto, link,
                           assunto, cabecalho, saudacao, botao, rodape)
    values (rt.id, rt.turma_id, trim(p_titulo), coalesce(p_texto,''), trim(p_link),
            coalesce(nullif(trim(p_assunto),''),   _repo_omissao('assunto')),
            coalesce(nullif(trim(p_cabecalho),''), _repo_omissao('cabecalho')),
            coalesce(nullif(trim(p_saudacao),''),  _repo_omissao('saudacao')),
            coalesce(nullif(trim(p_botao),''),     _repo_omissao('botao')),
            coalesce(nullif(trim(p_rodape),''),    _repo_omissao('rodape')))
    returning id into v_sess;

  update repo_turmas set def_assunto=p_assunto, def_cabecalho=p_cabecalho,
    def_saudacao=p_saudacao, def_botao=p_botao, def_rodape=p_rodape where id = rt.id;

  insert into repo_acessos(sessao_id, user_id, email, email2)
    select v_sess, u.id,
           coalesce(nullif(lower(trim(u.email2)),''), nullif(lower(trim(u.email)),'')),
           case when nullif(trim(u.email2),'') is not null and nullif(trim(u.email),'') is not null
                then nullif(lower(trim(u.email)),'') end
      from utilizadores u
     where u.turma_id = rt.turma_id and u.papel='Formando'
       and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is not null;
  get diagnostics v_dest = row_count;

  select count(*) into v_sem from utilizadores u
   where u.turma_id = rt.turma_id and u.papel='Formando'
     and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is null;

  return json_build_object('id', v_sess, 'destinatarios', v_dest, 'sem_email', v_sem);
end $$;

-- Editar um rascunho (só antes do 1.º envio).
create or replace function public.repo_sessao_editar(
  p_token uuid, p_id uuid, p_titulo text, p_texto text, p_link text,
  p_assunto text, p_cabecalho text, p_saudacao text, p_botao text, p_rodape text
) returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform _repo_root(p_token);
  if coalesce(trim(p_titulo),'')='' or coalesce(trim(p_link),'')='' then raise exception 'DADOS_EM_FALTA'; end if;
  update repo_sessoes set titulo=trim(p_titulo), texto=coalesce(p_texto,''), link=trim(p_link),
    assunto=coalesce(nullif(trim(p_assunto),''),assunto), cabecalho=coalesce(nullif(trim(p_cabecalho),''),cabecalho),
    saudacao=coalesce(nullif(trim(p_saudacao),''),saudacao), botao=coalesce(nullif(trim(p_botao),''),botao),
    rodape=coalesce(nullif(trim(p_rodape),''),rodape)
   where id = p_id and enviado_em is null;
  get diagnostics n = row_count;
  if n = 0 then
    if exists(select 1 from repo_sessoes where id=p_id) then raise exception 'JA_ENVIADA';
    else raise exception 'NAO_ENCONTRADO'; end if;
  end if;
  return json_build_object('ok', true);
end $$;

create or replace function public.repo_sessoes_listar(p_token uuid, p_repo_turma_id uuid)
returns table(id uuid, titulo text, texto text, link text, criado_em timestamptz, enviado_em timestamptz,
              assunto text, cabecalho text, saudacao text, botao text, rodape text,
              destinatarios bigint, enviados bigint, abriram bigint)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select s.id, s.titulo, s.texto, s.link, s.criado_em, s.enviado_em,
           s.assunto, s.cabecalho, s.saudacao, s.botao, s.rodape,
           (select count(*) from repo_acessos a where a.sessao_id=s.id),
           (select count(*) from repo_acessos a where a.sessao_id=s.id and a.enviado_em is not null),
           (select count(*) from repo_acessos a where a.sessao_id=s.id and a.primeiro_clique is not null)
      from repo_sessoes s
     where s.repo_turma_id = p_repo_turma_id
     order by s.criado_em desc;
end $$;

create or replace function public.repo_sessao_estado(p_token uuid, p_sessao_id uuid)
returns table(nome text, username text, email text, email2 text, enviado_em timestamptz,
              erro text, primeiro_clique timestamptz, cliques int)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select trim(coalesce(u.nome,'')||' '||coalesce(u.apelido,'')),
           u.username, a.email, a.email2, a.enviado_em, a.erro, a.primeiro_clique, a.cliques
      from repo_acessos a join utilizadores u on u.id = a.user_id
     where a.sessao_id = p_sessao_id
     order by a.primeiro_clique nulls first, u.nome;
end $$;

create or replace function public.repo_sessao_remover(p_token uuid, p_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform _repo_root(p_token);
  delete from repo_sessoes where id = p_id;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'NAO_ENCONTRADO'; end if;
  return json_build_object('ok', true);
end $$;

-- Reabrir os que ainda não abriram, para reenviar.
create or replace function public.repo_reabrir_nao_abriram(p_token uuid, p_sessao_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform _repo_root(p_token);
  update repo_acessos set enviado_em=null, erro=null
   where sessao_id=p_sessao_id and enviado_em is not null and primeiro_clique is null
     and coalesce(email,'')<>'';
  get diagnostics n = row_count;
  return json_build_object('reabertos', n);
end $$;

-- ---------------------------------------------------------------------
-- Para as Edge Functions
-- ---------------------------------------------------------------------

-- Destinatários por enviar (com os dois emails e o texto congelado).
create or replace function public.repo_pendentes(p_token uuid, p_sessao_id uuid)
returns table(acesso_id uuid, email text, email2 text, nome text, envio_token uuid,
              titulo text, texto text, turma text,
              assunto text, cabecalho text, saudacao text, botao text, rodape text)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select a.id, a.email, a.email2,
           trim(coalesce(u.nome,'')||' '||coalesce(u.apelido,'')), a.token,
           s.titulo, s.texto, rt.codigo,
           s.assunto, s.cabecalho, s.saudacao, s.botao, s.rodape
      from repo_acessos a
      join repo_sessoes s  on s.id = a.sessao_id
      join repo_turmas  rt on rt.id = s.repo_turma_id
      join utilizadores u  on u.id = a.user_id
     where a.sessao_id = p_sessao_id and a.enviado_em is null and coalesce(a.email,'')<>'';
end $$;

create or replace function public.repo_marcar_enviado(p_token uuid, p_acesso_id uuid, p_erro text default null)
returns json language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  update repo_acessos set enviado_em = case when p_erro is null then now() else null end, erro = p_erro
   where id = p_acesso_id;
  update repo_sessoes set enviado_em = coalesce(enviado_em, now())
   where id = (select sessao_id from repo_acessos where id = p_acesso_id);
  return json_build_object('ok', true);
end $$;

-- Clique: SEM auth (o token do acesso é a credencial). Regista e devolve o link.
create or replace function public.repo_click(p_token uuid)
returns json language plpgsql security definer set search_path = public as $$
declare v_link text;
begin
  update repo_acessos a set cliques=a.cliques+1,
    primeiro_clique=coalesce(a.primeiro_clique, now()), ultimo_clique=now()
   from repo_sessoes s where a.token=p_token and s.id=a.sessao_id
  returning s.link into v_link;
  if v_link is null then return json_build_object('ok', false); end if;
  return json_build_object('ok', true, 'link', v_link);
end $$;
