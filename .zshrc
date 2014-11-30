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
alias x='cd /mnt/files'
alias j='journalctl -xe'



alias a='atom .'
alias rg='ranger'
alias wm='sudo wifi-menu wlp4s0'
alias wf='sudo netgui'
alias sf='screenfetch'
alias p='pcmanfm'
alias sp='sudo pcmanfm'

alias pi='pacman -Q'
alias psy='sudo pacman -Sy'
alias psu='sudo pacman -Syu'

alias gp='git push origin master'
alias gs='git status'
alias gd='git diff'
alias ga='git add .'

# clear console
clear
