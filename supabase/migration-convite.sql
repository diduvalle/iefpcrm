-- IEFP CRM — Migração: convites enviados MANUALMENTE (em massa ou individual).
-- Correr UMA vez no Supabase → SQL Editor. Idempotente (pode repetir sem estragar).
-- Depois disto, criar/importar formandos JÁ NÃO envia convite: o formador decide quando envia.

-- 1) marca de quando o convite foi enviado (null = ainda por enviar)
alter table public.utilizadores add column if not exists convite_em timestamptz;

-- 2) o roster passa a devolver convite_em (largar primeiro: o TIPO DE RETORNO muda → erro 42P13)
drop function if exists public.listar_utilizadores(uuid);
create or replace function public.listar_utilizadores(p_token uuid)
returns table(id uuid, username text, nome text, apelido text,
              email text, email2 text, papel text, criado_em timestamptz, convite_em timestamptz)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  return query
    select u.id,u.username,u.nome,u.apelido,u.email,u.email2,u.papel,u.criado_em,u.convite_em
    from utilizadores u where u.turma_id = caller.turma_id
    order by case u.papel when 'Administrador' then 0 when 'Formador' then 1 else 2 end, u.nome;
end $$;

-- 3) marcar o convite como enviado (só Formador/Administrador, e só na sua turma)
create or replace function public.marcar_convite(p_token uuid, p_user_id uuid)
returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; alvo public.utilizadores; v_agora timestamptz := now();
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  if caller.papel not in ('Formador','Administrador') then raise exception 'SEM_PERMISSAO'; end if;
  select * into alvo from utilizadores where id = p_user_id and turma_id = caller.turma_id;
  if alvo.id is null then raise exception 'UTILIZADOR_NAO_ENCONTRADO'; end if;
  update utilizadores set convite_em = v_agora where id = p_user_id;
  return json_build_object('id', p_user_id, 'convite_em', v_agora);
end $$;

grant execute on function public.marcar_convite(uuid,uuid) to anon, authenticated;
