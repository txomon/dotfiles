use epm
use os

use direnv
use tfenv

set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~
set edit:insert:binding[Ctrl-F] = $edit:-instant:start~

var extra-paths = [~/bin ~/go/bin ~/node/bin]
var append-paths = [~/.pyenv/shims]
set paths = [(each {|p| if (os:is-dir $p) { put $p }} $extra-paths) $@paths (each {|p| if (os:is-dir $p) { put $p }} $append-paths)]

eval (starship init elvish)

set-env CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional

eval (carapace _carapace|slurp)
eval (zoxide init elvish | slurp)

fn open {|@a| xdg-open $@a }
fn cs {|@a| claude --dangerously-skip-permissions $@a }
fn chj { sudo chown -R javier: . }
fn atm10-rcon {|@a| ssh -t gandalf 'podman exec -it all-the-mods-10 rcon-cli' $@a }
fn xcc {|@a| xclip -selection clipboard $@a }
fn xcp {|@a| xclip -selection primary $@a }
