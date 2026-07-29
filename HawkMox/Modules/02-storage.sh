#!/usr/bin/env bash
#
# HawkMox
# Module 02 - Storage Provisioning
# Version 1.0
#

set -Eeuo pipefail

###########################################
# Colors
###########################################

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

PASS="${GREEN}[PASS]${RESET}"
FAIL="${RED}[FAIL]${RESET}"
INFO="${BLUE}[INFO]${RESET}"
WARN="${YELLOW}[WARN]${RESET}"

###########################################

die() {
    echo -e "${FAIL} $1"
    exit 1
}

###########################################
# Root
###########################################

[[ $EUID -eq 0 ]] || die "Run as root."

###########################################
# Verify Proxmox
###########################################

command -v pvesm >/dev/null || die "Proxmox not detected."
command -v sgdisk >/dev/null || die "sgdisk missing."
command -v pvcreate >/dev/null || die "lvm2 not installed."

###########################################
# Detect boot disk
###########################################

ROOTDEV=$(findmnt -n -o SOURCE /)
ROOTDISK=$(lsblk -no pkname "${ROOTDEV}" | head -1)

BOOTDISK="/dev/${ROOTDISK}"

###########################################
# Detect SSD
###########################################

SSDDISK=""

while read -r DEV TYPE SIZE
do

    [[ "$TYPE" != "disk" ]] && continue

    [[ "$DEV" == "$ROOTDISK" ]] && continue

    [[ "$DEV" =~ ^mmcblk ]] && continue
    [[ "$DEV" =~ ^loop ]] && continue
    [[ "$DEV" =~ ^sr ]] && continue

    SSDDISK="/dev/${DEV}"

done < <(lsblk -dn -o NAME,TYPE,SIZE)

[[ -n "$SSDDISK" ]] || die "No SSD found."

###########################################
# Banner
###########################################

clear

echo
echo "====================================================="
echo " HawkMox Storage Provisioning"
echo "====================================================="
echo

echo "Boot Disk : ${BOOTDISK}"
echo "SSD       : ${SSDDISK}"

echo
echo "THIS WILL DESTROY ALL DATA ON ${SSDDISK}"
echo

read -rp "Type YES to continue: " CONFIRM

[[ "$CONFIRM" == "YES" ]] || exit 0

###########################################
# Remove swap
###########################################

echo
echo "Removing swap..."

swapoff -a || true

if lvdisplay /dev/pve/swap >/dev/null 2>&1
then
    lvremove -fy /dev/pve/swap
fi

sed -i '\|swap|d' /etc/fstab

echo -e "${PASS} Swap removed"

###########################################
# Remove local-lvm
###########################################

echo
echo "Removing local-lvm..."

if pvesm status | grep -q "^local-lvm"
then
    pvesm remove local-lvm || true
fi

if lvdisplay /dev/pve/data >/dev/null 2>&1
then
    lvremove -fy /dev/pve/data
fi

echo -e "${PASS} local-lvm removed"

###########################################
# Wipe SSD
###########################################

echo
echo "Preparing SSD..."

wipefs -af "${SSDDISK}"

sgdisk --zap-all "${SSDDISK}"

###########################################
# Create GPT
###########################################

echo
echo "Creating GPT..."

sgdisk \
    -n 1:1MiB:0 \
    -t 1:8E00 \
    -c 1:"app-storage" \
    "${SSDDISK}"

partprobe "${SSDDISK}" || true
udevadm settle

PART="${SSDDISK}1"

[[ -b "$PART" ]] || die "Partition was not created."

###########################################
# Create PV
###########################################

echo
echo "Creating Physical Volume..."

pvcreate -ff -y "${PART}"

###########################################
# Create VG
###########################################

echo
echo "Creating Volume Group..."

vgcreate appvg "${PART}"

###########################################
# Create Thin Pool
###########################################

echo
echo "Creating Thin Pool..."

lvcreate \
    -l 90%VG \
    -T appvg/app-storage

###########################################
# Enable discard
###########################################

echo
echo "Enabling discard..."

lvchange --discard passdown appvg/app-storage

###########################################
# Register Storage
###########################################

echo
echo "Registering Proxmox Storage..."

if ! grep -q "^lvmthin: app-storage" /etc/pve/storage.cfg
then

cat >> /etc/pve/storage.cfg <<EOF

lvmthin: app-storage
        thinpool app-storage
        vgname appvg
        content images,rootdir
EOF

fi

###########################################
# Enable weekly TRIM
###########################################

echo
echo "Enabling TRIM..."

systemctl enable fstrim.timer
systemctl start fstrim.timer

###########################################
# Summary
###########################################

echo
echo "====================================================="
echo " Storage Summary"
echo "====================================================="
echo

echo "Volume Groups"

vgs

echo

echo "Logical Volumes"

lvs

echo

echo "Storage"

pvesm status

echo

echo "Block Devices"

lsblk

echo
echo -e "${PASS} Storage provisioning complete."

echo
echo "Next step:"
echo "Run Module 03."
