-- =============================================================================
-- CÓPIA DE SEGURANÇA DO TRABALHO (rascunhos)
--
-- Porquê: até agora o trabalho de cada formando vivia num único sítio - o
-- localStorage daquele navegador, naquele computador. Isso desaparece com outro
-- computador, outro navegador, uma janela anónima ou um "limpar dados de
-- navegação". Nenhuma dessas coisas é erro do utilizador, e não havia aviso,
-- cópia nem recuperação.
--
-- A peça difícil já estava provada: a submissão já envia o estado inteiro para
-- `submissoes`. Isto é o mesmo, mas:
--   - UMA linha por formando, substituída (não acumula histórico);
--   - não gasta nenhuma das entregas limitadas;
--   - não dispara email nenhum.
--
-- Correr uma vez no SQL Editor do Supabase.
-- =============================================================================

create table if not exists public.rascunhos (
  user_id      uuid primary key references public.utilizadores(id) on delete cascade,
  turma_id     uuid not null references public.turmas(id) on delete cascade,
  payload      jsonb not null,                    -- snapshot do state do CRM
  bytes        integer not null default 0,        -- tamanho, para vigiar o crescimento
  atualizado_em timestamptz not null default now()
);
create index if not exists ix_rasc_turma on public.rascunhos(turma_id);

-- Fechado a cadeado: só se lá chega pelas funções abaixo, que exigem sessão.
alter table public.rascunhos enable row level security;

-- -----------------------------------------------------------------------------
-- Guardar (upsert). Devolve quando ficou guardado.
-- -----------------------------------------------------------------------------
create or replace function public.guardar_rascunho(p_token uuid, p_payload jsonb)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; v_bytes integer;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;

  v_bytes := length(p_payload::text);
  -- Um estado real com dados gerados anda pelos 90 KB. 5 MB é folga larga e
  -- trava um payload absurdo antes de encher a base.
  if v_bytes > 5242880 then raise exception 'PAYLOAD_GRANDE'; end if;

  insert into public.rascunhos (user_id, turma_id, payload, bytes, atualizado_em)
  values (caller.id, caller.turma_id, p_payload, v_bytes, now())
  on conflict (user_id) do update
    set payload = excluded.payload,
        bytes = excluded.bytes,
        atualizado_em = now();

  return jsonb_build_object('ok', true, 'bytes', v_bytes, 'em', now());
end $$;

-- -----------------------------------------------------------------------------
-- Ver se existe cópia, SEM a trazer. O cliente pergunta isto ao arrancar - não
-- faz sentido transferir 90 KB só para descobrir que não são precisos.
-- -----------------------------------------------------------------------------
create or replace function public.tenho_rascunho(p_token uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; r public.rascunhos;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  select * into r from public.rascunhos where user_id = caller.id;
  if r.user_id is null then return jsonb_build_object('existe', false); end if;
  return jsonb_build_object('existe', true, 'bytes', r.bytes, 'em', r.atualizado_em);
end $$;

-- -----------------------------------------------------------------------------
-- Trazer a cópia.
-- -----------------------------------------------------------------------------
create or replace function public.obter_rascunho(p_token uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; r public.rascunhos;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  select * into r from public.rascunhos where user_id = caller.id;
  if r.user_id is null then raise exception 'SEM_RASCUNHO'; end if;
  return jsonb_build_object('payload', r.payload, 'em', r.atualizado_em, 'bytes', r.bytes);
end $$;

grant execute on function public.guardar_rascunho(uuid, jsonb) to anon, authenticated;
grant execute on function public.tenho_rascunho(uuid)          to anon, authenticated;
grant execute on function public.obter_rascunho(uuid)          to anon, authenticated;

-- -----------------------------------------------------------------------------
-- Para o formador: quem tem cópia e de quando. Sem trazer os dados.
-- Serve para responder a "perdi o meu trabalho" sem ter de adivinhar.
-- -----------------------------------------------------------------------------
create or replace function public.rascunhos_da_turma(p_token uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  if caller.papel not in ('Administrador','Formador') then raise exception 'SEM_PERMISSAO'; end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object(
             'nome', u.nome, 'username', u.username,
             'bytes', r.bytes, 'em', r.atualizado_em) order by r.atualizado_em desc)
    from public.rascunhos r
    join public.utilizadores u on u.id = r.user_id
    where r.turma_id = caller.turma_id
  ), '[]'::jsonb);
end $$;

grant execute on function public.rascunhos_da_turma(uuid) to anon, authenticated;
