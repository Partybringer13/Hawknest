#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 04 - Register Proxmox Storage"

############################################################
# Verify
############################################################

pool_exists "${POOL_NAME}" \
    || die "ZFS pool '${POOL_NAME}' does not exist."

dataset_exists "${POOL_NAME}/${VM_DATASET}" \
    || die "Dataset '${VM_DATASET}' missing."

dataset_exists "${POOL_NAME}/${FILE_DATASET}" \
    || die "Dataset '${FILE_DATASET}' missing."

############################################################
# Create directory structure
############################################################

section "Creating directory structure"

mkdir -p "${ISO_DIR}"
mkdir -p "${TEMPLATE_DIR}"
mkdir -p "${BACKUP_DIR}"
mkdir -p "${SNIPPET_DIR}"
mkdir -p "${IMPORT_DIR}"

success "Directory structure verified."

############################################################
# Remove default local storage
############################################################

section "Removing default local storage"

if storage_exists local; then

    pvesm remove local

    success "Removed default local storage."

else

    info "Default local storage already removed."

fi

############################################################
# Register ZFS Storage
############################################################

section "Registering ZFS storage"

if storage_exists "${ZFS_STORAGE_ID}"; then

    info "${ZFS_STORAGE_ID} already exists."

else

    pvesm add zfspool "${ZFS_STORAGE_ID}" \
        --pool "${POOL_NAME}/${VM_DATASET}" \
        --content images,rootdir \
        --blocksize 16k \
        --sparse 1

    success "Registered ${ZFS_STORAGE_ID}"

fi

############################################################
# Register Directory Storage
############################################################

section "Registering directory storage"

if storage_exists "${DIR_STORAGE_ID}"; then

    info "${DIR_STORAGE_ID} already exists."

else

    pvesm add dir "${DIR_STORAGE_ID}" \
        --path "${FILE_MOUNT}" \
        --content iso,vztmpl,backup,snippets,import

    success "Registered ${DIR_STORAGE_ID}"

fi

############################################################
# Verification
############################################################

section "Storage Status"

pvesm status

echo

cat /etc/pve/storage.cfg

echo

success "Module 04 completed successfully."
