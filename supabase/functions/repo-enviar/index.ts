// IEFP CRM — Repositório: envia o aviso de uma publicação à turma (Resend).
//
// O browser (formador, autenticado) chama isto com { token, publicacao_id }.
// A função pede ao Postgres os destinatários AINDA POR ENVIAR — cada um com
// o SEU token de envio — manda um email a cada, e marca o resultado.
//
// O email é TODO do formador: assunto, cabeçalho, saudação, mensagem (texto
// rico), rótulo do botão e nota de rodapé vêm da base de dados, não daqui.
// Marcadores: {nome} {ufcd} {titulo} {turma}
//
// O link do botão NÃO aponta ao bitly: aponta à função `r` desta mesma app,
// que regista o clique e só depois reencaminha. É assim que se sabe QUEM leu.
//
// Deploy (Supabase): Edge Functions → "repo-enviar" → colar este ficheiro.
// Desligar "Enforce JWT" (a autorização é o token de sessão, validado no SQL).
// Secrets:
//   RESEND_API_KEY  = re_xxx
//   REPO_FROM       = "IEFP CRM <iefpcrm@iefpcrm.cr0x.org>"
//                     ^ o domínio depois do @ TEM de estar verificado no Resend.
//   REPO_REPLY_TO   = "iefpcrm@cr0x.org"   (opcional; para onde vão as respostas)

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

// A mensagem é HTML escrito pelo formador (editor de texto rico). Confiamos
// nele, mas não em acidentes: fora scripts, iframes e handlers inline.
function limpar(html: string) {
  return String(html ?? "")
    .replace(/<\s*(script|iframe|object|embed|style)[^>]*>[\s\S]*?<\s*\/\s*\1\s*>/gi, "")
    .replace(/\son\w+\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)/gi, "")
    .replace(/javascript:/gi, "");
}

// {nome} {ufcd} {titulo} {turma} — sempre com o valor escapado.
function marcadores(txt: string, d: Record<string, string>) {
  return String(txt ?? "").replace(/\{(nome|ufcd|titulo|turma)\}/g, (_, k) => esc(d[k] || ""));
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
    const REPLY_TO = Deno.env.get("REPO_REPLY_TO") || "";

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
      return json({
        ok: false,
        erro: t.includes("SEM_PERMISSAO") ? "SEM_PERMISSAO" : "SESSAO_INVALIDA",
      }, 403);
    }
    const destinos = (await rDest.json()) as Array<{
      envio_id: string; email: string; email2: string | null; nome: string; envio_token: string;
      titulo: string; texto: string; ufcd: string; turma: string;
      assunto: string; cabecalho: string; saudacao: string; botao: string; rodape: string;
    }>;
    if (!destinos.length) return json({ ok: true, enviados: 0, falhados: 0 });

    // 2) Enviar, um a um, com o link tokenizado de cada formando.
    let enviados = 0, falhados = 0;
    for (const d of destinos) {
      const vars = { nome: d.nome, ufcd: d.ufcd, titulo: d.titulo, turma: d.turma };
      const url = `${SUPABASE_URL}/functions/v1/r?t=${d.envio_token}`;

      const html = `
        <div style="font-family:Inter,Arial,sans-serif;max-width:520px;margin:0 auto;color:#15302a">
          <div style="background:linear-gradient(135deg,#006B3C,#00A651);color:#fff;padding:20px 24px;border-radius:14px 14px 0 0">
            <h1 style="margin:0;font-size:18px;font-weight:800">${marcadores(d.cabecalho, vars)}</h1>
          </div>
          <div style="border:1px solid #dbe6df;border-top:0;border-radius:0 0 14px 14px;padding:24px">
            <p style="margin:0 0 12px">${marcadores(d.saudacao, vars)}</p>
            <p style="margin:0 0 16px;font-weight:700;font-size:16px">${esc(d.titulo)}</p>
            <div style="margin:0 0 8px">${limpar(marcadores(d.texto, vars))}</div>
            <p style="margin:24px 0 8px">
              <a href="${url}" style="display:inline-block;background:#006B3C;color:#fff;text-decoration:none;padding:12px 22px;border-radius:10px;font-weight:700">${marcadores(d.botao, vars)}</a>
            </p>
            <p style="color:#5f746b;font-size:12px;margin:16px 0 0">${marcadores(d.rodape, vars)}</p>
          </div>
        </div>`;

      // Enviar para os dois emails (pessoal + IEFP); a turma não usa o do IEFP.
      // Um só clique de qualquer deles conta, porque o token é do envio, não do email.
      const to = [...new Set([d.email, d.email2].filter(Boolean))] as string[];
      const corpo: Record<string, unknown> = {
        from: FROM,
        to,
        subject: marcadores(d.assunto, vars).replace(/&amp;/g, "&"),
        html,
      };
      if (REPLY_TO) corpo.reply_to = REPLY_TO;

      let erro: string | null = null;
      try {
        const res = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            Authorization: `Bearer ${RESEND_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(corpo),
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
