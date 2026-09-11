{ config
, lib
, ...
}: {
  config = lib.mkIf config.programs.discord.enable {
    # Carried over from the Arch install's ~/.config/discord/settings.json.
    # The upstream module generates that file whole, so anything not listed
    # here is gone, and the file is a read-only store symlink, so Discord
    # cannot write it back either.
    #
    # Deliberately omitted: WINDOW_BOUNDS and IS_MINIMIZED, which are runtime
    # state rather than settings. Freezing a window geometry in the config
    # would be wrong, and IS_MAXIMIZED below makes the geometry irrelevant.
    programs.discord.settings = {
      BACKGROUND_COLOR = "#2c2d32";
      IS_MAXIMIZED = true;

      chromiumSwitches = { };
      enableHardwareAcceleration = true;
      asyncVideoInputDeviceInit = false;
      openH264Enabled = true;
      offloadAdmControls = true;

      DESKTOP_TTI_REMOVE_V8_CACHE_CLEAR = false;
      DESKTOP_TTI_DNSTCP_WARMUP = false;
      DESKTOP_TTI_EARLY_UPDATE_CHECK = true;
      DESKTOP_TTI_SPLASH_USE_WEBP = true;
    };
  };
}
