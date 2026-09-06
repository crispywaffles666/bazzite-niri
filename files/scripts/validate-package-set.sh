#!/usr/bin/bash
# Catch Fedora or Bazzite package changes that would break the Niri desktop.
set -euxo pipefail

required=(
    niri
    noctalia
    gnome-keyring
    # The PAM module that unlocks the login keyring via greetd. GDM depends
    # on it, so the GNOME removal path must not let autoremove take it.
    gnome-keyring-pam
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    nautilus
)

banned=(
    gnome-shell
    mutter
    gdm
    gnome-session
)

for pkg in "${required[@]}"; do
    if ! rpm -q --quiet "$pkg"; then
        echo "ERROR: required package is not installed: $pkg" >&2
        exit 1
    fi
done

for pkg in "${banned[@]}"; do
    if rpm -q --quiet "$pkg"; then
        echo "ERROR: forbidden GNOME desktop package is installed: $pkg" >&2
        exit 1
    fi
done

if rpm -q --quiet sassc; then
    echo "ERROR: theme build-only package leaked into the final image: sassc" >&2
    exit 1
fi

graphite_theme=/usr/share/themes/Graphite-purple-Dark-dracula
graphite_files=(
    "$graphite_theme/index.theme"
    "$graphite_theme/gtk-3.0/gtk.css"
    "$graphite_theme/gtk-3.0/gtk-dark.css"
    "$graphite_theme/gtk-4.0/gtk.css"
    "$graphite_theme/gtk-4.0/gtk-dark.css"
)
for theme_file in "${graphite_files[@]}"; do
    if [[ ! -s "$theme_file" ]]; then
        echo "ERROR: generated Graphite theme file is missing: $theme_file" >&2
        exit 1
    fi
done
for asset_dir in "$graphite_theme/gtk-3.0/assets" "$graphite_theme/gtk-4.0/assets"; do
    if [[ ! -d "$asset_dir" || -z "$(find "$asset_dir" -type f -print -quit)" ]]; then
        echo "ERROR: generated Graphite assets are missing: $asset_dir" >&2
        exit 1
    fi
done

dracula_icons=/usr/share/icons/dracula-icons-main
for icon_file in "$dracula_icons/index.theme" "$dracula_icons/icon-theme.cache"; do
    if [[ ! -s "$icon_file" ]]; then
        echo "ERROR: Dracula icon theme file is missing: $icon_file" >&2
        exit 1
    fi
done
if [[ ! -s /usr/share/licenses/Graphite-gtk-theme/LICENSE ]]; then
    echo "ERROR: Graphite upstream license is missing" >&2
    exit 1
fi
if [[ ! -s /usr/share/licenses/dracula-icons/README.md ]]; then
    echo "ERROR: Dracula Icons upstream licensing notice is missing" >&2
    exit 1
fi

for gtk_settings in /etc/skel/.config/gtk-{3,4}.0/settings.ini; do
    if ! grep -Fxq 'gtk-theme-name=Graphite-purple-Dark-dracula' "$gtk_settings"; then
        echo "ERROR: configured GTK theme name is incorrect: $gtk_settings" >&2
        exit 1
    fi
    if ! grep -Fxq 'gtk-icon-theme-name=dracula-icons-main' "$gtk_settings"; then
        echo "ERROR: configured icon theme name is incorrect: $gtk_settings" >&2
        exit 1
    fi
done
theme_schema=/usr/share/glib-2.0/schemas/zz_bazzite-niri.gschema.override
if ! grep -Fxq "gtk-theme='Graphite-purple-Dark-dracula'" "$theme_schema"; then
    echo "ERROR: GNOME schema override has the wrong GTK theme name" >&2
    exit 1
fi
if ! grep -Fxq "icon-theme='dracula-icons-main'" "$theme_schema"; then
    echo "ERROR: GNOME schema override has the wrong icon theme name" >&2
    exit 1
fi

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

