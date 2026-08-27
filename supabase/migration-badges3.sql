/* ================== O TITULO DEIXA DE SER A CHAVE ==================
   A sessao dos badges era encontrada pelo TITULO ('Selo de conclusão').
   Isso quer dizer que mudar a palavra que o formando ve no email partia a
   ligacao por dentro - uma armadilha a espera de quem la mexer.

   Passa a haver um campo proprio, `tipo`. O titulo fica texto livre, e pode
   mudar sempre que se quiser sem partir nada.

   Aproveita-se para trocar "Selo" por "Badge" e para o email deixar de dizer
   duas vezes a mesma coisa.
   ==================================================================== */

-- 1) O campo que passa a ser a chave -----------------------------------------
alter table public.repo_sessoes add column if not exists tipo text;

update public.repo_sessoes
   set tipo = 'badge',
       titulo = 'O teu badge está pronto',
       texto  = 'Concluíste a formação prática em CRM. Este é o teu badge, com uma página própria onde qualquer pessoa pode confirmar.'
 where titulo = 'Selo de conclusão';

-- 2) As funcoes passam a procurar pelo tipo ----------------------------------
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
   where repo_turma_id = p_repo_turma_id and tipo = 'badge' limit 1;
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

create or replace function public.repo_selos_preparar(p_token uuid, p_repo_turma_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare rt public.repo_turmas; v_sess uuid; v_novos int; s public.repo_sessoes;
begin
  perform _repo_root(p_token);
  select * into rt from repo_turmas where id = p_repo_turma_id;
  if rt.id is null then raise exception 'NAO_ENCONTRADO'; end if;

  select id into v_sess from repo_sessoes
   where repo_turma_id = rt.id and tipo = 'badge' limit 1;

  if v_sess is null then
    insert into repo_sessoes(repo_turma_id, turma_id, tipo, titulo, texto, link, modulo,
                             assunto, cabecalho, saudacao, botao, rodape)
      values (rt.id, rt.turma_id, 'badge',
              'O teu badge está pronto',
              'Concluíste a formação prática em CRM. Este é o teu badge, com uma página própria onde qualquer pessoa pode confirmar.',
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

create or replace function public.repo_selos_definir(
  p_token uuid, p_repo_turma_id uuid, p_pares jsonb
) returns json language plpgsql security definer set search_path = public as $$
declare v_sess uuid; v_n int;
begin
  perform _repo_root(p_token);
  select id into v_sess from repo_sessoes
   where repo_turma_id = p_repo_turma_id and tipo = 'badge' limit 1;
  if v_sess is null then raise exception 'SEM_SESSAO'; end if;

  update repo_acessos a set destino = x.url
    from (select key as username, value #>> '{}' as url from jsonb_each(p_pares)) x
    join utilizadores u on lower(u.username) = lower(x.username)
   where a.sessao_id = v_sess and a.user_id = u.id;
  get diagnostics v_n = row_count;
  return json_build_object('ok', true, 'definidos', v_n);
end $$;

-- 3) A sessao dos badges sai da lista de sessoes, no servidor ----------------
--    Assim o ecra deixa de precisar de a filtrar pelo nome.
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
       and coalesce(s.tipo,'') <> 'badge'
     order by s.criado_em desc;
end $$;

grant execute on function public.repo_selos(uuid,uuid)               to anon, authenticated;
grant execute on function public.repo_selos_preparar(uuid,uuid)      to anon, authenticated;
grant execute on function public.repo_selos_definir(uuid,uuid,jsonb) to anon, authenticated;
grant execute on function public.repo_sessoes_listar(uuid,uuid)      to anon, authenticated;
