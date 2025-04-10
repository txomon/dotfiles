use epm

use direnv
use tfenv

set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~
set edit:insert:binding[Ctrl-F] = $edit:-instant:start~

set paths = [~/bin ~/go/bin $@paths]

eval (starship init elvish)

set-env CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional

eval (carapace _carapace|slurp)
eval (zoxide init elvish | slurp)
