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

#tmux values
LEFT_STATUS_LENGTH=$(tmux display -p "#{status-left-length}")
RIGHT_STATUS_LENGTH=$(tmux display -p "#{status-right-length}")
CLIENT_WIDTH="$1"
STATUS_BG=$(tmux display -p "#{status-bg}")

max_width=$((CLIENT_WIDTH - LEFT_STATUS_LENGTH - 10))

if [[ $RIGHT_STATUS_LENGTH -lt "$max_width" ]]; then
    max_width="$RIGHT_STATUS_LENGTH"
fi
if [[ $max_width -le 4 ]]; then
    exit 0
fi

# Status values
tmux_status_right=""
cur_size=0
last_bg=""
sections_started=false

# In this file the sections go right to left. There is no truncation outside the
# starting section. If the section is too long it simply dissapears
function start_section () {
    tmux_status_right="#[fg=$2,bg=$3$4] $1 "
    last_bg="$3"
    cur_size=$((cur_size + ${#1} + 3))

    if [[ $cur_size -ge $max_width ]]; then
        end_of_status=$((${#tmux_status_right} - (cur_size - max_width) - 2))
        tmux_status_right="${tmux_status_right:0:end_of_status} "
        end_sections
    fi
}

function middle_section () {
    cur_size=$((cur_size + ${#1} + 3))
    if [[ $cur_size -ge $max_width ]]; then
        end_sections
    fi

    if [[ $last_bg = "$3" ]]; then
        tmux_status_right="#[none]$PL_LEFT$tmux_status_right"
    else
        tmux_status_right="#[fg=$last_bg,bg=$3,none]$PL_LEFT_BLACK\
$tmux_status_right"
    fi
    tmux_status_right="#[fg=$2,bg=$3$4] $1 $tmux_status_right"

    last_bg="$3"
}

function end_sections () {
    if [[ $last_bg = "$STATUS_BG" ]]; then
        tmux_status_right="$PL_LEFT$tmux_status_right"
    else
        tmux_status_right="#[fg=$last_bg,bg=$STATUS_BG]$PL_LEFT_BLACK\
$tmux_status_right"
    fi

    echo " $tmux_status_right"

    exit 0
}

function new_section () {
    # 1 Contents
    # 2 Forground colour
    # 3 Background colour
    # 4 Extra formatting

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

new_section "$(date +"%l:%M %p %Z")" "colour0" "colour3" ",bold"
new_section "$(date +"%a %b %d")" "colour0" "colour6"
new_section "$(eval ~/.tmux/battery.sh)" "colour7" "colour0"

# This is needed to finalize the last divider
end_sections

