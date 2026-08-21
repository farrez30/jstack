# Jira dari luar Claude Code (Claude Chat / Cowork / mobile)

Surface tanpa terminal tidak bisa memakai acli. Jalurnya: **Atlassian connector (remote MCP)** — resmi dari Atlassian, gratis, OAuth per akun claude.ai.

## Aktivasi (sekali per akun claude.ai)

1. Buka claude.ai → **Settings → Connectors**.
2. Cari **Atlassian** → Connect → login OAuth ke akun Atlassian → pilih site (mis. `farrez.atlassian.net`).
3. Selesai — berlaku di Claude Chat, Cowork, dan mobile untuk akun itu. Tiap orang (kamu & teman) mengaktifkan di akunnya masing-masing; permission tetap mengikuti akun Atlassian masing-masing.

Tidak ada token yang ditempel manual — OAuth ditangani Atlassian. Jangan pernah menempelkan API token ke chat mana pun.

## Pola pemakaian di Chat/Cowork

Sebut key + aksinya secara eksplisit, contoh:

- "Lihat semua work item saya yang belum selesai di project COD"
- "Tambahkan komentar di COD-7: integrasi webhook selesai, tinggal test e2e"
- "Pindahkan COD-7 ke In Review"
- "Buat task baru di COD: <judul> — assignee saya, label tgr-website, due Jumat"

Aturan yang sama dengan /jstack tetap berlaku secara etika: minta Claude menampilkan draft dulu sebelum menulis, dan sebutkan label repo (`tgr-website`, `viralytics-v2`, …) supaya konsisten dengan konvensi jstack.

## Project baru yang lahir di Chat/Cowork

Kalau kamu memulai project baru dari Chat, minta Claude menanyakan konteksnya sekalian — contoh: *"Saya mulai project X — buatkan Epic-nya di COD: tanya saya target selesai & tujuannya, lalu tampilkan draft sebelum dibuat."* Konvensinya sama dengan di Claude Code: satu project/repo = satu Epic (+ label), start = kenyataan, due = target.

## Sinkron dengan sesi Claude Code

Tidak perlu sinkronisasi apa pun — acli dan connector menulis ke Jira yang sama. Update dari Chat langsung terlihat saat `/jstack status` dijalankan di device mana pun, dan sebaliknya.
