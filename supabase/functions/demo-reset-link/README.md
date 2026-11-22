# demo-reset-link (⚠️ DEMO ONLY)

Edge Function untuk fitur "Lupa Kata Sandi" **tanpa mengirim email**.

Dipakai karena Supabase menolak mengirim email ke `@gmail.com` yang username-nya
kurang dari 6 karakter (mis. `wandi@gmail.com`). Function ini memakai
`auth.admin.generateLink(type: recovery)` yang membuat token reset tanpa lewat
pengirim email, lalu aplikasi menukarnya dengan `auth.verifyOTP`.

## Risiko

Siapa pun yang mengetahui email sebuah akun bisa mengganti password akun itu
tanpa akses ke inbox. Karena itu hanya email pada `DEMO_EMAIL_ALLOWLIST` yang
dilayani. **Hapus atau nonaktifkan function ini sebelum produksi.**

## Deploy lewat Dashboard

1. Supabase Dashboard → **Edge Functions** → **Deploy a new function**
2. Nama: `demo-reset-link`
3. Paste isi `index.ts`
4. Matikan **Enforce JWT Verification**
5. **Edge Functions → Secrets**, tambahkan:

   ```
   DEMO_EMAIL_ALLOWLIST = wandi@gmail.com,budi@gmail.com,jono@gmail.com,dafa@gmail.com,haris@gmail.com,white@gmail.com,siswa@gmail.com,admin@gmail.com,petugas@gmail.com,superadmin@gmail.com,absenku@gmail.com
   ```

6. Deploy

## Deploy lewat CLI

```bash
supabase functions deploy demo-reset-link --no-verify-jwt --project-ref wfyijokzozgzbygnlijj

supabase secrets set \
  DEMO_EMAIL_ALLOWLIST="wandi@gmail.com,budi@gmail.com,jono@gmail.com,dafa@gmail.com,haris@gmail.com,white@gmail.com,siswa@gmail.com,admin@gmail.com,petugas@gmail.com,superadmin@gmail.com,absenku@gmail.com" \
  --project-ref wfyijokzozgzbygnlijj
```

`SUPABASE_URL` dan `SUPABASE_SERVICE_ROLE_KEY` sudah tersedia otomatis di Edge
Functions — tidak perlu di-set manual dan tidak pernah masuk ke aplikasi.

## Mengizinkan semua email (tidak disarankan)

```bash
supabase secrets set ALLOW_ALL_EMAILS=true --project-ref wfyijokzozgzbygnlijj
```

## Response

| Status | Body | Arti |
|---|---|---|
| 200 | `{ "token_hash": "..." }` | Aplikasi langsung membuka halaman password baru |
| 400 | `{ "error": "email_required" }` / `generate_link_failed` | Input salah / user tidak ada |
| 403 | `{ "error": "not_allowed" }` | Email tidak ada di allowlist → app pakai alur email |
| 405 | `{ "error": "method_not_allowed" }` | Bukan POST |
| 500 | `{ "error": "server_not_configured" }` / `token_missing` | Konfigurasi/secret bermasalah |
