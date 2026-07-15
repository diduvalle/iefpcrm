-- =====================================================================
--  IEFP CRM — REPOSITÓRIO v3: repor o contador de aberturas de uma sessão
-- =====================================================================
--  Serve para limpar aberturas falsas (as que os scanners geraram antes de
--  termos a página à prova de bots) SEM apagar a sessão nem reenviar.
--
--  Os links já enviados continuam válidos e passam agora pela função `r`
--  nova (registo só com JavaScript). Depois de repor, a coluna "abriu"
--  fica a zero e só volta a encher quando alguém abrir MESMO o link.
--
--  COMO USAR: Supabase → SQL Editor → colar → Run. Idempotente.
--  Corre depois de repo-v3.sql.
-- =====================================================================

create or replace function public.repo_sessao_repor(p_token uuid, p_sessao_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform _repo_root(p_token);
  update repo_acessos
     set primeiro_clique = null, ultimo_clique = null, cliques = 0
   where sessao_id = p_sessao_id;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'NAO_ENCONTRADO'; end if;
  return json_build_object('ok', true, 'repostos', n);
end $$;
