// IEFP CRM — Repositório: envia o aviso de uma publicação à turma (Resend).
//
// O browser (formador, autenticado) chama isto com { token, publicacao_id }.
// A função pede ao Postgres os destinatários AINDA POR ENVIAR — cada um com
// o SEU token de envio — manda um email a cada, e marca o resultado.
//
// O link do email NÃO aponta ao bitly: aponta à função `r` desta mesma app,
// que regista o clique e só depois reencaminha. É assim que se sabe QUEM leu.
//
// Deploy (Supabase): Edge Functions → criar "repo-enviar" → colar este ficheiro.
// Desligar "Enforce JWT" (a autorização é o token de sessão, validado no SQL).
// Secrets:
//   RESEND_API_KEY  = re_xxx                       (já existe)
//   REPO_FROM       = "IEFP CRM <iefpcrm@iefpcrm.cr0x.org>"
//                     ^ a parte depois do @ TEM de ser um domínio verificado
//                       no Resend, senão o envio é rejeitado.

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });

function esc(s: string) {
  return String(s ?? "").replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c] as string));
}

// O texto que o formador escreveu na caixa: parágrafos simples, sem HTML.
function paragrafos(texto: string) {
  return esc(texto)
    .split(/\n{2,}/)
    .filter((p) => p.trim())
    .map((p) => `<p style="margin:0 0 12px">${p.replace(/\n/g, "<br>")}</p>`)
    .join("");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ ok: false, erro: "METODO" }, 405);

  try {
    const { token, publicacao_id } = await req.json().catch(() => ({}));
    if (!token || !publicacao_id) return json({ ok: false, erro: "DADOS_EM_FALTA" }, 400);

    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
    const FROM = Deno.env.get("REPO_FROM") ||
      Deno.env.get("RECOVERY_FROM") ||
      "IEFP CRM <onboarding@resend.dev>";

    if (!RESEND_API_KEY) return json({ ok: false, erro: "SEM_RESEND" }, 500);

    const rpc = (nome: string, body: unknown) =>
      fetch(`${SUPABASE_URL}/rest/v1/rpc/${nome}`, {
        method: "POST",
        headers: {
          apikey: SERVICE_ROLE,
          Authorization: `Bearer ${SERVICE_ROLE}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      });

    // 1) Quem falta? (o SQL valida que o `token` é de um formador desta turma)
    const rDest = await rpc("repo_envios_pendentes", {
      p_token: token,
      p_publicacao: publicacao_id,
    });
    if (!rDest.ok) {
      const t = await rDest.text();
      return json({ ok: false, erro: t.includes("SEM_PERMISSAO") ? "SEM_PERMISSAO" : "SESSAO_INVALIDA" }, 403);
    }
    const destinos = (await rDest.json()) as Array<{
      envio_id: string; email: string; nome: string; envio_token: string;
      titulo: string; texto: string; ufcd: string; turma: string;
    }>;
    if (!destinos.length) return json({ ok: true, enviados: 0, falhados: 0 });

    // 2) Enviar, um a um, com o link tokenizado de cada formando.
    let enviados = 0, falhados = 0;
    for (const d of destinos) {
      const url = `${SUPABASE_URL}/functions/v1/r?t=${d.envio_token}`;
      const html = `
        <div style="font-family:Inter,Arial,sans-serif;max-width:520px;margin:0 auto;color:#15302a">
          <div style="background:linear-gradient(135deg,#006B3C,#00A651);color:#fff;padding:20px 24px;border-radius:14px 14px 0 0">
            <h1 style="margin:0;font-size:18px;font-weight:800">UFCD ${esc(d.ufcd)} — material novo</h1>
          </div>
          <div style="border:1px solid #dbe6df;border-top:0;border-radius:0 0 14px 14px;padding:24px">
            <p style="margin:0 0 12px">Olá ${esc(d.nome || "")},</p>
            <p style="margin:0 0 16px;font-weight:700;font-size:16px">${esc(d.titulo)}</p>
            ${paragrafos(d.texto)}
            <p style="margin:24px 0 8px">
              <a href="${url}" style="display:inline-block;background:#006B3C;color:#fff;text-decoration:none;padding:12px 22px;border-radius:10px;font-weight:700">Abrir o material</a>
            </p>
            <p style="color:#5f746b;font-size:12px;margin:16px 0 0">Turma ${esc(d.turma)}. Este link é pessoal e regista a sua abertura, para o formador saber quem já teve acesso ao material.</p>
          </div>
        </div>`;

      let erro: string | null = null;
      try {
        const res = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            Authorization: `Bearer ${RESEND_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            from: FROM,
            to: [d.email],
            subject: `UFCD ${d.ufcd} — ${d.titulo}`,
            html,
          }),
        });
        if (!res.ok) erro = (await res.text()).slice(0, 300);
      } catch (e) {
        erro = String(e).slice(0, 300);
      }

      if (erro) falhados++; else enviados++;
      await rpc("repo_marcar_enviado", {
        p_token: token,
        p_envio_id: d.envio_id,
        p_erro: erro,
      });
    }

    return json({ ok: true, enviados, falhados });
  } catch (e) {
    return json({ ok: false, erro: String(e).slice(0, 300) }, 500);
  }
});
