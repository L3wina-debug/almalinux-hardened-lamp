#!/usr/bin/env bash
# Base system: updates, admin user, time sync, basic tools.
# shellcheck source=00-common.sh
. "$(dirname "$0")/00-common.sh"
require_root; require_alma9

log "Updating packages"
dnf -y upgrade --refresh
dnf -y install chrony policycoreutils-python-utils setroubleshoot-server dnf-automatic vim curl

log "Enabling time sync"
systemctl enable --now chronyd

log "Automatic security updates (download + apply security errata)"
sed -i 's/^upgrade_type.*/upgrade_type = security/; s/^apply_updates.*/apply_updates = yes/' /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer

if ! id "${ADMIN_USER}" &>/dev/null; then
  log "Creating admin user ${ADMIN_USER} (member of wheel)"
  useradd -m -G wheel "${ADMIN_USER}"
  passwd "${ADMIN_USER}"
else
  log "User ${ADMIN_USER} already exists"
fi
