#!/usr/bin/env bash

source "$HOME/.tmux/glyphs.sh"

#tmux values
TMUX_STATUS_LEFT_LENGTH="$1"
TMUX_STATUS_RIGHT_LENGTH="$2"
TMUX_CLIENT_WIDTH="$3"
TMUX_STATUS_BG="$4"

max_width=$((TMUX_CLIENT_WIDTH - TMUX_STATUS_LEFT_LENGTH - 10))

if [[ $TMUX_STATUS_RIGHT_LENGTH -lt "$max_width" ]]; then
    max_width="$TMUX_STATUS_RIGHT_LENGTH"
fi
if [[ $max_width -le 4 ]]; then
    exit 0
fi

# Status values
tmux_status_right=""
cur_size=0
last_fg=""
last_bg=""
sections_started=false

# Strips Tmux color commands to get the actual content length once displayed
# This doesn't expand tmux expressions ${}
function content_size () {
    local stripped="$(echo "$1" | perl -pe "s/\#\[.*?\]//g")"
    if [ -x /usr/local/bin/gwc ]; then
        # gnu wc (brew installed as gwc) has -L for max line length
        #  this accounts for "full width" characters in unicode
        echo "$stripped" | /usr/local/bin/gwc -L
    else
        echo "${#stripped}"
    fi
}

# In this file the sections go right to left. There is no truncation outside the
# starting section. If the section is too long it simply disappears
function start_section () {
    tmux_status_right="#[fg=$2,bg=$3$4] $1 "
    last_fg="$2"
    last_bg="$3"
    cur_size=$((cur_size + $(content_size "$1") + 3))

    if [[ $cur_size -ge $max_width ]]; then
        # Note: Don't end the starting section with formatting or it
        # risks getting truncated
        end_of_status=$((${#tmux_status_right} - (cur_size - max_width) - 2))
        tmux_status_right="${tmux_status_right:0:end_of_status} "
        end_sections
    fi
}

function middle_section () {
    local content
    local estimate
    estimate="$5"
    if [[ $((cur_size + estimate + 3)) -ge $max_width ]]; then
        return
    fi

    content="$(eval "echo \"$1\"")"
    if [ -z "$content" ]; then
        return
    fi

    cur_size=$((cur_size + $(content_size "$content") + 3))
    if [[ $cur_size -gt $max_width ]]; then
        end_sections
    fi

    if [[ $last_bg = "$3" ]]; then
        tmux_status_right="#[fg=$last_fg,bold]$PL_LEFT#[none]$tmux_status_right"
    else
        tmux_status_right="#[fg=$last_bg,bg=$3,none]$PL_LEFT_BLACK\
$tmux_status_right"
    fi
    tmux_status_right="#[fg=$2,bg=$3$4] $content $tmux_status_right"

    last_fg="$2"
    last_bg="$3"
}

function end_sections () {
    if [[ $last_bg = "$TMUX_STATUS_BG" ]]; then
        tmux_status_right="#[fg=$last_fg,bold]$PL_LEFT#[none]$tmux_status_right"
    else
        tmux_status_right="#[fg=$last_bg,bg=$TMUX_STATUS_BG,none]\
$PL_LEFT_BLACK$tmux_status_right"
    fi

    echo " $tmux_status_right"
    exit 0
}

function new_section () {
    # 1 Contents, or content template
    # 2 Foreground colour
    # 3 Background colour
    # 4 Extra formatting or blank if no extra formatting but 5th argument
    # 5 Estimate of length of evaluated template

    if [ -z "$1" ]; then
        return
    fi

    if [[ $sections_started = false ]]; then
        sections_started="t"
        start_section "$(eval "echo \"$1\"")" "$2" "$3" "$4"
    else
        middle_section "$1" "$2" "$3" "$4" "$5"
    fi
}

# Extra Calculations

# Magic number 28 is from the two date sections
# TODO: Figure out why something that is too big for 120 still dissapears on 262
# For example with magic number of 25 while playing Polygondwanaland
np_w="$(( max_width - 28 ))"

# Sections: new_section 1 2 3 4
# Argument order for sections
#     1 Contents, section skipped if empty,
#         lazy evaluates templates (if using single quotes)
#     2 Foreground colour, eg colour0-255, 8 colour palette names, #ffffff
#     3 Background colour, see foreground
#     4 Extra formatting attributes starting with comma, eg ",bold"
#     5 Estimate of length of evaluated template
#         needs 4th argument even if no extra formatting
#         use 0 or omit to force template evaluation
#         Evaluated template is still checked for length
#         so estimate can safely be too small

# new_sec   content                           fgColour   bgColour  extra    est
new_section '$(date +"%l:%M %p")'             "colour0"  "colour3"  ",bold" "11"
new_section '$(date +"%a %b %d")'             "colour0"  "colour6"  ""      "10"
new_section "\$(~/.tmux/nowplaying.sh $np_w)" "colour0"  "colour2"  ""   "$np_w"
new_section '$(~/.tmux/battery.sh)'           "default"  "colour0"  ""      "07"

# This is needed to finalize the last divider
end_sections

