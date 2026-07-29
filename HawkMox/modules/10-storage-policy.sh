#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 10 - Storage Policy"

section "Verifying ZFS"

zpool list hawktank >/dev/null

zfs create -p hawktank/vmstore 2>/dev/null || true
zfs set mountpoint=none hawktank/vmstore

zfs create -p hawktank/data 2>/dev/null || true
zfs set mountpoint=/var/lib/vz hawktank/data

zfs create -p hawktank/iso 2>/dev/null || true
zfs create -p hawktank/templates 2>/dev/null || true
zfs create -p hawktank/import 2>/dev/null || true
zfs create -p hawktank/backups 2>/dev/null || true
zfs create -p hawktank/snippets 2>/dev/null || true

mkdir -p /srv/hawkmox/{iso,vztmpl,backup,snippets,import}

section "Configuring Proxmox Storage"

if ! pvesm status | awk '{print $1}' | grep -qx hawktank; then
    pvesm add zfspool hawktank \
        --pool hawktank/vmstore \
        --content images,rootdir \
        --sparse 1 \
        --blocksize 16k
fi

if ! pvesm status | awk '{print $1}' | grep -qx hawkfiles; then
    pvesm add dir hawkfiles \
        --path /srv/hawkmox \
        --content iso,vztmpl,backup,snippets,import
fi

if pvesm status | awk '{print $1}' | grep -qx local; then
    pvesm set local \
        --path /var/lib/vz \
        --content iso,vztmpl,backup,snippets
fi

section "Verification"

echo
pvesm status

echo
zfs list

echo
cat /etc/pve/storage.cfg

success "Storage policy applied."
