#!/usr/bin/env bash
# LAMP stack: Apache (httpd), MariaDB, PHP, with a least-privilege DB account.
# shellcheck source=00-common.sh
. "$(dirname "$0")/00-common.sh"
require_root; require_alma9

log "Installing Apache, MariaDB, PHP"
dnf -y install httpd mod_ssl mariadb-server php php-mysqlnd php-fpm
systemctl enable --now httpd mariadb php-fpm

log "Hiding version banners"
cat > /etc/httpd/conf.d/00-security.conf <<'CONF'
ServerTokens Prod
ServerSignature Off
TraceEnable Off
Header always set X-Content-Type-Options "nosniff"
Header always set X-Frame-Options "DENY"
CONF
sed -i 's/^expose_php.*/expose_php = Off/' /etc/php.ini

log "Securing MariaDB (equivalent of mysql_secure_installation)"
read -r -s -p "New MariaDB root password: " DB_ROOT_PW; echo
read -r -s -p "Password for ${DB_USER}: " DB_APP_PW; echo
mysql -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PW}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_APP_PW}';
GRANT SELECT, INSERT, UPDATE, DELETE ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL
unset DB_ROOT_PW DB_APP_PW

log "MariaDB listens on localhost only"
printf '[mysqld]\nbind-address=127.0.0.1\n' > /etc/my.cnf.d/99-bind-local.cnf

log "Test page (no phpinfo exposed)"
cat > /var/www/html/index.php <<'PHP'
<?php
header('Content-Type: text/plain; charset=utf-8');
echo "AlmaLinux 9 LAMP server is up.\n";
PHP

apachectl configtest
systemctl restart mariadb httpd php-fpm
