# dotfiles

## Requirements

Nix, installed system-wide, with the store at `/nix`:

```
pacman -Syu nix
systemctl enable --now nix-daemon.socket
```

`-Syu`, not `-S`. Installing it alone after a database refresh links it against
a boost the system does not have yet and it fails to start.
