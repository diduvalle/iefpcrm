-- =====================================================================
--  IEFP CRM — REPOSITÓRIO v3: dashboard devolve o token de cada formando
-- =====================================================================
--  Para o formador poder COPIAR o link pessoal de um formando específico
--  (ex.: reenviar à mão por WhatsApp), o dashboard precisa do token.
--  O link monta-se no browser: <SUPABASE_URL>/functions/v1/r?t=<token>.
--
--  COMO USAR: Supabase → SQL Editor → colar → Run. Idempotente.
--  Corre depois de repo-v3.sql.
-- =====================================================================

-- (drop: o tipo de retorno muda ao acrescentar a coluna do token.)
drop function if exists public.repo_sessao_estado(uuid, uuid);
create or replace function public.repo_sessao_estado(p_token uuid, p_sessao_id uuid)
returns table(nome text, username text, email text, email2 text, enviado_em timestamptz,
              erro text, primeiro_clique timestamptz, cliques int, envio_token uuid)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select trim(coalesce(u.nome,'') || ' ' || coalesce(u.apelido,'')),
           u.username, a.email, a.email2, a.enviado_em, a.erro, a.primeiro_clique, a.cliques, a.token
      from repo_acessos a join utilizadores u on u.id = a.user_id
     where a.sessao_id = p_sessao_id
     order by a.primeiro_clique nulls first, u.nome;
end $$;
