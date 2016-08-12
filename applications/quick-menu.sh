#!/bin/bash
yellow="\e[0;93m"
white="\e[0;37m"
active="\e[1;36m"
inactive="\e[0;36m"

# init =====================================================
function quickMenu {
  clear
  loadFiles settings
  settingsMenu
}

function loadFiles {
  #read and print app file
  i=0
  if [[ $1 = apps ]]
    then
    getFiles $1
    IFS=$'\n' apps=($(sort <<<"${tmp[*]}"))
    unset tmp
  else
    getFiles $1
    IFS=$'\n' settings=($(sort <<<"${tmp[*]}"))
    unset tmp
  fi
  ((i++))
}

function getFiles {
  i=1
  while read f; do
    tmp[i]=$f
    ((i++))
  done < $HOME/dotfiles/applications/$1
}

# main menu =====================================================
function mainMenu {
 clear
 echo -e "$1Apps $2Settings $3Help"
 echo -e "$white================================================"
 echo -e "Command\t Action"
 echo -e "$yellow a$white \t \e[1mApps menu"
 echo -e "$yellow s$white \t \e[1mSettings menu"
 echo -e "$yellow h$white \t \e[1mHelp"
 echo -e "$yellow q$white \t \e[1mQuit\n"
}

function getOption {
  echo -e "\n\e[1mExecute: \c"
  read opt
  mainOptions $opt
  if [[ $1 = apps ]]
    then
    appOptions $opt
  else
    settingsOptions $opt
  fi
}

function mainOptions {
  case "$1" in
    a)
    appsMenu
    ;;
    s)
    settingsMenu
    ;;
    h)
    echo help
    ;;
    q)
    exit 0
    ;;
    *)
  esac
}

# app menu =========================================================
function appsMenu {
  mainMenu $active $inactive $inactive

  echo -e "\n\e[0m Chrome Apps"
  echo -e "$yellow 1\t $white\e[1mFacebook"
  echo -e "$yellow 2\t $white\e[1mMessenger"
  echo -e "$yellow 3\t $white\e[1mTweetDeck"
  getOption "apps"
}

function appOptions {
  case "$1" in
    1)
    echo "hello"
    exec deskopen /home/ninja/Desktop/facebook.desktop
    ;;
    2)
    exec deskopen /home/ninja/Desktop/facebook.desktop
    ;;
    3)
    exec deskopen /home/ninja/Desktop/facebook.desktop
    ;;
    *)
  esac
}

# settings menu =====================================================
function settingsMenu {
  mainMenu $inactive $active $inactive

  echo -e "\n\e[0m Display settings"
  echo -e "$yellow 10\t $white\e[1mBuilt-in only"
  echo -e "$yellow 11\t $white\e[1mHDMI only"
  echo -e "$yellow 12\t $white\e[1mExtended"
  echo -e "$yellow 13\t $white\e[1mCloned"
  echo -e "$yellow 14\t $white\e[1mGraphics settings"

  echo -e "\n\e[0m Keyboard settings"
  echo -e "$yellow 21\t $white\e[1mUS"
  echo -e "$yellow 22\t $white\e[1mGB"
  echo -e "$yellow 23\t $white\e[1mPL"

  echo -e "\n\e[0m Network settings"
  echo -e "$yellow 30\t $white\e[1mBluetooth"
  echo -e "$yellow 31\t $white\e[1mWifi"

  echo -e "\n\e[0m Sound settings"
  echo -e "$yellow 40\t $white\e[1mMixer"

  echo -e "\n\e[0m System settings"
  echo -e "$yellow 90\t $white\e[1mTop"
  echo -e "$yellow 99\t $white\e[1mConfiguration files"

  getOption settings
}

function settingsOptions {
  case "$1" in
    10)
    exec xrandr --output LVDS-0 --auto --output HDMI-0 --off
    ;;
    11)
    exec terminator -x xrandr --output LVDS-0 --off --output HDMI-0 --auto
    ;;
    12)
    exec terminator -x xrandr --output LVDS-0 --auto --output HDMI-0 --auto --left-of LVDS-0 --output DP-3 --auto --left-of HDMI-0
    ;;
    13)
    exec terminator -x xrandr  --output LVDS-0 --auto --output HDMI-0--auto
    ;;
    14)
    exec nvidia-settings
    ;;
    21)
    exec setxkbmap us
    ;;
    22)
    exec setxkbmap gb
    ;;
    23)
    exec setxkbmap pl
    ;;
    30)
    exec blue-manager
    ;;
    31)
    exec terminator -x sudo wifi-menu
    ;;
    10)
    exec pavucontrol
    ;;
    90)
    exec terminator -x htop
    ;;
    99)
    (atom ~/dotfiles/read.md&> /dev/null &)
    ;;
    *)
  esac
}

# start =====================================================
quickMenu
