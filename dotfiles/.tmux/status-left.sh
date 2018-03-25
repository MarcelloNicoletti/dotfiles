#!/usr/bin/env bash

# Powerline font glyphs
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
TMUX_STATUS_LEFT_LENGTH="$1"
TMUX_STATUS_BG="$2"
TMUX_SESSION_NAME="$3"

# To allow for last divider
TMUX_STATUS_LEFT_LENGTH=$((TMUX_STATUS_LEFT_LENGTH - 4))

# Status values
tmux_status_left=""
cur_size=0
last_bg=""
sections_started=false

# In this file the sections go left to right
# When a section is too long it is truncated for length.
# If it is truncated to only the dividers the whole section disappears
function start_section () {
    tmux_status_left="#[fg=$2,bg=$3$4] $1"
    last_bg="$3"
    cur_size=$((cur_size + ${#1}))

    if [[ $cur_size -ge $TMUX_STATUS_LEFT_LENGTH ]]; then
        end_of_status=$((${#tmux_status_left} - \
                                          (cur_size - TMUX_STATUS_LEFT_LENGTH)))
        tmux_status_left="${tmux_status_left:0:end_of_status}"
        end_sections
    fi
}

function middle_section () {
    cur_size=$((cur_size + 3))
    if [[ $cur_size -ge $TMUX_STATUS_LEFT_LENGTH ]]; then
        end_sections
    fi

    if [[ $last_bg = "$3" ]]; then
        tmux_status_left="$tmux_status_left #[none]$PL_RIGHT"
    else
        tmux_status_left="$tmux_status_left #[fg=$last_bg,bg=$3,none]\
$PL_RIGHT_BLACK"
    fi

    tmux_status_left="$tmux_status_left#[fg=$2,bg=$3$4] $1"
    last_bg="$3"
    cur_size=$((cur_size + ${#1}))

    if [[ $cur_size -ge $TMUX_STATUS_LEFT_LENGTH ]]; then
        end_of_status=$((${#tmux_status_left} - \
                                          (cur_size - TMUX_STATUS_LEFT_LENGTH)))
        tmux_status_left="${tmux_status_left:0:end_of_status}"
        end_sections
    fi
}

function end_sections () {
    if [[ $last_bg = "$TMUX_STATUS_BG" ]]; then
        tmux_status_left="$tmux_status_left #[none]$PL_RIGHT"
    else
        tmux_status_left="$tmux_status_left \
#[fg=$last_bg,bg=$TMUX_STATUS_BG,none]$PL_RIGHT_BLACK"
    fi

    echo "$tmux_status_left "
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

new_section "$TMUX_SESSION_NAME" "colour0" "colour9" ",bold"
new_section "$(whoami)@$(hostname -s)" "colour0" "colour7"

# This is needed to finalize the last divider
end_sections
