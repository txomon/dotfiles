# csr — Claude credential switch/rotate

Rotate the active Claude Code login (`~/.claude/.credentials.json`) between several
saved client profiles by cycling a **hardlink**.

## Why a hardlink

`~/.claude/.credentials.json` is the file Claude Code reads and refreshes. `csr` keeps
it as a *hardlink* to one of the saved profile files, so the active profile and
`.credentials.json` are literally the same inode:

- **Write-back is automatic** when Claude Code edits the file in place — every token
  refresh lands in the shared inode, keeping the profile current with no copy step.
- **Rotation is just re-pointing the link** (atomic), and never overwrites profile
  contents.
- **The active profile is self-identifying**: it's the profile whose inode equals
  `.credentials.json`'s inode.

### The one risk it guards against

If Claude Code ever writes credentials by *atomic rename* (temp file + rename-over)
instead of in place, the rename replaces `.credentials.json` with a new inode and
silently breaks the hardlink, leaving the profile stale. `csr` is robust to this:
on every run it **reconciles** first.

- Inode of `.credentials.json` matches a profile → link intact, active known.
- Matches none → link was broken; `.credentials.json` holds the freshest tokens. Copy
  its content back over the profile named in the `active` marker (the real
  write-back), then continue.

So: in-place writes → free continuous write-back; atomic-rename writes → marker-driven
recovery. Correct either way.

## Layout

```
~/.claude/
  .credentials.json                                   active login (hardlink; CC reads this)
  credentials/
    credentials-javier-jointriple.json                profile
    credentials-javier-domingo-jointriple.json        profile
    active                                             recovery marker: basename of current profile
    backups/                                           timestamped pre-overwrite backups (last 10)
```

- Profiles are discovered with `credentials/credentials-*.json`, sorted
  lexicographically for a stable cycle order. The `active` file (no extension) and
  `backups/` dir are excluded by the glob.
- All credential files are kept `chmod 600`.

## Preconditions (csr never creates or migrates anything)

`csr` operates on an already-set-up layout and **fails loudly** if any of these are
missing — it will not create directories, move files, or invent profiles:

- `~/.claude/.credentials.json` exists.
- `~/.claude/credentials/` exists.
- At least one `credentials/credentials-*.json` profile exists.
- The current profile is determinable: either the link is intact (inode match) or the
  `active` marker exists and names an existing profile. Otherwise `csr` refuses to
  guess and tells you to set up the link.

(`credentials/backups/` is the only thing `csr` may create — lazily, the first time it
writes a backup.)

## Usage

```
csr          # reconcile, then rotate to the next profile in the cycle
csr status   # show current profile, cycle order, and link integrity (no changes)
```

## Behavior

### `csr` (cycle)
1. Check preconditions; fail loudly if any are missing.
2. Reconcile (see above) to determine the current profile.
3. Compute the next profile in the sorted cycle (wrapping).
4. Validate the next profile is well-formed JSON (best-effort: `jq`/`python3` if
   present, else skipped — no hard dependency).
5. Atomically re-point the hardlink to the next profile and `chmod 600`.
6. Write the next profile's basename to `credentials/active`.

### `csr status`
Prints the current profile, the full cycle order, whether the hardlink is intact, and
the marker value. Makes no changes. Still reports clearly when preconditions are
missing.

### Edge cases
- `.credentials.json` missing, `credentials/` missing, or no profiles → error, do
  nothing.
- Only one profile → nothing to cycle to; report and exit 0.
- Broken link **and** no usable marker → refuse to guess; instruct the user to
  re-establish the link.
- Invalid JSON in the file about to become active → abort before linking.

## One-time setup (manual, not part of csr)

The layout is established once, by hand, by *linking the live credentials onto the
moved profile name* so the freshest tokens are preserved with no content copy:

```sh
cd ~/.claude
mkdir -p credentials/backups
# move the saved profiles into the subdir (names unchanged)
mv credentials-javier-jointriple.json credentials-javier-domingo-jointriple.json credentials/
# the live .credentials.json holds the freshest tokens for the currently-active client
# (javier-jointriple). Replace that moved profile with a hardlink to the live inode:
ln -f .credentials.json credentials/credentials-javier-jointriple.json
# record the active profile for recovery
printf '%s\n' credentials-javier-jointriple.json > credentials/active
chmod 600 .credentials.json credentials/credentials-*.json
```

After this, `.credentials.json` and `credentials/credentials-javier-jointriple.json`
are the same inode (live content); the domingo profile keeps its own (stale-until-used)
content. `.credentials.json`'s bytes are unchanged, so a running Claude Code session is
unaffected.

## Backups

Before the recovery path overwrites a profile, the old profile is copied to
`credentials/backups/<basename>.<YYYYmmdd-HHMMSS-NS>.bak` (nanosecond suffix, so two
backups in the same second cannot collide) and pruned to the last 10 per profile. The
recovery path also refuses to write back a live file that is empty or not valid JSON,
so a corrupt/truncated live file can never clobber a saved profile.

## Concurrency

`csr` (the cycle command) takes a non-blocking `flock` on the `credentials/` directory
fd, so a second concurrent run fails fast instead of interleaving the relink and marker
updates. `csr status` is read-only and takes no lock.

Residual: the relink and the `active` marker write are two separate filesystem
operations and cannot be made atomic together. If the process is killed in the tiny
window between them, the marker can lag the link. This is harmless while the link is
intact (the inode match is authoritative); it only matters if the app then breaks the
link before the next `csr` run, and even then the mandatory backup-before-overwrite
makes it recoverable. This is an accepted trade-off for a single-user tool.

## Platform

Linux only — uses GNU `stat -c`, `flock`, and `date +%N`.

## Testing

The base directory is overridable via `CSR_CLAUDE_DIR` (default `~/.claude`), so the
tool can be exercised against a throwaway sandbox without touching real credentials.
