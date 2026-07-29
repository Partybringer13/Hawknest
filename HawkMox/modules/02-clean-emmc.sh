#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 02 - eMMC Cleanup"

section "Verifying boot device"

ROOT_SOURCE="$(findmnt -n -o SOURCE /)"

info "Root filesystem: ${ROOT_SOURCE}"
info "Boot disk: ${BOOT_DISK}"

[[ "${ROOT_SOURCE}" == /dev/mapper/* ]] \
    || die "Root filesystem is not on LVM."

section "Removing swap"

if lvs pve/swap &>/dev/null; then

    swapoff -a || true

    lvremove -fy pve/swap

    success "Swap logical volume removed."

else

    info "Swap logical volume already absent."

fi

section "Removing local-lvm"

if lvs pve/data &>/dev/null; then

    lvremove -fy pve/data

    success "Thin pool removed."

else

    info "Thin pool already absent."

fi

if grep -q "^lvmthin: local-lvm" /etc/pve/storage.cfg 2>/dev/null; then

    pvesm remove local-lvm

    success "Removed local-lvm storage."

else

    info "local-lvm storage already absent."

fi

section "Current layout"

echo
lvs || true

echo
vgs || true

echo
pvs || true

echo

success "Module 02 completed successfully."
