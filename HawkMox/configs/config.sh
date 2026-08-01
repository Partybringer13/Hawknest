#!/usr/bin/env bash

############################################################
# HawkMox Configuration
############################################################

#
# Storage
#

BOOT_DISK="/dev/mmcblk0"
APP_DISK="/dev/sda"

POOL_NAME="hawktank"

VM_DATASET="vmstore"

FILE_DATASET="hawkfiles"

FILE_MOUNT="/srv/hawkmox"

#
# Proxmox Storage IDs
#

ZFS_STORAGE_ID="hawktank"

DIR_STORAGE_ID="hawkfiles"

#
# ZFS
#

ASHIFT="12"

COMPRESSION="lz4"

ATIME="off"

AUTOTRIM="on"

#
# Directories
#

ISO_DIR="${FILE_MOUNT}/iso"

TEMPLATE_DIR="${FILE_MOUNT}/templates"

BACKUP_DIR="${FILE_MOUNT}/backups"

SNIPPET_DIR="${FILE_MOUNT}/snippets"

IMPORT_DIR="${FILE_MOUNT}/import"

#
# Cluster
#

CLUSTER_NAME="HawkCluster"
CLUSTER_MASTER_IP="192.168.1.10"

#
# Logging
#

LOG_FILE="/var/log/hawkmox.log"

#
# Colors
#

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"
