# VMware Workstation: snapshots and clones

Take a snapshot before each risky change, so a mistake (for example locking yourself out of SSH or a wrong SELinux label) can be undone in seconds. Suggested snapshot points:

| When | Snapshot name |
|---|---|
| Fresh install, before any change | `00-clean-install` |
| After `01-base.sh` | `01-base` |
| After SSH hardening, once a new login was tested | `02-ssh-ok` |
| After LAMP + SELinux, `verify.sh` all PASS | `05-hardened` |

**Snapshot:** VM ▸ Snapshot ▸ Take Snapshot. **Restore:** VM ▸ Snapshot ▸ Revert to Snapshot.

**Clone** (VM ▸ Manage ▸ Clone): a **linked clone** from `05-hardened` gives a ready test server in seconds and shares the parent's disk; a **full clone** is independent. After cloning, change the hostname (`hostnamectl set-hostname`) and regenerate the SSH host keys (`rm /etc/ssh/ssh_host_* && systemctl restart sshd`) so the clones do not share identities.
