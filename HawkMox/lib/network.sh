#!/usr/bin/env bash

set -Eeuo pipefail

gateway() {

    ip route \
        | awk '/default/ {print $3; exit}'

}

check_gateway() {

    local GW

    GW="$(gateway)"

    [[ -n "${GW}" ]] || die "No default gateway."

    info "Gateway : ${GW}"

    ping -c2 -W2 "${GW}" >/dev/null

}

check_internet() {

    ping -c2 -W2 1.1.1.1 >/dev/null

}
