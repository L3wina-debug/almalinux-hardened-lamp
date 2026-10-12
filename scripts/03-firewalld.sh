#!/usr/bin/env bash
# firewalld: default zone public, only SSH + HTTP/HTTPS open.
# shellcheck source=00-common.sh
. "$(dirname "$0")/00-common.sh"
require_root

systemctl enable --now firewalld
ZONE=public
firewall-cmd --set-default-zone="${ZONE}"

log "Removing services that are not needed"
for svc in cockpit dhcpv6-client; do
  firewall-cmd --permanent --zone="${ZONE}" --remove-service="${svc}" 2>/dev/null || true
done

log "Allowing SSH (${SSH_PORT}/tcp), HTTP and HTTPS"
if [[ ${SSH_PORT} == 22 ]]; then
  firewall-cmd --permanent --zone="${ZONE}" --add-service=ssh
else
  firewall-cmd --permanent --zone="${ZONE}" --remove-service=ssh 2>/dev/null || true
  firewall-cmd --permanent --zone="${ZONE}" --add-port="${SSH_PORT}/tcp"
fi
firewall-cmd --permanent --zone="${ZONE}" --add-service=http
firewall-cmd --permanent --zone="${ZONE}" --add-service=https
firewall-cmd --reload
firewall-cmd --zone="${ZONE}" --list-all
