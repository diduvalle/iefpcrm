-- IEFP CRM — Migração: 2.º email (pessoal) dos formandos.
-- Correr UMA vez no Supabase → SQL Editor. Idempotente (pode repetir sem estragar).

-- 1) coluna email2 (email pessoal; o principal é o do IEFP)
alter table public.utilizadores add column if not exists email2 text default '';

-- 2) roster passa a devolver email2
create or replace function public.listar_utilizadores(p_token uuid)
returns table(id uuid, username text, nome text, apelido text,
              email text, email2 text, papel text, criado_em timestamptz)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  return query
    select u.id,u.username,u.nome,u.apelido,u.email,u.email2,u.papel,u.criado_em
    from utilizadores u where u.turma_id = caller.turma_id
    order by case u.papel when 'Administrador' then 0 when 'Formador' then 1 else 2 end, u.nome;
end $$;

-- 3) criar_formando aceita e grava email2 (largar a assinatura antiga de 7 args)
drop function if exists public.criar_formando(uuid,text,text,text,text,text,text);
create or replace function public.criar_formando(
  p_token uuid, p_username text, p_password text, p_nome text,
  p_apelido text default '', p_email text default '', p_papel text default 'Formando',
  p_email2 text default ''
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
  insert into utilizadores(turma_id, username, nome, apelido, email, email2, papel, pass_hash)
    values (caller.turma_id, lower(trim(p_username)), p_nome, p_apelido, p_email, p_email2, v_papel,
            extensions.crypt(p_password, extensions.gen_salt('bf')))
    returning id into v_id;
  return json_build_object('id', v_id, 'username', lower(trim(p_username)), 'papel', v_papel);
end $$;

grant execute on function public.criar_formando(uuid,text,text,text,text,text,text,text) to anon, authenticated;
