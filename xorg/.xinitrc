#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# stop monitor from sleeping
xset -dpms
xset s off

#keyboard layout
setxkbmap -layout us,gb -option grp:shift_shift_toggle

# set networktable screen
xinput map-to-output 15 HDMI-0

xrandr --output LVDS-0 --auto --output HDMI-0 --auto --left-of LVDS-0 --output DP-3 --auto --left-of HDMI-0

# switch on numlock
numlockx &

# launch i3
exec i3
#exec gnome-session
