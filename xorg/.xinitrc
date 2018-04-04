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

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

# switch on numlock
numlockx &

#usb automount
udiskie &

# mutple monitors
intel-virtual-output &
# launch i3
exec i3
#exec gnome-session
