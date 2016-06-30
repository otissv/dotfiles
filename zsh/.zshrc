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


# S/PDIF output
amixer -c 0 cset name='IEC958 Playback Switch' on



# Alias
alias p='cd ~/work/projects'
alias pc='cd ~/work/projects/react-site-builder'
alias dot='cd ~/dotfiles'
alias a='atom .'
alias s='subl3 .'
alias wm='sudo wifi-menu wlp4s0'
alias sf='screenfetch'
alias fm='ranger'
alias sfm='sudo ranger'
alias rc='clear && source ~/.zshrc'
alias c='clear'
alias r='source ~/.zshrc'
alias z='nano ~/.zshrc'
alias lc='ls --color=always'
alias ll='ls -all --color=always'
alias ld='ls -la --color=always | egrep "^d"'
alias lf='ls -la --color=always | egrep -v '^d''
alias lrt='ls -lrt --color=always'
alias mlwd='ls -d */'
alias mlrt='ls -lrt'
alias mls='ls'
alias mll='ls -all'
alias mld='ls -la | egrep "^d"'
alias mlf='ls -la | egrep -v '^d''
alias mlwd='ls -d */'
alias mlrt='ls -lrt'
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
alias killnode='killall node'
alias ncm='ncmpcpp'
alias apache='sudo systemctl start httpd'
alias w='curl -4 http://wttr.in/Opole'
alias mkdir="mkdir -p"
alias droid="/opt/android-sdk/tools/android avd"
alias www='cd /var/www'
alias htdocs='cd /Applications/MAMP/htdocs'
alias mampsql='/Applications/MAMP/bin/apache2/bin/mysql'
alias mampdump='/Applications/MAMP/bin/apache2/bin/mysqldump'
alias mampphp='/Applications/MAMP/bin/php/php5.6.2/bin/php'

# Run command on all subdirs in dir
function alldir {
  # for D in $1*/; do $($@); done
  # find $1 -maxdepth 1 -type f
  cmd=${@:2};

  find $1 -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && $cmd" \;
}

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
alias npmis='npm install --save'
alias npmid='npm install --save-dev'
alias npmu='npm update'
alias npmo='npm outdated'

alias npmi-g='npm install -g'
alias npmu-g='npm update -g'
alias npmo-g='npm outdated -g'

alias npms='clear && npm start'
alias npmt='clear && npm test'
alias npmtw='clear && npm run test:watch'
alias npmts='clear && npm run test:spec'
alias npml='clear && npm run lint'
alias npmlw='clear && npm run lint:watch'
alias npmw='clear && npm run watch'
alias npmv='clear && npm run server'
alias npmb='clear && npm run build'
alias npmbw='clear && npm run build:watch'
alias npmpub='clear && npm publish'
alias npmalli='clear && alldir . npm install'
alias npmallb='clear && alldir . npm run build'
alias npmallt='clear && alldir . npm run test'
alias npmallu='clear && alldir . ncu upgrade -a'
alias npmd='npm run docs'
alias npmdw='npm run docs:watch'
alias nomalld='clear && npm alldir . npm run docs'


function tc {
  touch $1
}

function mkcd {
  mkdir $1 && cd $1
}

# git
alias gpushm='git push origin master'
alias gpullm='git pull origin master'
alias gpullp='git pull origin gh-pages'
alias gpushp='git push origin gh-pages'
alias gpulld='git pull origin dev'
alias gpushd='git push origin dev'
alias gr='git reset --soft HEAD~1'
alias gs='git status'
alias gd='git diff'


function ga {
  git add $1;
  git commit -m $2;
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

function gremote {
  git remote add origin https://github.com/otissv/${PWD##*/}
}

function grchange {
  git remote set-url origin https://github.com/otissv/${PWD##*/}
}

function gcreate {
  hub create $1
}

function gfetch {
 hub fetch $1
}


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

#react-native aliases
alias rns='react-native start'
alias rna='react-native run-android'
