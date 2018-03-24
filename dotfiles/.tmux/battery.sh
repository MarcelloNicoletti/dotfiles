#!/usr/local/bin/bash

# All of these functions are taken from the tmux-plugins/tmux-battery repo on
# github https://github.com/tmux-plugins/tmux-battery.

# helpers.sh
get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value="$(tmux show-option -gqv "$option")"
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

is_osx() {
    [ $(uname) == "Darwin" ]
}

is_chrome() {
    chrome="/sys/class/chromeos/cros_ec"
    if [ -d "$chrome" ]; then
        return 0
    else
        return 1
    fi
}

command_exists() {
    local command="$1"
    type "$command" >/dev/null 2>&1
}

battery_status() {
    if command_exists "pmset"; then
        pmset -g batt | awk -F '; *' 'NR==2 { print $2 }'
    elif command_exists "upower"; then
        local battery
        battery=$(upower -e | grep -m 1 battery)
        upower -i $battery | awk '/state/ {print $2}'
    elif command_exists "acpi"; then
        acpi -b | awk '{gsub(/,/, ""); print tolower($3); exit}'
    elif command_exists "termux-battery-status"; then
        termux-battery-status | jq -r '.status' | awk '{printf("%s%", tolower($1))}'
    fi
}

# battery_percentage.sh
print_battery_percentage() {
    # percentage displayed in the 2nd field of the 2nd row
    if command_exists "pmset"; then
        pmset -g batt | grep -o "[0-9]\{1,3\}%"
    elif command_exists "upower"; then
        local battery=$(upower -e | grep -m 1 battery)
        if [ -z "$battery" ]; then
            return
        fi
        local energy
        local energy_full
        energy=$(upower -i $battery | awk -v nrg="$energy" '/energy:/ {print nrg+$2}')
        energy_full=$(upower -i $battery | awk -v nrgfull="$energy_full" '/energy-full:/ {print nrgfull+$2}')
        if [ -n "$energy" ] && [ -n "$energy_full" ]; then
            echo $energy $energy_full | awk '{printf("%d%%", ($1/$2)*100)}'
        fi
    elif command_exists "acpi"; then
        acpi -b | grep -m 1 -Eo "[0-9]+%"
    elif command_exists "termux-battery-status"; then
        termux-battery-status | jq -r '.percentage' | awk '{printf("%d%%", $1)}'
    fi
}

# battery_graph.sh
print_graph() {
    if [ -z "$1" ]; then
        echo ""
    elif [ "$1" -lt "20" ]; then
        echo "▁"
    elif [ "$1" -lt "40" ]; then
        echo "▂"
    elif [ "$1" -lt "60" ]; then
        echo "▃"
    elif [ "$1" -lt "80" ]; then
        echo "▅"
    else
        echo "▇"
    fi
}

# battery_icon.sh

get_icon() {
    local status="$1"
    if [[ $status =~ (charged) ]] || [[ $status =~ (finishing) ]]; then
        echo " ✓ "
    elif [[ $status =~ (^charging) ]]; then
        echo " ↑ "
    elif [[ $status =~ (^discharging) ]]; then
        echo " ↓ "
    elif [[ $status =~ (attached) ]]; then
        echo " ↕ "
    fi
}

main() {
    local percentage=$(print_battery_percentage | sed "s/%//")
    local status=$(battery_status)
    local graph=$(print_graph "$percentage")
    local icon=$(get_icon "$status")

    echo "$percentage%$icon$graph"
}
main
