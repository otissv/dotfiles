# Paths
export PATH=$PATH:/usr/bin/
export PATH=$PATH:$HOME/bin/
PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
eval "$(rbenv init -)"
export VISUAL="nano"
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
export ANDROID_HOME=/opt/android-sdk
export PATH="$PATH:$HOME/.yarn/bin"
export NODE_ENV=dev
