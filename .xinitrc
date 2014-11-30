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

#keyboard layout
setxkbmap -layout gb,us -variant ,dvorak -option grp:shift_shift_toggle

# switch on numlock
# numlockx must be installed
numlockx &

# hides mouse cursor when nit in use
#unclutter &

# launch i3
exec i3
