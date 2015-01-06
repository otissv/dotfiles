#~/.zlogin

#run start x
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx

# exit terminal when startx stops running
while [ "$(pidof startx)" != true ]
do
  exit
done