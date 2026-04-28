#!/usr/bin/env bash

polybar_toggle() {
    local toggle="$1"

    start() {
        nohup polybar top >/dev/null 2>&1 &
        disown
    }

    stop() {
        pkill -x polybar
    }

    if [[ "$toggle" == "true" ]]; then
        # TOGGLE
        if pgrep -x polybar >/dev/null; then
            stop
        else
            start
        fi
    else
        # FORCE RESTART
        stop
        while pgrep -x polybar >/dev/null; do
            sleep 0.2
        done
        start
    fi
}

polybar_toggle $@
