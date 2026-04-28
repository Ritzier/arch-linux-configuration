#!/usr/bin/env bash

BAT="/sys/class/power_supply/BAT1"
AC="/sys/class/power_supply/ADP1"

[[ -d "$BAT" ]] || {
    echo "No battery"
    exit 0
}

capacity=$(<"$BAT/capacity")
status=$(<"$BAT/status")
online=0
[[ -f "$AC/online" ]] && online=$(<"$AC/online")

if ((capacity <= 10)); then
    icon=""
    color="%{F#ff5c57}"
elif ((capacity <= 25)); then
    icon=""
    color="%{F#ffb86c}"
elif ((capacity <= 50)); then
    icon=""
    color="%{F#f1fa8c}"
elif ((capacity <= 75)); then
    icon=""
    color="%{F#8be9fd}"
else
    icon=""
    color="%{F#a6e3a1}"
fi

case "$status" in
Charging)
    prefix=" "
    ;;
Full)
    prefix=" "
    ;;
Discharging)
    prefix=""
    ;;
*)
    prefix=" ?"
    ;;
esac

if [[ "$online" == "1" && "$status" == "Not charging" ]]; then
    prefix=" "
fi

echo "${color}${prefix} ${icon} ${capacity}%%{F-}"
