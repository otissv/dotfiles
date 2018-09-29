#~/.zshrc

# Detect OS
source ~/dotfiles/zsh/.os

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory nomatch notify
unsetopt autocd beep extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/ninja/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Prompt setup
source ~/dotfiles/zsh/zshrc-config/.prompt

# Alias and functions
source ~/dotfiles/zsh/zshrc-config/.aliases
source ~/dotfiles/zsh/zshrc-config/.directory-aliases
source ~/dotfiles/zsh/zshrc-config/.git-aliases
source ~/dotfiles/zsh/zshrc-config/.mamp-aliases
source ~/dotfiles/zsh/zshrc-config/.nginx-aliases
source ~/dotfiles/zsh/zshrc-config/.npm-aliases
source ~/dotfiles/zsh/zshrc-config/.pacman-aliases
source ~/dotfiles/zsh/zshrc-config/.rethinkdb-aliases
source ~/dotfiles/zsh/zshrc-config/.trash-aliases
source ~/dotfiles/zsh/zshrc-config/.vagrant-aliases
source ~/dotfiles/zsh/zshrc-config/.yarn-aliases

# Go version manager
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

# OPAM configuration
. /home/ninja/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
