#!/usr/bin/env bash

set -Eeuo pipefail

timestamp() {
    date "+%F %T"
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
