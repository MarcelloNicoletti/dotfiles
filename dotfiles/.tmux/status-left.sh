#!/usr/bin/env bash

# Powerline font glyhps
POWERLINE_ENABLE=true
PL_RIGHT_BLACK=$(printf "\\uE0B0")
PL_RIGHT=$(printf "\\uE0B1")
PL_LEFT_BLACK=$(printf "\\uE0B2")
PL_LEFT=$(printf "\\uE0B3")

if [[ $POWERLINE_ENABLE = false ]]; then
    PL_RIGHT_BLACK=$(printf "\\u2551")
    PL_RIGHT=$(printf "\\u2502")
    PL_LEFT_BLACK=$(printf "\\u2551")
    PL_LEFT=$(printf "\\u2502")
fi

# tmux values
LEFT_STATUS_LENGTH=$(tmux display -p "#{status-left-length}")
LEFT_STATUS_LENGTH=$((LEFT_STATUS_LENGTH - 4)) # To allow for last divider
STATUS_BG=$(tmux display -p "#{status-bg}")
TMUX_SESSION="$1"

# Status values
tmux_status_left=""
cur_size=0
last_bg=""
sections_started=false

# In this file the sections go left to right
# When a section is too long it is truncated for length.
# If it is tuncated to only the dividers the whole section disappears
function start_section () {
    tmux_status_left="#[fg=$2,bg=$3$4] $1"
    last_bg="$3"
    cur_size=$((cur_size + ${#1}))

    if [[ $cur_size -ge $LEFT_STATUS_LENGTH ]]; then
        end_of_status=$((${#tmux_status_left} - \
                                          (cur_size - LEFT_STATUS_LENGTH)))
        tmux_status_left="${tmux_status_left:0:end_of_status}"
        end_sections
    fi

    tmux_status_left="$tmux_status_left#[none]"
}

function middle_section () {
    cur_size=$((cur_size + 3))
    if [[ $cur_size -ge $LEFT_STATUS_LENGTH ]]; then
        end_sections
    fi

    if [[ $last_bg = "$3" ]]; then
        tmux_status_left="$tmux_status_left $PL_RIGHT"
    else
        tmux_status_left="$tmux_status_left #[fg=$last_bg,bg=$3]$PL_RIGHT_BLACK"
    fi

    tmux_status_left="$tmux_status_left#[fg=$2,bg=$3$4] $1"
    last_bg="$3"
    cur_size=$((cur_size + ${#1}))

    if [[ $cur_size -ge $LEFT_STATUS_LENGTH ]]; then
        end_of_status=$((${#tmux_status_left} - \
                                          (cur_size - LEFT_STATUS_LENGTH)))
        tmux_status_left="${tmux_status_left:0:end_of_status}"
        end_sections
    fi

    tmux_status_left="$tmux_status_left#[none]"
}

function end_sections () {
    if [[ $last_bg = "$STATUS_BG" ]]; then
        tmux_status_left="$tmux_status_left $PL_RIGHT "
    else
        tmux_status_left="$tmux_status_left \
#[fg=$last_bg,bg=$STATUS_BG]$PL_RIGHT_BLACK "
    fi

    echo "$tmux_status_left#[none]"
    exit 0
}

function new_section () {
    if [ -z "$1" ]; then
        return
    fi

    if [[ $sections_started = false ]]; then
        sections_started="t"
        start_section "$1" "$2" "$3" "$4"
    else
        middle_section "$1" "$2" "$3" "$4"
    fi
}

# Sections: new_section 1 2 3 4
# Argument order for sections
#     1 Contents, section skipped if empty
#     2 Foreground colour, eg colour0-255, 8 colour palette names, #ffffff
#     3 Background colour, see foreground
#     4 Extra formatting attributes starting with comma, eg ,bold

new_section "$TMUX_SESSION" "colour0" "colour9" ",bold"
new_section "$(whoami)@$(hostname -s)" "colour0" "colour7"

# This is needed to finalize the last divider
end_sections
