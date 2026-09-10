{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.programs.tmux;

  absDiff = a: b:
    if a > b
    then a - b
    else b - a;

  ## HSL to RGB, integer arithmetic only
  # h is 0..359 degrees, s is 0..100 percent, l is 0..1000 tenths of a percent.
  # The conversion is carried as exact integers over a common denominator of
  # 6000000 and rounded once, at the very end, half up. Nothing truncates on
  # the way.
  #
  #   chroma  (1 - |2L - 1|) * S, over 100000
  #   slope   position within the 60 degree sector, over 60
  #   lift    the usual "m" term, L - chroma/2, over 6000000
  #
  # A channel is lift + chroma * weight: weight 60 for the channel sitting at
  # full chroma, slope for the one ramping across the sector, 0 for the third.
  # lift is never negative, so no intermediate can be either. Every channel is
  # non-decreasing in l, which is what lets solveLightness below bisect.
  hsl = h: s: l:
    let
      sector = h / 60;
      rem = lib.mod h 60;
      slope =
        if lib.mod sector 2 == 0
        then rem
        else 60 - rem;
      chroma = (1000 - absDiff (2 * l) 1000) * s;
      lift = 6000 * l - 30 * chroma;
      weights =
        if sector == 0
        then [ 60 slope 0 ]
        else if sector == 1
        then [ slope 60 0 ]
        else if sector == 2
        then [ 0 60 slope ]
        else if sector == 3
        then [ 0 slope 60 ]
        else if sector == 4
        then [ slope 0 60 ]
        else [ 60 0 slope ];
      channel = i: ((lift + chroma * lib.elemAt weights i) * 255 + 3000000) / 6000000;
    in
    {
      r = channel 0;
      g = channel 1;
      b = channel 2;
    };

  ## WCAG relative luminance
  # Contrast is the hard requirement here, and contrast is defined on relative
  # luminance, not on HSL lightness. The two are wildly different: at a fixed
  # HSL lightness a yellow is roughly ten times as luminous as a blue, which is
  # why a single fixed lightness cannot serve every hue. So the palette targets
  # luminance directly and solves for the lightness that reaches it.
  #
  # That needs the sRGB transfer function, which needs a fractional power, and
  # nix has no pow. Newton's method gives square roots, and 0.4 in binary is
  # 0.0110011001100... repeating, so x^0.4 is the product of x^(1/2^k) over the
  # set bits k = 2,3,6,7,10,11,14,15. Eight terms put the exponent within 6e-6
  # of 0.4. Across the 2880 colours this palette can produce that agrees with
  # an exact implementation in all but one boundary case, which lands a single
  # lightness step dimmer and still clears its floor. x^2.4 is then
  # x * x * that. Floats are fine here: the result is quantised to 8 bits
  # immediately afterwards, and every ratio the palette promises is checked
  # exactly, outside nix, against the built config.
  sqrtF = x:
    if x <= 0.0
    then 0.0
    else lib.foldl' (g: _: (g + x / g) / 2.0) 1.0 (lib.range 1 24);

  pow24 = x:
    if x <= 0.0
    then 0.0
    else
      let
        roots = lib.foldl' (acc: _: acc ++ [ (sqrtF (lib.last acc)) ]) [ x ] (lib.range 1 15);
        at = k: lib.elemAt roots k;
      in
      x * x * at 2 * at 3 * at 6 * at 7 * at 10 * at 11 * at 14 * at 15;

  linearise = c:
    let
      x = c / 255.0;
    in
    if x <= 0.03928
    then x / 12.92
    else pow24 ((x + 0.055) / 1.055);

  luminance = c: 0.2126 * linearise c.r + 0.7152 * linearise c.g + 0.0722 * linearise c.b;

  # The dimmest colour on the (hue, saturation) locus that reaches the target
  # luminance. Luminance is non-decreasing in l, so bisection finds it, and
  # taking the dimmest one keeps the overshoot from 8 bit quantisation to a
  # single step.
  solveLightness = h: s: target:
    let
      go = lo: hi:
        if lo >= hi
        then lo
        else
          let
            mid = (lo + hi) / 2;
          in
          if luminance (hsl h s mid) < target
          then go (mid + 1) hi
          else go lo mid;
    in
    go 0 1000;

  byteToHex = n:
    let
      digits = "0123456789abcdef";
    in
    lib.substring (n / 16) 1 digits + lib.substring (lib.mod n 16) 1 digits;

  # A role: the given hue at the given saturation, placed at the given
  # luminance. Every colour in the palette is one of these.
  tone = h: s: target:
    let
      c = hsl h s (solveLightness h s target);
    in
    "#" + byteToHex c.r + byteToHex c.g + byteToHex c.b;

  ## Tone
  # Saturation says how much colour a role carries; luminance says how much
  # light. Splitting them is what makes the palette work: every contrast ratio
  # below follows from the luminance targets alone and so is identical on every
  # host, while the hue and the saturations carry the identity.
  #
  # Saturations are chosen for appearance. Backgrounds sit at 50 because blue
  # has a luminance coefficient of 0.0722 against green's 0.7152, so at full
  # saturation a blue host would need a near maximum intensity blue to reach
  # the same luminance as a modest green, and the hosts would stop looking like
  # siblings. Foregrounds sit at 25 so bar text reads as text rather than as
  # coloured text. The active pane border stays fully saturated because that is
  # the host's signature.
  backgroundSaturation = 50;
  foregroundSaturation = 25;
  accentSaturation = 100;
  signalSaturation = 100;
  # The idle pane border is the one role with no hue: neutral grey against the
  # accent's full saturation is the clearest reading of idle against active.
  borderSaturation = 0;

  ## Luminance targets for everything drawn on the status bar
  # Chosen so every pair of these meets WCAG AA, which is 4.5 because all of
  # them are text. With contrast (Y1+0.05)/(Y2+0.05):
  #
  #   text on surface    0.55 / 0.065 = 8.46
  #   text on panel      0.55 / 0.115 = 4.78
  #   muted on surface   0.32 / 0.065 = 4.92
  #   signal on surface  0.35 / 0.065 = 5.38
  #   panel on surface   0.115 / 0.065 = 1.77   (bands, not text)
  #   text on muted      0.55 / 0.32 = 1.72     (hierarchy, not text)
  surfaceLuminance = 0.015;
  panelLuminance = 0.065;
  mutedLuminance = 0.27;
  textLuminance = 0.50;
  signalLuminance = 0.30;

  # Pane borders, pane numbers and the clock are drawn on the terminal's own
  # background, which this module cannot know, so they are measured against
  # black and white both. They are non-text graphical objects, so the floor
  # that applies to them is WCAG's 3.0 for UI components, not 4.5. That gives
  # a luminance window of [0.10, 0.30]: 3.0 against black needs at least 0.10,
  # 3.0 against white needs at most 0.30.
  #
  # The accent spends that window on saturation. It stays at 100 and moves
  # only in lightness, and only as far as it must: take the luminance the pure
  # hue already has and clamp it into the window. A hue whose pure form already
  # sits inside keeps it, so a red host gets red rather than a dimmed red. The
  # ceiling is held at 0.29 rather than 0.30 so that the single step of
  # overshoot from 8 bit quantisation cannot push it under 3.0 against white.
  #
  # The idle border sits at the bottom of the window, below the accent, so
  # active and idle separate by light as well as by colour wherever the hue
  # allows it.
  accentLuminanceFloor = 0.15;
  accentLuminanceCeiling = 0.29;
  borderLuminance = 0.11;

  pureAccentLuminance = luminance (hsl cfg.palette.hue accentSaturation 500);
  accentLuminance =
    if pureAccentLuminance < accentLuminanceFloor
    then accentLuminanceFloor
    else if pureAccentLuminance > accentLuminanceCeiling
    then accentLuminanceCeiling
    else pureAccentLuminance;

  ## Palette
  # Roles, applied uniformly across every directive below:
  #   surface  recessive background (status bar, inactive tabs)
  #   panel    raised background (active tab, message bar)
  #   text     primary foreground on surface and panel
  #   muted    recessive foreground (inactive tabs)
  #   accent   the host's signature: active pane border, clock, pane numbers
  #   border   idle pane border and idle pane numbers
  #   alert    a bell fired
  #   notice   background output was seen
  #
  # muted and border were one role until contrast decided otherwise. muted is
  # bar text and needs 4.5 against surface; border sits on an unknown terminal
  # background and needs 4.5 against black and white both. Those two pin
  # incompatible luminances, so they are two roles now.
  #
  # alert and notice keep fixed hues rather than offsets from the host hue.
  # Signal colour is absolute: offset +180 from pippin's green a bell lands on
  # violet, which nobody reads as urgent. gandalf shares the alert hue and
  # loses nothing by it, because accent and alert never share a surface.
  alertHue = 0;
  noticeHue = 45;

  palette = {
    surface = tone cfg.palette.hue backgroundSaturation surfaceLuminance;
    panel = tone cfg.palette.hue backgroundSaturation panelLuminance;
    text = tone cfg.palette.hue foregroundSaturation textLuminance;
    muted = tone cfg.palette.hue foregroundSaturation mutedLuminance;
    accent = tone cfg.palette.hue accentSaturation accentLuminance;
    border = tone cfg.palette.hue borderSaturation borderLuminance;
    alert = tone alertHue signalSaturation signalLuminance;
    notice = tone noticeHue signalSaturation signalLuminance;
  };

  # `prefix S` runs this. Packaging it points the binding at a store path
  # instead of depending on the script being somewhere on PATH.
  tmux-solo = pkgs.writeShellApplication {
    name = "tmux-solo";
    runtimeInputs = [ cfg.package ];
    text = builtins.readFile ./tmux-solo.sh;
  };
in
{
  options.programs.tmux.palette = {
    hue = lib.mkOption {
      type = lib.types.ints.between 0 359;
      default = 205;
      example = 1;
      description = ''
        The host's identity hue, in degrees. Saturation and luminance are
        fixed in the tmux module, so this is the only thing that varies
        between hosts and every other tmux colour derives from it.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      shell = "/usr/bin/elvish";
      terminal = "tmux-256color";
      baseIndex = 1;
      historyLimit = 100000;
      mouse = true;
      keyMode = "vi";
      escapeTime = 500;

      extraConfig = ''
        # Key scheme as vim
        bind -r h select-pane -L
        bind -r j select-pane -D
        bind -r k select-pane -U
        bind -r l select-pane -R

        # clipboard
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi Y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

        # start shell in
        ## new window
        bind c new-window -c "#{pane_current_path}"

        ## window splits
        bind | split-window -h -c "#{pane_current_path}"
        bind _ split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"

        # solo: flip this client to a session holding ONLY the current window
        # (the window stays linked in the default session; killing the solo leaves it alive)
        bind S run-shell "${tmux-solo}/bin/tmux-solo '#{window_id}' '#{client_name}'"

        #### COLOUR (derived from programs.tmux.palette.hue)

        # status bar
        set-option -g status-style 'fg=${palette.text},bg=${palette.surface}'

        # inactive window titles
        set-window-option -g window-status-style 'fg=${palette.muted},bg=${palette.surface}'

        # active window title
        set-window-option -g window-status-current-style 'fg=${palette.text},bg=${palette.panel}'

        # pane border (drawn on the terminal's own background, not on surface)
        set-option -g pane-border-style 'fg=${palette.border}'
        set-option -g pane-active-border-style 'fg=${palette.accent}'

        # message text
        set-option -g message-style 'fg=${palette.text},bg=${palette.panel}'

        # pane number display
        set-option -g display-panes-active-colour '${palette.accent}'
        set-option -g display-panes-colour '${palette.border}'

        # clock
        set-window-option -g clock-mode-colour '${palette.accent}'

        # bell
        set-window-option -g window-status-bell-style 'fg=${palette.alert},bg=${palette.surface},bold'

        # activity (mirrors the bell style, in notice to distinguish from a bell)
        set-window-option -g window-status-activity-style 'fg=${palette.notice},bg=${palette.surface}'

        #### NOTIFICATIONS

        # Let programs inside tmux pass terminal escape sequences (OSC 9 / OSC 777
        # desktop notifications, etc.) through to the outer terminal. tmux blocks
        # these by default; "on" allows them for visible panes.
        set -g allow-passthrough on

        # Watch background windows for output (activity) and bells...
        set-window-option -g monitor-activity on
        set-window-option -g monitor-bell on

        # Bells get a status-line message (deliberate signal, worth interrupting for).
        # Activity is highlight-only (notice in the status bar) — no popup message,
        # because busy panes with continuous output make visual-activity spam.
        set-option -g visual-activity off
        set-option -g visual-bell on
      '';
    };
  };
}
