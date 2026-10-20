# jstack

Plugin Claude Code untuk manajemen kerja lintas project, device, dan orang lewat **Jira**, dengan **acli** (Atlassian CLI) sebagai mesinnya. Satu skill `/jstack` yang workspace-aware: repo Coderoach menunjuk project Jira bersama, repo pribadi menunjuk project pribadi. Tidak pernah menulis ke Jira tanpa konfirmasi.

| Subcommand | Fungsi |
|---|---|
| `/jstack setup` | First-run per device: instal acli, pandu login, tulis config global |
| `/jstack init` | Hubungkan repo ke Jira (`.jira-map.json`) + set graphify |
| `/jstack task` | Buat work item baru (summary, type, assignee, due, label repo) |
| `/jstack log [KEY]` | Catat progres sesi sebagai komentar + transisi status |
| `/jstack status` | Dashboard di terminal: item kamu lintas project, urut deadline |
| `/jstack sync` | Rekonsiliasi batch: cocokkan commit terakhir vs status di Jira |

## Instalasi (device baru / teman)

Prasyarat: [Claude Code](https://claude.com/claude-code), git, dan akun Atlassian yang **sudah diundang** ke site Jira tim (minta undangan ke admin site).

```bash
claude plugin marketplace add farrez30/jstack
claude plugin install jstack@jstack
```

(Kalau repo belum tersedia di GitHub: minta folder `jstack` ke pemiliknya (zip atau clone dari remote privat), lalu `claude plugin marketplace add <path-folder-jstack>`.)

Lalu buka sesi Claude Code **baru** (sesi yang sudah terlanjur terbuka: jalankan `/reload-plugins` dulu), dan ketik:

```
/jstack setup
```

Setup akan memasang acli bila belum ada, lalu **memandumu login sendiri di terminalmu**. Jalur utamanya `acli jira auth login --web` (OAuth lewat browser, tanpa token sama sekali). Kredensialmu tidak pernah lewat chat; Claude hanya memverifikasi hasilnya.

Repo yang sudah membawa `.jira-map.json` ter-commit (mis. repo Coderoach yang kamu clone) **sudah otomatis terhubung**, tidak perlu apa-apa lagi. `init` hanya untuk repo yang belum:

```
/jstack init
```

## Pemakaian harian

Kerja seperti biasa. Di repo yang ter-mapping, Claude akan menawarkan diri di checkpoint natural (selesai task / habis commit / akhir sesi): *"ini bagian dari work item Jira? mau dicatat via /jstack log?"*. Jawab sekali, tidak dicecar. Semua tulisan ke Jira selalu ditampilkan draftnya dulu.

Dari **Claude Chat / Cowork / HP** (tanpa terminal): aktifkan **Atlassian connector** di claude.ai, lalu Settings, lalu Connectors (sekali per akun), lalu perintah biasa seperti "pindahkan COD-7 ke In Review". Detail: [chat-surfaces.md](skills/jstack/references/chat-surfaces.md).

## Panduan memakai Jira-nya

Cara membaca tab-tab project COD, evaluasi lewat Timeline & Reports, alur status (termasuk Halt), dan konvensi tim: **[docs/panduan-jira-coderoach.md](docs/panduan-jira-coderoach.md)**. Cukup dibaca sekali oleh setiap anggota.

## Konvensi

- **Label = repo.** Setiap work item diberi label nama repo (`tgr-website`, `viralytics-v2`, …) supaya bisa difilter per repo dalam satu project Jira.
- **Epic = repo.** Tiap repo punya satu Epic di Jira; item baru otomatis ber-parent ke sana (`epicKey`).
- `.jira-map.json` di-commit ke repo (tanpa secret): `{ "site": "…", "projectKey": "…", "label": "…", "epicKey": "…" }`.
- Config global per device di `~/.jstack/config.json` (tanpa secret).

## Keamanan & privasi

- API token hanya hidup di credential store acli di device masing-masing, tidak pernah di chat, file repo, atau config jstack.
- Hook plugin (SessionStart) read-only: cuma pengingat, tidak menyentuh Jira.
- Akses per orang mengikuti permission akun Atlassian-nya. Yang tidak diundang ke sebuah project akan ditolak Jira (403), bukan sekadar "disembunyikan" oleh skill.
- **Catatan plan Free Jira**: dalam satu site, plan Free tidak mendukung project private, jadi semua anggota site bisa melihat semua project di site itu. Ini keputusan sadar pemilik site; kalau kelak butuh isolasi keras, opsinya upgrade ke Standard atau pisah site.

## Untuk maintainer

Pengembangan lokal: `claude plugin marketplace add <path-clone-ini>`, perubahan langsung terasa tanpa publish. Rilis: bump `version` di `.claude-plugin/plugin.json`, commit, push; pemakai lain tinggal `claude plugin update jstack`. Validasi struktur: `claude plugin validate .`
