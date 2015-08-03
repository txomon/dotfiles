# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

export ANTIGEN_DEFAULT_REPO_URL='https://github.com/txomon/oh-my-zsh/'

source $HOME/.antigen-git/antigen.zsh

HIST_STAMPS="yyyy-mm-dd"

antigen use oh-my-zsh

antigen bundle colored-man
antigen bundle colorize
antigen bundle compleat
antigen bundle copydir
antigen bundle copyfile
antigen bundle cp
antigen bundle dircycle
antigen bundle encode64
antigen bundle extract
antigen bundle hsi
antigen bundle supervisor

ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOCONNECT=true
ZSH_TMUX_AUTOQUIT=false
antigen bundle tmux
antigen bundle tmuxinator
antigen bundle urltools
antigen bundle vundle
antigen bundle web-search
antigen bundle docker
antigen bundle git
antigen bundle github
antigen bundle go
antigen bundle rvm
antigen bundle python
antigen bundle themes
antigen bundle history
antigen bundle git-extras

antigen theme random

antigen apply


# Plugins to be used
#
# source $ZSH/oh-my-zsh.sh
#
# zstyle ':omz:module:tmux' auto-start 'yes'
#
# autoload -U compinit
# compinit
# setopt completealiases
