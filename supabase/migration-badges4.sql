/* ================== EDITAR O EMAIL DOS BADGES ==================
   O ecra so mostrava o email. As sessoes ja se editavam; os badges nao -
   ficou a faltar, e e o texto que doze pessoas vao ler.
   =============================================================== */
create or replace function public.repo_selos_email(
  p_token uuid, p_repo_turma_id uuid,
  p_assunto text, p_cabecalho text, p_saudacao text,
  p_titulo text, p_texto text, p_botao text, p_rodape text
) returns json language plpgsql security definer set search_path = public as $$
declare v_sess uuid;
begin
  perform _repo_root(p_token);
  select id into v_sess from repo_sessoes
   where repo_turma_id = p_repo_turma_id and tipo = 'badge' limit 1;
  if v_sess is null then raise exception 'SEM_SESSAO'; end if;

  update repo_sessoes set
    assunto   = nullif(trim(p_assunto),''),
    cabecalho = nullif(trim(p_cabecalho),''),
    saudacao  = nullif(trim(p_saudacao),''),
    titulo    = coalesce(nullif(trim(p_titulo),''), titulo),
    texto     = coalesce(p_texto, texto),
    botao     = nullif(trim(p_botao),''),
    rodape    = nullif(trim(p_rodape),'')
   where id = v_sess;
  return json_build_object('ok', true);
end $$;

grant execute on function public.repo_selos_email(uuid,uuid,text,text,text,text,text,text,text)
  to anon, authenticated;

/* Repor a linha de teste do formador, para voltar a poder enviar. */
update public.repo_acessos a
   set enviado_em = null, erro = null, cliques = 0,
       primeiro_clique = null, ultimo_clique = null, bloqueado = false
  from public.repo_sessoes s, public.utilizadores u
 where s.id = a.sessao_id and s.tipo = 'badge'
   and u.id = a.user_id and lower(u.username) = 'duvalle';

select trim(u.nome||' '||coalesce(u.apelido,'')) as quem, a.enviado_em, a.cliques, a.bloqueado
  from public.repo_acessos a
  join public.utilizadores u on u.id = a.user_id
  join public.repo_sessoes  s on s.id = a.sessao_id
 where s.tipo='badge' and lower(u.username)='duvalle';
