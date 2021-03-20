use epm

epm:install &silent-if-installed github.com/href/elvish-gitstatus
use github.com/href/elvish-gitstatus/gitstatus

use direnv
use prompt

set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~
