-- =====================================================================
--  IEFP CRM — REPOSITÓRIO v2: o link da turma passa a ser a própria app
-- =====================================================================
--  O que muda:
--  1) Os FORMANDOS também entram (com a conta que já têm da app IEFP)
--     e ganham a vista "Materiais": tudo o que foi publicado para a
--     turma, cada item com o SEU link pessoal — o clique conta na mesma,
--     venha do email ou da página. O bitly deixa de ser necessário:
--     o link de aula é iefpcrm.cr0x.org/repo, sempre o mesmo.
--  2) Rascunhos passam a poder ser EDITADOS antes do envio.
--  3) "Reenviar a quem não abriu": reabre esses envios para a Edge
--     Function os despachar outra vez.
--  4) Quem entra na turma DEPOIS de uma publicação vê-a na mesma
--     (auto-reparação: o registo dele é criado quando abre a página).
--
--  COMO USAR: Supabase → SQL Editor → colar tudo → Run. Idempotente.
--  Corre depois de repo.sql, repo-email.sql e repo-email2.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Vista do formando: os meus materiais, com o meu link pessoal
-- ---------------------------------------------------------------------
create or replace function public.repo_meus_materiais(p_token uuid)
returns table(publicacao_id uuid, titulo text, texto text, ufcd text, modulo text,
              publicado_em timestamptz, botao text, envio_token uuid, aberto_em timestamptz)
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores;
begin
  select * into caller from _user_from_token(p_token);
  if caller.id is null then raise exception 'SESSAO_INVALIDA'; end if;

  -- auto-reparação: se este formando entrou na turma depois de uma
  -- publicação (ou não tinha email na altura), cria-se agora o registo
  -- dele, com token próprio. Fica com email vazio — vê e clica na
  -- página, só não recebeu o aviso por email.
  insert into repo_envios(publicacao_id, user_id, email)
  select p.id, caller.id, ''
    from repo_publicacoes p
   where p.turma_id = caller.turma_id and p.enviado_em is not null
  on conflict (publicacao_id, user_id) do nothing;

  return query
    select p.id, p.titulo, p.texto, m.ufcd, m.nome,
           p.enviado_em, coalesce(p.botao, _repo_omissao('botao')),
           e.token, e.primeiro_clique
      from repo_envios e
      join repo_publicacoes p on p.id = e.publicacao_id
      join repo_modulos m     on m.id = p.modulo_id
     where e.user_id = caller.id
       and p.enviado_em is not null
     order by p.enviado_em desc;
end $$;

-- ---------------------------------------------------------------------
-- 2) Editar um rascunho (só antes do primeiro envio)
-- ---------------------------------------------------------------------
create or replace function public.repo_publicacao_editar(
  p_token uuid, p_id uuid, p_titulo text, p_texto text, p_link text,
  p_assunto text default null, p_cabecalho text default null,
  p_saudacao text default null, p_botao text default null, p_rodape text default null
) returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; n int;
begin
  caller := _repo_formador(p_token);
  if coalesce(trim(p_titulo),'') = '' or coalesce(trim(p_link),'') = '' then
    raise exception 'DADOS_EM_FALTA';
  end if;
  update repo_publicacoes
     set titulo = trim(p_titulo), texto = coalesce(p_texto,''), link = trim(p_link),
         assunto   = coalesce(nullif(trim(p_assunto),''),   assunto),
         cabecalho = coalesce(nullif(trim(p_cabecalho),''), cabecalho),
         saudacao  = coalesce(nullif(trim(p_saudacao),''),  saudacao),
         botao     = coalesce(nullif(trim(p_botao),''),     botao),
         rodape    = coalesce(nullif(trim(p_rodape),''),    rodape)
   where id = p_id and turma_id = caller.turma_id and enviado_em is null;
  get diagnostics n = row_count;
  if n = 0 then
    if exists (select 1 from repo_publicacoes where id = p_id and turma_id = caller.turma_id)
      then raise exception 'JA_ENVIADA';
      else raise exception 'NAO_ENCONTRADO';
    end if;
  end if;
  return json_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- 3) Reenviar a quem não abriu: reabre esses envios
-- ---------------------------------------------------------------------
create or replace function public.repo_reabrir_nao_abriram(p_token uuid, p_publicacao uuid)
returns json
language plpgsql security definer set search_path = public as $$
declare caller public.utilizadores; n int;
begin
  caller := _repo_formador(p_token);
  update repo_envios e
     set enviado_em = null, erro = null
    from repo_publicacoes p
   where e.publicacao_id = p_publicacao and p.id = e.publicacao_id
     and p.turma_id = caller.turma_id
     and e.enviado_em is not null
     and e.primeiro_clique is null
     and coalesce(e.email,'') <> '';
  get diagnostics n = row_count;
  return json_build_object('reabertos', n);
end $$;

-- ---------------------------------------------------------------------
-- 4) Os registos de auto-reparação (sem email) nunca entram na fila
--    de envio — redefinição de repo_envios_pendentes com esse guarda.
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
       and e.enviado_em is null
       and coalesce(e.email,'') <> '';
end $$;
