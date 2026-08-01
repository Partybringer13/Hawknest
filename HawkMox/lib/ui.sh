#!/usr/bin/env bash

set -Eeuo pipefail

header() {
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
    echo
}

section() {
    echo
    echo "------------------------------------------------------------"
    echo " $1"
    echo "------------------------------------------------------------"
}

confirm() {
    local prompt="${1:-Continue?}"

    read -rp "${prompt} [YES]: " RESPONSE

    [[ "${RESPONSE}" == "YES" ]]
}

pause() {
    read -rp "Press ENTER to continue..."
}

require_root() {
    [[ $EUID -eq 0 ]] || die "This installer must be run as root."
}
