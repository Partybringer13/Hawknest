#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 16 - Cleanup"

############################################################
section "Cleaning Package Cache"

apt clean

apt autoremove -y

############################################################
section "Removing Logs"

journalctl --vacuum-time=7d >/dev/null 2>&1 || true

rm -rf /var/cache/apt/*

rm -rf /var/lib/apt/lists/*

############################################################
section "Archiving Installer"

ARCHIVE="/root/HawkMox-$(date +%Y%m%d).tar.gz"

tar czf "${ARCHIVE}" \
    -C "$(dirname "${PROJECT_ROOT}")" \
    "$(basename "${PROJECT_ROOT}")"

pass "Installer archived."

############################################################
section "Removing Installer"

rm -rf "${PROJECT_ROOT}"

pass "Installer removed."

############################################################
section "Filesystem"

sync

df -h

echo

pass "Module 16 completed successfully."
