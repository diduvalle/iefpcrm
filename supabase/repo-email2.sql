-- =====================================================================
--  IEFP CRM — REPOSITÓRIO: enviar para os dois emails + reler o enviado
-- =====================================================================
--  Três correções pedidas depois do primeiro envio real:
--
--  1) A turma disse que ninguém usa o email do IEFP. Passamos a enviar
--     para AMBOS (pessoal + IEFP), com o pessoal como principal.
--  2) Os textos de fábrica passam a ser os que o formador aprovou.
--  3) A lista de publicações passa a devolver o texto congelado do email,
--     para se poder reler exatamente o que foi enviado.
--
--  COMO USAR: Supabase → SQL Editor → colar tudo → Run. Idempotente.
--  Corre DEPOIS de repo.sql e repo-email.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Segundo email por envio
-- ---------------------------------------------------------------------
alter table public.repo_envios add column if not exists email2 text;

-- ---------------------------------------------------------------------
-- 2) Textos de fábrica (os do print aprovado)
-- ---------------------------------------------------------------------
create or replace function public._repo_omissao(p_campo text)
returns text language sql immutable as $$
  select case p_campo
    when 'assunto'   then 'UFCD {ufcd} - {titulo}'
    when 'cabecalho' then 'UFCD {ufcd} - material novo'
    when 'saudacao'  then 'Olá {nome},'
    when 'botao'     then 'Aceder ao material'
    when 'rodape'    then '{nome}, este link é pessoal e regista a sua abertura.'
  end;
$$;

-- ---------------------------------------------------------------------
-- 3) Publicar: guardar os DOIS emails
--    email  = pessoal (o principal, já que ninguém usa o do IEFP)
--    email2 = o do IEFP, quando existe além do pessoal
-- ---------------------------------------------------------------------
create or replace function public.repo_publicar(
  p_token uuid, p_modulo_id uuid, p_titulo text, p_texto text, p_link text,
  p_assunto text default null, p_cabecalho text default null,
  p_saudacao text default null, p_botao text default null, p_rodape text default null
) returns json
language plpgsql security definer set search_path = public as $$
declare
  caller public.utilizadores; m public.repo_modulos;
  v_pub uuid; v_dest int; v_sem int;
  v_assunto text; v_cab text; v_saud text; v_btn text; v_rod text;
begin
  caller := _repo_formador(p_token);
  if coalesce(trim(p_titulo),'') = '' or coalesce(trim(p_link),'') = '' then
    raise exception 'DADOS_EM_FALTA';
  end if;
  select * into m from repo_modulos
   where id = p_modulo_id and turma_id = caller.turma_id;
  if m.id is null then raise exception 'NAO_ENCONTRADO'; end if;

  v_assunto := coalesce(nullif(trim(p_assunto),''),   m.def_assunto,   _repo_omissao('assunto'));
  v_cab     := coalesce(nullif(trim(p_cabecalho),''), m.def_cabecalho, _repo_omissao('cabecalho'));
  v_saud    := coalesce(nullif(trim(p_saudacao),''),  m.def_saudacao,  _repo_omissao('saudacao'));
  v_btn     := coalesce(nullif(trim(p_botao),''),     m.def_botao,     _repo_omissao('botao'));
  v_rod     := coalesce(nullif(trim(p_rodape),''),    m.def_rodape,    _repo_omissao('rodape'));

  insert into repo_publicacoes(turma_id, modulo_id, titulo, texto, link, criado_por,
                               assunto, cabecalho, saudacao, botao, rodape)
    values (caller.turma_id, p_modulo_id, trim(p_titulo), coalesce(p_texto,''),
            trim(p_link), caller.id, v_assunto, v_cab, v_saud, v_btn, v_rod)
    returning id into v_pub;

  update repo_modulos
     set def_assunto = v_assunto, def_cabecalho = v_cab, def_saudacao = v_saud,
         def_botao = v_btn, def_rodape = v_rod
   where id = p_modulo_id;

  -- um envio por formando com PELO MENOS um email; guarda os dois.
  insert into repo_envios(publicacao_id, user_id, email, email2)
    select v_pub, u.id,
           coalesce(nullif(lower(trim(u.email2)),''), nullif(lower(trim(u.email)),'')),   -- principal: pessoal
           case when nullif(trim(u.email2),'') is not null
                 and nullif(trim(u.email),'')  is not null
                then nullif(lower(trim(u.email)),'') end                                   -- secundário: IEFP
      from utilizadores u
     where u.turma_id = caller.turma_id
       and u.papel = 'Formando'
       and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is not null;
  get diagnostics v_dest = row_count;

  select count(*) into v_sem
    from utilizadores u
   where u.turma_id = caller.turma_id
     and u.papel = 'Formando'
     and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is null;

  return json_build_object('id', v_pub, 'destinatarios', v_dest, 'sem_email', v_sem);
