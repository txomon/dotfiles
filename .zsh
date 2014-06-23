# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="random"
#ZSH_THEME="robbyrussell"
THEMES_FILE="$HOME/.omz-themes"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOCONNECT=false
# Plugins to be used
plugins=(
  autoenv,
  colored-man
  colorize
  compleat
  copydir
  copyfile
  cp
  dircycle
  encode64
  extract
  hsi
  supervisor
  tmux
  tmuxinator
  urltools
  vundle
  web-search
  docker
  git
  github
  go
  rvm
  python
  debian
  themes
  history
  git-extras)

source $ZSH/oh-my-zsh.sh

zstyle ':omz:module:tmux' auto-start 'yes'
