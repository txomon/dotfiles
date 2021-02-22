fish_vi_key_bindings

# Load general configuration
if test -d "$HOME/.env-vars/"
        for f in (find $HOME/.env-vars/ -name '*.env' -or -name '*.env.fish')
                source $f
        end
	set -q f
end

if which direnv
	eval (direnv hook fish)
end

bind \e\[1\;5C forward-word
bind \e\[1\;5D backward-word
bind -M insert \e\[1\;5C forward-word
bind -M insert \e\[1\;5D backward-word
bind -M visual \e\[1\;5C forward-word
bind -M visual \e\[1\;5D backward-word
