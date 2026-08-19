#!/bin/sh
# Pengingat jstack di awal sesi. Read-only: tidak menyentuh Jira, tidak menulis file.
# Diam total kalau repo tidak ter-mapping — supaya tidak berisik di project lain.

d="${CLAUDE_PROJECT_DIR:-.}"
[ -f "$d/.jira-map.json" ] || exit 0

key=$(sed -n 's/.*"projectKey"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$d/.jira-map.json" | head -n 1)
# hanya bentuk project key Jira yang sah yang boleh ikut ke output — isi file bisa saja aneh/berbahaya
case "$key" in
  ""|*[!A-Z0-9]*) key="?" ;;
esac
[ ${#key} -le 10 ] || key="?"

echo "jstack: repo ini terhubung Jira (project ${key:-?})."
if [ ! -d "$d/graphify-out" ]; then
  echo "jstack: graphify-out/ belum ada — tawarkan /graphify di awal sesi sebelum kerja lain."
fi
echo "jstack: di checkpoint (task selesai / habis commit / akhir sesi) tanyakan sekali apakah pekerjaan ini bagian dari work item Jira; kalau ya tawarkan /jstack log. Jangan menulis ke Jira tanpa konfirmasi user."
exit 0
