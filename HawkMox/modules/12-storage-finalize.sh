#!/usr/bin/env bash

source "$(dirname "$0")/../lib/common.sh"

header "Module 12 - Storage Finalization"

section "Removing obsolete storage definitions"

if storage_exists local-lvm; then
    pvesm remove local-lvm
    pass "Removed local-lvm"
else
    info "local-lvm already absent."
fi

section "Reconfiguring local storage"

mkdir -p /srv/hawkmox

if storage_exists local; then
    pvesm set local \
        --path /srv/hawkmox \
        --content iso,vztmpl,backup,snippets,import
    pass "Updated local storage"
else
    pvesm add dir local \
        --path /srv/hawkmox \
        --content iso,vztmpl,backup,snippets,import
    pass "Created local storage"
fi

section "Storage Status"

pvesm status

echo
cat /etc/pve/storage.cfg

pass "Module 12 completed successfully."
