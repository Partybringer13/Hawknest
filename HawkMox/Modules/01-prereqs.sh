#!/usr/bin/env bash
#
# HawkMox
# Module 01
#
# Verifies this machine is suitable for provisioning.
#

set -Eeuo pipefail

SCRIPT_VERSION="1.0.0"

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

echo
echo "==========================================="
echo " HawkMox Provisioning"
echo " Prerequisite Verification"
echo " Version ${SCRIPT_VERSION}"
echo "==========================================="
echo

############################################################
# Root
############################################################

[[ $EUID -eq 0 ]] || die "Must be run as root."

echo -e "${PASS} Running as root"

############################################################
# Proxmox
############################################################

command -v pvesm >/dev/null \
    || die "Proxmox VE not detected."

echo -e "${PASS} Proxmox detected"

############################################################
# Detect hardware
############################################################

MODEL=$(tr -d '\0' </sys/class/dmi/id/product_name)

echo
echo "Detected Hardware"

echo "  ${MODEL}"

case "$MODEL" in
    *5070*)
        PLATFORM="wyse5070"
        ;;

    *3000*)
        PLATFORM="optiplex3000"
        ;;

    *)
        PLATFORM="generic"
        ;;
esac

echo "Platform: ${PLATFORM}"

############################################################
# Detect boot device
############################################################

ROOTDEV=$(findmnt -n -o SOURCE /)

ROOTDISK=$(lsblk -no pkname "${ROOTDEV}" | head -1)

BOOTDISK="/dev/${ROOTDISK}"

echo
echo "Boot Device"

echo "  ${BOOTDISK}"

############################################################
# Find candidate storage devices
############################################################

echo
echo "Scanning disks..."

mapfile -t DISKS < <(
lsblk -dn -o NAME,SIZE,TYPE |
awk '$3=="disk"{print $1,$2}'
)

SSD=""

for entry in "${DISKS[@]}"; do

    DEV=$(echo "$entry" | awk '{print $1}')

    if [[ "$DEV" == "$ROOTDISK" ]]; then
        continue
    fi

    if [[ "$DEV" =~ ^mmcblk ]]; then
        continue
    fi

    if [[ "$DEV" =~ ^loop ]]; then
        continue
    fi

    if [[ "$DEV" =~ ^sr ]]; then
        continue
    fi

    SIZE=$(lsblk -dn -o SIZE "/dev/${DEV}")

    echo "Candidate SSD: /dev/${DEV} (${SIZE})"

    SSD="/dev/${DEV}"

done

[[ -n "$SSD" ]] || die "No application SSD detected."

echo
echo -e "${PASS} Application SSD detected"

echo "  ${SSD}"

############################################################
# Cluster
############################################################

echo
echo "Checking cluster membership..."

if pvecm status >/dev/null 2>&1; then

    if pvecm status | grep -q "Nodes:"; then

        die "Node is already joined to a cluster."

    fi

fi

echo -e "${PASS} Node is standalone"

############################################################
# Summary
############################################################

echo
echo "=========================================="

echo "Platform : ${PLATFORM}"
echo "Boot Disk: ${BOOTDISK}"
echo "SSD      : ${SSD}"

echo "=========================================="

echo
echo -e "${GREEN}Prerequisites Passed${RESET}"

echo

export HAWKMOX_PLATFORM="${PLATFORM}"
export HAWKMOX_BOOTDISK="${BOOTDISK}"
export HAWKMOX_SSD="${SSD}"
