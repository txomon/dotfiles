{ lib
, symlinkJoin
, writeTextFile
, writeShellApplication
, wineWow64Packages
, coreutils
  # The prefix is mutable per-user state that this package cannot build, so its
  # location is an input rather than something derived, and it has no default:
  # there is no path that is right for an arbitrary user. default.nix supplies it.
, prefix
}:

let
  pname = "pcon-planner";
  version = "8.6.0.1485";

  # The prefix was last run under wine 11.0 and nixpkgs' stable series is still
  # 11.0, so the pin is exact. It has to be a 64-bit-capable build: the prefix is
  # win64 and planner.exe 8.6 is x64, so plain `pkgs.wine`, which nixpkgs still
  # builds 32-bit only, cannot run it at all.
  wine = wineWow64Packages.stable;

  launcher = writeShellApplication {
    name = pname;

    runtimeInputs = [ coreutils wine ];

    text = ''
      prefix="''${WINEPREFIX:-${prefix}}"
      exe='C:\Program Files\EasternGraphics\pCon.planner STD\bin\planner.exe'
      exe_unix="''${prefix}/drive_c/Program Files/EasternGraphics/pCon.planner STD/bin/planner.exe"

      # This prefix cannot be rebuilt: EasternGraphics stopped serving the 8.6
      # installer and the versioned URL 404s, so there is nothing to reinstall
      # from. Failing loudly beats handing wine an empty directory, which it
      # would silently provision into a fresh prefix with no pCon in it.
      if [ ! -f "''${exe_unix}" ]; then
        echo "${pname}: no pCon.planner 8.6 at ''${exe_unix}" >&2
        echo "That prefix is irreplaceable state, not something this package builds." >&2
        echo "Restore it from your backup, or set programs.${pname}.prefix to" >&2
        echo "wherever the working copy lives." >&2
        exit 1
      fi

      export WINEPREFIX="''${prefix}"
      export WINEARCH=win64
      export WINEDEBUG="''${WINEDEBUG:--all}"

      # The three overrides the prefix already carries in its registry, restated
      # so the configuration lives in nix rather than only inside the blob.
      # msxml6 keeps builtin as a fallback; mscoree native is what routes .NET to
      # the dotnet472 install winetricks put in the prefix.
      export WINEDLLOVERRIDES="*mscoree=n;*msxml3=n;*msxml6=n,b"

      # Only real paths are translated; anything else is a pCon switch.
      args=()
      for arg in "$@"; do
        if [ -e "''${arg}" ]; then
          args+=("$(winepath -w "''${arg}")")
        else
          args+=("''${arg}")
        fi
      done

      exec wine "''${exe}" "''${args[@]}"
    '';
  };

  # No Icon= line: the only copy of pCon's icon is inside the prefix, outside the
  # store, so there is nothing reproducible to point at.
  desktopItem = writeTextFile {
    name = "${pname}-desktop";
    destination = "/share/applications/${pname}.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=pCon.planner 8.6
      GenericName=CAD / Interior Planner
      Comment=EasternGraphics pCon.planner 8.6, in its existing Wine prefix
      Exec=${pname} %f
      Terminal=false
      Categories=Graphics;Engineering;
      MimeType=image/vnd.dwg;application/dxf;
      StartupWMClass=planner.exe
      Keywords=cad;dwg;interior;furniture;planning;3d;
    '';
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ launcher desktopItem ];

  meta = {
    description = "Launcher for an existing pCon.planner 8.6 Wine prefix";
    homepage = "https://pcon-planner.com/";
    license = {
      fullName = "pCon.planner End User License Agreement";
      url = "https://pcon-solutions.com/en/terms-of-use/";
      free = false;
    };
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
