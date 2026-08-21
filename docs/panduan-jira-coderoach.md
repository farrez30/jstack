# Panduan Jira Coderoach

Untuk farrez & wafi. Satu halaman ini menjelaskan cara membaca dan memakai project **COD** di `farrez.atlassian.net` — apa fungsi tiap tab, bagaimana mengevaluasi pekerjaan lewat Timeline & Reports, dan konvensi yang kita sepakati. Simpan sebagai rujukan; perubahan konvensi diedit di file ini (repo `farrez30/jstack`).

## Peta cepat: tab mana yang dipakai kapan

Urutan yang disarankan (geser tab dengan drag; sembunyikan sisanya lewat menu **⋯** di deretan tab):

**Summary → Timeline → Board → List → Reports → Development**

| Tab | Fungsi | Kapan dibuka |
|---|---|---|
| **Summary** | Angka ringkas otomatis: selesai minggu ini, overdue, dibuka-kembali | Sekilas tiap mulai hari |
| **Timeline** | Bar per Epic dari start sampai due — "project dibuat kapan, target selesai kapan" | Evaluasi & re-planning |
| **Board** | Kanban drag-and-drop; kolom = status | Sepanjang hari kerja |
| **List** | Semua item sebagai tabel (bisa sort/filter/edit inline) | Beres-beres massal, audit |
| **Reports** | Grafik created vs resolved, cycle time, distribusi | Evaluasi rutin berdua |
| **Development** | Commit/PR/branch GitHub yang menyebut `COD-x` menempel ke item-nya | Cek jejak kode sebuah item |

Tab yang kita sembunyikan dan alasannya: **Forms** (formulir intake — tidak ada pihak luar yang submit request), **Goals** (target strategis lintas-tim — berlebihan untuk tim 2 orang; cukup Epic), **Components** (perannya sudah diambil label), **Code/Releases/Deployments** (belum ada rilis ber-versi), **Docs/Shortcuts** (belum dipakai). Menyembunyikan tidak menghapus apa pun — bisa dimunculkan lagi kapan saja.

## Struktur kerja: Epic → Task → status

