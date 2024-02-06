use epm

epm:install &silent-if-installed github.com/href/elvish-gitstatus
use github.com/href/elvish-gitstatus/gitstatus

use direnv
use prompt

set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~
set edit:insert:binding[Ctrl-F] = $edit:-instant:start~

# for f (ls ~/.env-vars/*.env)  {
#    source $f
# }

set paths = [~/bin ~/.tfenv/bin $@paths]
