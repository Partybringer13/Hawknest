#!/usr/bin/env bash

############################################################
# HawkMox Configuration
############################################################

############################
# Cluster
############################

CLUSTER_NAME="HawkCluster"

# Leave blank to prompt during install
CLUSTER_MASTER_IP=""

############################
# Node Roles
############################

# Hostnames beginning with these prefixes become infrastructure nodes.
INFRA_PREFIXES=(
    "HawkMox0"
)

############################
# Storage
############################

BOOT_DISK="/dev/mmcblk0"
APP_DISK="/dev/sda"

ZFS_POOL="hawktank"
VM_DATASET="${ZFS_POOL}/vmstore"

FILES_DIR="/srv/hawkmox"

ZFS_STORAGE_NAME="hawktank"
FILES_STORAGE_NAME="hawkfiles"

############################
# ZFS
############################

ZFS_ASHIFT=12
ZFS_COMPRESSION="zstd"
ZFS_ATIME="off"
ZFS_XATTR="sa"
ZFS_ACLTYPE="posixacl"
ZFS_DNODESIZE="auto"
ZFS_RECORDSIZE="16K"

############################
# ARC
############################

ARC_MAX_GB=7

############################
# Networking
############################

DNS_SERVER="1.1.1.1"

############################
# Time
############################

USE_CHRONY=true

############################
# Proxmox Repository
############################

USE_PVE_NO_SUBSCRIPTION=true
USE_CEPH_NO_SUBSCRIPTION=true

############################
# Optional Components
############################

INSTALL_OMADA=false
INSTALL_CEPH=false
INSTALL_KSM=true

############################
# Logging
############################

LOG_DIR="/var/log/hawkmox"
REPORT_FILE="/root/hawkmox-report.txt"
