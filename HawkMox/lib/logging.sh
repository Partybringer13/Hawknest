#!/usr/bin/env bash

set -Eeuo pipefail

LOG_FILE="${LOG_FILE:-/tmp/hawkmox.log}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

timestamp() {
    date "+%F %T"
}

log_raw() {
    echo "$(timestamp) $*" >> "$LOG_FILE"
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

# ------------------------------------------------------------------
# Compatibility aliases (old HawkMox modules)
# ------------------------------------------------------------------

pass() {
    success "$@"
}

warn() {
    warning "$@"
}

fail() {
    error "$@"
}

die() {
    fail "$@"
    exit 1
}
