// IEFP CRM — Recuperação de acesso do formador por email (self-service).
//
// O browser chama esta função com { codigo, email }. A função (com a
// service_role) gera um NOVO código de recuperação via a função SQL
// gerar_recovery_email e ENVIA-O por email (Resend) para a caixa do
// formador. O código NUNCA volta ao browser — a resposta é sempre neutra
// ({ ok: true }), para não revelar se o email existe (anti-enumeração).
//
// Deploy (Supabase): Edge Functions → criar "recuperar-email" → colar este
// ficheiro. Desligar "Enforce JWT" (função pública). Secrets necessários:
//   RESEND_API_KEY   = re_xxx (da conta Resend)
//   RECOVERY_FROM    = "IEFP CRM <iefpcrm@cr0x.org>"   (remetente verificado no Resend)
// SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY já são injetados automaticamente.

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
  return String(s).replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c] as string));
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ ok: true });

  const NEUTRAL = json({ ok: true }); // resposta padrão — nunca revela nada

  try {
    const { codigo, email } = await req.json().catch(() => ({}));
    if (!codigo || !email) return NEUTRAL;

    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
    const FROM = Deno.env.get("RECOVERY_FROM") || "IEFP CRM <onboarding@resend.dev>";

    // 1) Gerar o código no servidor (service_role → ignora RLS).
    const rpc = await fetch(`${SUPABASE_URL}/rest/v1/rpc/gerar_recovery_email`, {
      method: "POST",
      headers: {
        "apikey": SERVICE_ROLE,
        "Authorization": `Bearer ${SERVICE_ROLE}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ p_codigo: String(codigo), p_email: String(email) }),
    });
    const data = await rpc.json().catch(() => null);

    // Email não corresponde a um formador desta turma → resposta neutra.
    if (!data || data.ok !== true || !data.code) return NEUTRAL;

    // 2) Enviar o email com o utilizador + novo código.
    if (RESEND_API_KEY) {
      const nome = esc(data.nome || "Formador(a)");
      const user = esc(data.username || "");
      const code = esc(data.code);
      const turma = esc(String(codigo));
      const html = `
        <div style="font-family:Inter,Arial,sans-serif;max-width:520px;margin:0 auto;color:#15302a">
          <div style="background:linear-gradient(135deg,#006B3C,#00A651);color:#fff;padding:20px 24px;border-radius:14px 14px 0 0">
            <h1 style="margin:0;font-size:18px;font-weight:800">IEFP CRM — Recuperação de acesso</h1>
          </div>
          <div style="border:1px solid #dbe6df;border-top:0;border-radius:0 0 14px 14px;padding:24px">
            <p>Olá ${nome},</p>
            <p>Recebemos um pedido para recuperar o acesso à turma <strong>${turma}</strong>. Use estes dados no ecrã de entrada, em <em>"Recuperar palavra-passe"</em>:</p>
            <table style="border-collapse:collapse;margin:16px 0;font-size:15px">
              <tr><td style="padding:4px 12px 4px 0;color:#5f746b">Turma</td><td style="font-weight:700">${turma}</td></tr>
              <tr><td style="padding:4px 12px 4px 0;color:#5f746b">Utilizador</td><td style="font-weight:700">${user}</td></tr>
              <tr><td style="padding:4px 12px 4px 0;color:#5f746b">Código de recuperação</td><td style="font-weight:800;font-size:18px;letter-spacing:1px;color:#006B3C">${code}</td></tr>
            </table>
            <p style="color:#5f746b;font-size:13px">Aí define a sua nova palavra-passe. Este código substitui qualquer código anterior. Se não foi você a pedir, ignore este email — o acesso mantém-se seguro.</p>
          </div>
        </div>`;
      await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${RESEND_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          from: FROM,
          to: [data.email],
          subject: "IEFP CRM — Recuperação de acesso",
          html,
        }),
      }).catch(() => {});
    }

    return NEUTRAL;
  } catch (_e) {
    return NEUTRAL;
  }
});
