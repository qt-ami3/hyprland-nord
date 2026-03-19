#!/bin/bash

CURRENT=$(powerprofilesctl get)

case "$1" in
    toggle)
        if [ "$CURRENT" = "balanced" ]; then
            powerprofilesctl set power-saver
        else
            powerprofilesctl set balanced
        fi
        ;;
    *)
        if [ "$CURRENT" = "balanced" ]; then
            echo " "
        else
            echo ""
        fi
        ;;
esac
