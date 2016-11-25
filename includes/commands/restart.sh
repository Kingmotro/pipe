#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/start.sh"
source "${BASH_SOURCE%/*}/stop.sh"

restart() {
    stop "$@"
    start "$@"
}