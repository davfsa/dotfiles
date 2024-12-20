#!/usr/bin/env bash
# https://github.com/devadathanmb/hyprland-smart-borders
# Based on commit 283fb47b939d146b3b05c65358b51c1d28284b34

set -euo pipefail
IFS=$'\n\t'

function handle {
    if [[ ${1:0:10} == "openwindow" ]]
    then
        window_id=$(echo $1 | cut --delimiter ">" --fields=3 | cut --delimiter "," --fields=1)
        workspace_id=$(echo $1 | cut --delimiter ">" --fields=3 | cut --delimiter "," --fields=2)
        if [[ $workspace_id == "special" ]]
        then
            workspace_id=-99
        fi

        grounded=$(hyprctl clients -j | jq ".[] | select(.workspace.id == $workspace_id and .floating == false) | .address")
        grounded_count=$(wc -l <<< "$grounded")

        floating_status=$(hyprctl clients -j | jq ".[] | select(.address == \"0x$window_id\" ) | .floating" )
        if [[ $floating_status == "true" ]]
        then
            hyprctl dispatch setprop address:0x$window_id noborder 0 >/dev/null
            return
        fi

        if [[ $grounded_count -eq 1 ]]
        then
            hyprctl dispatch setprop address:0x$window_id noborder 1 >/dev/null
        elif [[ $grounded_count -eq 2 ]]
        then
            for address in $grounded
            do
                if [[ "$address" != "$window_id" ]]; then
                    hyprctl dispatch setprop address:$(echo $address | xargs) noborder 0 >/dev/null
                fi
            done
        fi

    elif [[ ${1:0:10} == "movewindow" ]]
    then
        echo $1
        window_id=$(echo $1 | cut --delimiter ">" --fields=3 | cut --delimiter "," --fields=1)
        workspace_id=$(echo $1 | cut --delimiter ">" --fields=3 | cut --delimiter "," --fields=2)

        # Sepcial workspaces have an id of -99, they need to be handled separately
        if [[ $workspace_id == "special" ]]
        then
            workspace_id=-99
        fi

        grounded=$(hyprctl clients -j | jq ".[] | select(.workspace.id == $workspace_id and .floating == false) | .address")
        grounded_count=$(wc -l <<< "$grounded")

        if [[ $grounded_count -eq 1 ]]
        then
            # Check if the current window is floating and then set the border accordingly
            floating_status=$(hyprctl clients -j | jq ".[] | select(.address == \"0x$window_id\" ) | .floating" )
            if [[ $floating_status == "false" ]]
            then
                hyprctl dispatch setprop address:0x$window_id noborder 1 >/dev/null
            else
                hyprctl dispatch setprop address:0x$window_id noborder 0 >/dev/null
                return
            fi
        elif [[ $grounded_count -eq 2 ]]
        then
            for address in $grounded
            do
                if [[ "$address" != "$window_id" ]]; then
                    hyprctl dispatch setprop address:$(echo $address | xargs) noborder 0 >/dev/null
                fi
            done
        fi

        # Handle all the other workspaces with only one window
        single_window_workspaces=$(hyprctl workspaces -j | jq '.[] | select(.windows == 1)' | jq ".id")
        for workspace in $single_window_workspaces
        do
            window=$(hyprctl clients -j | jq ".[] | select(.workspace.id == $workspace) | .address")
            hyprctl dispatch setprop address:$(echo $window | xargs) noborder 1 >/dev/null
        done

    elif [[ ${1:0:11} == "closewindow" ]]
    then
        workspace_id=$(hyprctl activewindow -j | jq ".workspace.id")

        grounded=$(hyprctl clients -j | jq ".[] | select(.workspace.id == $workspace_id and .floating == false) | .address")
        grounded_count=$(wc -l <<< "$grounded")

        if [[ $grounded_count -eq 1 ]]
        then
            window_id=$(hyprctl activewindow -j | jq -r ".address")
            floating_status=$(hyprctl activewindow -j | jq ".floating")
            if [[ $floating_status == "false" ]]
            then
                hyprctl dispatch setprop address:$window_id noborder 1 >/dev/null
            else
                hyprctl dispatch setprop address:$window_id noborder 0 >/dev/null
                return
            fi
        fi

    elif [[ ${1:0:18} == "changefloatingmode" ]]
    then
        floating_status=$(echo $1 | cut --delimiter ">" --fields 3 | cut --delimiter "," --fields 2)
        window_id=$(echo $1 | cut --delimiter ">" --fields 3 | cut --delimiter "," --fields 1)

        workspace_id=$(hyprctl activewindow -j | jq ".workspace.id")

        grounded=$(hyprctl clients -j | jq ".[] | select(.workspace.id == $workspace_id and .floating == false) | .address")
        grounded_count=$(wc -l <<< "$grounded")

        if [[ $floating_status -eq 1 ]]
        then
            hyprctl dispatch setprop address:0x$window_id noborder 0 >/dev/null
        fi

        if [[ $grounded_count -eq 1 ]]
        then
            hyprctl dispatch setprop address:$(echo $grounded | xargs) noborder 1 >/dev/null
        elif [[ $grounded_count -eq 2 ]]
        then
            for address in $grounded
            do
                if [[ "$address" != "$window_id" ]]; then
                    hyprctl dispatch setprop address:$(echo $address | xargs) noborder 0 >/dev/null
                fi
            done
        fi
    fi
}

# Socket directory has changed in Hyprland v0.40.0
# socat - UNIX-CONNECT:/tmp/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock | while read line; do handle $line; done
socat -U - UNIX-CONNECT:$(echo $XDG_RUNTIME_DIR)/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock | while read line; do handle $line; done
