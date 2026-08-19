# Field map — isian /jstack task ↔ Jira/acli

| Isian | Wajib? | Cara kirim ke acli | Catatan |
|---|---|---|---|
| Summary | ya | `--summary` | Judul singkat gaya dev, bukan kalimat panjang |
| Type | ya | `--type` | Case sensitive (`Task`, `Bug`, `Story`, …). Cek yang tersedia di project — beda project bisa beda type |
| Project | ya | `--project` | Dari `.jira-map.json` repo; user boleh override eksplisit |
| Description | tidak | `--description` / `--description-file` | Plain text diterima; multiline pakai file |
| Assignee | tidak | `--assignee` | Email, account ID, `@me`, atau `default` |
| Label repo | ya (konvensi) | `--label` | **Konvensi jstack: setiap item diberi label nama repo** (mis. `tgr-website`, `viralytics-v2`) — inilah pengganti Components, karena `create` tidak punya flag component dan project team-managed belum tentu punya Components. Lowercase, tanpa spasi |
| Label lain | tidak | `--label` (koma) | `bug`, `infra`, dsb. — secukupnya |
| Due date | tidak | `--from-json` → `additionalAttributes` | Tidak ada flag khusus. Bentuk standar Jira: `"duedate": "2026-08-30"` di `additionalAttributes`. **Uji sekali di item sandbox sebelum diandalkan**; kalau ditolak, set lewat UI/`edit` dan catat hasilnya di file ini |
| Priority | tidak | `--from-json` → `additionalAttributes` | Sama seperti due date: `"priority": {"name": "High"}` — uji dulu. Board Free sering cukup tanpa priority |
| Parent/Epic | tidak | `--parent` | ID parent, untuk sub-task/epic-child |
| Link antar item | tidak | `workitem link create` | Jalankan `link type` dulu untuk jenis relasi yang tersedia |

## Bentuk `--from-json`

Hasil `acli jira workitem create --generate-json` (bisa dipangkas — kirim hanya field yang diisi):

```json
{
  "projectKey": "COD",
  "type": "Task",
  "summary": "Judul task",
  "assignee": "email-atau-@me",
  "labels": ["tgr-website"],
  "description": {
    "type": "doc", "version": 1,
    "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Deskripsi" }] }]
  },
  "additionalAttributes": { "duedate": "2026-08-30" }
}
```

Deskripsi di `--from-json` wajib ADF (bentuk di atas); kalau cuma butuh plain text, lebih simpel pakai flag `--description` biasa.

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
