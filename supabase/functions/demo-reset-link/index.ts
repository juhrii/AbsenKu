// ⚠️ DEMO ONLY — JANGAN DIPAKAI DI PRODUKSI.
//
// Fungsi ini membuat token reset password TANPA mengirim email, sehingga
// alamat Gmail dengan username < 6 karakter (mis. wandi@gmail.com) yang
// ditolak oleh validateclient Supabase tetap bisa direset.
//
// Risiko: siapa pun yang tahu email bisa mengganti password akun tersebut.
// Karena itu hanya email di secret DEMO_EMAIL_ALLOWLIST yang dilayani.
//
// Sebelum produksi:
//   1. Hapus function ini, ATAU
//   2. Kosongkan DEMO_EMAIL_ALLOWLIST dan jangan set ALLOW_ALL_EMAILS=true.
//
// Deploy:
//   supabase functions deploy demo-reset-link --no-verify-jwt --project-ref <ref>
//   supabase secrets set DEMO_EMAIL_ALLOWLIST=a@x.com,b@x.com --project-ref <ref>

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return json({ error: 'method_not_allowed' }, 405)
  }

  // ---------------------------------------------------------------- input
  let email = ''
  try {
    const body = await req.json()
    if (typeof body?.email === 'string') {
      email = body.email.trim().toLowerCase()
    }
  } catch (_) {
    return json({ error: 'invalid_body' }, 400)
  }

  if (email === '' || !email.includes('@')) {
    return json({ error: 'email_required' }, 400)
  }

  // ------------------------------------------------------------- allowlist
  const allowAll =
    (Deno.env.get('ALLOW_ALL_EMAILS') ?? 'false').toLowerCase() === 'true'

  const allowList = (Deno.env.get('DEMO_EMAIL_ALLOWLIST') ?? '')
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter((s) => s.length > 0)

  if (!allowAll && !allowList.includes(email)) {
    // Aplikasi akan otomatis memakai alur email biasa.
    return json({ error: 'not_allowed' }, 403)
  }

  // ------------------------------------------------------------ admin client
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: 'server_not_configured' }, 500)
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  // --------------------------------------------------------------- generate
  const { data, error } = await admin.auth.admin.generateLink({
    type: 'recovery',
    email,
  })

  if (error) {
    console.error('generateLink failed:', email, error.message)
    return json({ error: 'generate_link_failed', message: error.message }, 400)
  }

  const tokenHash = data?.properties?.hashed_token
  if (!tokenHash) {
    return json({ error: 'token_missing' }, 500)
  }

  // Token hash dipakai aplikasi lewat auth.verifyOTP(type: recovery).
  // Tidak ada email yang dikirim.
  return json({ token_hash: tokenHash })
})
