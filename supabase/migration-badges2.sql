/* ================== BADGES: TRANCAR OS NAO APROVADOS ==================
   Um formando que nao passou nao deve poder receber o badge por engano.
   Em vez de o apagar da lista - onde deixaria de se perceber porque nao
   recebeu - fica la, trancado e a dizer porque.

   Aditivo. Correr depois do migration-selos.sql.
   ====================================================================== */

-- 1) A tranca ----------------------------------------------------------------
alter table public.repo_acessos add column if not exists bloqueado boolean not null default false;

-- 2) Trancar e destrancar ----------------------------------------------------
create or replace function public.repo_selo_bloquear(
  p_token uuid, p_acesso_id uuid, p_bloqueado boolean
) returns json language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  update repo_acessos set bloqueado = coalesce(p_bloqueado,false) where id = p_acesso_id;
  return json_build_object('ok', true);
end $$;

-- 3) A lista passa a dizer quem esta trancado --------------------------------
drop function if exists public.repo_selos(uuid, uuid);
create or replace function public.repo_selos(p_token uuid, p_repo_turma_id uuid)
returns table(acesso_id uuid, user_id uuid, nome text, username text,
              email text, destino text, enviado_em timestamptz, erro text,
              cliques int, ultimo_clique timestamptz, bloqueado boolean)
language plpgsql security definer set search_path = public as $$
declare v_sess uuid;
begin
  perform _repo_root(p_token);
  select id into v_sess from repo_sessoes
   where repo_turma_id = p_repo_turma_id and titulo = 'Selo de conclusão' limit 1;
  if v_sess is null then return; end if;
  return query
    select a.id, u.id, trim(coalesce(u.nome,'')||' '||coalesce(u.apelido,'')),
           u.username, a.email, a.destino, a.enviado_em, a.erro,
           a.cliques, a.ultimo_clique, a.bloqueado
      from repo_acessos a
      join utilizadores u on u.id = a.user_id
     where a.sessao_id = v_sess
     order by u.nome, u.apelido;
end $$;

-- 4) Um trancado nunca entra num envio ---------------------------------------
--    A tranca vive aqui, no servidor, e nao no botao do ecra: assim vale
--    mesmo, e nao so enquanto o ecra estiver aberto.
drop function if exists public.repo_pendentes(uuid, uuid, uuid);
create or replace function public.repo_pendentes(
  p_token uuid, p_sessao_id uuid, p_acesso_id uuid default null
) returns table(acesso_id uuid, email text, email2 text, nome text, envio_token uuid,
                titulo text, texto text, turma text,
                assunto text, cabecalho text, saudacao text, botao text, rodape text)
language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  return query
    select a.id, a.email, a.email2,
           trim(coalesce(u.nome,'')||' '||coalesce(u.apelido,'')), a.token,
           s.titulo, s.texto, rt.codigo,
           s.assunto, s.cabecalho, s.saudacao, s.botao, s.rodape
      from repo_acessos a
      join repo_sessoes s  on s.id = a.sessao_id
      join repo_turmas  rt on rt.id = s.repo_turma_id
      join utilizadores u  on u.id = a.user_id
     where a.sessao_id = p_sessao_id
       and (p_acesso_id is null or a.id = p_acesso_id)
       and a.bloqueado = false
       and a.enviado_em is null and coalesce(a.email,'') <> '';
end $$;

-- 5) O preparar devolve tambem o texto do email, para o ecra o mostrar -------
create or replace function public.repo_selos_preparar(p_token uuid, p_repo_turma_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare rt public.repo_turmas; v_sess uuid; v_novos int; s public.repo_sessoes;
begin
  perform _repo_root(p_token);
  select * into rt from repo_turmas where id = p_repo_turma_id;
  if rt.id is null then raise exception 'NAO_ENCONTRADO'; end if;

  select id into v_sess from repo_sessoes
   where repo_turma_id = rt.id and titulo = 'Selo de conclusão' limit 1;

  if v_sess is null then
    insert into repo_sessoes(repo_turma_id, turma_id, titulo, texto, link, modulo,
                             assunto, cabecalho, saudacao, botao, rodape)
      values (rt.id, rt.turma_id, 'Selo de conclusão',
              'O teu badge da formação prática em CRM.',
              'https://crm.cr0x.org/', '',
              'O teu badge - Formação prática em CRM',
              'Formação prática em CRM',
              'Olá {nome},',
              'Ver o meu badge',
              'Este badge confirma a conclusão de um módulo de formação. Não é uma certificação profissional nem substitui o certificado da entidade formadora.')
      returning id into v_sess;
  end if;

  insert into repo_acessos(sessao_id, user_id, email, email2)
    select v_sess, u.id,
           coalesce(nullif(lower(trim(u.email2)),''), nullif(lower(trim(u.email)),'')),
           null
      from utilizadores u
     where u.turma_id = rt.turma_id and u.papel = 'Formando'
       and coalesce(nullif(trim(u.email),''), nullif(trim(u.email2),'')) is not null
       and not exists (select 1 from repo_acessos a
                        where a.sessao_id = v_sess and a.user_id = u.id);
  get diagnostics v_novos = row_count;

  select * into s from repo_sessoes where id = v_sess;
  return json_build_object('ok', true, 'sessao_id', v_sess, 'novos', v_novos,
    'titulo', s.titulo, 'texto', s.texto, 'assunto', s.assunto,
    'cabecalho', s.cabecalho, 'saudacao', s.saudacao, 'botao', s.botao, 'rodape', s.rodape);
end $$;

-- 6) Permissoes --------------------------------------------------------------
grant execute on function public.repo_selo_bloquear(uuid,uuid,boolean) to anon, authenticated;
grant execute on function public.repo_selos(uuid,uuid)                 to anon, authenticated;
grant execute on function public.repo_pendentes(uuid,uuid,uuid)        to anon, authenticated;
grant execute on function public.repo_selos_preparar(uuid,uuid)        to anon, authenticated;
