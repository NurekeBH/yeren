#!/usr/bin/env bash
# Redeploy ALTYN landing + backend + admin to the VPS (213.155.20.198 / altyn.social).
#
# Routes (nginx): /  -> static landing (/var/www/altyn)
#                 /admin -> Next.js admin (:3001, basePath=/admin)
#                 /api, /health -> backend (:3000)
#
# Prereq: passwordless SSH alias `altyn` is configured in ~/.ssh/config
#         (Host altyn -> ubuntu@213.155.20.198, IdentityFile ~/.ssh/altyn_deploy).
#
# Usage:
#   docs/deploy.sh            # rsync + rebuild + restart backend & admin
#   docs/deploy.sh --migrate  # also run DB migration (schema + seed)
set -euo pipefail

HOST=altyn
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MIGRATE=0
[[ "${1:-}" == "--migrate" ]] && MIGRATE=1

echo ">>> rsync backend"
rsync -az --delete \
  --exclude node_modules --exclude dist --exclude .git \
  --exclude .env --exclude '*.log' --exclude .DS_Store \
  "$ROOT/apps/backend/" "$HOST:/home/ubuntu/altyn/backend/"

echo ">>> rsync admin"
rsync -az --delete \
  --exclude node_modules --exclude .next --exclude .git \
  --exclude .env --exclude .env.local --exclude '*.log' --exclude .DS_Store \
  "$ROOT/apps/admin/" "$HOST:/home/ubuntu/altyn/admin/"

echo ">>> rsync landing"
rsync -az --delete --exclude .DS_Store \
  "$ROOT/apps/landing/" "$HOST:/home/ubuntu/altyn/landing/"

echo ">>> remote build + restart"
ssh "$HOST" "MIGRATE=$MIGRATE bash -s" <<'REMOTE'
set -e
cd /home/ubuntu/altyn/backend
npm install --no-audit --no-fund >/dev/null
npm run build
[ "$MIGRATE" = "1" ] && npm run db:migrate || true
# Каталог деректерін DB-ге салу (Кітап/Фильм/Подкаст + курс + академия + Gallup).
# on conflict do nothing — бар жазбаларды (админ өзгерткен) қозғамайды.
[ "$MIGRATE" = "1" ] && npm run db:seed-catalog || true

cd /home/ubuntu/altyn/admin
npm install --no-audit --no-fund >/dev/null
npm run build

# publish static landing (+ invite.html — deferred deep link реферал-страница)
sudo -n mkdir -p /var/www/altyn
sudo -n cp /home/ubuntu/altyn/landing/index.html /var/www/altyn/index.html
sudo -n cp /home/ubuntu/altyn/landing/invite.html /var/www/altyn/invite.html
sudo -n chown -R www-data:www-data /var/www/altyn

sudo -n systemctl restart altyn-backend altyn-admin
sleep 2
echo -n "backend health: "; curl -fsS http://127.0.0.1:3000/health && echo
systemctl is-active altyn-backend altyn-admin nginx
REMOTE

echo ">>> done — https://altyn.social (landing) · https://altyn.social/admin (panel)"
