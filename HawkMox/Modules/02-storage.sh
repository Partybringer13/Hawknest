#!/usr/bin/env bash
#
# HawkMox
# Module 02 - Storage Provisioning
#

set -Eeuo pipefail

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

PASS="${GREEN}[PASS]${RESET}"
FAIL="${RED}[FAIL]${RESET}"
INFO="${BLUE}[INFO]${RESET}"
WARN="${YELLOW}[WARN]${RESET}"

die() {
    echo -e "${FAIL} $1"
    exit 1
}

[[ $EUID -eq 0 ]] || die "Run as root"

BOOTDISK="/dev/mmcblk0"
SSDDISK="/dev/sda"

echo
echo "========================================"
echo " HawkMox Storage Provisioning"
echo "========================================"

############################################################
# Safety Checks
############################################################

[[ -b "$BOOTDISK" ]] || die "Boot disk missing."
[[ -b "$SSDDISK" ]] || die "SSD missing."

echo
echo "Boot Disk : $BOOTDISK"
echo "SSD       : $SSDDISK"

echo
read -rp "Type YES to continue: " CONFIRM

[[ "$CONFIRM" == "YES" ]] || exit 1

############################################################
# Disable Swap
############################################################

echo
echo "Disabling swap..."

swapoff -a || true

lvremove -fy /dev/pve/swap 2>/dev/null || true
lvremove -fy /dev/pve/pve-swap 2>/dev/null || true

sed -i '/swap/d' /etc/fstab

echo -e "${PASS} Swap removed"

############################################################
# Remove local-lvm
############################################################

echo
echo "Removing local-lvm..."

pvesm remove local-lvm 2>/dev/null || true

lvremove -fy /dev/pve/data 2>/dev/null || true
lvremove -fy /dev/pve/pve-data 2>/dev/null || true

lvremove -fy /dev/pve/data_tmeta 2>/dev/null || true
lvremove -fy /dev/pve/data_tdata 2>/dev/null || true

echo -e "${PASS} local-lvm removed"

############################################################
# Wipe SSD
############################################################

echo
echo "Preparing SSD..."

wipefs -af "$SSDDISK"
sgdisk --zap-all "$SSDDISK"

parted -s "$SSDDISK" mklabel gpt
parted -s "$SSDDISK" mkpart primary 1MiB 100%

partprobe "$SSDDISK"

sleep 2

PART="${SSDDISK}1"

############################################################
# Create VG
############################################################

pvcreate "$PART"

vgcreate appvg "$PART"

############################################################
# Create Thin Pool
############################################################

lvcreate \
    -l 90%VG \
    -T appvg/app-storage

############################################################
# Enable discard
############################################################

lvchange --discard passdown appvg/app-storage

############################################################
# Register Storage
############################################################

if ! pvesm status | grep -q '^app-storage'; then

    pvesm add lvmthin app-storage \
        --vgname appvg \
        --thinpool app-storage \
        --content images,rootdir

fi

############################################################
# Enable TRIM
############################################################

systemctl enable fstrim.timer
systemctl start fstrim.timer

############################################################
# Summary
############################################################

echo
echo "========================================"

echo "Current LVM"

vgs

echo

lvs

echo

pvesm status

echo

lsblk

echo
echo -e "${PASS} Storage provisioning complete."
