#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/../lib/common.sh"

header "Module 12 - Storage Finalization"

############################################################
section "Removing obsolete storage definitions"

if storage_exists local-lvm; then
    info "Removing local-lvm..."
    pvesm remove local-lvm
fi

success "Legacy storage definitions removed."

############################################################
section "Verifying HawkMox storage"

storage_exists hawktank  || die "hawktank missing."
storage_exists hawkfiles || die "hawkfiles missing."

success "hawktank verified."
success "hawkfiles verified."

############################################################
section "Current Configuration"

cat /etc/pve/storage.cfg
echo
pvesm status

success "Module 12 completed successfully."
