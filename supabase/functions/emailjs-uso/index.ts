// Consumo do EmailJS deste mes, lido do historico real da conta.
//
// Porque e que isto e uma Edge Function e nao codigo da app:
// o endpoint /history do EmailJS exige a chave PRIVADA (accessToken). O index.html
// e servido em GitHub Pages e qualquer pessoa o le - a chave privada NAO pode la
// estar. Fica aqui como segredo, tal como no nif-lookup.
//
// Segredos a definir no Supabase (Edge Functions -> Secrets):
//   EMAILJS_PUBLIC_KEY   (a mesma que esta na app)
//   EMAILJS_PRIVATE_KEY  (EmailJS -> Account -> API Keys -> Private Key)

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...CORS, 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });

  const userId = Deno.env.get('EMAILJS_PUBLIC_KEY');
  const token  = Deno.env.get('EMAILJS_PRIVATE_KEY');
  if (!userId || !token) return json({ erro: 'FALTAM_SEGREDOS' }, 500);

  // inicio do mes corrente, em UTC
  const agora = new Date();
  const inicioMes = Date.UTC(agora.getUTCFullYear(), agora.getUTCMonth(), 1);

  let mes = 0, falhas = 0, total = 0;
  const recentes: Array<Record<string, unknown>> = [];

  try {
    // O historico vem paginado e por ordem decrescente. Paramos assim que
    // encontrarmos um registo anterior ao mes corrente - nao ha motivo para
    // percorrer a conta inteira. O limite de paginas e uma rede de seguranca.
    for (let page = 1; page <= 20; page++) {
      const url = `https://api.emailjs.com/api/v1.1/history?user_id=${encodeURIComponent(userId)}&accessToken=${encodeURIComponent(token)}&page=${page}&count=100`;
      const r = await fetch(url);
      if (!r.ok) return json({ erro: 'EMAILJS_' + r.status, detalhe: (await r.text()).slice(0, 200) }, 502);
      const d = await r.json();
      const linhas: any[] = Array.isArray(d) ? d : (d.rows || d.history || d.data || []);
      if (!linhas.length) break;

      let saiu = false;
      for (const l of linhas) {
        total++;
        const quando = new Date(l.created_at || l.updated_at || 0);
        if (quando.getTime() < inicioMes) { saiu = true; break; }
        mes++;
        const ok = String(l.result ?? '').toLowerCase() !== 'failure' && !l.error;
        if (!ok) falhas++;
        if (recentes.length < 20) {
          const p = l.template_params || {};
          recentes.push({
            quando: quando.toISOString().slice(0, 16).replace('T', ' '),
            para: p.to_email || p.email || p.reply_to || '-',
            assunto: p.subject || p.title || '-',
            ok,
          });
        }
      }
      if (saiu || d.is_last_page === true) break;
    }
  } catch (e) {
    return json({ erro: 'FALHA_HISTORICO', detalhe: String(e).slice(0, 200) }, 502);
  }

  return json({ mes, falhas, lidos: total, recentes, desde: new Date(inicioMes).toISOString().slice(0, 10) });
});
