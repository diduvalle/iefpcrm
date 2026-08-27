/* ================== SELOS NO REPO ==================
   Enviar a cada formando o link do SEU selo, a partir do sítio onde a turma
   já vive. O Repo já sabe fazer isto quase todo: gera um link por pessoa,
   envia por email e regista quem abriu. Só lhe falta uma coisa - hoje todos
   os links de uma sessão apontam para o MESMO destino (a pasta do Drive), e
   aqui cada pessoa tem de ir para um sítio diferente.

   Por isso: uma coluna `destino` em repo_acessos. Quando está preenchida,
   manda para lá; quando está vazia, tudo se comporta como antes.

   Tudo aditivo. Nada do que já existe muda de comportamento.
   Correr UMA VEZ no SQL Editor.
   ==================================================== */

-- 1) O destino de cada pessoa -----------------------------------------------
alter table public.repo_acessos add column if not exists destino text;

-- 2) O clique passa a preferir o destino da pessoa ---------------------------
--    Sem destino, devolve o link da sessão: exatamente como sempre fez.
create or replace function public.repo_click(p_token uuid)
returns json language plpgsql security definer set search_path = public as $$
declare v_link text;
begin
  update repo_acessos a set cliques=a.cliques+1,
    primeiro_clique=coalesce(a.primeiro_clique, now()), ultimo_clique=now()
   from repo_sessoes s where a.token=p_token and s.id=a.sessao_id
  returning coalesce(nullif(trim(a.destino),''), s.link) into v_link;
  if v_link is null then return json_build_object('ok', false); end if;
  return json_build_object('ok', true, 'link', v_link);
end $$;

-- 3) Enviar a UMA pessoa -----------------------------------------------------
--    O terceiro argumento é opcional: sem ele, continua a enviar a todos os
--    que faltam, que é o que o botão de sessão faz hoje.
drop function if exists public.repo_pendentes(uuid, uuid);
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
       and a.enviado_em is null and coalesce(a.email,'') <> '';
end $$;

-- 4) Preparar os selos de uma turma ------------------------------------------
--    Cria (uma vez) a "sessão" dos selos e a linha de cada formando.
--    Chamar as vezes que quiser: não duplica nada.
create or replace function public.repo_selos_preparar(p_token uuid, p_repo_turma_id uuid)
returns json language plpgsql security definer set search_path = public as $$
declare rt public.repo_turmas; v_sess uuid; v_novos int;
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
              'O teu selo da formação prática em CRM.',
              'https://crm.cr0x.org/', '',
              'O teu selo - Formação prática em CRM',
              'Formação prática em CRM',
              'Olá {nome},',
              'Ver o meu selo',
              'Este selo confirma a conclusão de um módulo de formação. Não é uma certificação profissional nem substitui o certificado da entidade formadora.')
      returning id into v_sess;
  end if;

  -- email pessoal com recurso ao do IEFP, como no resto do Repo
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

  return json_build_object('ok', true, 'sessao_id', v_sess, 'novos', v_novos);
end $$;

-- 5) A lista, para o ecrã ----------------------------------------------------
create or replace function public.repo_selos(p_token uuid, p_repo_turma_id uuid)
returns table(acesso_id uuid, user_id uuid, nome text, username text,
              email text, destino text, enviado_em timestamptz, erro text,
              cliques int, ultimo_clique timestamptz)
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
           a.cliques, a.ultimo_clique
      from repo_acessos a
      join utilizadores u on u.id = a.user_id
     where a.sessao_id = v_sess
     order by u.nome, u.apelido;
end $$;

-- 6) Definir os destinos, por utilizador -------------------------------------
--    p_pares: {"amendes":"https://crm.cr0x.org/b/XXXX/", ...}
create or replace function public.repo_selos_definir(
  p_token uuid, p_repo_turma_id uuid, p_pares jsonb
) returns json language plpgsql security definer set search_path = public as $$
declare v_sess uuid; v_n int;
begin
  perform _repo_root(p_token);
  select id into v_sess from repo_sessoes
   where repo_turma_id = p_repo_turma_id and titulo = 'Selo de conclusão' limit 1;
  if v_sess is null then raise exception 'SEM_SESSAO'; end if;

  update repo_acessos a set destino = x.url
    from (select key as username, value #>> '{}' as url from jsonb_each(p_pares)) x
    join utilizadores u on lower(u.username) = lower(x.username)
   where a.sessao_id = v_sess and a.user_id = u.id;
  get diagnostics v_n = row_count;
  return json_build_object('ok', true, 'definidos', v_n);
end $$;

-- 7) Reenviar a uma pessoa ---------------------------------------------------
--    Limpa a marca de enviado para aquela linha voltar a ficar pendente.
create or replace function public.repo_selo_reabrir(p_token uuid, p_acesso_id uuid)
returns json language plpgsql security definer set search_path = public as $$
begin
  perform _repo_root(p_token);
  update repo_acessos set enviado_em = null, erro = null where id = p_acesso_id;
  return json_build_object('ok', true);
end $$;

-- 8) Permissões --------------------------------------------------------------
grant execute on function public.repo_pendentes(uuid,uuid,uuid)      to anon, authenticated;
grant execute on function public.repo_selos_preparar(uuid,uuid)      to anon, authenticated;
grant execute on function public.repo_selos(uuid,uuid)               to anon, authenticated;
grant execute on function public.repo_selos_definir(uuid,uuid,jsonb) to anon, authenticated;
grant execute on function public.repo_selo_reabrir(uuid,uuid)        to anon, authenticated;
