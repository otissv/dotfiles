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
alias p='cd ~/projects'
alias pc='cd ~/projects/express-starter'
alias dot='cd ~/dotfiles'
alias a='atom .'
alias wm='sudo wifi-menu wlp4s0'
alias sf='screenfetch'
alias fm='pcmanfm'
alias sfm='sudo pcmanfm'
alias http='httpster'

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



function tc {
  touch $1
}

function mkcd {
  mkdir $1 && cd $1
}

# git
alias gp='git push origin master'
alias gr='git reset --soft HEAD~1'
alias gs='git status'
alias gd='git diff'
alias gh='git push heroku master'

function ga {
  case $1 in
    -m)
      git add $3;
      git commit -m $2;
      ;;
    *)
    git add $1;
    ;;
  esac  
}

function gc {
  git commit -m $1
}

function gb {
    case $1 in
      -b)
        git checkout -b $2;
        ;;
      -c)
        git checkout $2;
        ;;
      -d)
        git branch -d $2;
        ;;
      -l)
        git branch;
        ;;
      -m)
        git merge $2;
        ;;
      -v)
        git branch -v;
        ;;
      *)
        echo -e "Usage: gb <command>\n"
        echo -e "gb -b\tcreate and immediately switch to a branch"
        echo -e "gb -c\tswitched to a new branch"
        echo -e "gb -d\tdelete a branch"
        echo -e "gb -l\tlist your available branches"
        echo -e "gb -m\tmerge a branch context into current one"
        echo -e "gb -v\tsee the last commit on each branch"
        echo -e "\n* beside a branch name indicates the branch as the   currently checkour branch"
        echo "\n~/.zshrc"
        ;; 
    esac   
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

#
function crm {
  google-chrome-stable $1 
}

#Vagrant aliases
#alias vcd ='cd ~/vagrant'
alias vdir="cd $HOME/vagrant"
alias vinit='vagrant init hashicorp/precise32'
alias vup='vagrant up'
alias vssh='vagrant ssh'
alias vssh='vagrant up && vagrant ssh'
alias vreload='vagrant reload && vagrant ssh'
alias vhalt='vagrant halt'

#Rails
alias rbower-init='rails g bower_rails:initialize json'
alias rbower='rake bower:install'