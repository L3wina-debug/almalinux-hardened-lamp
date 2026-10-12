#!/usr/bin/env bash
# SELinux: enforcing mode, correct file contexts, only the booleans the app needs.
# shellcheck source=00-common.sh
. "$(dirname "$0")/00-common.sh"
require_root

log "Setting SELinux to enforcing (now and at boot)"
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
setenforce 1 || warn "setenforce failed: a reboot is needed if SELinux was disabled"

log "Restoring file contexts of the web root"
restorecon -Rv /var/www/html

log "Booleans: allow httpd to reach the local database, nothing else"
setsebool -P httpd_can_network_connect_db on
setsebool -P httpd_can_network_connect off
setsebool -P httpd_enable_homedirs off

getenforce
getsebool -a | grep -E '^httpd_(can_network_connect|can_network_connect_db|enable_homedirs) '
