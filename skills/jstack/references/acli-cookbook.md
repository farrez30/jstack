# Cookbook acli — sintaks terverifikasi

Diverifikasi terhadap `acli version 1.3.23-stable` (output `--help` asli, bukan dari ingatan). Kalau versi acli di device berbeda dan sebuah perintah error, jalankan `acli jira <grup> <cmd> --help` dulu sebelum mencoba variasi lain. Catatan: `--help` keluar dengan exit code non-nol — itu normal, bukan kegagalan.

## Instalasi

**Windows (PowerShell):**

```powershell
$dir = "$env:LOCALAPPDATA\Programs\acli"
New-Item -ItemType Directory -Force $dir | Out-Null
Invoke-WebRequest -Uri https://acli.atlassian.com/windows/latest/acli_windows_amd64/acli.exe -OutFile "$dir\acli.exe"
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$dir", "User")
$env:Path += ";$dir"
& "$dir\acli.exe" --version
```

(ARM64: ganti `acli_windows_amd64` → `acli_windows_arm64`.)

Catatan PATH Windows: baris `SetEnvironmentVariable` hanya menulis registry — terbaca oleh terminal/sesi Claude Code **berikutnya**; baris `$env:Path +=` hanya berlaku di proses shell yang sama. Karena tiap tool call bisa jadi proses baru, **di sesi ini selalu panggil dengan path penuh** `& "$dir\acli.exe" …` sampai Claude Code dibuka ulang.

**macOS (Homebrew):**

```bash
brew tap atlassian/homebrew-acli
brew install acli
```

Tanpa brew: unduh `https://acli.atlassian.com/darwin/latest/acli_darwin_arm64/acli` (Intel: `acli_darwin_amd64`), lalu `chmod +x` dan pindahkan ke `/usr/local/bin`.

Verifikasi: `acli --version`. Atlassian hanya mendukung tiap versi ±6 bulan — kalau perintah mulai aneh, unduh ulang binary terbaru.

## Auth — DIJALANKAN USER SENDIRI

Kredensial tidak boleh melewati Claude. Jalur utama — OAuth via browser, tanpa token:

```
acli jira auth login --web
```

