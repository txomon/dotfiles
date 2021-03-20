use math
use re

# Colours are used with the next into account:
# * ANSI colour compatibility
# * Gnome terminal compatibility
# * Dark/Light theme compatibility
#
# In whatever theme you are using Colour 0 and 8 (black and bright black in ANSI) should
#  be whatever the normal text is coloured with
#
# Colours 7 and 15 (white and bright white in ANSI) should NEVER be used.

last-cmd-start-time = 0
last-cmd-end-time = 0

fn now {
  put (date +%s%2N)
}

fn after-readline-hook [cmd]{
  set last-cmd-start-time = (now)
}

fn before-readline-hook {
  set last-cmd-end-time = (now)
}

fn prompt-username {
  set user = (whoami)
  if (==s $user "root") {
    put (styled "root" red)
  }
  put (styled $user green)
}

fn prompt-hostname {
  put (styled (hostname) black)
}

fn prompt-date {
  put (styled (date -u '+%Y-%m-%dT%H:%M:%SZ') yellow)
}

fn prompt-pwd {
  set dir-length = 3
  set dir = (tilde-abbr $pwd)
  short-dir = (re:replace '(\.?[^/]{'$dir-length'})[^/]*/' '$1/' $dir)
  put (styled $short-dir green)
}

fn ts-diff [end start]{
  delta = (- $end $start)

  milis = (% $delta 100)

  _seconds = (math:floor (/ $delta 100 ))
  seconds = (% $_seconds 60)
  final_time = $seconds.$milis
  _minutes = (math:floor (/ $_seconds 60))
  if (== $_minutes 0 ) {
    put $final_time
    return
  }

  minutes = (% $_minutes 60)
  final_time = $minutes"m"$final_time
  _hours = (math:floor (/ $_minutes 60))
  if (== $_hours 0 ) {
    put $final_time
    return
  }

  hours = (% $_hours 60)
  final_time = $hours"h"$final_time
  _days = (math:floor (/ $_hours 60))
  if (== $_days 0) {
    put $final_time
    return
  }

  days = (% $_days 24)
  put $days"d"$final_time
}

fn prompt-times {
  put (styled (ts-diff $last-cmd-end-time $last-cmd-start-time) cyan)
}

fn prompt-status {
  put ""
}

fn prompt-git {
  put ""
}


fn init {
  last-cmd-start-time = (now)
  set _prompt-username = (prompt-username)
  set _prompt-hostname = (prompt-hostname)
  edit:prompt = {
    print (prompt-date)" "(prompt-times)" "$_prompt-username"@"$_prompt-hostname" "(prompt-pwd)(prompt-git)(prompt-status)"$ "
  }
  edit:rprompt = { print ( date -u '+=>%Y-%m-%dT%H:%M:%SZ' -d "@"$last-cmd-end-time[0..-2] ) }
  set edit:after-readline = [$@edit:after-readline $after-readline-hook~]
  set edit:before-readline = [$@edit:before-readline $before-readline-hook~]
  set edit:-prompt-eagerness = 10
  last-cmd-end-time = (now)
}

init
