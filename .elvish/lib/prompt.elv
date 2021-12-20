use math
use re
use github.com/href/elvish-gitstatus/gitstatus

set gitstatus:binary = "/usr/share/gitstatus/usrbin/gitstatusd"

# Colours are used with the next into account:
# * ANSI colour compatibility
# * Gnome terminal compatibility
# * Dark/Light theme compatibility
# * Linux VTTY compatibility
#
# By default ANSI 0, ANSI 7, ANSI 8, and ANSI 15 will be background and foreground colours
#  black, white, bright black, bright white respectively. However, never format as any
#  of these 4 colours, or you will get set ups (vtty) in which fg and bg colours are the
#  same because the shell itself relies on the pallete definition. This is not a problem
#  when using other terminal emulators such as gnome, because they have Text, Background,
#  Highlighted Text and Highlighted Background as base colours, and then the palette

var last-cmd-start-time = 0
var last-cmd-end-time = 0

fn now {
  put (date +%s%2N)
}

fn after-readline-hook {|cmd|
  set last-cmd-start-time = (now)
}

fn before-readline-hook {
  set last-cmd-end-time = (now)
}

fn prompt-username {
  var user = (whoami)
  if (==s $user "root") {
    put (styled "root" red)
  }
  put (styled $user green)
}

fn prompt-hostname {
  put (hostname)
}

fn prompt-date {
  put (styled (date -u '+%Y-%m-%dT%H:%M:%SZ') yellow)
}

fn prompt-pwd {
  var dir-length = 3
  var dir_ = (tilde-abbr $pwd)
  var short-dir = (re:replace '(\.?[^/]{'$dir-length'})[^/]*/' '$1/' $dir_)
  put (styled $short-dir green)
}

fn ts-diff {|end start|
  var delta = (- $end $start)

  var milis = (% $delta 100)

  var _seconds = (math:floor (/ $delta 100 ))
  var seconds = (% $_seconds 60)
  var final_time = $seconds.$milis
  var _minutes = (math:floor (/ $_seconds 60))
  if (== $_minutes 0 ) {
    put $final_time
    return
  }

  var minutes = (% $_minutes 60)
  var final_time = $minutes"m"$final_time
  var _hours = (math:floor (/ $_minutes 60))
  if (== $_hours 0 ) {
    put $final_time
    return
  }

  var hours = (% $_hours 60)
  var final_time = $hours"h"$final_time
  var _days = (math:floor (/ $_hours 60))
  if (== $_days 0) {
    put $final_time
    return
  }

  var days = (% $_days 24)
  put $days"d"$final_time
}

fn prompt-times {
  put (styled (ts-diff $last-cmd-end-time $last-cmd-start-time) cyan)
}

fn prompt-status {
  put ""
}

fn prompt-git {
  var git = (gitstatus:query $pwd)
  if (not $git[is-repository]) {
    put ""
    return
  }

  var status = " ("
  if (eq $git[local-branch] "") {
      set status = $status$git[commit][:8]
  } else {
      set status = $status$git[local-branch]
  }
  # show a state indicator
  if (or (> $git[unstaged] 0) (> $git[untracked] 0)) {
      set status = $status(styled '*' yellow)
  } elif (> $git[staged] 0) {
      set status = $status(styled '*' green)
  } elif (> $git[commits-ahead] 0) {
      set status = $status(styled '^' yellow)
  } elif (> $git[commits-behind] 0) {
      set status = (styled '⌄' yellow)
  }

  put $status")"
  return
}


fn init {
  set last-cmd-start-time = (now)
  var _prompt-username = (prompt-username)
  var _prompt-hostname = (prompt-hostname)
  set edit:prompt = {
    print (prompt-date)" "(prompt-times)" "$_prompt-username"@"$_prompt-hostname" "(prompt-pwd)(prompt-git)(prompt-status)"$ "
  }
  set edit:rprompt = { print ( date -u '+=>%Y-%m-%dT%H:%M:%SZ' -d "@"$last-cmd-end-time[0..-2] ) }
  set edit:after-readline = [$@edit:after-readline $after-readline-hook~]
  set edit:before-readline = [$@edit:before-readline $before-readline-hook~]
  set edit:-prompt-eagerness = 10
  set last-cmd-end-time = (now)
}

init
