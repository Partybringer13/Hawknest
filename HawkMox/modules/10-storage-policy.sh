#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/../lib/common.sh"

header "Module 10 - Storage Policy"

section "Verify Storages"

if storage_exists hawktank; then
    pass "hawktank present."
else
    die "hawktank missing."
fi

if storage_exists hawkfiles; then
    pass "hawkfiles present."
else
    die "hawkfiles missing."
fi

section "Configure hawktank"

pvesm set hawktank \
    --content images,rootdir \
    --sparse 1 >/dev/null

pass "hawktank configured."

section "Configure hawkfiles"

# Directory storages cannot have their path modified with pvesm set.
# Only update the content types.

pvesm set hawkfiles \
    --content iso,vztmpl,backup,snippets,import >/dev/null

pass "hawkfiles configured."

section "Current Storage Configuration"

cat /etc/pve/storage.cfg

echo
pvesm status

pass "Module 10 completed successfully."