- **Epic = repo.** Tiga epic: *The Global Review Website*, *Viralytics v2*, *Ops & Tooling — jstack*. Setiap task ber-**parent** ke epic repo-nya, plus **label** nama repo (`tgr-website`, `viralytics-v2`, `jstack`) untuk filter cepat.
- **Task** = satuan kerja harian. **Bug**/**Story** dipakai bila memang bug atau fitur ber-narasi. **Sub-task** untuk pecahan kecil di dalam task.
- **Status** (kolom board):

```
Backlog → To Do → In Progress → In Review → Done
                    ↑ ↓  (bisa dari/ke tahap mana pun)
                    HALT
```

| Status | Artinya |
|---|---|
| **Backlog** | Ide/rencana — belum siap dikerjakan |
| **To Do** | Siap diambil; sudah jelas apa yang harus dilakukan |
| **In Progress** | Sedang dikerjakan seseorang |
| **In Review** | Menunggu dicek partner (PR/hasil kerja) |
| **Halt** | Ditahan dulu — menunggu pihak luar (hosting, WP admin, keputusan) — bukan gagal, bukan selesai |
| **Done** | Selesai dan terverifikasi |

Aturan kecil yang menyelamatkan board: item di **Halt wajib punya komentar** yang menyebut menunggu apa — tanpa itu dia jadi kuburan.

## Cara membaca Timeline

- Tiap **bar = satu Epic**: ujung kiri = start (kita isi dari tanggal commit pertama repo — fakta git, bukan karangan), ujung kanan = **due/target** (kesepakatan: TGR 30 Sep 2026, Viralytics 31 Okt 2026).
- **Menggeser ujung bar = re-planning** — sah dan memang begitu cara pakainya, asal digeser sadar (sebut di komentar epic kenapa mundur), bukan diam-diam.
- Item di dalam epic muncul sebagai baris di bawah bar-nya (expand panah di kiri). Item tanpa due date tetap terhitung, hanya tidak tergambar panjangnya.
- Pertanyaan yang dijawab Timeline: *proyek mana yang mendekati target tapi item-nya masih banyak terbuka?* — itu sinyal untuk memindah tenaga atau menggeser target.

## Cara membaca Reports (evaluasi rutin berdua)

Ritual yang disarankan — 15 menit tiap dua minggu, buka bersama (bisa sambil call):

1. **Reports → Created vs Resolved**: garis merah (dibuat) di atas garis hijau (selesai) terus-menerus = backlog menggemuk → kurangi ambil kerjaan baru, atau ada scope creep.
2. **Cycle time**: item yang lama nyangkut di In Progress/In Review = terlalu besar (pecah jadi sub-task) atau review-nya menunggu terlalu lama.
3. **Board, saring Halt**: baca komentarnya — masih valid menunggunya? Yang sudah tidak relevan: gerakkan atau tutup.
4. **Timeline**: cocokkan sisa item vs sisa waktu tiap epic → geser target yang tidak realistis, dan catat alasannya di komentar epic.
5. Tutup dengan `/jstack status` di terminal masing-masing — pastikan tidak ada item assigned yang terlupa.

Semua angka report dihitung dari perpindahan status yang kalian lakukan sehari-hari — report akurat ⇔ status dirawat. Itu alasan sebenarnya kolom board harus digeser jujur.

## Konvensi Coderoach

1. **Epic = repo; label = repo** — dua-duanya, selalu.
2. **Due date diisi saat item dibuat** (bisa lewat `/jstack task`); tanpa due date, Timeline dan "overdue" tidak bisa menolongmu.
3. **Sebut key di commit** — `fix: COD-12 …` — supaya tab Development menautkan kode ke item otomatis.
4. **Progres dicatat sebagai komentar** via `/jstack log` di akhir sesi kerja (Claude menawarkan ini otomatis di repo ter-mapping).
5. **Assignee = yang mengerjakan sekarang**; item tak bertuan dibiarkan Unassigned supaya kelihatan bisa diambil.
6. **Project baru = ditanya di awal**: begitu project/repo baru lahir (di Claude Code maupun Chat), Claude menawarkan menghubungkannya — bagian dari Epic yang ada atau Epic baru, tujuan 1 kalimat, dan target selesai. Boleh dijawab "nanti dulu".
7. Semua tulisan ke Jira dari Claude selalu lewat konfirmasi — token/kredensial tidak pernah lewat chat.

## Langkah admin sekali-jalan (farrez, ±10 menit total)

Checklist klik yang cukup dilakukan sekali, dicentang dari atas:

- [ ] **Tambah issue type** Epic + Bug + Story ke COD: ⚙️ **Settings → Issues → Issue type schemes** → skema milik COD → **Edit** → seret Epic, Bug, Story ke dalam skema → Save.
- [ ] **Tambah status** Backlog, In Review, Halt: ⚙️ **Settings → Issues → Workflows** → workflow COD → **Edit** → *Add status* × 3 (transisi: *All statuses can transition to this one*) → **Publish**. Lalu di **Board ⋯ → Configure board → Columns**: buat kolom untuk tiap status dan urutkan Backlog · To Do · In Progress · In Review · Halt · Done.
- [ ] **Munculkan Timeline**: kalau belum ada tab-nya, klik **+** di ujung deretan tab → **Timeline**.
- [ ] **Rapikan tab**: drag sesuai urutan di atas; sembunyikan Forms/Goals/Components/dll lewat ⋯.
- [ ] **Hubungkan item lama ke epic** (bila belum otomatis): Board → **Group by: Epic** → drag item ke epic-nya; atau buka item → **Add parent**.
- [ ] **Set start date epic** (kalau belum terisi): Timeline → tarik ujung kiri bar ke tanggal mulai (TGR 9 Jul 2026, Viralytics 27 Apr 2026, jstack 19 Agu 2026).
- [ ] **Selesaikan GitHub for Atlassian**: tab Development → *get started* → pilih akun `farrez30` → izinkan repo Coderoach. (Email "order confirmed (Free)" yang kamu terima = konfirmasi $0 app ini, bukan tagihan.)

## FAQ

**Dari HP/Claude Chat bisa?** Bisa — aktifkan Atlassian connector sekali di claude.ai → Settings → Connectors (per akun), lalu perintah biasa: *"pindahkan COD-7 ke In Review"*.

**Kalau trial Premium habis?** Tidak ada yang kita pakai yang hilang — item, epic, board, Timeline per project, Reports, integrasi GitHub, acli: semuanya fitur Free. Yang hilang hanya fitur Premium yang tidak kita sentuh (Plans lintas-project, audit log, storage >2 GB).

**Siapa tercatat melakukan apa?** Identitas mengikuti login di device/akun masing-masing — farrez di device farrez, wafi di device wafi. Assignee cuma field tugas; keduanya tidak saling menimpa.

**Item saya kok tidak muncul di `/jstack status`?** Dashboard menyaring `assignee = currentUser()` — item Unassigned muncul di bagian terpisah ("kandidat diambil"), dan item partner tidak muncul di daftarmu.
