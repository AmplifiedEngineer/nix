# nix

> **Renamed.** The GitHub organization was `pragmatic-engineer`. It is now `amplifiedengineer`, so the flake is `github:amplifiedengineer/nix`. If you installed from the old address, remove the old entry and install again: run `nix profile remove playbook`, then `nix profile install github:amplifiedengineer/nix#playbook`. If the name does not match, find the entry with `nix profile list`. Your data stays in `~/.config/playbook`.

Nix flake for the [amplifiedengineer/playbook](https://github.com/amplifiedengineer/playbook) toolkit.

| Output | Run | What it is |
|---|---|---|
| `playbook` | `nix run github:amplifiedengineer/nix#playbook` | The Claude Code plugin toolkit and its binary. |
| `pbtop` | `nix run github:amplifiedengineer/nix#pbtop` | The token and cost dashboard. |

## Install

```bash
nix profile install github:amplifiedengineer/nix#playbook
```

Upgrade with `nix profile upgrade playbook`. You do not need `pbtop` if you have `playbook`, because `playbook usage` runs the same code.

## What the flake does

The flake fetches the prebuilt release binary for `x86_64-linux`, `aarch64-linux`, `x86_64-darwin` or `aarch64-darwin` and checks it against a fixed hash. It does not build from source. `pbtop` is the same binary installed under that name, which starts the dashboard.

The `pbdoc` document converter is not part of the flake. Use Homebrew or `install.sh` if you need `playbook doc`.

A Nix install is read-only. The automatic update shows a notice that the install directory is not writable, and `playbook update` stops with "cannot write to" the store path. Update with `nix profile upgrade playbook` instead. Your config is not touched.

## Versions

A release of `amplifiedengineer/playbook` opens a pull request here that moves the `releases` block of `flake.nix` to the new version and hashes. Do not edit that block by hand.

`main` is one release behind for a short while after each release. To pin a version, use the merge commit of the `chore(release): nix flake X.Y.Z` pull request, for example `github:amplifiedengineer/nix/<commit>#playbook`. To roll back, pin the commit of the earlier pull request. The older hashes stay valid because release assets do not change.

## Security

See [SECURITY.md](SECURITY.md).
