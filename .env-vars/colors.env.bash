if [ "$TERM" = "linux" ]; then
  function solarized_dark {
    echo -en "\e]P0002832" # ANSI 0  Black
    echo -en "\e]P1dc322f" # ANSI 1  Red
    echo -en "\e]P2859900" # ANSI 2  Green
    echo -en "\e]P3b58900" # ANSI 3  Yellow
    echo -en "\e]P4268bd2" # ANSI 4  Blue
    echo -en "\e]P5d33682" # ANSI 5  Magenta
    echo -en "\e]P62aa198" # ANSI 6  Cyan
    echo -en "\e]P7839496" # ANSI 7  White
    echo -en "\e]P8073642" # ANSI 8  Bright Black
    echo -en "\e]P9dc322f" # ANSI 9  Bright Red
    echo -en "\e]PA859900" # ANSI 10 Bright Green
    echo -en "\e]PBb58900" # ANSI 11 Bright Yellow
    echo -en "\e]PC268bd2" # ANSI 12 Bright Blue
    echo -en "\e]PDd33682" # ANSI 13 Bright Magenta
    echo -en "\e]PE2aa198" # ANSI 14 Bright Cyan
    echo -en "\e]PF93a1a1" # ANSI 15 Bright White
  }
  function solarized_light {
    echo -en "\e]P0faf3e0" # ANSI 0  Black
    echo -en "\e]P1dc322f" # ANSI 1  Red
    echo -en "\e]P2859900" # ANSI 2  Green
    echo -en "\e]P3b58900" # ANSI 3  Yellow
    echo -en "\e]P4268bd2" # ANSI 4  Blue
    echo -en "\e]P5d33682" # ANSI 5  Magenta
    echo -en "\e]P62aa198" # ANSI 6  Cyan
    echo -en "\e]P7657b83" # ANSI 7  White
    echo -en "\e]P8eee8d5" # ANSI 8  Bright Black
    echo -en "\e]P9dc322f" # ANSI 9  Bright Red
    echo -en "\e]PA859900" # ANSI 10 Bright Green
    echo -en "\e]PBb58900" # ANSI 11 Bright Yellow
    echo -en "\e]PC268bd2" # ANSI 12 Bright Blue
    echo -en "\e]PDd33682" # ANSI 13 Bright Magenta
    echo -en "\e]PE2aa198" # ANSI 14 Bright Cyan
    echo -en "\e]PF586e75" # ANSI 15 Bright White
  }
fi
