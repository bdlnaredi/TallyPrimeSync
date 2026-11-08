#!/usr/bin/env bash
# TallyPrimeSync (Bahi) on a cloud server, in one go:
#   curl -fsSL https://raw.githubusercontent.com/bdlnaredi/TallyPrimeSync/main/deploy/cloud/install.sh | sudo bash
# Installs Docker if needed, asks for an app password and the web address, sets up HTTPS (Caddy, free
# certificate), opens ports 80 and 443, starts Bahi, and updates it every night. Safe to run again: it keeps
# the settings it already has and only updates.
set -euo pipefail

DIR=/opt/tallyprimesync
RAW=https://raw.githubusercontent.com/bdlnaredi/TallyPrimeSync/main/deploy/cloud

say()  { printf '\n\033[1;34m%s\033[0m\n' "$*"; }
fail() { printf '\n\033[1;31m%s\033[0m\n' "$*" >&2; exit 1; }
ask()  { local v; read -r -p "$1" v </dev/tty || true; printf '%s' "$v"; }

[ "$(id -u)" = 0 ] || fail "Run it with sudo (as in the instructions)."
command -v curl >/dev/null || { apt-get update -qq && apt-get install -y -qq curl; }

# ---- swap: the small free servers (1 GB, like Oracle's E2.1.Micro) need room to breathe
mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
if [ "${mem_kb:-0}" -lt 2000000 ] && ! swapon --show | grep -q .; then
  say "Adding 2 GB of swap (this server has little memory) ..."
  if fallocate -l 2G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none; then
    chmod 600 /swapfile && mkswap /swapfile >/dev/null && swapon /swapfile
    grep -q "^/swapfile" /etc/fstab || echo "/swapfile none swap sw 0 0" >> /etc/fstab
  fi
fi

# ---- Docker
if ! command -v docker >/dev/null || ! docker compose version >/dev/null 2>&1; then
  say "Installing Docker (a few minutes) ..."
  curl -fsSL https://get.docker.com | sh >/dev/null
fi
systemctl enable --now docker >/dev/null 2>&1 || true

# ---- files
mkdir -p "$DIR/data"
cd "$DIR"
curl -fsSL "$RAW/docker-compose.yml" -o docker-compose.yml
curl -fsSL "$RAW/Caddyfile" -o Caddyfile

# ---- settings (kept from an earlier run)
if [ -f .env ]; then
  say "Keeping the settings already in $DIR/.env"
  # shellcheck disable=SC1091
  . ./.env
else
  IP=$(curl -4 -fsS --max-time 10 https://api.ipify.org || curl -4 -fsS --max-time 10 https://ifconfig.me || true)
  DEFAULT_DOMAIN=""
  [ -n "$IP" ] && DEFAULT_DOMAIN="$(echo "$IP" | tr . -).sslip.io"
  say "The web address for Bahi"
  echo "Press Enter to use $DEFAULT_DOMAIN (free, works straight away),"
  echo "or type your own domain (e.g. books.yourshop.in) if you have pointed it at this server ($IP)."
  DOMAIN=$(ask "Address [$DEFAULT_DOMAIN]: ")
  DOMAIN=${DOMAIN:-$DEFAULT_DOMAIN}
  DOMAIN=${DOMAIN#https://}; DOMAIN=${DOMAIN#http://}; DOMAIN=${DOMAIN%%/*}
  [ -n "$DOMAIN" ] || fail "No address given."

  say "A password for the Bahi app (at least 8 characters; this server is on the internet, so make it a good one)"
  while :; do
    read -r -s -p "Password: " P1 </dev/tty; echo
    read -r -s -p "Again: " P2 </dev/tty; echo
    [ "${#P1}" -ge 8 ] && [ "$P1" = "$P2" ] && break
    echo "They don't match or are shorter than 8 characters. Try again."
  done
  APP_PASSWORD=$P1
  SYNC_TOKEN=$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')
  umask 077
  cat > .env <<ENV
DOMAIN=$DOMAIN
APP_PASSWORD=$APP_PASSWORD
SYNC_TOKEN=$SYNC_TOKEN
TZ=Asia/Kolkata
ENV
  chmod 600 .env
fi

# ---- firewall: Oracle's Ubuntu images block everything but SSH in iptables
if command -v iptables >/dev/null; then
  for p in 80 443; do
    iptables -C INPUT -p tcp --dport $p -j ACCEPT 2>/dev/null || iptables -I INPUT 1 -p tcp --dport $p -j ACCEPT
  done
  if command -v netfilter-persistent >/dev/null; then netfilter-persistent save >/dev/null 2>&1 || true; fi
fi
if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then ufw allow 80/tcp >/dev/null; ufw allow 443/tcp >/dev/null; fi

# ---- start
say "Starting Bahi ..."
docker compose pull -q
docker compose up -d

# ---- nightly update (new versions of Bahi arrive by themselves)
cat > /etc/cron.d/tallyprimesync <<CRON
# TallyPrimeSync: fetch the newest Bahi every night and restart it if there is one
17 3 * * * root cd $DIR && docker compose pull -q && docker compose up -d && docker image prune -f >/dev/null 2>&1
CRON

# ---- wait for HTTPS
say "Getting the HTTPS certificate (up to a minute) ..."
ok=""
for _ in $(seq 1 30); do
  if curl -fsS --max-time 5 "https://$DOMAIN/manifest.webmanifest" >/dev/null 2>&1; then ok=1; break; fi
  sleep 3
done

echo
echo "=============================================================="
if [ -n "$ok" ]; then
  echo " Bahi is running at:  https://$DOMAIN"
else
  echo " Bahi has started, but https://$DOMAIN didn't answer yet."
  echo " If it still doesn't open in a few minutes, ports 80 and 443 are"
  echo " probably closed in your cloud provider's firewall (see docs/CLOUD.md)."
fi
echo
echo " Sync token (for Bahi Sync on the Tally PC):"
echo "   $SYNC_TOKEN"
echo
echo " Next:"
echo "  1. Bahi Sync on the Tally PC: Settings, server address https://$DOMAIN"
echo "     and the sync token above."
echo "  2. Phone app: change the server address to https://$DOMAIN"
echo "  3. Moving from Unraid: Settings, Backups on the old Bahi: Download;"
echo "     then on the new one: Restore from a backup file."
echo "  4. Bahi Sync, Tools: Back up to Google Drive (or OneDrive)."
echo
echo " Settings are in $DIR/.env, data in $DIR/data."
echo "=============================================================="
