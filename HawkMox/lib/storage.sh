#!/usr/bin/env bash

set -Eeuo pipefail

############################################################
# ZFS
############################################################

pool_exists() {

    zpool list -H "$1" >/dev/null 2>&1

}

dataset_exists() {

    zfs list -H "$1" >/dev/null 2>&1

}

ensure_pool() {

    if pool_exists "${POOL_NAME}"
    then
        info "Pool '${POOL_NAME}' already exists."
        return
    fi

    wipefs -af "${APP_DISK}" >/dev/null 2>&1 || true
    sgdisk --zap-all "${APP_DISK}" >/dev/null 2>&1 || true

    zpool create \
        -f \
        -o ashift="${ASHIFT}" \
        -O compression="${COMPRESSION}" \
        -O atime="${ATIME}" \
        -O xattr=sa \
        -O acltype=posixacl \
        -O mountpoint="/${POOL_NAME}" \
        "${POOL_NAME}" \
        "${APP_DISK}"

    success "Created ZFS pool."

}

ensure_file_dataset() {

    if dataset_exists "${POOL_NAME}/${FILE_DATASET}"
    then
        return
    fi

    zfs create \
        -o mountpoint="${FILE_MOUNT}" \
        "${POOL_NAME}/${FILE_DATASET}"

    success "Created file dataset."

}

############################################################
# Directories
############################################################

ensure_storage_dirs() {

    mkdir -p \
        "${ISO_DIR}" \
        "${TEMPLATE_DIR}" \
        "${BACKUP_DIR}" \
        "${SNIPPET_DIR}" \
        "${IMPORT_DIR}"

}

############################################################
# Proxmox Storage
############################################################

storage_exists() {

    pvesm status 2>/dev/null \
        | awk '{print $1}' \
        | grep -qx "$1"

}

remove_storage() {

    local NAME="$1"

    if storage_exists "${NAME}"
    then
        pvesm remove "${NAME}"
        sleep 2
    fi

}

register_zfs_storage() {

    if storage_exists "${ZFS_STORAGE_ID}"
    then
        return
    fi

    pvesm add zfspool "${ZFS_STORAGE_ID}" \
        --pool "${POOL_NAME}" \
        --content images,rootdir \
        --sparse 1 \
        --blocksize 16k

    success "Registered ZFS storage."

}

register_dir_storage() {

    if storage_exists "${DIR_STORAGE_ID}"
    then
        return
    fi

    ensure_storage_dirs

    pvesm add dir "${DIR_STORAGE_ID}" \
        --path "${FILE_MOUNT}" \
        --content iso,vztmpl,backup,snippets,import

    success "Registered directory storage."

}
