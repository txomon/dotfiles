# set PATH so it includes user's private bin if it exists
if test -d "$HOME/bin"
    set PATH "$HOME/bin" $PATH
end
alias serve='python3 -m http.server'