end $$;

-- ---------------------------------------------------------------------
-- 4) Pendentes: devolver os dois emails à Edge Function
-- ---------------------------------------------------------------------
drop function if exists public.repo_envios_pendentes(uuid,uuid);
create or replace function public.repo_envios_pendentes(p_token uuid, p_publicacao uuid)
returns table(envio_id uuid, email text, email2 text, nome text, envio_token uuid,
              titulo text, texto text, ufcd text, turma text,
              assunto text, cabecalho text, saudacao text, botao text, rodape text)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  return query
    select e.id, e.email, e.email2,
           trim(coalesce(u.nome,'') || ' ' || coalesce(u.apelido,'')),
           e.token, p.titulo, p.texto, m.ufcd, t.codigo,
           coalesce(p.assunto,   _repo_omissao('assunto')),
           coalesce(p.cabecalho, _repo_omissao('cabecalho')),
           coalesce(p.saudacao,  _repo_omissao('saudacao')),
           coalesce(p.botao,     _repo_omissao('botao')),
           coalesce(p.rodape,    _repo_omissao('rodape'))
      from repo_envios e
      join repo_publicacoes p on p.id = e.publicacao_id
      join repo_modulos m     on m.id = p.modulo_id
      join turmas t           on t.id = p.turma_id
      join utilizadores u     on u.id = e.user_id
     where e.publicacao_id = p_publicacao
       and p.turma_id = caller.turma_id
       and e.enviado_em is null;
end $$;

-- ---------------------------------------------------------------------
-- 5) Lista de publicações: devolver o email congelado (para reler)
-- ---------------------------------------------------------------------
drop function if exists public.repo_publicacoes_listar(uuid,uuid);
create or replace function public.repo_publicacoes_listar(p_token uuid, p_modulo uuid default null)
returns table(id uuid, modulo_id uuid, ufcd text, titulo text, texto text, link text,
              criado_em timestamptz, enviado_em timestamptz,
              assunto text, cabecalho text, saudacao text, botao text, rodape text,
              destinatarios bigint, enviados bigint, abriram bigint)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  return query
    select p.id, p.modulo_id, m.ufcd, p.titulo, p.texto, p.link,
           p.criado_em, p.enviado_em,
           coalesce(p.assunto,   _repo_omissao('assunto')),
           coalesce(p.cabecalho, _repo_omissao('cabecalho')),
           coalesce(p.saudacao,  _repo_omissao('saudacao')),
           coalesce(p.botao,     _repo_omissao('botao')),
           coalesce(p.rodape,    _repo_omissao('rodape')),
           (select count(*) from repo_envios e where e.publicacao_id = p.id),
           (select count(*) from repo_envios e where e.publicacao_id = p.id and e.enviado_em is not null),
           (select count(*) from repo_envios e where e.publicacao_id = p.id and e.primeiro_clique is not null)
      from repo_publicacoes p
      join repo_modulos m on m.id = p.modulo_id
     where p.turma_id = caller.turma_id
       and (p_modulo is null or p.modulo_id = p_modulo)
     order by p.criado_em desc;
end $$;

-- ---------------------------------------------------------------------
-- 6) Estado por formando: mostrar os dois emails
-- ---------------------------------------------------------------------
drop function if exists public.repo_estado(uuid,uuid);
create or replace function public.repo_estado(p_token uuid, p_publicacao uuid)
returns table(nome text, username text, email text, email2 text, enviado_em timestamptz,
              erro text, primeiro_clique timestamptz, cliques int)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  return query
    select trim(coalesce(u.nome,'') || ' ' || coalesce(u.apelido,'')),
           u.username, e.email, e.email2, e.enviado_em, e.erro, e.primeiro_clique, e.cliques
      from repo_envios e
      join repo_publicacoes p on p.id = e.publicacao_id
      join utilizadores u     on u.id = e.user_id
     where e.publicacao_id = p_publicacao
       and p.turma_id = caller.turma_id
     order by e.primeiro_clique nulls first, u.nome;
end $$;
