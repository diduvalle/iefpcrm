/* ================== O PERFIL É DA PESSOA, NÃO DA SANDBOX ==================
   A foto e a assinatura viviam só no localStorage, dentro do estado do CRM.
   Bastava recuperar uma cópia de segurança, importar um JSON ou dar reset ao
   ambiente para desaparecerem - e voltar a pô-las a cada início de sessão é um
   imposto que ninguém devia pagar. O nome e o email já vinham do servidor:
   isto põe o resto do perfil no mesmo sítio.

   NULL   = nunca foi definido  -> a app sobe o que tiver localmente (uma vez).
   ''     = apagado de propósito -> a app apaga também no navegador.
   É essa distinção que evita que o primeiro arranque depois desta migração
   apague as fotos que as pessoas já tinham.

   Correr UMA VEZ no SQL Editor do Supabase. É aditivo: não apaga nada nem
   toca nos dados de prática (esses são locais).
   ========================================================================== */

-- 1) Colunas do perfil ------------------------------------------------------
alter table public.utilizadores add column if not exists avatar          text;
alter table public.utilizadores add column if not exists assinatura      text;
alter table public.utilizadores add column if not exists assinatura_font text;
alter table public.utilizadores add column if not exists assinatura_size text;
alter table public.utilizadores add column if not exists telefone        text;
alter table public.utilizadores add column if not exists cargo           text;

-- 2) O login passa a trazer o perfil -----------------------------------------
--    (a foto vem em data URI, ~20 KB depois do redimensionamento feito na app)
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
            'apelido', r.apelido, 'email', r.email, 'papel', r.papel,
            'avatar', r.avatar, 'assinatura', r.assinatura,
            'assinaturaFont', r.assinatura_font, 'assinaturaSize', r.assinatura_size,
            'telefone', r.telefone, 'cargo', r.cargo));
end $$;

-- 3) Ler o meu perfil sem voltar a fazer login (usado ao recuperar/ao arrancar)
create or replace function public.meu_perfil(p_token uuid)
returns json
language plpgsql security definer set search_path = public, extensions as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  return json_build_object('id', caller.id, 'username', caller.username,
    'nome', caller.nome, 'apelido', caller.apelido, 'email', caller.email,
    'papel', caller.papel, 'avatar', caller.avatar, 'assinatura', caller.assinatura,
    'assinaturaFont', caller.assinatura_font, 'assinaturaSize', caller.assinatura_size,
    'telefone', caller.telefone, 'cargo', caller.cargo);
end $$;

-- 4) Gravar o perfil ---------------------------------------------------------
--    Cada campo novo é opcional: NULL = "não mexer", '' = "apagar".
--    Largar primeiro a versão de 4 argumentos, senão a chamada fica ambígua.
drop function if exists public.atualizar_meu_perfil(uuid,text,text,text);
create or replace function public.atualizar_meu_perfil(
  p_token uuid, p_nome text, p_apelido text, p_email text,
  p_avatar text default null, p_assinatura text default null,
  p_assinatura_font text default null, p_assinatura_size text default null,
  p_telefone text default null, p_cargo text default null
) returns json
language plpgsql security definer set search_path = public, extensions as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  if coalesce(trim(p_nome),'') = '' then raise exception 'DADOS_EM_FALTA'; end if;
  -- travão de tamanho: a foto vem já redimensionada da app; isto é a rede por baixo
  if octet_length(coalesce(p_avatar,''))     > 150000 then raise exception 'PERFIL_GRANDE'; end if;
  if octet_length(coalesce(p_assinatura,'')) > 250000 then raise exception 'PERFIL_GRANDE'; end if;
  update utilizadores
     set nome            = trim(p_nome),
         apelido         = coalesce(trim(p_apelido),''),
         email           = coalesce(trim(p_email),''),
         avatar          = coalesce(p_avatar,          avatar),
         assinatura      = coalesce(p_assinatura,      assinatura),
         assinatura_font = coalesce(p_assinatura_font, assinatura_font),
         assinatura_size = coalesce(p_assinatura_size, assinatura_size),
         telefone        = coalesce(p_telefone,        telefone),
         cargo           = coalesce(p_cargo,           cargo)
   where id = caller.id;
  return json_build_object('ok', true, 'id', caller.id);
end $$;

-- 5) Permissões --------------------------------------------------------------
grant execute on function public.meu_perfil(uuid) to anon, authenticated;
grant execute on function public.atualizar_meu_perfil(uuid,text,text,text,text,text,text,text,text,text)
  to anon, authenticated;

/* RGPD: a fotografia é dado pessoal. Fica ligada à conta e desaparece com ela -
   remover_utilizador apaga a linha, e apagar a turma leva tudo em cascata.
   O roster (listar_utilizadores) NÃO devolve fotos: cada pessoa vê a sua. */
