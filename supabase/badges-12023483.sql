/* ================== LIGAR OS BADGES AOS FORMANDOS ==================
   Correr DEPOIS de:
     1. migration-selos.sql
     2. abrir uma vez o ecra Badges da turma no Repo - e ai que a lista nasce

   Nao precisa de token: corre no SQL Editor, que ja tem privilegios.
   Pode correr as vezes que quiser - so escreve o destino, nada mais.
   ================================================================== */
update public.repo_acessos a
   set destino = v.url
  from (values
    ('amendes','https://crm.cr0x.org/b/KCP43DBw/'),
    ('amartins','https://crm.cr0x.org/b/wffsG4CQ/'),
    ('bneves','https://crm.cr0x.org/b/Rwf96Zmz/'),
    ('cnunes','https://crm.cr0x.org/b/h8mTmGPV/'),
    ('dprata','https://crm.cr0x.org/b/yjqjtsWH/'),
    ('ggonzaga','https://crm.cr0x.org/b/DXcPf5zZ/'),
    ('gsantos','https://crm.cr0x.org/b/Czhr9FwR/'),
    ('ilima','https://crm.cr0x.org/b/RrJ5ZSHB/'),
    ('imachado','https://crm.cr0x.org/b/7cp55GGy/'),
    ('jferreira','https://crm.cr0x.org/b/g9N6cZ5q/'),
    ('lferreira','https://crm.cr0x.org/b/mH6F29Rr/'),
    ('ysilva','https://crm.cr0x.org/b/9GVj6HsP/')
  ) as v(username, url)
  join public.utilizadores u  on lower(u.username) = v.username
  join public.repo_sessoes  s on s.titulo = 'Selo de conclusão' and s.turma_id = u.turma_id
 where a.user_id = u.id and a.sessao_id = s.id;

/* conferir */
select u.username, trim(u.nome||' '||coalesce(u.apelido,'')) as formando, a.destino, a.enviado_em
  from public.repo_acessos a
  join public.utilizadores u on u.id = a.user_id
  join public.repo_sessoes  s on s.id = a.sessao_id
 where s.titulo = 'Selo de conclusão'
 order by u.nome;
