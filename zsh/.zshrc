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


# Prompt setup
autoload colors; colors;
export LSCOLORS="Gxfxcxdxbxegedabagacad"
setopt prompt_subst

# prompt
ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
 
# show git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
}
 
# show red star if there are uncommitted changes
parse_git_dirty() {
  if command git diff-index --quiet HEAD 2> /dev/null; then
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  else
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  fi
}
 
# if in a git repo, show dirty indicator + git branch
git_custom_status() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX${git_where#(refs/heads/|tags/)}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}
 
# show current rbenv version if different from rbenv global
rbenv_version_status() {
  local ver=$(rbenv version-name)
  [ "$(rbenv global)" != "$ver" ] && echo "[$ver]"
}
 
# put fancy stuff on the right
if which rbenv &> /dev/null; then
  RPS1='$(git_custom_status)%{$fg[red]%}$(rbenv_version_status)%{$reset_color%} $EPS1'
else
  RPS1='$(git_custom_status) $EPS1'
fi
 
# basic prompt on the left
precmd() { print -rP "[%{$fg[green]%}%n@%m%{$reset_color%}]" }
PROMPT='%{$fg[yellow]%} %~% %(?.%{$fg[green]%}.%{$fg[red]%})%B$%b '



# Paths
export PATH=$PATH:/usr/bin/
export PATH=$PATH:$HOME/bin/
PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
eval "$(rbenv init -)"

#Node Version Manager
source /usr/share/nvm/init-nvm.sh
nvm use 0.12

# S/PDIF output
amixer -c 0 cset name='IEC958 Playback Switch' on

# Alias
alias p='cd ~/projects'
alias pc='cd ~/projects/ui-builder'
alias dot='cd ~/dotfiles'
alias a='atom .'
alias wm='sudo wifi-menu wlp4s0'
alias sf='screenfetch'
alias fm='pcmanfm'
alias sfm='sudo pcmanfm'
alias rc='clear && source ~/.zshrc'
alias c='clear'
alias r='source ~/.zshrc'
alias z='nano ~/.zshrc'
alias l='ls -lah'
alias ld='ls -l | egrep "^d"'
alias lf="ls -l | egrep -v '^d'"
alias lwd='ls -d */'
alias cd.='cd ..'
alias cd..='cd ..'
alias cd~='cd ~'
alias jx='journalctl -xe'
alias j='journalctl'
alias qm='~/dotfiles/applications/quick-menu.sh'
alias mr='sudo nano /etc/pacman.d/mirrorlist'
alias lg='sudo nano /etc/locale.gen'
alias h='nano /etc/hostname'
alias fs='sudo nano /etc/fstab'
alias bs='browser-sync start --server --files "**/*.*"'
alias gulpclone='git clone https://github.com/otissv/gulp.git'

# Trash
alias rm='trash-put'
alias tl='trash-list'
alias rt='restore-trash'

# History
function hist() { if [ -z "$*" ]; then history 1; else history 1 | egrep "$@"; fi; }

# Nginx
alias ngstart='sudo /etc/init.d/nginx start'
alias ngstop='sudo /etc/init.d/nginx stop'
alias ngr='sudo /etc/init.d/nginx restart'

# npm
alias npmi='npm install'
alias npms='npm install --save'
alias npmd='npm install --save-dev'
alias npmu='npm update'
alias npmo='npm outdated'
alias npmi-g='npm install -g'
alias npmu-g='npm update -g'
alias npmo-g='npm outdated -g'

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
    -c)
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
alias ysu='yaourt -Syu --aur'

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
alias vp='vagrant package'
alias vinit='vagrant init ubuntu/trusty64'
alias vssh='vagrant ssh'
alias vup='vagrant up && vagrant ssh'
alias vr='vagrant reload && vagrant ssh'
alias vh='vagrant halt'


#Rails
alias rbower-init='rails g bower_rails:initialize json'
alias rbower='rake bower:install'
