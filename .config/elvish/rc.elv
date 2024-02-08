use epm

use direnv
use tfenv

set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~
set edit:insert:binding[Ctrl-F] = $edit:-instant:start~

set paths = [~/bin $@paths]

eval (starship init elvish)
