source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
   echo "
 ██████╗  █████╗ ███╗   ███╗███████╗██╗  ██╗
██╔════╝ ██╔══██╗████╗ ████║██╔════╝╚██╗██╔╝
██║  ███╗███████║██╔████╔██║█████╗   ╚███╔╝ 
██║   ██║██╔══██║██║╚██╔╝██║██╔══╝   ██╔██╗ 
╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██╔╝ ██╗
 ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝                                                                                                                                                                   
"
end


fish_add_path $HOME/.local/bin


set -U fish_history_max 0

# Bookmarks
abbr dot "cd ~/dotfiles; lt"
abbr p "cd ~/Projects; lt"
abbr w "cd ~/Work; lt"
abbr yogini "cd ~/Work/yogini/; lt"
abbr cms "cd ~/Projects/365-cms; lt"

# Editor
set EDITOR "nvim"
set VISUAL "code"

# Reload
abbr rc "source ~/.config/fish/config.fish"
abbr clear "clear"


abbr cd "z"
abbr cd. "z .."
abbr cd.. "z .."
abbr cd~ "z ~"
abbr mkdir "mkdir -p"

abbr mntc "cd /mnt/c"
abbr mntd "cd /mnt/d"
abbr mnte: "cd /mnt/e"

# Tmux
abbr ts tmux new -s
abbr tsp tmux new -s $PWD
abbr ta tmux attach -t
abbr tp tmux attach -t $PWD

# Nginx
abbr ngstart "sudo /etc/init.d/nginx start"
abbr ngstop "sudo /etc/init.d/nginx stop"
abbr ngr "sudo /etc/init.d/nginx restart"

# NPM
abbr npms "clear; npm start"
abbr npmd "clear; npm run dev"
abbr npmt "clear; npm test"
abbr npmw "clear; npm run watch"
abbr npmtw "clear; npm run test:watch"
abbr npmts "clear; npm run test:spec"
abbr npmtc "clear; npm run test --coverage"
abbr npml "clear; npm run lint"
abbr npmlw "clear; npm run lint:watch"
abbr npmb "clear; npm run build"
abbr npmpub "clear; npm publish"

# abbr ncu "npx npm-check-updates"
abbr ncuu "npx npm-check-updates -u"

#Misc
abbr killnode "killall node"
abbr myip "curl https://ipinfo.io/ip"
abbr rsync "rsync -avhP"

# Bytesafe
abbr bytsafe "npm publish --registry https://otis.bytesafe.dev/r/default/"

# Curl into directory
# function curl
#     cd ~/Downloads; { curl -O $argv ; cd -; }∫
# end

# Remove to trash
function rm
    trash $argv
end

# Create file
function tc
    touch $argv
end

# Grid list
function ls
    eza -g --group-directories-first --icons $argv
end

# Grid list all
function la
    eza -g -a --group-directories-first --icons $argv
end

# Long list
function ll
    eza -h -g -l -a --group-directories-first --color=always --icons $argv
end

# Long list git repos
function llg
    eza -h -g -l -a --group-directories-first --git-repos --color=always --icons $argv
end

# Long list directories
function ld
    eza -h -g -l -a --only-dirs --show-symlinks --group-directories-first -icons $argv
end

# Long list directories git repos
function ldg
    eza -h -g -l -a --only-dirs --show-symlinks --group-directories-first --git-repos --icons $argv
end

# Long list directories
function lf
    eza -h -a -g -l --only-files --group-directories-first --icons $argv
end

# Long list directories git repos
function lf
    eza -h -a -g -l --only-files --group-directories-first --git-repos --icons $argv
end

# Tree list
function lt
    eza -a --group-directories-first --icons --tree --level 2 $argv
end

#  Long list tree
function llt
    eza -h -g -l -a --group-directories-first -icons --tree --level 2 --git-ignore $argv
end


zoxide init fish | source

# PATHS
# set -U PATH $PATH: /usr/local/bin
set -U PATH $PATH: /$USER/local/bin
set -U PATH $PATH: /$USER/.local/bin
set -U PATH $PATH: /$USER/bin
set -U NNN_FIFO /tmp/nnn.fifo
set -U NNN_PLUG_DEFAULT "p:preview-tui;"
set -U NNN_TRASH n
set -U NNN_TMPFILE '/tmp/.lastd'
set -U BYTESAFE_TOKEN '01FCBJWGDEFAZWVR1TGHF1YB0T'

set -U SPLIT "v"

set -gx GTK_THEME Orchis-Pink-Dark:dark
set -gx GTK_ICON_THEME Vimix
set -gx QT_QPA_PLATFORMTHEME gtk3
set -gx BROWSER zen-browser
set -gx TERM kitty

set -x N_PREFIX "$HOME/n"; contains "$N_PREFIX/bin" $PATH; or set -a PATH "$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

set -gx GOROOT "$HOME/.g/go"
set -gx G_MIRROR "https://golang.google.cn/dl/"

# Go setup (fish)

# Where Go-managed binaries and workspace live
set -gx GOPATH "$HOME/go"

# If you use voidint/g (the `g` version manager)
set -gx GOROOT "$HOME/.g/go"

# Add Go tools to PATH
fish_add_path "$HOME/.g/bin"
fish_add_path "$GOROOT/bin"
fish_add_path "$GOPATH/bin"

# pnpm
set -gx PNPM_HOME "/home/ninja/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/ninja/.lmstudio/bin
# End of LM Studio CLI section

# fnm
if type -q fnm
  fnm env --use-on-cd | source
end

# chezmoi sync
function dotsync
    # Capture changes to managed files
    chezmoi re-add; or return 1

    # Stage changes
    chezmoi git -- add -A; or return 1

    # Check whether there's anything to commit
    if test -n "$(chezmoi git -- status --porcelain)"
        chezmoi git -- commit -m "Update dotfiles (date '+%Y-%m-%d %H:%M')"; or return 1
    else
        echo "No changes to commit."
    end

    # Push to remote
    #chezmoi git -- push; or return 1

    echo "Dotfiles synchronized successfully."
end
