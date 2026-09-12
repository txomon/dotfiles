{ ... }: {
  # A bundle holds nothing but enables of modules. The moment a pkgs reference
  # appears in one it has become txomon-graphical again under a nicer name.
  #
  # The grouping is by what a host is, not by what a program does. Every host
  # in the fleet is a GNOME laptop that also gets the terminal tools, so a
  # finer taxonomy (media, wine, gnome-extras) would be a classification
  # nobody acts on. Split one when a host wants half of it and not the other.
  imports = [
    ./graphical
  ];
}
