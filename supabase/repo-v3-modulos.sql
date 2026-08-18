-- =====================================================================
--  IEFP CRM — REPOSITÓRIO v3: distinguir sessões por MÓDULO (UFCD)
-- =====================================================================
--  A mesma turma tem vários UFCD (ex.: 10868 e 10870) e os números de
--  sessão repetem-se entre eles. Solução leve: cada sessão ganha uma
--  etiqueta de módulo, escolhida de uma lista definida na turma.
--
--   • repo_turmas.modulos  -> lista de UFCD da turma ("10868, 10870")
--   • repo_sessoes.modulo  -> o UFCD desta sessão ("10868")
--
--  Sem hierarquia nova: é só um campo. Aparece na lista, no dashboard e
--  no email (marcador {modulo}).
--
--  COMO USAR: Supabase → SQL Editor → colar → Run. Idempotente.
--  Corre depois de repo-v3.sql, repo-v3-antibot.sql e repo-v3-token.sql.
-- =====================================================================

alter table public.repo_turmas  add column if not exists modulos text default '';
alter table public.repo_sessoes add column if not exists modulo  text default '';

-- ---------------------------------------------------------------------
-- Turmas geridas: devolver também a lista de módulos
-- ---------------------------------------------------------------------
drop function if exists public.repo_geridas(uuid);
create or replace function public.repo_geridas(p_token uuid)
returns table(id uuid, codigo text, nome text, drive_url text,
              n_formandos bigint, n_sessoes bigint, ultimo_envio timestamptz,
              def_assunto text, def_cabecalho text, def_saudacao text, def_botao text, def_rodape text,
              modulos text)
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
           coalesce(rt.def_rodape,    _repo_omissao('rodape')),
           coalesce(rt.modulos, '')
      from repo_turmas rt
     order by rt.criado_em desc;
end $$;

-- ---------------------------------------------------------------------
-- Guardar definições da turma: aceitar a lista de módulos
-- ---------------------------------------------------------------------
drop function if exists public.repo_turma_guardar(uuid,uuid,text,text,text,text,text,text);
create or replace function public.repo_turma_guardar(
  p_token uuid, p_id uuid, p_drive_url text,
  p_assunto text, p_cabecalho text, p_saudacao text, p_botao text, p_rodape text,
  p_modulos text
) returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform _repo_root(p_token);
  update repo_turmas set
    drive_url = coalesce(p_drive_url, drive_url),
    def_assunto = p_assunto, def_cabecalho = p_cabecalho, def_saudacao = p_saudacao,
    def_botao = p_botao, def_rodape = p_rodape, modulos = coalesce(p_modulos, '')
   where id = p_id;
  get diagnostics n = row_count;
  if n = 0 then raise exception 'NAO_ENCONTRADO'; end if;
  return json_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- Publicar: guardar o módulo da sessão
-- ---------------------------------------------------------------------
drop function if exists public.repo_sessao_publicar(uuid,uuid,text,text,text,text,text,text,text,text);
create or replace function public.repo_sessao_publicar(
  p_token uuid, p_repo_turma_id uuid, p_titulo text, p_texto text, p_link text,
  p_assunto text, p_cabecalho text, p_saudacao text, p_botao text, p_rodape text,
  p_modulo text
) returns json language plpgsql security definer set search_path = public as $$
declare rt public.repo_turmas; v_sess uuid; v_dest int; v_sem int;
begin
  perform _repo_root(p_token);
  if coalesce(trim(p_titulo),'')='' or coalesce(trim(p_link),'')='' then raise exception 'DADOS_EM_FALTA'; end if;
  select * into rt from repo_turmas where id = p_repo_turma_id;
  if rt.id is null then raise exception 'NAO_ENCONTRADO'; end if;

  insert into repo_sessoes(repo_turma_id, turma_id, titulo, texto, link, modulo,
                           assunto, cabecalho, saudacao, botao, rodape)
    values (rt.id, rt.turma_id, trim(p_titulo), coalesce(p_texto,''), trim(p_link), coalesce(trim(p_modulo),''),
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

-- ---------------------------------------------------------------------
-- Editar rascunho: aceitar o módulo
-- ---------------------------------------------------------------------
drop function if exists public.repo_sessao_editar(uuid,uuid,text,text,text,text,text,text,text,text);
create or replace function public.repo_sessao_editar(
  p_token uuid, p_id uuid, p_titulo text, p_texto text, p_link text,
  p_assunto text, p_cabecalho text, p_saudacao text, p_botao text, p_rodape text,
  p_modulo text
) returns json language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform _repo_root(p_token);
  if coalesce(trim(p_titulo),'')='' or coalesce(trim(p_link),'')='' then raise exception 'DADOS_EM_FALTA'; end if;
  update repo_sessoes set titulo=trim(p_titulo), texto=coalesce(p_texto,''), link=trim(p_link),
    modulo=coalesce(trim(p_modulo),''),
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

-- ---------------------------------------------------------------------
-- Lista de sessões: devolver o módulo
-- ---------------------------------------------------------------------
drop function if exists public.repo_sessoes_listar(uuid,uuid);
create or replace function public.repo_sessoes_listar(p_token uuid, p_repo_turma_id uuid)
returns table(id uuid, titulo text, texto text, link text, criado_em timestamptz, enviado_em timestamptz,
              assunto text, cabecalho text, saudacao text, botao text, rodape text, modulo text,
              destinatarios bigint, enviados bigint, abriram bigint)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select s.id, s.titulo, s.texto, s.link, s.criado_em, s.enviado_em,
           s.assunto, s.cabecalho, s.saudacao, s.botao, s.rodape, coalesce(s.modulo,''),
           (select count(*) from repo_acessos a where a.sessao_id=s.id),
           (select count(*) from repo_acessos a where a.sessao_id=s.id and a.enviado_em is not null),
           (select count(*) from repo_acessos a where a.sessao_id=s.id and a.primeiro_clique is not null)
      from repo_sessoes s
     where s.repo_turma_id = p_repo_turma_id
     order by s.criado_em desc;
end $$;

-- ---------------------------------------------------------------------
-- Pendentes (para a Edge Function): devolver o módulo p/ o marcador {modulo}
-- ---------------------------------------------------------------------
drop function if exists public.repo_pendentes(uuid,uuid);
create or replace function public.repo_pendentes(p_token uuid, p_sessao_id uuid)
returns table(acesso_id uuid, email text, email2 text, nome text, envio_token uuid,
              titulo text, texto text, turma text, modulo text,
              assunto text, cabecalho text, saudacao text, botao text, rodape text)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select a.id, a.email, a.email2,
           trim(coalesce(u.nome,'')||' '||coalesce(u.apelido,'')), a.token,
           s.titulo, s.texto, rt.codigo, coalesce(s.modulo,''),
           s.assunto, s.cabecalho, s.saudacao, s.botao, s.rodape
      from repo_acessos a
      join repo_sessoes s  on s.id = a.sessao_id
      join repo_turmas  rt on rt.id = s.repo_turma_id
      join utilizadores u  on u.id = a.user_id
     where a.sessao_id = p_sessao_id and a.enviado_em is null and coalesce(a.email,'')<>'';
end $$;
