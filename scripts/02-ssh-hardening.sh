#!/usr/bin/env bash
# SSH hardening with a drop-in file (the vendor sshd_config stays untouched).
# shellcheck source=00-common.sh
. "$(dirname "$0")/00-common.sh"
require_root; require_alma9

DROPIN=/etc/ssh/sshd_config.d/50-hardening.conf
log "Writing ${DROPIN}"
cat > "${DROPIN}" <<CONF
Port ${SSH_PORT}
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 30
PermitEmptyPasswords no
X11Forwarding no
AllowUsers ${ADMIN_USER}
ClientAliveInterval 300
ClientAliveCountMax 2
CONF
chmod 600 "${DROPIN}"

if [[ ${SSH_PORT} != 22 ]]; then
  log "Labelling port ${SSH_PORT} as ssh_port_t for SELinux"
  semanage port -a -t ssh_port_t -p tcp "${SSH_PORT}" 2>/dev/null || semanage port -m -t ssh_port_t -p tcp "${SSH_PORT}"
fi

log "Validating configuration before restart"
sshd -t
systemctl restart sshd
warn "Keep your current session open and test a new SSH login as ${ADMIN_USER} before logging out."
