#!/usr/bin/env bash
# Shared helpers. Every script is safe to run twice (idempotent).
set -euo pipefail

log()  { printf '\033[1;34m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

require_root() { [[ ${EUID} -eq 0 ]] || die "run as root (sudo $0)"; }

require_alma9() {
  [[ -r /etc/os-release ]] || die "/etc/os-release not found"
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ ${ID:-} == "almalinux" && ${VERSION_ID%%.*} == "9" ]] || warn "tested on AlmaLinux 9, found ${PRETTY_NAME:-unknown}"
}

# Load settings from config/server.env if present.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/../config/server.env}"
if [[ -r ${CONFIG_FILE} ]]; then
  # shellcheck disable=SC1090
  . "${CONFIG_FILE}"
fi
ADMIN_USER="${ADMIN_USER:-webadmin}"
SSH_PORT="${SSH_PORT:-22}"
DB_NAME="${DB_NAME:-appdb}"
DB_USER="${DB_USER:-appuser}"
