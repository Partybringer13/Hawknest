#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 06 - Network Validation"

############################################################
section "Interface"

ip -br addr

############################################################
section "Gateway"

check_gateway

success "Gateway reachable."

############################################################
section "Internet"

check_internet

success "Internet reachable."

############################################################
section "DNS"

getent hosts download.proxmox.com >/dev/null

success "DNS resolution verified."

############################################################

success "Module 06 completed successfully."
