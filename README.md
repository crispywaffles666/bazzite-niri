# bazzite-niri

This is my personal bazzite image which strips out most of GNOME and instead replaces it with niri and the required tooling and services for my dots. If you want to use it, my configs live in `/etc/skel` so any new user will inherit them, or you can copy them over to your existing user's `~/.config` and use them to get yourself started.

**A warning to anyone looking to migrate their existing configs to this image:** 
If our dotfiles aren't similar enough (for example if you use tooling that i don't such as `swayidle`) this image won't include those services you need. Plan on adjusting your configs accordingly or you can fork and create your own image. 

## Rebasing onto this image

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/crispywaffles666/bazzite-niri:latest
sudo systemctl reboot
```
**Rollback:** bootc keeps the previous deployment. Pick the old entry in the
boot menu, or after booting: `sudo bootc rollback`.

**If you've rebased to this image and are stuck in niri with a bad config on an existing user:**

1. Switch to a TTY with `Ctrl+Alt+F3` and log in.
2. Copy the niri config, the noctalia shell config it launches, and the helper
   scripts its autostart expects:

   ```bash
   cp -r /etc/skel/.config/niri ~/.config/
   cp -r /etc/skel/.config/noctalia ~/.config/
   cp -r /etc/skel/.local/bin ~/.local/
   ```

3. niri live-reloads its config, so switch back to the graphical session
   (`Ctrl+Alt+F2`) and you should have a working environment. Copy more of
   `/etc/skel` later if you want the full setup (terminal, shell, and other
   app configs).

My keybinds to get you started:

| Keybind | Action |
|---|---|
| `Mod+\` | Terminal (Ghostty) |
| `Super+Space` / `Alt+Space` | App launcher (**see note below**) |
| `Mod+E` | File manager (Nautilus) |
| `Mod+B` | Browser (Firefox) |
| `Mod+Q` | Close window |
| `Mod+H` / `Mod+L` (or ←/→) | Focus column left/right |
| `Mod+K` / `Mod+J` (or ↑/↓) | Focus window up/down |
| `Mod+Ctrl+H/L/K/J` (or Ctrl+arrows) | Move column/window |
| `Mod+1`–`Mod+9` | Switch workspace |
| `Mod+Ctrl+1`–`Mod+Ctrl+9` | Move column to workspace |
| `Mod+F` | Fullscreen window |
| `Mod+T` | Toggle floating |
| `Mod+-` / `Mod+=` | Shrink/grow column width |
| `Print` | Screenshot |
| `Ctrl+Alt+Delete` | Quit niri |

**To get the launcher working:**
Go to noctalia settings > niri > enable `Type to Launch`.
Or in `~/.config/niri/cfg/keybinds.kdl`, change `Super+Space repeat=false { toggle-overview; }` to `Super+Space repeat=false { spawn-sh "noctalia msg panel-toggle launcher"; }`.

**If you do want to use my configs, you'll want to install these to get the full effect:** 

| What | Which config wants it | Install |
|---|---|---|
| `pfetch` | runs at every interactive bash/zsh startup (`.bashrc`, `.zshrc`) | `brew install pfetch-rs` (or `cargo install pfetch`) |
| `antidote` | `.zshrc` sources it for zsh plugins if present | `brew install antidote` |
| ble.sh | `.bashrc` sources `~/.local/share/blesh/ble.sh` if present (optional bash line editor) | build from source into `~/.local/share/blesh` |
| Graphite GTK / Colloid icons | gschema override (see *First boot* above) | [Graphite-gtk-theme-dracula](https://github.com/crispywaffles666/Graphite-gtk-theme-dracula) + [Colloid-icon-theme](https://github.com/vinceliuice/Colloid-icon-theme) |

## About:

This is a custom [bootc](https://bootc-dev.github.io/) image: **bazzite-gnome with GNOME
stripped, running the niri compositor + noctalia shell**, replicating my CachyOS
desktop setup. Built with [BlueBuild](https://blue-build.org), signed with
cosign, published to GHCR by GitHub Actions.

- Base: `ghcr.io/ublue-os/bazzite-gnome:stable` (Fedora 44)
- Compositor: `niri` + `xwayland-satellite` (official Fedora repos)
- Shell: `noctalia` v5 (official Fedora repos)
- Display manager: `greetd` + `tuigreet` (GDM removed; both from the official Fedora repos)
- Kept from GNOME: `xdg-desktop-portal-gnome` (niri has no portal backend),
  `gnome-keyring` (secret service / SSH agent) `nautilus` (file manager)

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

## First boot

- `/etc/skel` contains my personal dotfiles, so **new** users get niri,
  noctalia, ghostty/alacritty, shell configs, and `~/.local/bin` helpers by
  default. An **existing** user (rebase path) is unaffected.
- GTK theming defaults are set via gschema override
  (`/usr/share/glib-2.0/schemas/zz_bazzite-niri.gschema.override`):
  dark preference, `Overpass Nerd Font`, Graphite gtk-theme +
  Colloid icon-theme. The **themes themselves are not in the image** — install
  Graphite-purple-Dark-dracula / Colloid-Purple-Dracula — from
  [Graphite-gtk-theme-dracula](https://github.com/crispywaffles666/Graphite-gtk-theme-dracula)
  (my fork of the Graphite GTK theme with the dracula variant) and
  [Colloid-icon-theme](https://github.com/vinceliuice/Colloid-icon-theme).

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
