---
name: jstack
description: "Manajemen kerja via Jira dari sesi Claude Code, lintas project/device/orang. Router: setup | init | task | log | status | sync. Pakai saat user mengetik /jstack, minta membuat/meng-update work item Jira, menanyakan status task, atau menghubungkan sebuah repo ke Jira. Backbone-nya acli (Atlassian CLI); config per-repo di .jira-map.json."
---

# /jstack — Jira workflow untuk sesi kerja

Satu skill untuk semua workspace: repo Coderoach menunjuk project bersama, repo kerjaan pribadi menunjuk project pribadi. Privasi ditegakkan oleh Jira (permission per user/token), bukan oleh skill ini.

## Aturan keras (berlaku untuk SEMUA subcommand)

1. **Jangan pernah memegang API token.** Jangan pernah meminta user menempelkan token ke chat, jangan mengetikkannya, jangan menyimpannya di file mana pun. Login acli dijalankan **user sendiri di terminalnya** — skill hanya memandu dan memverifikasi hasilnya.
2. **Tidak ada tulisan ke Jira tanpa konfirmasi.** Sebelum operasi tulis APA PUN — `create`, `comment create`, `transition`, `edit`, `assign`, `link create`, `delete`, `project create`, maupun subcommand tulis lain yang belum tercantum di sini — tampilkan ringkasan apa yang akan ditulis + ke item mana, tunggu persetujuan eksplisit. Hanya perintah read (`view`, `search`, `list`, `auth status`) yang bebas.
3. **Config tanpa secret.** `.jira-map.json` dan `~/.jstack/config.json` hanya berisi mapping/identitas non-rahasia sehingga aman di-commit / di-backup.
4. Resep perintah acli ada di [references/acli-cookbook.md](references/acli-cookbook.md); parameter field Jira di [references/field-map.md](references/field-map.md). Kalau sintaks acli meragukan, cek `acli jira <cmd> --help` dulu — jangan menebak.
5. **Teks bebas tidak disisipkan ke argumen shell.** Field teks yang bersumber dari user/percakapan/git (summary, description, body komentar) rawan merusak quoting shell. Jalur aman: komentar → tulis ke file temp lalu `--body-file`; create/edit → `--from-json` (bentuk di field-map). Argumen inline hanya untuk teks singkat yang kamu susun sendiri tanpa karakter rawan (kutip, `$`, backtick, newline).

## Model config

- **Global per-device** — `~/.jstack/config.json`:
  ```json
  { "site": "farrez.atlassian.net", "email": "user@example.com", "displayName": "farrez" }
  ```
- **Per-repo** — `.jira-map.json` di root repo (di-commit):
  ```json
  { "site": "farrez.atlassian.net", "projectKey": "COD", "label": "tgr-website", "epicKey": "COD-10" }
  ```
  `label` = penanda repo pada tiap work item (konvensi jstack, pengganti Components — lihat field-map). `epicKey` = Epic milik repo ini (konvensi: **satu repo = satu Epic**, supaya Timeline per project terbaca); item baru dari `/jstack task` otomatis ber-parent ke sana. Repo tanpa file ini = belum terhubung Jira → tawarkan `/jstack init`.

## Routing

Argumen pertama menentukan subcommand. Tanpa argumen: tampilkan ringkasan subcommand + status singkat (auth ok? repo ini ter-mapping?). Argumen berupa key work item (mis. `COD-7`) = shortcut untuk `log COD-7`.

---

## /jstack setup — first-run per device

