-- ============================================================================
-- LIMITE DE ENTREGAS CONFIGURÁVEL
--
-- Antes: o máximo de 2 entregas por formando estava escrito à mão dentro de
-- submeter_trabalho() e meus_envios(). Mudá-lo obrigava a editar SQL.
--
-- Agora:
--   turmas.limite_envios        -> o valor por omissão da turma (arranca em 2)
--   utilizadores.limite_envios  -> exceção para uma pessoa (NULL = usa o da turma)
--
-- O limite continua a ser contado e imposto NO SERVIDOR: a app só mostra.
-- Correr uma vez no SQL Editor do Supabase.
-- ============================================================================

alter table public.turmas
  add column if not exists limite_envios int not null default 2
  check (limite_envios between 1 and 50);

alter table public.utilizadores
  add column if not exists limite_envios int
  check (limite_envios is null or limite_envios between 1 and 50);

-- Limite efetivo de um utilizador: a exceção dele, senão o da turma, senão 2.
create or replace function public.limite_envios_efetivo(p_user_id uuid)
returns int language sql stable security definer set search_path = public as $$
  select coalesce(u.limite_envios, t.limite_envios, 2)
  from public.utilizadores u
  join public.turmas t on t.id = u.turma_id
  where u.id = p_user_id;
$$;

-- ---------------------------------------------------------------------------
-- Submeter: passa a ler o limite efetivo em vez do 2 fixo.
-- ---------------------------------------------------------------------------
create or replace function public.submeter_trabalho(p_token uuid, p_mensagem text, p_payload jsonb)
returns json language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; n int; lim int;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  lim := public.limite_envios_efetivo(caller.id);
  select count(*) into n from submissoes where user_id = caller.id;
  if n >= lim then raise exception 'LIMITE_ENVIOS'; end if;
  insert into submissoes(turma_id, user_id, nome, username, mensagem, payload)
    values (caller.turma_id, caller.id,
            trim(coalesce(caller.nome,'')||' '||coalesce(caller.apelido,'')), caller.username,
            coalesce(p_mensagem,''), p_payload);
  return json_build_object('ok', true, 'enviados', n+1, 'limite', lim);
end $$;

create or replace function public.meus_envios(p_token uuid)
returns json language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; n int; lim int;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  lim := public.limite_envios_efetivo(caller.id);
  select count(*) into n from submissoes where user_id = caller.id;
  return json_build_object('enviados', n, 'limite', lim);
end $$;

-- ---------------------------------------------------------------------------
-- Roster: traz o limite e quantas entregas já fez, para o formador ver X/Y
-- sem ter de cruzar listas do lado do browser.
-- (largar primeiro: o tipo de retorno muda)
-- ---------------------------------------------------------------------------
drop function if exists public.listar_utilizadores(uuid);
create or replace function public.listar_utilizadores(p_token uuid)
returns table(id uuid, username text, nome text, apelido text,
              email text, email2 text, papel text, criado_em timestamptz,
              limite int, envios int, limite_proprio int, limite_turma int)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  return query
    select u.id,u.username,u.nome,u.apelido,u.email,u.email2,u.papel,u.criado_em,
           coalesce(u.limite_envios, t.limite_envios, 2)::int as limite,
           (select count(*) from submissoes s where s.user_id = u.id)::int as envios,
           u.limite_envios as limite_proprio,
           coalesce(t.limite_envios,2)::int as limite_turma
    from utilizadores u
    join turmas t on t.id = u.turma_id
    where u.turma_id = caller.turma_id
    order by case u.papel when 'Administrador' then 0 when 'Formador' then 1 else 2 end, u.nome;
end $$;

-- ---------------------------------------------------------------------------
-- Formador altera o limite.
--   p_user_id NULL  -> muda o valor por omissão da TURMA
--   p_user_id != NULL -> exceção para essa pessoa (p_limite NULL volta ao da turma)
-- ---------------------------------------------------------------------------
create or replace function public.definir_limite_envios(p_token uuid, p_user_id uuid, p_limite int)
returns json language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; alvo public.utilizadores; feitas int;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  if caller.papel not in ('Administrador','Formador') then raise exception 'SEM_PERMISSAO'; end if;
  if p_limite is not null and (p_limite < 1 or p_limite > 50) then raise exception 'LIMITE_INVALIDO'; end if;

  if p_user_id is null then
    if p_limite is null then raise exception 'LIMITE_INVALIDO'; end if;
    update turmas set limite_envios = p_limite where id = caller.turma_id;
    return json_build_object('ok', true, 'ambito', 'turma', 'limite', p_limite);
  end if;

  select * into alvo from utilizadores where id = p_user_id;
  if alvo.id is null or alvo.turma_id <> caller.turma_id then raise exception 'UTILIZADOR_INVALIDO'; end if;

  -- não faz sentido pôr o limite abaixo do que a pessoa já entregou: as entregas
  -- feitas não se desfazem e o roster passaria a mostrar 3/2.
  if p_limite is not null then
    select count(*) into feitas from submissoes where user_id = p_user_id;
    if p_limite < feitas then raise exception 'LIMITE_ABAIXO_DAS_ENTREGAS'; end if;
  end if;

  update utilizadores set limite_envios = p_limite where id = p_user_id;
  return json_build_object('ok', true, 'ambito', 'formando',
                           'limite', public.limite_envios_efetivo(p_user_id));
end $$;

grant execute on function public.limite_envios_efetivo(uuid)          to anon, authenticated;
grant execute on function public.definir_limite_envios(uuid,uuid,int) to anon, authenticated;
grant execute on function public.listar_utilizadores(uuid)            to anon, authenticated;
