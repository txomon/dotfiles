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

`.config/nix/private/` holds one sops file per host, named `<hostname>.yaml`.
It is gitignored in full and never committed.

Modules take a path into it and read the file at service start, so the
contents never enter the world-readable nix store. The directory is searched
by absolute path, first match wins:

```
/home/javier/.config/nix/private
/home/javier/projects/txomonltd/nix-learn/dotfiles/.config/nix/private
```

That list is the default of `secrets.searchPaths`, declared in
`.config/nix/nixos/modules/sops.nix`. Change it there and nothing else moves.
Nothing creates these directories and a missing one is skipped.

`pippin` is the only host anything asks a secret of, the Vanta agent key.
Syncing the directory between machines is not solved yet.

### From nothing to a working secret

No file exists yet. In order:

1. `age-keygen -o ~/.config/sops/age/keys.txt`, then put the public half it
   prints into `.config/nix/.sops.yaml` as `&admin` and uncomment that block.
2. On pippin as root, `install -d -m 0700 /var/lib/sops-nix` then
   `age-keygen -o /var/lib/sops-nix/key.txt`, and add its public half as
   `&pippin`.
3. `sops /home/javier/.config/nix/private/pippin.yaml`, and put the JSON Vanta
   gave you under a key named `vanta_conf`:

   ```yaml
   vanta_conf: |
     {"ACTIVATION_REQUESTED_NONCE":0,"AGENT_KEY":"...","OWNER_EMAIL":"...","REGION":"US","NEEDS_OWNER":true}
   ```

4. `services.vanta-agent.enable = true` on pippin, and rebuild.

Steps 1 and 2 are once per machine. `rosita` and `sam` need nothing until
something on them asks for a secret.

### Editing

```
sops /home/javier/.config/nix/private/pippin.yaml
```

`.config/nix/.sops.yaml` says which keys each file is written for. It is found
by walking up from the file, so it applies at either search path.

**It lists no keys yet**, so that command refuses until you add yours. See
Keys below. The refusal is deliberate: a file encrypted to a key nobody holds
looks like it worked and cannot be read again.

### Keys

Two age keys read any host file, and neither exists yet.

`~/.config/sops/age/keys.txt` is yours, mode 0600, on every machine you edit
from. `.gitignore` already excludes it via `/.config/*`. Make it once, then
paste the public half into `.config/nix/.sops.yaml`:

```
age-keygen -o ~/.config/sops/age/keys.txt
```

**Back it up off these machines.** It is the only key that reads every file,
and if it and the machine keys are all gone, nothing here can be recovered:
the Vanta agent key would have to be reissued.

`/var/lib/sops-nix/key.txt` is the machine's, root only, and is what
`sops-install-secrets.service` decrypts with. It is not derived from anything
the install produces, which is why it survives the move off Arch: copy the
file to the new install and nothing needs re-encrypting. Make it once per
host, then add its public half to `.config/nix/.sops.yaml` and run
`sops updatekeys`:

```
install -d -m 0700 /var/lib/sops-nix
age-keygen -o /var/lib/sops-nix/key.txt
```

No ssh host key is involved. sops-nix would derive an age identity from
`services.openssh.hostKeys` by default, but openssh is off on all three hosts,
so that list is empty.

### When the file is not there

Absolute paths are read at service start, not at evaluation time, which is the
point: nix never sees them and never copies them into the store. It also means
a missing file cannot fail `nix build` or `nixos-rebuild`.

So it fails at the unit instead. The search runs as `ExecStartPre` of
`sops-install-secrets.service`, and finding nothing fails that unit, naming
every directory it looked in, in order. Services that asked for a secret
declare `Requires=` on it, so they refuse to start rather than looping against
a config that is not there:

```
systemctl status sops-install-secrets
```

It is not silent. That unit is `RequiredBy=sysinit-reactivation.target`, so
`nixos-rebuild switch` exits non-zero and names it. What it does not do is
abort the switch: nothing sops-shaped runs in the activation script, so the
new generation is activated either way and you lose that one service rather
than the whole rebuild.
