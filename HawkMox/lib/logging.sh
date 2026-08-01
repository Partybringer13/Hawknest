#!/usr/bin/env bash

set -Eeuo pipefail

LOG_FILE="${LOG_FILE:-/var/log/hawkmox.log}"

RED="${RED:-\033[0;31m}"
GREEN="${GREEN:-\033[0;32m}"
YELLOW="${YELLOW:-\033[1;33m}"
BLUE="${BLUE:-\033[0;34m}"
NC="${NC:-\033[0m}"

timestamp() {

    date '+%F %T'

}

log_raw() {

    echo "$(timestamp) $*" >> "${LOG_FILE}"

}

info() {

    echo -e "${BLUE}[INFO]${NC} $*"

    log_raw "[INFO] $*"

}

success() {

    echo -e "${GREEN}[PASS]${NC} $*"

    log_raw "[PASS] $*"

}

warning() {

    echo -e "${YELLOW}[WARN]${NC} $*"

    log_raw "[WARN] $*"

}

error() {

    echo -e "${RED}[FAIL]${NC} $*"

    log_raw "[FAIL] $*"

}

die() {

    error "$*"

    exit 1

}

pass() {

    success "$@"

}
