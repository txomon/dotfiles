#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set_colors()
{
	local base03="002b36"
	local base02="073642"
	local base01="586e75"
	local base00="657b83"
	local base0="839496"
	local base1="93a1a1"
	local base2="eee8d5"
	local base3="fdf6e3"
	local yellow="b58900"
	local orange="cb4b16"
	local red="dc322f"
	local magenta="d33682"
	local violet="6c71c4"
	local blue="268bd2"
	local cyan="2aa198"
	local green="859900"

	echo -en "\e]P0${base02}" #black
	echo -en "\e]P8${base03}" #brblack
	echo -en "\e]P1${red}" #red
	echo -en "\e]P9${orange}" #brred
	echo -en "\e]P2${green}" #green
	echo -en "\e]PA${base01}" #brgreen
	echo -en "\e]P3${yellow}" #yellow
	echo -en "\e]PB${base00}" #bryellow
	echo -en "\e]P4${blue}" #blue
	echo -en "\e]PC${base0}" #brblue
	echo -en "\e]P5${magenta}" #magenta
	echo -en "\e]PD${violet}" #brmagenta
	echo -en "\e]P6${cyan}" #cyan
	echo -en "\e]PE${base1}" #brcyan
	echo -en "\e]P7${base2}" #white
	echo -en "\e]PF${base3}" #brwhite
	clear #for background artifacting
}

if [ "$TERM" = "linux" ]; then
	set_colors
fi

unset -f set_colors

if [[ "x$TMUX" =~ "x" ]]; then
	tmux attach || tmux
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000000
HISTFILESIZE=200000000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# we want color
color_prompt=yes

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH=~/bin:$PATH

# Load computer specific env variables
if [ -f "$HOME/.env" ]; then
    . "$HOME/.env"
fi

# Load general configuration
if [ -d "$HOME/.env-vars/" ]; then
	for f in `find $HOME/.env-vars/ -name '*.env' -or -name '*.env.bash'`; do
		. $f
	done
fi

