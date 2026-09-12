# Everything specific to the ThinkPad X1 Carbon 7th Gen.
#
# rosita and sam are the same machine down to the part number pair
# (20QDS37700 and 20QDS0E700), the same i7-8565U, the same 06cb:00bd
# fingerprint reader and the same 8086:7360 modem, so this is shared rather
# than duplicated. pippin is a Framework 13 and imports none of it.
#
# Not imported by ../default.nix: that one is the fleet-wide set, and this is
# per-model. The two host files that need it import it by path.
{ ... }: {
  imports = [
    ./fingerprint.nix
    ./modem.nix
  ];
}
