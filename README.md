# dotfiles

## Requirements

Nix, installed system-wide, with the store at `/nix`:

```
pacman -Syu nix
systemctl enable --now nix-daemon.socket
```

`-Syu`, not `-S`. Installing it alone after a database refresh links it against
a boost the system does not have yet and it fails to start.

## Secrets

`.config/nix/private/` holds one sops file per host. It is gitignored in full
and never committed.

Modules take a path into it and read the file at activation or service start,
so the contents never enter the world-readable nix store. The directory is
searched by absolute path, first match wins:

```
/home/javier/.config/nix/private
/home/javier/projects/txomonltd/nix-learn/dotfiles/.config/nix/private
```

Only `pippin` has anything in its file today, the Vanta agent key. Syncing the
directory between machines is not solved yet.
