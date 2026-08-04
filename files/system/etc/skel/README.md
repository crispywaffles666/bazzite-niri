# Dotfiles

Personal shell, editor, terminal, and Niri desktop configs managed with
[GNU Stow](https://www.gnu.org/software/stow/).

Files in this repo are symlinked into `~` so edits to config files are automatically reflected here.

> [!NOTE]
> These are personal configs, not a general-purpose distribution. The Niri setup contains monitor
> names, paths under `/home/user`, commands from `~/delta-shell`, and scripts from `~/.local/bin`.
> Review those values before using the desktop config on another machine.
>
> Device-specific configs live on separate branches (e.g. `asahi-macbook` for the M2 MacBook Pro).
> Configs listed in `.dotfiles-shared` are kept in sync across all branches automatically.

## Companion projects

- [Graphite GTK Dracula](https://github.com/crispywaffles666/Graphite-gtk-theme-dracula) — the custom
  GTK theme used with this desktop setup

## Dependencies

Install these before stowing on a new Arch/CachyOS machine. Some packages below come from the
AUR, so bootstrap `paru` first if it is not already installed.

### Shell

```bash
sudo pacman -S bash bash-completion bat fastfetch fzf git neovim pfetch-rs starship stow zsh
paru -S blesh-git zsh-antidote
```

- `zsh-antidote` reads `.zsh_plugins.txt` and installs the zsh plugins listed there:
  `zsh-users/zsh-completions`, `Aloxaf/fzf-tab`, `zsh-users/zsh-autosuggestions`,
  `zsh-users/zsh-history-substring-search`, and `zsh-users/zsh-syntax-highlighting`.
- `blesh-git` is required by `.bashrc`.
- `pfetch-rs` provides `pfetch`, which runs at interactive shell startup.
- `resolvectl` is used by the `ivpn-connect` helper and is expected from the base system.
- `~/.npm-global/bin`, `~/.cargo/bin`, `~/bin`, and `~/.local/bin` are added to `PATH` if present.

Optional shell helper:

```bash
paru -S ivpn
```

- `ivpn` is used by the `ivpn-connect` helper.
- `paru` is used by the `yay` alias.

### Window Manager

```bash
sudo pacman -S alacritty awww bluez bluez-utils brightnessctl cliphist firefox gnome-control-center libnotify matugen nautilus niri pavucontrol pipewire pipewire-pulse playerctl power-profiles-daemon satty slurp upower wl-clipboard xdg-desktop-portal xdg-desktop-portal-gnome xwayland-satellite
paru -S ghostty-git pwvucontrol
```

- `niri` is the main compositor config in `.config/niri`.
- Niri launches Noctalia Shell at startup (see setup below).
- `brightnessctl`, `playerctl`, and PipeWire's `wpctl` back the hardware media key bindings.
- `xwayland-satellite` provides Xwayland support under Niri.
- `cliphist` and `wl-clipboard` provide clipboard history.
- `awww` (formerly `swww`) is used for wallpaper management.
- `matugen` generates Material You color themes for various configs.
- `satty` uses `wl-copy` for annotated screenshots.
- `bluez`, `pipewire`, `power-profiles-daemon`, and `upower` back the shell widgets for Bluetooth, audio, power profiles, and battery status.
- `xdg-desktop-portal` plus a backend is needed for portal-based screen recording and desktop integration.
- `gnome-control-center` is opened by the network and Bluetooth settings panels.
- `pavucontrol`/`pwvucontrol` are used by the volume widget.
- `ghostty-git` must be built from AUR; there is no official package yet.
- `inotify-tools` provides `inotifywait`, used by the screenshot notification script.

### Noctalia Shell

```bash
paru -S noctalia
```

Niri's autostart launches `noctalia` directly. Configuration lives in
`.config/noctalia/config.toml` (v5 format).

### Tools

```bash
sudo pacman -S adw-gtk-theme alacritty btop firefox geany gnome-themes-extra kitty matugen micro nautilus neovim npm qt5ct qt6ct ripgrep sassc yazi xterm
```

- `alacritty`, `ghostty`, and `kitty` all have terminal configs in this repo.
- `btop`, `geany`, `micro`, `neovim`, and `yazi` have app configs in `.config`.
- `ripgrep` backs Neovim's `:Rg` workflow through `fzf.vim`.
- `xterm` is referenced by Geany's terminal command.
- `adw-gtk-theme`, `qt5ct`, and `qt6ct` are referenced by Matugen's generated GTK/Qt theme outputs.
- `gnome-themes-extra` and `sassc` are required to build and install the custom Graphite GTK
  Dracula theme.

Neovim external formatters and language servers:

```bash
sudo pacman -S bash-language-server pyright ruff shfmt stylua taplo-cli typescript-language-server yaml-language-server
npm install -g @vtsls/language-server @fsouza/prettierd vscode-langservers-extracted
```

- Mason manages Neovim plugins, but the configured LSP servers and Conform formatters still need these executables available.

Fonts referenced by the configs:

```bash
sudo pacman -S noto-fonts noto-fonts-emoji otf-overpass-nerd ttf-hack-nerd ttf-sourcecodepro-nerd
paru -S ttf-material-symbols-variable-git
```

## Setup on an Arch/CachyOS machine

```bash
git clone http://your.forgejo.host/user/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ .
```

Before starting Niri, review these machine-specific files:

- `.config/niri/cfg/display.kdl` for outputs and workspace assignments
- `.config/niri/cfg/autostart.kdl` for the Noctalia startup and local helper scripts
- `.config/systemd/user/dotfiles-sync.service` for the hard-coded repository path

Install the custom GTK theme (use the `dracula` branch):

```bash
git clone https://github.com/crispywaffles666/Graphite-gtk-theme-dracula.git ~/Graphite-gtk-theme-dracula
cd ~/Graphite-gtk-theme-dracula
git checkout dracula
./install.sh -l -t purple --tweaks dracula rimless normal
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Graphite-purple-Dark-dracula
```

The installer symlinks `~/.config/gtk-4.0` to the Light variant by default. For the dark theme to
work with libadwaita apps, relink to the Dark variant:

```bash
rm ~/.config/gtk-4.0/assets ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk.css
ln -s ~/.themes/Graphite-purple-Dark-dracula/gtk-4.0/assets ~/.config/gtk-4.0/assets
ln -s ~/.themes/Graphite-purple-Dark-dracula/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
ln -s ~/.themes/Graphite-purple-Dark-dracula/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
```

Run `./install.sh --help` to select theme variants, compact sizing, libadwaita integration, or a
different installation directory.

## Setup on Asahi Linux (aarch64)

This repo has an `asahi-macbook` branch with MacBook-specific niri config (workspaces,
keybinds, autostart, environment). Clone and stow from that branch instead of `main`:

```bash
git clone -b asahi-macbook http://your.forgejo.host/user/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ .
```

The dotfiles-sync timer on this branch pushes to `asahi-macbook` automatically.

### keyd (Mac keyboard remapping)

Install and enable [keyd](https://github.com/rvaiya/keyd) to remap the Mac keyboard so that
Cmd acts like Ctrl for common shortcuts (copy, paste, find, etc.) while preserving Ctrl for
terminal use and niri compositor bindings:

```bash
sudo pacman -S keyd
sudo cp ~/.config/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
```

After editing the config, reload with `sudo keyd reload`.

Additional notes when running on Apple Silicon with the Asahi kernel:

- **ghostty** requires its terminfo entry installed manually — the `ghostty-git` AUR package
  does not include it. From a machine that has it: `infocmp -x xterm-ghostty | ssh asahi-host 'tic -x -'`.
- **gtk-engine-murrine** is not available on aarch64 (only affects legacy GTK2 theme rendering).
- Many AUR packages (libastal, AGS, satty) are marked `arch=(x86_64)` but compile and run fine
  on aarch64. Use `paru -S --mflags '--ignorearch'` to build them.
- The `ghostty-nightly-bin` AUR package is x86_64 only; use `ghostty-git` (source build with zig).
- The user should be in the `video` group for `brightnessctl` to work without sudo.

## Setup on a headless machine

Use this path for Debian servers, SSH-only systems, or machines that do not run the Niri
desktop environment. It installs zsh, the prompt, editor, and terminal CLI tools without the
graphical environment packages. Neovim and Yazi are installed with Homebrew.

```bash
sudo apt update
sudo apt install bat btop build-essential curl fastfetch fzf git micro npm ripgrep starship stow zsh zsh-antidote
mkdir -p ~/.local/bin
command -v bat >/dev/null || ln -sf /usr/bin/batcat ~/.local/bin/bat
```

Install Homebrew, then use it for Neovim, Yazi, and pfetch-rs:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install neovim pfetch-rs yazi
```

Optional helpers:

```bash
sudo apt install pyright ruff shfmt stylua taplo-cli typescript-language-server yaml-language-server
npm install -g @vtsls/language-server @fsouza/prettierd vscode-langservers-extracted
```

Then clone and stow the repo as usual:

```bash
git clone http://your.forgejo.host/user/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ .
```

- Skip the Window Manager dependencies entirely on headless systems.
- Skip graphical tools such as Alacritty, Firefox, Geany, Ghostty, Kitty, Nautilus, Matugen, GTK/Qt
  theme packages, screenshot tools, portals, PipeWire desktop packages, Bluetooth tools, and fonts.
- Stowing the full repo may still create symlinks for graphical app configs under `~/.config`; those
  are inert unless the corresponding applications are installed.

## Updating configs

Any changes to config files are already in the repo since they're symlinked. Just commit and push:

```bash
cd ~/dotfiles
git add -A
git commit -m "describe the change"
git push
```

### Automatic hourly sync

The included user timer runs `sync.sh` once per hour. It pulls the current branch, commits any
local changes, pushes, and then propagates shared configs to every other machine branch.

```bash
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-sync.timer
systemctl --user status dotfiles-sync.timer
```

Disable it before making a series of changes that should become one intentional commit:

```bash
systemctl --user disable --now dotfiles-sync.timer
```

Re-enable it afterward with `systemctl --user enable --now dotfiles-sync.timer`.

### Shared configs across branches

Some configs (like Neovim) should stay identical on every machine. Paths listed in
`.dotfiles-shared` are automatically kept in sync across all branches by `sync.sh`.

When the sync timer fires, `sync.sh`:

1. **Pulls** the current branch — picking up any shared changes pushed from another machine.
2. **Commits and pushes** local changes on the current branch.
3. **Propagates** shared files to every other remote branch using a temporary git worktree, so the
   working tree is never disturbed.

The last machine to sync wins for shared files. In practice this means your most recent edit is
always the one that lands on both branches.

To share a new config, add its path to `.dotfiles-shared`:

```
# .dotfiles-shared
.config/nvim/
.config/starship.toml
```

Directories should end with `/`. Lines starting with `#` are comments. The sync infrastructure
itself (`sync.sh`, `.dotfiles-shared`, and the systemd service) is also listed in `.dotfiles-shared`
so that updates to the sync mechanism propagate to all branches automatically.

After the first sync propagates the updated service file to another branch, run
`systemctl --user daemon-reload` on that machine once so systemd picks up the change.

## Adding new files or directories

```bash
# copy the file into the repo, preserving the path relative to ~
mkdir -p ~/dotfiles/.config/newapp
cp ~/.config/newapp/config.toml ~/dotfiles/.config/newapp/

# remove the original so stow can replace it with a symlink
rm ~/.config/newapp/config.toml

# re-stow (idempotent, safe to run anytime)
cd ~/dotfiles
stow -t ~ .

# commit
git add -A
git commit -m "add newapp config"
git push
```

## Rolling back a change

Because the stowed files point into this repo, restoring a file updates the active config immediately.
To reverse a committed change without rewriting shared history:

```bash
cd ~/dotfiles
git log --oneline
git revert <commit-hash>
git push
```

To restore one file from an earlier commit:

```bash
cd ~/dotfiles
git restore --source=<commit-hash> -- .config/ghostty/config
git commit -m "revert ghostty config to <commit-hash>"
git push
```

## Contents

- `.zshrc`, `.zshenv`, `.zsh_plugins.txt` — zsh config with antidote plugin manager
- `.bashrc`, `.bash_profile`, `.blerc` — bash config with ble.sh
- `.config/starship.toml` — shared prompt (starship)
- `.config/alacritty` — Alacritty terminal
- `.config/btop` — btop system monitor
- `.config/cava` — CAVA audio visualizer
- `.config/delta-shell` — legacy Delta Shell settings (retained for reference)
- `.config/geany` — Geany editor
- `.config/ghostty` — Ghostty terminal
- `.config/hypr` — shared colors plus legacy Hyprland/Hyprlock fragments
- `.config/ignis` — Ignis bar/widgets
- `.config/kitty` — Kitty terminal
- `.config/matugen` — Material color generation
- `.config/micro` — Micro editor
- `.config/nautilus` — Nautilus file manager
- `.config/niri` — Niri compositor
- `.config/noctalia` — Noctalia Shell (bar, dock, notifications, lock screen, OSD)
- `.local/bin/screenshot-notify.sh` — screenshot watcher with annotate/open/copy actions
- `.local/bin/niri-overview-autoclose.sh` — closes niri overview when a window opens
- `.config/nvim` — Neovim
- `.config/satty` — Satty screenshot annotation
- `.config/systemd/user` — hourly dotfiles auto-sync service and timer
- `sync.sh` — sync script called by the timer; propagates shared configs across branches
- `.dotfiles-shared` — list of paths to keep in sync across all machine branches
- `.config/keyd` — keyd key remapping (Mac keyboard layout for Linux)
- `.config/yazi` — Yazi file manager
