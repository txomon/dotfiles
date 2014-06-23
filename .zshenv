# Load computer specific env variables
if [ -f "$HOME/.env" ]; then
    . "$HOME/.env"
fi

# include .zshrc if it exists
if [ -f "$HOME/.zsh" ]; then
    . "$HOME/.zsh"
fi

# Load general configuration
if [ -d "$HOME/.env-vars/" ]; then
    for f in `find $HOME/.env-vars/ -name '*.env'`; do
        . $f
    done
fi