1. **Cek acli**: `acli --version`. Kalau belum ada, instal sesuai OS (perintah persis di cookbook §Instalasi), lalu verifikasi ulang — di Windows, sesi yang sama belum membaca PATH baru, jadi pakai path penuh `& "$env:LOCALAPPDATA\Programs\acli\acli.exe" --version` (detail di cookbook).
2. **Cek auth**: `acli jira auth status`. Kalau belum login, minta user menjalankan **sendiri di terminalnya** (jangan kamu jalankan):
   - **Jalur utama — OAuth browser, tanpa token:**
     ```
     acli jira auth login --web
     ```
   - **Fallback — API token** (buat di https://id.atlassian.com/manage-profile/security/api-tokens). Awas: `--token` membaca stdin tanpa prompt, jadi dijalankan polos di PowerShell interaktif pasti gagal `failed to read token from standard input`. Bentuk yang benar:
     ```powershell
     Read-Host "Paste token" | acli jira auth login --site "<site>" --email "<email>" --token
     ```
     (macOS/Linux: `acli jira auth login --site "<site>" --email "<email>" --token < token.txt`)
   - Tunggu user bilang selesai, lalu verifikasi: `acli jira auth status` + satu read ringan (mis. `acli jira project list` atau search 1 item).
3. **Tulis config global** `~/.jstack/config.json` (site, email, displayName — tanya kalau belum tahu).
4. **Tawarkan MCP connector** untuk surface non-CLI: sarankan user mengaktifkan Atlassian connector di claude.ai → Settings → Connectors (sekali per akun claude.ai). Detail di [references/chat-surfaces.md](references/chat-surfaces.md).
5. Tutup dengan menyebut langkah berikutnya: jalankan `/jstack init` di tiap repo yang mau dihubungkan.

## /jstack init — hubungkan repo ke Jira

Jalankan dari dalam repo target.

1. Kalau `.jira-map.json` sudah ada: tampilkan isinya, tanya mau diubah atau tidak.
2. Tanya (pakai pertanyaan terstruktur bila tersedia): project key tujuan (tampilkan pilihan dari `acli jira project list`), dan label repo untuk penanda item (konvensi: nama repo lowercase tanpa spasi, mis. `tgr-website`).
3. **Epic repo**: cari Epic yang sudah ada (`search --jql "project = <KEY> AND type = Epic"`); belum ada yang cocok → tawarkan membuat (konfirmasi dulu): summary = nama project/repo, label repo, start date = tanggal commit pertama (`git log --reverse --format=%ad --date=short | head -1` — fakta git, bukan karangan), due = target user (tanya). Tanyakan juga tujuan project 1 kalimat → jadi deskripsi Epic. Simpan key-nya untuk `epicKey`. Kalau project belum punya type Epic, menambahkannya = **admin site** (⚙️ → Issues → Issue type schemes — acli tidak bisa); user bukan admin → minta admin site (untuk COD: checklist farrez di docs/panduan-jira-coderoach.md).
4. Tulis `.jira-map.json` (site, projectKey, label, epicKey).
5. **graphify**: cek `graphify-out/` di root repo. Belum ada → tawarkan menjalankan `/graphify`. Lalu pastikan `.gitignore` punya entri `graphify-out/` — tambahkan bila belum.
6. **CLAUDE.md repo**: tambahkan blok kecil (idempoten — jangan dobel kalau sudah ada):
   ```markdown
   # jstack
   Repo ini terhubung Jira (lihat .jira-map.json). Di awal sesi: kalau graphify-out/ belum ada, tawarkan /graphify. Di checkpoint (task selesai / habis commit / akhir sesi), tanyakan apakah pekerjaan ini bagian dari work item Jira — kalau ya tawarkan /jstack log. Jangan menulis ke Jira tanpa konfirmasi.
   ```
7. Tawarkan commit untuk `.jira-map.json` + CLAUDE.md (ikuti konvensi commit repo tsb).

## /jstack task — buat work item baru

1. Baca `.jira-map.json` (tidak ada → tawarkan `init` dulu; atau user boleh menyebut project key eksplisit).
2. Kumpulkan field: summary (wajib), description, type (Task/Bug/Story — cek type yang tersedia di project), assignee, **due date (selalu tanyakan** — boleh dijawab "tidak ada", tapi tanpa ditanya Timeline & radar overdue mati), priority, link terkait. Jangan interogasi satu-satu kalau user sudah memberi sebagian di prompt — tanya hanya yang kosong dan penting (minimal: summary + type + due date).
3. Tampilkan draft item → konfirmasi → jalankan `create` sesuai cookbook (sertakan label repo + parent `epicKey` dari `.jira-map.json`; due date via `--from-json` additionalAttributes). Di `--from-json`, parent ditulis `"parentIssueId": "<epicKey>"` dan assignee berupa email (bukan `@me`) — bentuk lengkap di field-map. `epicKey` kosong/tidak ada → JANGAN buat item tanpa parent diam-diam: tawarkan dulu melengkapinya (pilih Epic yang ada / buat baru, seperti langkah init №3) — user boleh menolak, barulah buat tanpa parent.
4. Laporkan key hasil (mis. `COD-7`) + URL `https://<site>/browse/<KEY>`.

## /jstack log [KEY] — catat progres kerja

1. Tentukan target item, urutan prioritas:
   - `KEY` diberikan eksplisit → pakai itu.
   - Deteksi dari branch / pesan commit terakhir (pola `[A-Z][A-Z0-9]+-\d+`).
   - Kalau tetap tidak jelas → tampilkan item open milik user di project repo ini (`search` per cookbook) dan tanya: bagian dari item mana / item baru (→ alihkan ke `task`) / bukan kerjaan Jira (→ selesai, jangan paksa).
2. Rangkum pekerjaan sesi ini dalam 2–5 kalimat gaya dev (apa yang berubah, hasil tes, sisa pekerjaan) — bahan dari percakapan + `git log`/`git diff` terakhir. Tanpa jargon AI.
3. Tanya sekalian: perlu transisi status? Status saat ini dari `view KEY --fields status`; daftar status tujuan tidak disediakan acli — lihat board Jira atau tanya user (alur COD: Backlog → To Do → In Progress → In Review → Done, plus Halt sebagai parkir "ditahan dulu" dari/ke tahap mana pun; item masuk Halt wajib diberi komentar sedang menunggu apa).
4. Tampilkan draft komentar + rencana transisi → konfirmasi → eksekusi (`comment create` dengan `--body-file`, lalu `transition` bila diminta).
5. Konfirmasi hasil dengan menyebut key + status akhirnya.

## /jstack status — dashboard di terminal

1. Baca config global + `.jira-map.json` (kalau ada).
2. Jalankan search (cookbook §Search):
   - Milik saya, belum selesai, semua project: `assignee = currentUser() AND statusCategory != Done ORDER BY duedate ASC, updated DESC`
   - Varian repo ini: tambah `project = <KEY>` (+ filter `labels = "<label-repo>"` bila ada).
3. Render tabel markdown ringkas: Key | Summary (potong ±60 char) | Status | Due | Assignee. Tandai yang due-nya lewat/≤3 hari. Duedate/labels TIDAK bisa diambil dari `search` sama sekali — ambil per item via `view KEY --fields duedate,labels --json` (lihat jebakan di cookbook §Search/§View); parse JSON lewat Git Bash, bukan pipe PowerShell.
4. Sebutkan juga item Unassigned di project repo ini (kandidat untuk diambil).

## /jstack sync — rekonsiliasi batch

1. Scan `git log --oneline -20` untuk key yang disebut di commit; bandingkan dengan status item-nya di Jira (`view`).
2. Laporkan gap: commit menyebut item yang masih To Do (harusnya In Progress/Review?), pekerjaan besar tanpa item, item In Progress tanpa aktivitas.
3. Susun daftar aksi yang diusulkan (transisi/komentar/item baru) → konfirmasi **per daftar** (user boleh coret sebagian) → eksekusi satu-satu, laporkan tiap hasil.

---

## Etiket checkpoint (untuk sesi kerja normal, di luar pemanggilan /jstack)

**Repo/project BARU tanpa `.jira-map.json`** (termasuk project yang baru dibuat di sesi itu): sekali per sesi, di momen natural pertama (setelah scaffold jadi / commit pertama), tawarkan ringan: *"project baru — mau dihubungkan ke Jira sekarang? bagian dari Epic yang sudah ada atau Epic baru, dan target selesainya kapan?"* Jawaban "nanti dulu" final untuk sesi itu. Ini berlaku juga bila user menyebut memulai project dari Claude Chat — arahkan polanya (lihat chat-surfaces.md).

Kalau repo aktif punya `.jira-map.json`, di checkpoint natural — task user selesai, habis membuat commit, atau user berpamitan — tanyakan sekali dengan ringan: *"ini bagian dari work item Jira? mau saya catat via /jstack log?"* Satu kali tanya per checkpoint, jangan cerewet, dan jawaban "tidak" selalu final. Jangan pernah auto-update tanpa ditanya.
