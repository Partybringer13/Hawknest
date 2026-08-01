#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${PROJECT_ROOT}/lib/common.sh"

header "Module 08 - Node Role Detection"

HOST="$(hostname)"

ROLE="application"

case "${HOST}" in
    HawkMox0)
        ROLE="primary"
        ;;

    HawkMox01)
        ROLE="secondary"
        ;;

    HawkMox*)
        ROLE="application"
        ;;
esac

mkdir -p /etc/hawkmox

cat >/etc/hawkmox/node.conf <<EOF
ROLE=${ROLE}
HOSTNAME=${HOST}
EOF

section "Detected Role"

info "Hostname : ${HOST}"
info "Role     : ${ROLE}"

case "${ROLE}" in
    primary)

        info "Infrastructure node profile."

        ;;

    secondary)

        info "Infrastructure failover profile."

        ;;

    application)

        info "Application node profile."

        ;;
esac

success "Node role assigned."
