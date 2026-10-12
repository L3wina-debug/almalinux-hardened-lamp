# Hardened LAMP Server on AlmaLinux 9

![AlmaLinux](https://img.shields.io/badge/AlmaLinux-9-0F4266?logo=almalinux&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-scripts-4EAA25?logo=gnubash&logoColor=white)
![SELinux](https://img.shields.io/badge/SELinux-enforcing-darkred)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

A web server (Apache, MariaDB, PHP) on **AlmaLinux 9** in a VMware Workstation virtual machine, hardened step by step: SSH, **firewalld**, **SELinux**, user management and least-privilege database access.

> Academic project, **Innovation** module, Master in AI & Cybersecurity (Faculté des Sciences de Kénitra), done in a pair and presented with an exam-style Q&A.
> The original work was done by hand in the VM. This repository was **rebuilt in October 2026** as repeatable scripts that apply the same configuration. The scripts are syntax-checked (`bash -n`); run them on a fresh AlmaLinux 9 VM and use `verify.sh` to check the result.

## What the scripts do

| Script | Purpose |
|---|---|
| `01-base.sh` | Updates, `chrony`, automatic **security** updates (`dnf-automatic`), admin user in `wheel` |
| `02-ssh-hardening.sh` | Drop-in `sshd_config.d/50-hardening.conf`: no root login, `MaxAuthTries 3`, `AllowUsers`, idle timeout; config validated with `sshd -t` before restart; SELinux label if the port changes |
| `03-firewalld.sh` | Zone `public`: only SSH, HTTP, HTTPS; removes `cockpit` and `dhcpv6-client` |
| `04-lamp.sh` | Apache + `mod_ssl`, MariaDB, PHP-FPM; hidden banners (`ServerTokens Prod`, `expose_php Off`), security headers; MariaDB secured (no anonymous users, no remote root, no `test` DB), **bound to 127.0.0.1**, app user with only `SELECT/INSERT/UPDATE/DELETE` on its database |
| `05-selinux.sh` | **Enforcing** mode, `restorecon` on the web root, only `httpd_can_network_connect_db` enabled |
| `verify.sh` | Read-only PASS/FAIL checks of all the above |

Every script is idempotent and stops on the first error (`set -euo pipefail`). Passwords are typed interactively and never written to disk.

## Architecture

```text
 Client ──► firewalld (22, 80, 443 only)
              │
              ├── sshd  (no root, AllowUsers webadmin, 3 tries)
              └── Apache httpd + PHP-FPM   [SELinux: httpd_t]
                     │  httpd_can_network_connect_db = on
                     ▼
                 MariaDB on 127.0.0.1:3306  (app user, least privilege)
```

## Usage

```bash
git clone https://github.com/L3wina-debug/almalinux-hardened-lamp.git
cd almalinux-hardened-lamp
cp config/server.env.example config/server.env   # adjust admin user / SSH port
sudo ./scripts/01-base.sh
sudo ./scripts/02-ssh-hardening.sh   # test a new SSH login before closing your session
sudo ./scripts/03-firewalld.sh
sudo ./scripts/04-lamp.sh
sudo ./scripts/05-selinux.sh
sudo ./scripts/verify.sh
```

## Virtual machine workflow

VMware snapshots and cloning were part of the project: see [docs/vmware-snapshots.md](docs/vmware-snapshots.md).

## Skills

Linux system administration · SSH hardening · firewalld · SELinux (modes, contexts, booleans) · Apache/MariaDB/PHP deployment · least privilege · virtualisation (snapshots, clones).

## License

MIT. See [LICENSE](LICENSE).