# Parse all included files with the niri version in this image. The temporary
# home keeps the check free of any builder-user state and needs no session.
niri_skel=/etc/skel/.config/niri
if [[ ! -f "$niri_skel/config.kdl" ]]; then
    fail "skel niri config.kdl missing: $niri_skel/config.kdl"
fi
test_home="$(mktemp -d)"
mkdir -p "$test_home/.config"
cp -r "$niri_skel" "$test_home/.config/niri"
if ! HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" niri validate; then
    fail "skel niri config failed niri validate (removed option or broken include?)"
fi
rm -rf "$test_home"

# Parse the shipped Noctalia shell config with the exact noctalia build in
# this image. Validating by directory path keeps the check offline: no
# running shell, graphical session, or user DBus is required.
noctalia_skel=/etc/skel/.config/noctalia
if [[ ! -f "$noctalia_skel/config.toml" ]]; then
    fail "skel noctalia config.toml missing: $noctalia_skel/config.toml"
fi
noctalia_home="$(mktemp -d)"
mkdir -p "$noctalia_home/.config"
cp -r "$noctalia_skel" "$noctalia_home/.config/noctalia"
noctalia_log="$noctalia_home/validate.log"
noctalia_status=0
HOME="$noctalia_home" XDG_CONFIG_HOME="$noctalia_home/.config" \
    XDG_STATE_HOME="$noctalia_home/.local/state" \
    noctalia config validate "$noctalia_home/.config/noctalia" \
    >"$noctalia_log" 2>&1 || noctalia_status=$?
# Keep the validator's own output in the build log either way.
cat "$noctalia_log"
if [[ "$noctalia_status" -ne 0 ]]; then
    fail "skel noctalia config failed noctalia config validate (exit $noctalia_status)"
fi
# Unknown/removed settings, bad enum values, and migration-needed keys are
# reported as WARN diagnostics with exit status 0, so exit code alone cannot
# catch a stale shipped config. Those diagnostics always start with "WARN ";
# timestamped log lines (e.g. container-environment noise) never do.
if grep -E '^WARN[[:space:]]' "$noctalia_log"; then
    fail "skel noctalia config is stale for the installed noctalia (validator warnings above)"
fi
rm -rf "$noctalia_home"

# The update verification chain must stay internally consistent: policy.json,
# the registries.d sigstore config, and the public key all name the same GHCR
# namespace and key path. The README tells forks to change the namespace and
# key together; a forgotten half-edit must fail the build here.
sig_key=/etc/pki/containers/ghcr.io-crispywaffles666-bazzite-niri.pub
if [[ ! -s "$sig_key" ]]; then
    fail "container signature public key missing: $sig_key"
fi

sigstore_config=/etc/containers/registries.d/ghcr.io-crispywaffles666-bazzite-niri.yaml
if [[ ! -r "$sigstore_config" ]]; then
    fail "registries sigstore config missing: $sigstore_config"
fi
if ! grep -q 'use-sigstore-attachments: true' "$sigstore_config"; then
    fail "registries config missing use-sigstore-attachments"
fi
if ! grep -q 'ghcr.io/crispywaffles666/bazzite-niri' "$sigstore_config"; then
    fail "registries config missing GHCR namespace"
fi

policy_file=/etc/containers/policy.json
if [[ ! -r "$policy_file" ]]; then
    fail "container policy missing: $policy_file"
fi
if command -v python3 >/dev/null 2>&1; then
    if ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$policy_file" 2>/dev/null; then
        fail "container policy is not valid JSON: $policy_file"
    fi
fi
if ! grep -q '"ghcr.io/crispywaffles666/bazzite-niri"' "$policy_file"; then
    fail "container policy missing GHCR namespace"
fi
if ! grep -q '"type": "sigstoreSigned"' "$policy_file"; then
    fail "container policy missing sigstoreSigned rule"
fi
if ! grep -q "$sig_key" "$policy_file"; then
    fail "container policy does not reference the signature public key path: $sig_key"
fi

echo "Package-set and skel config validation passed."
