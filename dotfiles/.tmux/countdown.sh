#!/usr/local/bin/bash

start=$(date +%s)
end=$(date -j -f "%c %z" "$1" "+%s")
duration="$(( end - start ))"

function displaytime {
    # Conditionalize this more, Shorter output for longer time away
    # EG: 30 days to ... vs 30 days 12 hours 3 minutes to ...
    # but then 7 days 12 hours to ... and so on
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    if [[ $D -gt 7 ]]; then
        printf "%dd to %s\\n" "$D" "$2"
    elif [[ $D -gt 0 ]]; then
        printf "%dd %02dh to %s\\n" "$D" "$H" "$2"
    elif [[ $H -gt 0 ]]; then
        printf "%02dh %02dm to %s\\n" "$H" "$M" "$2"
    elif [[ $M -gt 0 ]]; then
        printf "%02dm %02ds to %s\\n" "$M" "$S" "$2"
    elif [[ $S -gt 0 ]]; then
        printf "%02ds to %s\\n" "$S" "$2"
    else
        printf "%s is done!\\n" "$2"
    fi
}

displaytime "$duration" "$2"
