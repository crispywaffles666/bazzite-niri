# bazzite-niri

Custom [bootc](https://bootc-dev.github.io/) image: **bazzite-gnome with GNOME
stripped, running the niri compositor + noctalia shell**, replicating a CachyOS
desktop setup. Built with [BlueBuild](https://blue-build.org), signed with
cosign, published to GHCR by GitHub Actions.

- Base: `ghcr.io/ublue-os/bazzite-gnome:stable` (Fedora 44)
- Compositor: `niri` + `xwayland-satellite` (official Fedora repos)
- Shell: `noctalia` v5 (official Fedora repos, native binary — no quickshell)
- Display manager: `greetd` + `tuigreet` (GDM removed)
- File manager: `nautilus` (kept deliberately)
- Kept from GNOME: `xdg-desktop-portal-gnome` (niri has no portal backend),
  `gnome-keyring` (secret service / SSH agent)

> Working on this repo from a fresh session? Read [HANDOFF.md](HANDOFF.md)
> first — build invariants, gotchas, and the tweak loop live there.

## Setup (fork / first push)

1. Push this repo to your GitHub account.
2. Generate a cosign key pair and add the private key as a repo secret:

   ```bash
   cosign generate-key-pair   # creates cosign.key / cosign.pub
   # GitHub repo → Settings → Secrets and variables → Actions → new secret:
   #   name: SIGNING_SECRET   value: <contents of cosign.key>
   ```

   Commit `cosign.pub` to the repo root. Keep `cosign.key` out of git.
3. GitHub Actions builds on push (and daily at 06:00 UTC), signs the image,
   and pushes `ghcr.io/crispywaffles666/bazzite-niri:latest`.

If you skip step 2, the workflow still builds and pushes, but images are
unsigned and `--enforce-container-sigpolicy` rebases will fail.

## Rebasing onto this image

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/crispywaffles666/bazzite-niri:latest
sudo systemctl reboot
```

`/var` survives the rebase: home directories, linuxbrew, distrobox containers,
and flatpaks are all untouched.

**Rollback:** bootc keeps the previous deployment. Pick the old entry in the
boot menu, or after booting: `sudo bootc rollback`.

## First boot

- `/etc/skel` contains the full dotfiles set, so **new** users get niri,
  noctalia, ghostty/alacritty, shell configs, and `~/.local/bin` helpers by
  default. An **existing** user (rebase path) is unaffected — clone the
  dotfiles repo and `stow -t ~ .` as usual.
- GTK theming defaults are set via gschema override
  (`/usr/share/glib-2.0/schemas/zz_bazzite-niri.gschema.override`):
  dark preference, `Overpass Nerd Font`, Graphite gtk-theme +
  Colloid icon-theme. The **themes themselves are not in the image** — install
  Graphite-purple-Dark-dracula / Colloid-Purple-Dracula per the dotfiles
  README; until then GTK apps fall back to defaults.
- Default login shell stays `bash` (ublue guidance). Set zsh in ghostty
  (`command = zsh`) or `chsh` if you want it everywhere.
- Install via **brew** (intentionally not in the image): `neovim`, the LSP
  servers / formatters (`bash-language-server`, `pyright`,
  `typescript-language-server`, `yaml-language-server`, `stylua`, `taplo`),
  `antidote`, `pfetch`. Also `npm install -g tree-sitter-cli` — brew's
  `tree-sitter` formula is the library only; nvim's tree-sitter-manager
  needs the CLI.
- Firefox comes as a flatpak via `bazzite-flatpak-manager` (first boot).

## Package sources

| Source | Packages |
|---|---|
| Fedora 44 | niri, xwayland-satellite, noctalia, greetd, tuigreet, alacritty, cliphist, brightnessctl, playerctl, inotify-tools, slurp, pavucontrol, cava, qt5ct, qt6ct, seahorse, sassc, xterm, zsh, bat, micro, geany, ripgrep, stow, overpass-fonts, xdg-desktop-portal-gnome, gnome-keyring, nautilus |
| terra (enabled at build only) | ghostty, awww, satty, yazi, starship |
| Vendored at build | Overpass Nerd Font (pinned Arch package `otf-overpass-nerd-3.4.0-2`, sha256-verified — not in Fedora/COPR/nerd-fonts release zips) |

GNOME removal is done by `files/scripts/remove-gnome.sh`: an explicit list
filtered through `rpm -q`, `clean_requirements_on_remove=false` (dnf5's remove
cascade ignores install reasons — without this, nautilus is destroyed as an
orphan of `nautilus-gsconnect`), then `dnf5 autoremove`.

## Known gaps / deliberate deviations from the CachyOS setup

- **pwvucontrol** — exists nowhere for Fedora 44. `pavucontrol` instead; the
  one config reference (`noctalia` `middleClickCommand`) already falls back to
  it, no config change needed.
- **power-profiles-daemon** — conflicts with the base image's `tuned-ppd`,
  which serves the same DBus API to noctalia. Not installed.
- **localsearch / tinysparql** — *kept*: Fedora nautilus hard-requires both
  (Arch makes tracker optional). One indexing daemon more than the CachyOS box.
- **ble.sh** — not packaged; install from source if you ever want it.
  `.bashrc` is patched to skip it silently when absent.
- **ivpn** — skipped by owner decision.
- **gnome-themes-extra** — retired in F44; only needed to *build* the Graphite
  theme, which is installed manually anyway.
- **matugen** — not installed: nothing invokes it at runtime (noctalia does
  its own color generation), and the seeded config predates matugen v4.
- **Material Symbols** font — only referenced by legacy ignis configs; skipped.
- **kitty / foot** — configs are seeded (inert), binaries intentionally absent.
- **Qt theming via qt5ct/qt6ct** — packages installed; the legacy matugen
  templates targeting them are inert (matugen itself is not installed).
- `~/.config/niri/cfg/display.kdl` and the `~/.local/bin/auto-fullwidth-dp3.sh`
  helper are machine-specific (monitor names/EDID serials) — correct for the
  reference machine, review before imaging other hardware.

## Local build

```bash
bluebuild build recipes/recipe.yml
# inspect: podman pull docker-daemon:localhost/bazzite-niri:latest
#          podman run --rm localhost/bazzite-niri:latest rpm -qa
```

## Layout

- `recipes/recipe.yml` — the BlueBuild recipe
- `files/system/` — copied verbatim to `/` (greetd config, gschema override,
  `/etc/skel` dotfiles seed)
- `files/scripts/` — build scripts (GNOME removal, greetd setup, font fetch)
- `.github/workflows/build.yml` — CI (blue-build reusable action, cosign)
