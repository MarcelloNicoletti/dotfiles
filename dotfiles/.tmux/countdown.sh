#!/usr/bin/env bash

start="$(date +%s)"
end=0
if [ "$(uname -s)" = "Darwin" ]; then
    end="$(date -j -f "%F %T %z" "$1" "+%s")"
else
    end="$(date -d "$1" "+%s")"
fi
duration="$(( end - start ))"

function displaytime {
    # Conditionalize this more, Shorter output for longer time away
    # EG: 30 days to ... vs 30 days 12 hours 3 minutes to ...
    # but then 7 days 12 hours to ... and so on
    local T="$1"
    local sep="to"

    if [[ $T -lt 0 ]] && [[ $3 ]]; then
        sep="since"
        T="$((T * -1))"
    fi

    local D="$((T / 60 / 60 / 24))"
    local H="$((T / 60 / 60 % 24))"
    local M="$((T / 60 % 60))"
    local S="$((T % 60))"
    if [ "$D" -gt 7 ]; then
        printf "%dd %s %s\\n" "$((D + 1))" "$sep" "$2"
    elif [ "$D" -gt 0 ]; then
        if [ "$H" -gt 0 ]; then
            printf "%dd %02dh %s %s\\n" "$D" "$H" "$sep" "$2"
        else
            printf "%dd %02dm %s %s\\n" "$D" "$M" "$sep" "$2"
        fi
    elif [ "$H" -gt 0 ]; then
        if [ "$M" -gt 0 ]; then
            printf "%02dh %02dm %s %s\\n" "$H" "$M" "$sep" "$2"
        else
            printf "%02dh %02ds %s %s\\n" "$H" "$S" "$sep" "$2"
        fi
    elif [ "$M" -gt 0 ]; then
        printf "%02dm %02ds %s %s\\n" "$M" "$S" "$sep" "$2"
    elif [ "$S" -gt 0 ]; then
        printf "%02ds %s %s\\n" "$S" "$sep" "$2"
    else
        printf "%s is done!\\n" "$2"
    fi
}

displaytime "$duration" "$2" "$3"
