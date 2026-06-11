-- =====================================================================
--  IEFP CRM — Backend de IDENTIDADE (Supabase)
-- =====================================================================
--  Modelo HÍBRIDO:
--    • Central (aqui)  -> turmas + roster de utilizadores + papéis
--    • Local (browser) -> dados de prática do CRM (sandbox descartável)
--
--  Auth caseira via funções RPC SECURITY DEFINER (sem Supabase Auth,
--  sem Edge Functions). O browser só chama funções; as tabelas estão
--  fechadas por RLS. Passwords cifradas com bcrypt (pgcrypto); o hash
--  NUNCA é devolvido ao cliente.
--
--  COMO USAR: cola tudo isto no Supabase -> SQL Editor -> Run.
--  É idempotente (podes correr outra vez sem partir nada).
-- =====================================================================

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------------
-- Tabelas
-- ---------------------------------------------------------------------
create table if not exists public.turmas (
  id          uuid primary key default gen_random_uuid(),
  codigo      text not null unique check (codigo ~ '^[0-9]{8}$'),
  nome        text,
  criado_por  text not null,                 -- email do formador que criou
  criado_em   timestamptz not null default now()
);

create table if not exists public.utilizadores (
  id          uuid primary key default gen_random_uuid(),
  turma_id    uuid not null references public.turmas(id) on delete cascade,
  username    text not null,
  nome        text not null,
  apelido     text default '',
  email       text default '',
  papel       text not null default 'Formando'
              check (papel in ('Administrador','Formador','Formando')),
  pass_hash   text not null,
  criado_em   timestamptz not null default now()
);

create unique index if not exists ux_util_turma_username
  on public.utilizadores (turma_id, lower(username));
create index if not exists ix_util_turma on public.utilizadores (turma_id);

create table if not exists public.sessoes (
  token     uuid primary key default gen_random_uuid(),
  user_id   uuid not null references public.utilizadores(id) on delete cascade,
  criado_em timestamptz not null default now(),
  expira_em timestamptz not null default (now() + interval '30 days')
);
create index if not exists ix_sessoes_user on public.sessoes (user_id);

-- ---------------------------------------------------------------------
-- RLS: liga, sem policies -> acesso DIRETO bloqueado para anon.
-- Tudo passa pelas funções SECURITY DEFINER (que correm como dono).
-- ---------------------------------------------------------------------
alter table public.turmas       enable row level security;
alter table public.utilizadores enable row level security;
alter table public.sessoes      enable row level security;

-- =====================================================================
-- Funções RPC
-- =====================================================================

-- Helper interno: utilizador a partir de um token de sessão válido
create or replace function public._user_from_token(p_token uuid)
returns public.utilizadores
language sql security definer set search_path = public as $$
  select u.* from public.utilizadores u
  join public.sessoes s on s.user_id = u.id
  where s.token = p_token and s.expira_em > now();
$$;

-- Criar TURMA (gate: email de formador IEFP) + conta do formador.
create or replace function public.criar_turma(
  p_codigo text, p_email text, p_username text, p_password text,
  p_nome text, p_apelido text default '', p_nome_turma text default null
) returns json
language plpgsql security definer set search_path = public, extensions as $$
declare v_turma uuid; v_user uuid; v_token uuid; v_email text;
begin
  v_email := lower(trim(p_email));
  -- GATE: email IEFP de formador (forNNNN@formacao.iefp.pt) OU admin autorizado.
  -- (Para autorizar mais emails, acrescenta-os à condição abaixo.)
  if not ( v_email ~ '^for[0-9]+@formacao\.iefp\.pt$'
           or v_email = 'diogovale.iefp@gmail.com' ) then
    raise exception 'EMAIL_NAO_AUTORIZADO';
  end if;
  if p_codigo !~ '^[0-9]{8}$' then raise exception 'CODIGO_INVALIDO'; end if;
  if coalesce(trim(p_username),'') = '' or coalesce(p_password,'') = '' then
    raise exception 'DADOS_EM_FALTA';
  end if;
  if exists (select 1 from turmas where codigo = p_codigo) then
    raise exception 'TURMA_JA_EXISTE';
  end if;

  insert into turmas(codigo, nome, criado_por)
    values (p_codigo, coalesce(nullif(trim(p_nome_turma),''), 'Turma '||p_codigo), v_email)
    returning id into v_turma;

  insert into utilizadores(turma_id, username, nome, apelido, email, papel, pass_hash)
    values (v_turma, lower(trim(p_username)), p_nome, p_apelido, v_email,
            'Formador', extensions.crypt(p_password, extensions.gen_salt('bf')))
    returning id into v_user;

  insert into sessoes(user_id) values (v_user) returning token into v_token;

  return json_build_object(
    'token', v_token,
    'turma', json_build_object('codigo', p_codigo),
    'user',  json_build_object('id', v_user, 'username', lower(trim(p_username)),
             'nome', p_nome, 'apelido', p_apelido, 'papel', 'Formador'));
end $$;

