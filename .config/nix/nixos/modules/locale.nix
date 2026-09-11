{ ... }: {
  # Read off pippin: `timedatectl` reports Europe/Madrid, /etc/locale.conf has
  # LANG=en_US.UTF-8, and `localectl` reports VC keymap "us" with no X11 layout.
  time.timeZone = "Europe/Madrid";

  i18n.defaultLocale = "en_US.UTF-8";

  # The running GNOME session sets the regional categories to es_ES via its
  # Formats setting, which on Arch lives in AccountsService rather than in
  # /etc/locale.conf. Declared here so a fresh NixOS install comes up the same.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  console.keyMap = "us";
}
