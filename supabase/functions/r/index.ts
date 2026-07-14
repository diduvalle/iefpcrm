// IEFP CRM — Repositório: o redirect que regista quem abriu.
//
// É este o link que vai dentro do email:  .../functions/v1/r?t=<token>
// O token é pessoal (um por formando por publicação). A função regista o
// clique e reencaminha para o bitly. Para o formando é indistinguível de
// um link normal: não pede login, não mostra nada, não trava nada.
//
// Deploy (Supabase): Edge Functions → criar "r" → colar este ficheiro.
// Desligar "Enforce JWT" — quem clica no email não traz credenciais.
// Não precisa de secrets além dos que o Supabase injeta sozinho.

const FALLBACK = "https://iefpcrm.cr0x.org/repo/"; // token inválido ou já apagado

Deno.serve(async (req) => {
  const url = new URL(req.url);
  // aceita ?t=<token> e também /r/<token>
  const t = url.searchParams.get("t") ||
    url.pathname.split("/").filter(Boolean).pop() || "";

  const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuid.test(t)) return Response.redirect(FALLBACK, 302);

  try {
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/repo_registar_clique`, {
      method: "POST",
      headers: {
        apikey: SERVICE_ROLE,
        Authorization: `Bearer ${SERVICE_ROLE}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ p_envio_token: t }),
    });

    const data = await res.json().catch(() => null);
    if (!data?.ok || !data?.link) return Response.redirect(FALLBACK, 302);

    // 302 e não 301: um 301 fica em cache no browser e os cliques seguintes
    // deixariam de passar por aqui — perdíamos a contagem.
    return new Response(null, {
      status: 302,
      headers: { Location: data.link, "Cache-Control": "no-store" },
    });
  } catch (_e) {
    return Response.redirect(FALLBACK, 302);
  }
});
