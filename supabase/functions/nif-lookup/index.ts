// IEFP CRM — Pesquisa de dados de empresa por NIPC (proxy do nif.pt).
//
// O browser chama esta função com { nif }. A função consulta o nif.pt com a
// chave (guardada como secret, nunca vai ao browser) e devolve os dados da
// empresa já normalizados (nome, morada, código postal, cidade, CAE, contactos).
// Só serve dados públicos de PESSOAS COLETIVAS — não expõe dados de particulares.
//
// Deploy (Supabase): Edge Functions → criar "nif-lookup" → colar este ficheiro.
// Desligar "Enforce JWT" (função pública, chamada com a anon key). Secret:
//   NIFPT_KEY = a chave gratuita obtida em https://www.nif.pt/api/ (registo grátis)

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

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "method" }, 405);

  try {
    const { nif } = await req.json().catch(() => ({}));
    const clean = String(nif || "").replace(/\D/g, "");
    if (!/^\d{9}$/.test(clean)) return json({ error: "invalid", message: "NIPC inválido (9 dígitos)." }, 400);

    const KEY = Deno.env.get("NIFPT_KEY");
    if (!KEY) return json({ error: "config", message: "NIFPT_KEY não configurada no servidor." }, 500);

    const r = await fetch(`https://www.nif.pt/?json=1&q=${clean}&key=${encodeURIComponent(KEY)}`);
    const data = await r.json().catch(() => null);

    if (!data || data.result !== "success" || !data.records || !data.records[clean]) {
      return json({ error: "not_found", message: (data && data.message) || "Empresa não encontrada para este NIPC." });
    }

    const rec = data.records[clean];
    const c = rec.contacts || {};
    const cp = [rec.pc4, rec.pc3].filter(Boolean).join("-");
    return json({
      nif: clean,
      nome: rec.title || "",
      morada: rec.address || "",
      codigoPostal: cp,
      cidade: rec.city || "",
      cae: String(rec.cae || (rec.structure && rec.structure.nature) || ""),
      atividade: rec.activity || "",
      estado: rec.status || "",
      website: c.website || "",
      telefone: c.phone || "",
      email: c.email || "",
    });
  } catch (e) {
    return json({ error: "server", message: String(e) }, 500);
  }
});
