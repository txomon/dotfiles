# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export PATH=~/bin:$PATH
# Load computer specific env variables
if [ -f "$HOME/.env" ]; then
    . "$HOME/.env"
fi

# Depending on the shell we are running...
# if running bash
if [ -n "$BASH_VERSION" && -n "$PS1" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# Load general configuration
if [ -d "$HOME/.env-vars/" ]; then
    for f in `find $HOME/.env-vars/ -name '*.env'`; do
        . $f
    done
fi

