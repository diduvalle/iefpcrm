-- =====================================================================
--  IEFP CRM — REPOSITÓRIO: o email passa a ser todo teu
-- =====================================================================
--  Antes, só o título e a mensagem eram editáveis; o assunto, a saudação,
--  o rótulo do botão e a nota de rodapé estavam à pedra dentro do código.
--  Agora são campos. E a mensagem passa a aceitar texto rico (HTML).
--
--  Cada módulo guarda o que usaste da última vez, e a publicação seguinte
--  já nasce preenchida com isso. Só escreves o que muda.
--
--  Marcadores que podes usar em qualquer campo:
--    {nome}   nome do formando        {ufcd}    número da UFCD
--    {titulo} título da publicação    {turma}   código da turma
--
--  COMO USAR: Supabase → SQL Editor → colar tudo → Run. Idempotente.
--  Corre DEPOIS do repo.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Colunas novas
-- ---------------------------------------------------------------------

-- Omissões por módulo: o que escreveste da última vez fica aqui.
alter table public.repo_modulos add column if not exists def_assunto   text;
alter table public.repo_modulos add column if not exists def_cabecalho text;
alter table public.repo_modulos add column if not exists def_saudacao  text;
alter table public.repo_modulos add column if not exists def_botao     text;
alter table public.repo_modulos add column if not exists def_rodape    text;

-- O que foi mesmo enviado, congelado na publicação (se mudares as omissões
-- do módulo amanhã, o histórico continua a mostrar o email que saiu hoje).
alter table public.repo_publicacoes add column if not exists assunto   text;
alter table public.repo_publicacoes add column if not exists cabecalho text;
alter table public.repo_publicacoes add column if not exists saudacao  text;
alter table public.repo_publicacoes add column if not exists botao     text;
alter table public.repo_publicacoes add column if not exists rodape    text;

-- Os valores de fábrica, quando o módulo ainda não tem nada guardado.
create or replace function public._repo_omissao(p_campo text)
returns text language sql immutable as $$
  select case p_campo
    when 'assunto'   then 'UFCD {ufcd} - {titulo}'
    when 'cabecalho' then 'UFCD {ufcd} - material novo'
    when 'saudacao'  then 'Olá {nome},'
    when 'botao'     then 'Abrir o material'
    when 'rodape'    then 'Turma {turma}. Este link é pessoal e regista a sua abertura, para o formador saber quem já teve acesso ao material.'
  end;
$$;

-- ---------------------------------------------------------------------
-- Módulos: passar a devolver as omissões guardadas
-- ---------------------------------------------------------------------
drop function if exists public.repo_modulos_listar(uuid);
create or replace function public.repo_modulos_listar(p_token uuid)
returns table(id uuid, ufcd text, nome text, drive_url text, bitly_url text,
              publicacoes bigint,
              def_assunto text, def_cabecalho text, def_saudacao text,
              def_botao text, def_rodape text)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;
  return query
    select m.id, m.ufcd, m.nome, m.drive_url, m.bitly_url,
           (select count(*) from repo_publicacoes p where p.modulo_id = m.id),
           coalesce(m.def_assunto,   _repo_omissao('assunto')),
           coalesce(m.def_cabecalho, _repo_omissao('cabecalho')),
           coalesce(m.def_saudacao,  _repo_omissao('saudacao')),
           coalesce(m.def_botao,     _repo_omissao('botao')),
           coalesce(m.def_rodape,    _repo_omissao('rodape'))
    from repo_modulos m
    where m.turma_id = caller.turma_id
    order by m.ufcd;
end $$;

-- ---------------------------------------------------------------------
-- Publicar: agora com o email inteiro
-- ---------------------------------------------------------------------
-- Os parâmetros novos têm omissão, por isso chamadas antigas continuam a
-- funcionar (caem nas omissões do módulo).
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

  -- o que veio do ecrã > o que o módulo guardou > o valor de fábrica
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

  -- o módulo passa a lembrar-se: a próxima publicação já nasce assim
  update repo_modulos
     set def_assunto = v_assunto, def_cabecalho = v_cab, def_saudacao = v_saud,
         def_botao = v_btn, def_rodape = v_rod
   where id = p_modulo_id;

  insert into repo_envios(publicacao_id, user_id, email)
    select v_pub, u.id, lower(trim(coalesce(nullif(trim(u.email),''), u.email2)))
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
-- Destinatários: devolver o email completo à Edge Function
-- ---------------------------------------------------------------------
drop function if exists public.repo_envios_pendentes(uuid,uuid);
create or replace function public.repo_envios_pendentes(p_token uuid, p_publicacao uuid)
returns table(envio_id uuid, email text, nome text, envio_token uuid,
              titulo text, texto text, ufcd text, turma text,
              assunto text, cabecalho text, saudacao text, botao text, rodape text)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  caller := _repo_formador(p_token);
  return query
    select e.id, e.email,
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
