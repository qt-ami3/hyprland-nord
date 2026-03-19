#!/bin/bash

CURRENT=$(hyprctl monitors -j | jq -r '.[] | select(.name == "eDP-1") | "\(.width)x\(.height)"')

case "$1" in
    toggle)
        if [ "$CURRENT" = "3840x2400" ]; then
            hyprctl keyword monitor "eDP-1,1920x1200,0x0,1.0,bitdepth,12"
        else
            hyprctl keyword monitor "eDP-1,3840x2400,0x0,1.6,bitdepth,12"
        fi
        ;;
    *)
        if [ "$CURRENT" = "3840x2400" ]; then
            echo "4K"
        else
            echo "FHD"
        fi
        ;;
esac
