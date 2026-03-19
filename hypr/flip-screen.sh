#!/bin/bash
CURRENT=$(hyprctl monitors -j | python3 -c "import sys,json; print(next(x['transform'] for x in json.load(sys.stdin) if x['name']=='eDP-1'))")
if [ "$CURRENT" = "2" ]; then
    hyprctl keyword monitor eDP-1,3840x2400,0x0,1.6,transform,0,bitdepth,12
else
    hyprctl keyword monitor eDP-1,3840x2400,0x0,1.6,transform,2,bitdepth,12
fi
