fish_vi_key_bindings

source $HOME/.config/fish/solarized.fish

# Load general configuration
if test -d "$HOME/.env-vars/"
        for f in (find $HOME/.env-vars/ -name '*.env' -or -name '*.env.fish')
                source $f
        end
	set -q f
end

