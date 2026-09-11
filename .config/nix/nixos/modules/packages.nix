{ pkgs, ... }: {
  # Things that belong to the machine rather than to a user session: hardware
  # probes, network diagnostics, debuggers, filesystem tools. Everything else
  # javier uses day to day comes from his home-manager profile.
  environment.systemPackages = with pkgs; [
    acpi
    arp-scan
    bind # dig, nslookup, host
    dmidecode
    dos2unix
    dosfstools
    ethtool
    evtest
    gdb
    intel-gpu-tools
    inxi
    iperf3
    iw
    jq
    lldb
    lldpd # the binaries only. services.lldpd exists if the daemon is wanted.
    mesa-demos # glxinfo, glxgears
    mosh
    netcat-openbsd
    nmap
    rsync
    sysstat
    tcpdump
    time
    tk
    tree
    vulkan-tools # vulkaninfo, vkcube
    wget
    whois
    zip

    # programs.adb was removed from nixpkgs: systemd 258 applies the uaccess
    # rules on its own, so android-tools is now a plain package and there is no
    # adbusers group to join.
    android-tools

    # Flashing tool for the Vial keyboard. Its udev rule is in peripherals.nix.
    vial
  ];
}