Fallback API token (dibuat di https://id.atlassian.com/manage-profile/security/api-tokens) — perhatikan: `--token` membaca stdin **tanpa prompt**; dijalankan polos di terminal interaktif akan gagal `failed to read token from standard input` (kejadian nyata saat rollout). Bentuk yang benar:

```powershell
# Windows / PowerShell — Read-Host memberi prompt dan meneruskan ke stdin (tidak masuk history):
Read-Host "Paste token" | acli jira auth login --site "farrez.atlassian.net" --email "email-user" --token
```

```bash
# macOS/Linux:
acli jira auth login --site "farrez.atlassian.net" --email "email-user" --token < token.txt
```

Yang boleh dijalankan Claude:

```bash
acli jira auth status    # cek siapa yang login
```

## Search (JQL) — read, bebas jalan

```bash
acli jira workitem search --jql "assignee = currentUser() AND statusCategory != Done ORDER BY duedate ASC, updated DESC" --limit 30 --json
acli jira workitem search --jql "project = COD AND statusCategory != Done" --fields "key,summary,status,assignee" --limit 30
acli jira workitem search --jql "project = COD AND statusCategory != Done" --count
```

Flag: `--jql` `--fields` (default `issuetype,key,assignee,priority,status,summary`) `--limit` `--paginate` `--json` `--csv` `--count`.

Jebakan teruji di lapangan:
- `--fields` search punya whitelist — `duedate` DITOLAK (`field 'duedate' is not allowed`), bahkan dengan `--json`. **`search` tidak bisa mengembalikan duedate/labels sama sekali** (di output JSON-nya field itu `null` walau nilainya ada di Jira). Resep dashboard yang benar: `search --json` untuk daftar + urutan (JQL `ORDER BY duedate ASC` tetap bekerja — sorting terjadi di server), lalu ambil nilai per item yang mau ditampilkan via `view KEY --fields duedate,labels --json`.
- Pipe output `--json` ke parser (python/jq) jangan lewat PowerShell 5.1 — pipeline-nya menambah BOM UTF-8 yang membuat `json.load` gagal. Jalankan lewat Git Bash, atau di python pakai `utf-8-sig`.

## View — read, bebas jalan

```bash
acli jira workitem view COD-7 --json
acli jira workitem view COD-7 --fields "labels,duedate,status" --json
```

**JEBAKAN PALING BERBAHAYA (teruji — sempat membuat kami salah menyimpulkan "data terhapus"):** `view`/`search` hanya mengambil field yang diminta. Tanpa `--fields`, field non-default (labels, duedate, dll.) muncul sebagai **`null` di JSON — padahal nilainya ada di Jira**. `null` di sini artinya "tidak diminta", bukan "kosong". Aturan keras: **memverifikasi nilai sebuah field = WAJIB menyebutnya di `--fields` + `--json`** (output tabel tanpa `--json` malah bisa tidak menampilkan kolomnya sama sekali).

## Create — KONFIRMASI DULU

```bash
acli jira workitem create --project "COD" --type "Task" --summary "Judul task" \
  --description "Deskripsi plain text" --assignee "@me" --label "tgr-website" --json
```

Flag: `-p/--project` `-t/--type` (case sensitive) `-s/--summary` `-d/--description` `-a/--assignee` (email, account ID, `@me`, atau `default`) `-l/--label` (koma untuk banyak) `--parent`. Field tanpa flag (due date, priority, custom field) → pakai `--from-json` (lihat field-map.md) atau `--generate-json` untuk contoh bentuknya. Di jalur `--from-json`, parent Epic ditulis sebagai `"parentIssueId"` dan assignee sebagai email atau account ID; `@me` hanya berlaku sebagai flag dan ditolak di JSON (teruji COD-42).

**Teks bebas dari user/percakapan/git → jangan inline.** Contoh flag di atas hanya untuk teks singkat yang kamu susun sendiri tanpa karakter rawan. Summary/description yang bersumber dari kata-kata user: tulis dulu ke file JSON di direktori temp lalu `--from-json`, atau `--description-file` — quoting shell terhadap teks arbitrer itu rapuh.

## Comment — KONFIRMASI DULU

```bash
acli jira workitem comment create --key "COD-7" --body-file "comment.txt"   # jalur standar: tulis body ke file temp dulu
acli jira workitem comment create --key "COD-7" --body "ok, siap review"    # inline HANYA untuk teks singkat tanpa karakter rawan
acli jira workitem comment list --key "COD-7"                               # read, bebas
```

`--body-file` adalah jalur standar karena isi komentar hampir selalu memuat kata-kata user/git — lihat aturan keras #5 di SKILL.md.

## Transition — KONFIRMASI DULU

```bash
acli jira workitem transition --key "COD-7" --status "In Progress" --yes
```

`--yes` melewati prompt interaktif acli — justru karena itu konfirmasi ke user WAJIB terjadi sebelum perintah ini dijalankan. Nama status harus persis (lihat status yang ada via `view` atau board).

## Edit / Assign — KONFIRMASI DULU

```bash
acli jira workitem edit --key "COD-7" --summary "Judul baru" --labels "tgr-website" --yes
acli jira workitem assign --key "COD-7" --assignee "email-teman" --yes
```

Seperti `transition`, keduanya punya prompt interaktif bawaan yang tidak bisa dijawab dari shell non-interaktif — `--yes` wajib, dan justru karena itu konfirmasi ke user WAJIB terjadi sebelum perintah dijalankan.

## Link antar item — KONFIRMASI DULU

```bash
acli jira workitem link type                 # daftar jenis link (read)
acli jira workitem link create --help        # cek flag persisnya sebelum pakai
```

## Project

```bash
acli jira project list --paginate --json     # read, bebas
acli jira project view --key COD             # read, bebas (key lewat flag, bukan posisional)
```

`acli jira project create` ada, tapi `--from-project` hanya bisa meng-clone project company-managed; untuk kebutuhan lain pakai `--from-json` (cek bentuknya via `--generate-json`) atau buat lewat UI Jira — pandu user.
