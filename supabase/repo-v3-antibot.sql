-- =====================================================================
--  IEFP CRM — REPOSITÓRIO v3: só o email pessoal + página à prova de bots
-- =====================================================================
--  Problema: os scanners de email (Microsoft Safe Links no @formacao.iefp.pt)
--  abrem AUTOMATICAMENTE todos os links ao entregar o email, o que registava
--  "abertura" para os 12 formandos ao mesmo segundo. Falso.
--
--  Duas correções:
--   1) Enviar só para o email PESSOAL (o do IEFP era o que disparava o
--      scanner e ninguém o lê). repo_sessao_publicar deixa de guardar o 2.º.
--   2) O registo passa a exigir JavaScript (ver a Edge Function `r`). Aqui
--      só acrescentamos uma função só-de-leitura para a página buscar o link
--      sem registar clique.
--
--  COMO USAR: Supabase → SQL Editor → colar → Run. Idempotente.
--  Corre depois de repo-v3.sql.
-- =====================================================================

-- 1) Publicar: um acesso por formando, mas guarda SÓ o email pessoal
--    (com fallback ao IEFP se o formando não tiver pessoal preenchido).
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

  -- email = pessoal (u.email2), com fallback ao IEFP (u.email) se não houver
  -- pessoal. email2 fica NULO: já não enviamos para o IEFP.
  insert into repo_acessos(sessao_id, user_id, email, email2)
    select v_sess, u.id,
           coalesce(nullif(lower(trim(u.email2)),''), nullif(lower(trim(u.email)),'')),
           null
      from utilizadores u
     where u.turma_id = rt.turma_id and u.papel='Formando'
       and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is not null;
  get diagnostics v_dest = row_count;

  select count(*) into v_sem from utilizadores u
   where u.turma_id = rt.turma_id and u.papel='Formando'
     and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is null;

  return json_build_object('id', v_sess, 'destinatarios', v_dest, 'sem_email', v_sem);
end $$;

-- 2) Só-de-leitura: devolve o link de um acesso SEM registar clique.
--    É o que a página (servida pela função `r`) usa para saber para onde
--    redirecionar, antes de o JavaScript confirmar a abertura real.
create or replace function public.repo_acesso_link(p_token uuid)
returns json language plpgsql security definer set search_path = public as $$
declare v_link text;
begin
  select s.link into v_link
    from repo_acessos a join repo_sessoes s on s.id = a.sessao_id
   where a.token = p_token;
  if v_link is null then return json_build_object('ok', false); end if;
  return json_build_object('ok', true, 'link', v_link);
end $$;
