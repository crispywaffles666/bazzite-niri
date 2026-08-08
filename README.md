# bazzite-niri

This is my personal bazzite image which strips out most of GNOME and instead replaces it with niri and the required tooling and services for my dots.

**A note if you're bringing your own niri config:**

This image is built around Noctalia shell. Noctalia provides most of the desktop stack (bar, launcher, notifications, lock screen, idle management). Because of that, alternatives such as `waybar`, `fuzzel`, `swaylock`, and `swayidle` are not included.

If your existing config depends on a different set of shell components, expect to layer the packages you need or fork this image and add them to the build.

## Standout features of this image:
- **All of bazzite, minus GNOME:** keeps the kernel, gaming stack, codecs, and hardware support that from-scratch niri images make you reassemble yourself.
- **Actually strips the base DE:** many similar images based on bazzite simply layer the compositor on top of the unused DE session. GNOME is completely removed from this image aside from a couple packages that support the niri environment (nautilus, keyring, portals).
- **greetd + tuigreet as Display Manager:** using this as our display manager means we avoid installing much of the GNOME/KDE stack that comes with using their Display Managers.
- **Avoids COPR:** All packages are sourced from the official Fedora repos, terra, or brave's first-party rpm repo.
- **Replicates a tuned Arch/CachyOS desktop:** My lived-in Niri/Noctalia CachyOS desktop was used as the reference for this image:
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/e14954d4-3e13-43b4-bfed-70ff6754043c" />
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/95cda50b-95e4-49e7-8d94-266b3401d73a" />




## Rebasing onto this image

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/crispywaffles666/bazzite-niri:latest
sudo systemctl reboot
```
**Rollback:** bootc keeps the previous deployment. Pick the old entry in the
boot menu, or after booting: `sudo bootc rollback`.

<details>
<summary><strong>Rebased and stuck in niri with a bad config?</strong></summary>

If you rebase to this image without planning ahead. You may find yourself stuck in niri unable to do anything. In that case:

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

</details>

## Copying my configs:
Whether you want them just to get a working environment, or to build off of; the bare minimum niri config, the noctalia shell config, and helper scripts can be copied by:

   ```bash
   cp -r /etc/skel/.config/niri ~/.config/
   cp -r /etc/skel/.config/noctalia ~/.config/
   cp -r /etc/skel/.local/bin ~/.local/
   ```
From there you can look at what else is included and decide how much you want to copy:

   ```bash
   ls /etc/skel
   ls /etc/skel/.config
   ```

My keybinds to get you started:

| Keybind | Action |
|---|---|
| `Mod+\` | Terminal (Ghostty) |
| `Super+Space` / `Alt+Space` | App launcher (**see note below**) |
| `Mod+E` | File manager (Nautilus) |
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

**A few things you might want to install depending on how much you're copying my configs:** 

| What | Which config wants it | Install |
|---|---|---|
| `pfetch` | runs at every interactive bash/zsh startup (`.bashrc`, `.zshrc`) | `brew install pfetch-rs` (or `cargo install pfetch`) |
| `antidote` | `.zshrc` sources it for zsh plugins if present | `brew install antidote` |
| ble.sh | `.bashrc` sources `~/.local/share/blesh/ble.sh` if present (optional bash line editor) | build from source into `~/.local/share/blesh` |
| Graphite GTK / Colloid icons | gschema override (see *First boot* above) | [Graphite-gtk-theme-dracula](https://github.com/crispywaffles666/Graphite-gtk-theme-dracula) + [Colloid-icon-theme](https://github.com/vinceliuice/Colloid-icon-theme) |

## Why use `bazzite-gnome` ?

A few reasons:
1. I was running `bazzite-gnome` before rebasing to this image
2. I tend to gravitate more towards GNOME tooling than KDE (i.e. nautilus is my gui file manager of choice included in this image)
3. This image replicates my CachyOS setup as closely as possible, which also made use of GNOME tooling such as the keyring and portals.
4. `gnome-keyring` does some heavy lifting here, supporting both our display manager and niri session. Doing the same with KDE tooling would require bringing in all of SDDM.

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

## Package sources

| Source | Packages |
|---|---|
| Fedora 44 | niri, xwayland-satellite, noctalia, greetd, tuigreet, alacritty, brightnessctl, playerctl, inotify-tools, wl-clipboard, pavucontrol, cava, seahorse, xterm, zsh, bat, micro, geany, ripgrep, stow, overpass-fonts, xdg-desktop-portal-gnome, gnome-keyring, nautilus |
| terra (enabled at build only) | ghostty, satty, yazi, starship |
| brave (first-party rpm repo, enabled at build only) | brave-origin |
| Vendored at build | Overpass Nerd Font (pinned Arch package `otf-overpass-nerd-3.4.0-2`, sha256-verified — not in Fedora/COPR/nerd-fonts release zips) |

GNOME removal is done by `files/scripts/remove-gnome.sh`: an explicit list
filtered through `rpm -q`, `clean_requirements_on_remove=false` (dnf5's remove
cascade ignores install reasons — without this, nautilus is destroyed as an
orphan of `nautilus-gsconnect`), then `dnf5 autoremove`.


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
