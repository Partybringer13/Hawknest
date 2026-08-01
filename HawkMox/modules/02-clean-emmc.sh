#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PROJECT_ROOT}/lib/common.sh"

header "Module 02 - eMMC Cleanup"

############################################################

section "Verifying boot device"

ROOT_SOURCE="$(findmnt -n -o SOURCE /)"

ROOT_DISK="$(lsblk -no pkname "${ROOT_SOURCE}" 2>/dev/null || true)"

[[ -n "${ROOT_DISK}" ]] || ROOT_DISK="$(basename "${BOOT_DISK}")"

info "Root filesystem: ${ROOT_SOURCE}"
info "Boot disk: /dev/${ROOT_DISK}"

############################################################

section "Removing swap"

if lvs pve/swap &>/dev/null
then

    swapoff -a || true

    lvremove -fy pve/swap

    success "Swap logical volume removed."

else

    info "Swap logical volume already absent."

fi

############################################################

section "Removing local-lvm"

if lvs pve/data &>/dev/null
then

    lvremove -fy pve/data

    success "Thin pool removed."

else

    info "Thin pool already absent."

fi

if storage_exists local-lvm
then

    pvesm remove local-lvm

    success "Removed local-lvm storage."

else

    info "local-lvm storage already absent."

fi

############################################################

section "Current layout"

echo

lvs || true

echo

vgs || true

echo

pvs || true

echo

success "Module 02 completed successfully."
