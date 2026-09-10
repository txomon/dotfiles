use direnv

set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~
set edit:insert:binding[Ctrl-F] = $edit:-instant:start~

eval (starship init elvish)

set-env CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional

eval (carapace _carapace|slurp)
eval (zoxide init elvish | slurp)

fn cd.. { cd .. }
fn cd... { cd ../.. }
fn cd.... { cd ../../.. }

# One file per module that wants a function here, numbered like udev rules.
# A fragment cannot define a name in this scope, so it calls edit:add-var,
# the same way lib/direnv.elv reaches into $edit:before-readline.
for f [(order [@rcd@/*[nomatch-ok].elv])] {
  eval (slurp < $f)
}