-- LOGIN numa turma (qualquer utilizador do roster dessa turma).
create or replace function public.login(
  p_codigo text, p_username text, p_password text
) returns json
language plpgsql security definer set search_path = public, extensions as $$
declare v_turma uuid; r public.utilizadores; v_token uuid;
begin
  select id into v_turma from turmas where codigo = p_codigo;
  if v_turma is null then raise exception 'TURMA_NAO_EXISTE'; end if;
  select * into r from utilizadores
    where turma_id = v_turma and lower(username) = lower(trim(p_username));
  if r.id is null or r.pass_hash <> extensions.crypt(p_password, r.pass_hash) then
    raise exception 'CREDENCIAIS_INVALIDAS';
  end if;
  insert into sessoes(user_id) values (r.id) returning token into v_token;
  return json_build_object('token', v_token,
    'user', json_build_object('id', r.id, 'username', r.username, 'nome', r.nome,
            'apelido', r.apelido, 'email', r.email, 'papel', r.papel));
end $$;

-- Lista PÚBLICA para o dropdown de login (só username/nome/papel; sem hash).
create or replace function public.listar_utilizadores_publico(p_codigo text)
returns table(username text, nome text, apelido text, papel text)
language sql security definer set search_path = public as $$
  select u.username, u.nome, u.apelido, u.papel
  from public.utilizadores u join public.turmas t on t.id = u.turma_id
  where t.codigo = p_codigo
  order by case u.papel when 'Administrador' then 0 when 'Formador' then 1 else 2 end, u.nome;
$$;

-- Roster completo para a GESTÃO (só formador/admin; sem hash).
create or replace function public.listar_utilizadores(p_token uuid)
returns table(id uuid, username text, nome text, apelido text,
              email text, papel text, criado_em timestamptz)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  return query
    select u.id,u.username,u.nome,u.apelido,u.email,u.papel,u.criado_em
    from utilizadores u where u.turma_id = caller.turma_id
    order by case u.papel when 'Administrador' then 0 when 'Formador' then 1 else 2 end, u.nome;
end $$;

-- Formador CRIA um utilizador (formando/formador) na sua turma.
create or replace function public.criar_formando(
  p_token uuid, p_username text, p_password text, p_nome text,
  p_apelido text default '', p_email text default '', p_papel text default 'Formando'
) returns json
language plpgsql security definer set search_path = public, extensions as $$
declare caller public.utilizadores; v_id uuid; v_papel text;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  if caller.papel not in ('Formador','Administrador') then raise exception 'SEM_PERMISSAO'; end if;
  if coalesce(trim(p_username),'')='' or coalesce(p_password,'')='' or coalesce(trim(p_nome),'')='' then
    raise exception 'DADOS_EM_FALTA';
  end if;
  if exists (select 1 from utilizadores
             where turma_id = caller.turma_id and lower(username) = lower(trim(p_username))) then
    raise exception 'USERNAME_EM_USO';
  end if;
  v_papel := case when p_papel in ('Formador','Formando') then p_papel else 'Formando' end;
  insert into utilizadores(turma_id, username, nome, apelido, email, papel, pass_hash)
    values (caller.turma_id, lower(trim(p_username)), p_nome, p_apelido, p_email, v_papel,
            extensions.crypt(p_password, extensions.gen_salt('bf')))
    returning id into v_id;
  return json_build_object('id', v_id, 'username', lower(trim(p_username)), 'papel', v_papel);
end $$;

-- Formador REDEFINE a password de um utilizador da sua turma.
create or replace function public.redefinir_password(
  p_token uuid, p_user_id uuid, p_nova_password text
) returns json
language plpgsql security definer set search_path = public, extensions as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  if caller.papel not in ('Formador','Administrador') then raise exception 'SEM_PERMISSAO'; end if;
  if coalesce(p_nova_password,'')='' then raise exception 'DADOS_EM_FALTA'; end if;
  update utilizadores set pass_hash = extensions.crypt(p_nova_password, extensions.gen_salt('bf'))
    where id = p_user_id and turma_id = caller.turma_id;
  return json_build_object('ok', true);
end $$;

-- Formador REMOVE um utilizador da sua turma (não a si próprio).
create or replace function public.remover_utilizador(
  p_token uuid, p_user_id uuid
) returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  if caller.papel not in ('Formador','Administrador') then raise exception 'SEM_PERMISSAO'; end if;
  if p_user_id = caller.id then raise exception 'NAO_PODE_REMOVER_SE_PROPRIO'; end if;
  delete from utilizadores where id = p_user_id and turma_id = caller.turma_id;
  return json_build_object('ok', true);
end $$;

-- Terminar sessão.
create or replace function public.logout(p_token uuid)
returns json language sql security definer set search_path = public as $$
  delete from public.sessoes where token = p_token;
  select json_build_object('ok', true);
$$;

-- ---------------------------------------------------------------------
-- Permissões: o anon só pode EXECUTAR as funções públicas.
-- (O helper interno fica vedado.)
-- ---------------------------------------------------------------------
revoke all on function public._user_from_token(uuid) from public, anon, authenticated;

grant execute on function public.criar_turma(text,text,text,text,text,text,text) to anon, authenticated;
grant execute on function public.login(text,text,text)                            to anon, authenticated;
grant execute on function public.listar_utilizadores_publico(text)                to anon, authenticated;
grant execute on function public.listar_utilizadores(uuid)                        to anon, authenticated;
grant execute on function public.criar_formando(uuid,text,text,text,text,text,text) to anon, authenticated;
grant execute on function public.redefinir_password(uuid,uuid,text)               to anon, authenticated;
grant execute on function public.remover_utilizador(uuid,uuid)                    to anon, authenticated;
grant execute on function public.logout(uuid)                                     to anon, authenticated;

-- =====================================================================
--  Fim. Próximo: ligar o index.html ao Supabase (cliente).
-- =====================================================================
