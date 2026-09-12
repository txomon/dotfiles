# private

Secrets live here. This directory is gitignored: nothing in it is ever
committed, because the repository is public.

It is referred to, never generated. Modules that need a secret take a path
into this directory and read it at activation or service start, which keeps
the contents out of the world-readable nix store. That is the same reason
nixpkgs pairs `hashedPassword` with `hashedPasswordFile` and why every option
whose name ends in `File` exists.

Syncing this directory between machines is not solved yet. The intent is
Syncthing, whose home-manager service is enabled alongside this.

## Contents

| File | Used by | Shape |
| --- | --- | --- |
| `vanta.conf` | pippin only, `services.vanta-agent` | the JSON the Vanta deb's postinst writes, with `AGENT_KEY`. Mode 0600. |
