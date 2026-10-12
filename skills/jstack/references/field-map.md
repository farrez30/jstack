# Field map — isian /jstack task ↔ Jira/acli

| Isian | Wajib? | Cara kirim ke acli | Catatan |
|---|---|---|---|
| Summary | ya | `--summary` | Judul singkat gaya dev, bukan kalimat panjang |
| Type | ya | `--type` | Case sensitive (`Task`, `Bug`, `Story`, …). Cek yang tersedia di project — beda project bisa beda type |
| Project | ya | `--project` | Dari `.jira-map.json` repo; user boleh override eksplisit |
| Description | tidak | `--description` / `--description-file` | Plain text diterima; multiline pakai file |
| Assignee | tidak | `--assignee` / `"assignee"` di `--from-json` | Flag: email, account ID, `@me`, atau `default`. **Di `--from-json`, `@me` DITOLAK** (`User not found for email: @me`, teruji COD-42, acli 1.3.23): tulis email (ambil `email` dari `~/.jstack/config.json`) atau account ID |
| Label repo | ya (konvensi) | `--label` | **Konvensi jstack: setiap item diberi label nama repo** (mis. `tgr-website`, `viralytics-v2`) — inilah pengganti Components, karena `create` tidak punya flag component dan project team-managed belum tentu punya Components. Lowercase, tanpa spasi |
| Label lain | tidak | `--label` (koma) | `bug`, `infra`, dsb. — secukupnya |
| Due date | tidak | `create --from-json` → `additionalAttributes` | **TERUJI JALAN** (COD-2, acli 1.3.23): `"additionalAttributes": {"duedate": "2026-08-26"}` saat create. **`edit` TIDAK BISA** — `--from-json` edit menolak `additionalAttributes` (`json: unknown field`). Jadi: set saat create; menambah due date belakangan = lewat UI Jira |
| Priority | tidak | `create --from-json` → `additionalAttributes` | Polanya kemungkinan sama dengan due date (`"priority": {"name": "High"}`) tapi **belum diuji** — kalau dipakai, verifikasi hasilnya dengan `view` dan catat di sini. Board kecil biasanya cukup tanpa priority |
| Parent/Epic | ya (konvensi) | `--parent` saat create / `"parentIssueId"` di `--from-json` | **Konvensi jstack: satu repo = satu Epic**; item baru ber-parent ke `epicKey` dari `.jira-map.json` supaya Timeline per project terbaca. **TERUJI JALAN** (COD-42, acli 1.3.23): `"parentIssueId": "COD-12"` di `--from-json` memasang Epic sebagai parent Task, walau `--generate-json` menyebut field itu "only if the work item is a sub-task". Create dengan due date atau teks bebas selalu lewat `--from-json`, jadi taruh parent di JSON; mencampur flag `--parent` dengan `--from-json` belum diuji. Parent hanya bisa dipasang saat `create` — meng-parent-kan item lama = UI (buka item → Add parent, atau Board → Group by Epic → drag) |
| Start date | tidak (epic saja) | `create --from-json` → `additionalAttributes` → `customfield_10015` | **TERUJI JALAN** (COD-10/11/12, site farrez): `"customfield_10015": "2026-07-09"` saat create. ID customfield bisa beda di site lain — verifikasi dengan `view KEY --fields customfield_10015 --json`. Seperti duedate, `edit` tidak bisa — ubah belakangan via drag bar di Timeline |
| Link antar item | tidak | `workitem link create` | Jalankan `link type` dulu untuk jenis relasi yang tersedia |

## Bentuk `--from-json`

Hasil `acli jira workitem create --generate-json` (bisa dipangkas — kirim hanya field yang diisi):

```json
{
  "projectKey": "COD",
  "type": "Task",
  "summary": "Judul task",
  "assignee": "email-atau-account-id",
  "labels": ["tgr-website"],
  "parentIssueId": "COD-10",
  "description": {
    "type": "doc", "version": 1,
    "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Deskripsi" }] }]
  },
  "additionalAttributes": { "duedate": "2026-08-30" }
}
```

Deskripsi di `--from-json` wajib ADF (bentuk di atas); kalau cuma butuh plain text, lebih simpel pakai flag `--description` biasa. `"assignee"` di JSON tidak menerima `@me`, dan `"parentIssueId"` diisi `epicKey` repo (lihat tabel di atas).

## JQL siap pakai (untuk /jstack status)

```
assignee = currentUser() AND statusCategory != Done ORDER BY duedate ASC, updated DESC
project = COD AND statusCategory != Done ORDER BY duedate ASC
project = COD AND labels = "tgr-website" AND statusCategory != Done
project = COD AND assignee IS EMPTY AND statusCategory != Done
duedate <= 3d AND statusCategory != Done AND assignee = currentUser()
```

(JQL tidak punya sintaks komentar — tiap baris di atas utuh siap salin. Baris ke-4 = item unassigned kandidat diambil; baris ke-5 = deadline ≤3 hari.)

`statusCategory != Done` lebih tahan banting daripada `status != Done` karena mencakup semua nama status "selesai" apa pun sebutannya di board.
