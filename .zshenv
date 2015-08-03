export PATH=~/bin:$PATH

# Load computer specific env variables
if [ -f "$HOME/.env" ]; then
    . "$HOME/.env"
fi

# Load general configuration
if [ -d "$HOME/.env-vars/" ]; then
	for f in `find $HOME/.env-vars/ -name '*.env'`; do
		. $f
	done
fi

if  tty -s ; then
	# include .zsh if it exists
	if [ -f "$HOME/.zsh" ]; then
	    . "$HOME/.zsh"
	fi
fi
