#!/bin/bash
# Based on https://github.com/sandeel/i3-new-workspace
# Script occupies free workspace with lowest possible number
# Add -m as an argument to move current container to the next workspace

# Enable strict mode
set -euo pipefail

function show_help {
    echo "USAGE:"
    echo "    i3-new-workspace [OPTIONS]"
    echo
    echo "OPTIONS:"
    echo "    -m, --move   Move current container to the new workspace"
    echo "    -c, --carry  Carry (move and focus) current container to the new workspace"
    echo "    -h, --help   Print help information"
}

# Use swaymsg if WAYLAND_DISPLAY is set
msg_cmd=${WAYLAND_DISPLAY+swaymsg}
msg_cmd=${msg_cmd:-i3-msg}

# Set options
opt_mode=new

# Process CLI arguments
while [ $# -gt 0 ] ; do
    case $1 in
        "--move"|"-m") opt_mode=move ;;
        "--carry"|"-c") opt_mode=carry ;;
        "--help"|"-h"|"-?") show_help ; exit 0 ;;
        *) show_help ; exit 1 ;;
    esac
    shift
done
actual=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).output' | cut -d"\"" -f2)

monitor=$(~/.dotfiles/i3/functions/find-monitor-name.sh $actual)

ws_json=$($msg_cmd -t get_workspaces)
for i in {1..10} ; do
    go=$((i+(10*(monitor-1))))
    [[ $ws_json =~ \"num\":\ ?$go, ]] && continue
    
    case $opt_mode in
        "new") $msg_cmd workspace number "$go" ;;
        "move") $msg_cmd move container to workspace number "$go" ;;
        "carry") $msg_cmd move container to workspace number "$go", workspace number "$go" ;;
    esac
    break
done
