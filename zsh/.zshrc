#~/.zshrc

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory nomatch notify
unsetopt autocd beep extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/ninja/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Promot
autoload -U promptinit
promptinit
prompt adam2

# Paths
export PATH=$PATH:/usr/bin/
eval "$(rbenv init -)"

# S/PDIF output
amixer -c 0 cset name='IEC958 Playback Switch' on

# Alias
alias rc='clear && source ~/.zshrc'
alias c='clear'
alias r='source ~/.zshrc'
alias z='nano ~/.zshrc'
alias l='ls -lah'
alias cd.='cd ..'
alias cd..='cd ..'
alias cd~='cd ~'
alias jx='journalctl -xe'
alias j='journalctl'
alias qm='~/dotfiles/applications/quick-menu.sh'
alias mr='sudo nano /etc/pacman.d/mirrorlist'
alias lg='sudo nano /etc/locale.gen'
alias h 'nano /etc/hostname'
alias f 'sudo nano/etc/fstab'

alias rm='trash-put'
alias tl='trash-list'
alias tr='restore-trash'

alias a='atom .'
alias wm='sudo wifi-menu wlp4s0'
alias sf='screenfetch'
alias p='pcmanfm'
alias sp='sudo pcmanfm'

function tc {
  touch $1
}

# git
alias gp='git push origin master'
alias gs='git status'
alias gd='git diff'

function ga {
  git add "$1"
}

function gc {
  git commit -m "$1"
}

# clear console
clear

# pacman
alias pi='pacman -Q'
alias psy='sudo pacman -Sy'
alias psu='sudo pacman -Syu'
function ps {
  sudo pacman -S $1
}

function pr {
  sudo pacman -R $1
}
