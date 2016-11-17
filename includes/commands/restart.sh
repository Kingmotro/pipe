#!/usr/bin/env bash

source includes/commands/start.sh
source includes/commands/stop.sh

restart() {
    stop "$@"
    start "$@"
}