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

# Alias
alias r='source ~/.zshrc'
alias l='ls -lah'
alias c='claer'
alias cd.='cd ..'
alias cd..='cd ..'
alias cd~='cd ~'
alias x='cd /mnt/files'
alias pi='pacman -Q'

alias a='atom .'
alias rg='ranger'
alias wm='sudo wifi-menu wlp4s0'
alias wf='sudo netgui'
alias sf='screenfetch'

alias gp='git push origin master'
alias gs='git status'
alias gd='git diff'
alias ga='git add .'
