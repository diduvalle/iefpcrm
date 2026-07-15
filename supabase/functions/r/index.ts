// IEFP CRM — Repositório: redirect com registo À PROVA DE SCANNERS.
//
// Problema resolvido: os scanners de email (Microsoft Safe Links, antivírus)
// abrem automaticamente todos os links ao entregar a mensagem, o que gerava
// aberturas falsas (12 formandos "abriram" ao mesmo segundo).
//
// Solução: o link do email abre uma página mínima. O registo da abertura só
// acontece quando um BROWSER REAL corre o JavaScript (fetch a &hit=1). Os
// scanners buscam a página mas não correm JS -> não contam. Um humano é
// redirecionado para a pasta quase instantaneamente.
//
//   r?t=<token>          -> serve a página (NÃO regista)          [scanner + humano]
//   r?t=<token>&hit=1    -> regista o clique e devolve {link}     [só o JS da página]
//
// Deploy (Supabase): Edge Functions → r → Code → colar → Deploy.
// "Verify JWT" DESLIGADO (quem clica no email não traz credenciais).

const FALLBACK = "https://iefpcrm.cr0x.org/repo/";
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const json = (b: unknown) =>
  new Response(JSON.stringify(b), {
    status: 200,
    headers: { "Content-Type": "application/json", "Cache-Control": "no-store" },
  });

function esc(s: string) {
  return String(s ?? "").replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c] as string));
}

// Página mínima: spinner + registo por JS + fallback sem-JS (link direto).
function pagina(link: string) {
  const L = esc(link);
  const FB = JSON.stringify(FALLBACK);
  const LINK = JSON.stringify(link);
  const html = `<!doctype html><html lang="pt"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>A abrir…</title>
<style>
body{font-family:Inter,system-ui,-apple-system,Arial,sans-serif;background:#eef2f0;color:#15302a;display:grid;place-items:center;min-height:100vh;margin:0}
.c{text-align:center;padding:24px}
.s{width:36px;height:36px;border:3px solid #dbe6df;border-top-color:#006B3C;border-radius:50%;animation:spin .8s linear infinite;margin:0 auto 16px}
@keyframes spin{to{transform:rotate(360deg)}}
a{display:inline-block;margin-top:6px;background:#006B3C;color:#fff;text-decoration:none;padding:11px 20px;border-radius:9px;font-weight:700}
</style></head>
<body><div class="c">
<div class="s"></div>
<p>A abrir o material…</p>
<noscript><p>O teu navegador tem o JavaScript desativado.<br><a href="${L}">Abrir a pasta</a></p></noscript>
</div>
<script>
(function(){
  var u=location.pathname+location.search+(location.search?'&':'?')+'hit=1';
  fetch(u).then(function(r){return r.json();}).then(function(d){
    location.replace((d&&d.link)||${FB});
  }).catch(function(){ location.replace(${LINK}); });
})();
</script></body></html>`;
  return new Response(html, {
    status: 200,
    headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" },
  });
}

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const t = url.searchParams.get("t") ||
    url.pathname.split("/").filter(Boolean).pop() || "";
  const hit = url.searchParams.get("hit"); // presente = veio do JS da página

  if (!UUID.test(t)) {
    return hit ? json({ ok: false }) : Response.redirect(FALLBACK, 302);
  }

  const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
  const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const call = (fn: string, body: unknown) =>
    fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
      method: "POST",
      headers: {
        apikey: SERVICE_ROLE,
        Authorization: `Bearer ${SERVICE_ROLE}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

  try {
    if (hit) {
      // O JavaScript confirmou uma abertura real: regista e devolve o link.
      const res = await call("repo_click", { p_token: t });
      const d = await res.json().catch(() => null);
      return json(d?.ok ? { ok: true, link: d.link } : { ok: false });
    }
    // Primeira abertura do link (pode ser um scanner): serve a página, NÃO regista.
    const res = await call("repo_acesso_link", { p_token: t });
    const d = await res.json().catch(() => null);
    return pagina(d?.ok ? d.link : FALLBACK);
  } catch (_e) {
    return hit ? json({ ok: false }) : Response.redirect(FALLBACK, 302);
  }
});
