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
  put (hostname)
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
  git = (gitstatus:query $pwd)
  if (not $git[is-repository]) {
    put ""
    return
  }

  status = " ("
  if (eq $git[local-branch] "") {
      status = $status$git[commit][:8]
  } else {
      status = $status$git[local-branch]
  }
  # show a state indicator
  if (or (> $git[unstaged] 0) (> $git[untracked] 0)) {
      status = $status(styled '*' yellow)
  } elif (> $git[staged] 0) {
      status = $status(styled '*' green)
  } elif (> $git[commits-ahead] 0) {
      status = $status(styled '^' yellow)
  } elif (> $git[commits-behind] 0) {
      status = (styled '⌄' yellow)
  }

  put $status")"
  return
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
