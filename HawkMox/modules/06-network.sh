#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 06 - Network Baseline"

section "Detecting management interface"

IFACE="$(ip -o -4 route show to default | awk '{print $5}' | head -1)"

[[ -n "$IFACE" ]] || die "Unable to determine management interface."

IPADDR="$(ip -4 -o addr show "$IFACE" | awk '{print $4}')"
GATEWAY="$(ip route | awk '/default/ {print $3; exit}')"

info "Interface : ${IFACE}"
info "Address   : ${IPADDR}"
info "Gateway   : ${GATEWAY}"

section "Checking connectivity"

ping -c2 "${GATEWAY}" >/dev/null

success "Gateway reachable."

ping -c2 1.1.1.1 >/dev/null

success "Internet reachable."

section "Checking DNS"

getent hosts github.com >/dev/null

success "DNS resolution working."

section "Checking time synchronization"

timedatectl show -p NTPSynchronized --value | grep -qi yes \
    || warning "NTP not synchronized."

timedatectl show -p SystemClockSynchronized --value | grep -qi yes \
    || warning "Clock not synchronized."

success "Network validation complete."
