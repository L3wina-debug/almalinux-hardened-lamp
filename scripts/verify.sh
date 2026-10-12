#!/usr/bin/env bash
# Read-only checks of the hardening. Prints PASS/FAIL per item; exit code = number of failures.
# shellcheck source=00-common.sh
. "$(dirname "$0")/00-common.sh"
fails=0
check() { if eval "$2" &>/dev/null; then printf 'PASS  %s\n' "$1"; else printf 'FAIL  %s\n' "$1"; fails=$((fails+1)); fi; }

check "SELinux is enforcing"               '[[ $(getenforce) == Enforcing ]]'
check "firewalld is running"               'systemctl is-active --quiet firewalld'
check "only ssh/http/https services open"  '[[ $(firewall-cmd --list-services | tr " " "\n" | grep -vcE "^(ssh|http|https)?$") -eq 0 ]]'
check "root SSH login disabled"            'sshd -T | grep -qi "^permitrootlogin no"'
check "SSH MaxAuthTries <= 3"              '[[ $(sshd -T | awk "/^maxauthtries/{print \$2}") -le 3 ]]'
check "httpd running"                      'systemctl is-active --quiet httpd'
check "Apache banner hidden"               'curl -sI http://localhost | grep -qi "^Server: Apache\s*$"'
check "MariaDB bound to localhost"         'ss -ltn | grep -q "127.0.0.1:3306"'
check "PHP version not exposed"            '! curl -sI http://localhost | grep -qi "^X-Powered-By"'
check "httpd_can_network_connect_db on"    'getsebool httpd_can_network_connect_db | grep -q "on$"'
check "automatic security updates on"      'systemctl is-enabled --quiet dnf-automatic.timer'
echo "${fails} failure(s)"
exit "${fails}"
