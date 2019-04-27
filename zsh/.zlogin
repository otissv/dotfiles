#~/.zlogin

# run start x
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- vt1 &> /dev/null

# Walpaper
nitrogen --restore

# exit terminal when startx stops running
while [ "$(pidof startx)" != true ]
do
  exit
done
