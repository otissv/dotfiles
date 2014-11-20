#!/bin/sh



case "$1" in
  US)
  echo LANG=en_US.UTF-8 > /etc/locale.cof
    ;;
  GB)
  echo LANG=en_GB.UTF-8 > /etc/locale.cof
    ;;
  *)
esac

exit 0
