#!/bin/bash
set -euo pipefail

# -- config -------------------------------------------------------------

# Providers you want to install as folder emblems
# key=name used in filename; value=url to fetch if local file is missing
# You can add/remove entries freely.
declare -A PROVIDERS=(
  [kasm]="https://kasm-ci.s3.amazonaws.com/kasm.svg"
  [s3]="https://upload.wikimedia.org/wikipedia/commons/b/bc/Amazon-S3-Logo.svg"
  [nextcloud]="https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg"
  [onedrive]="https://upload.wikimedia.org/wikipedia/commons/3/3c/Microsoft_Office_OneDrive_%282019%E2%80%93present%29.svg"
  [gdrive]="https://upload.wikimedia.org/wikipedia/commons/1/12/Google_Drive_icon_%282020%29.svg"
  [dropbox]="https://upload.wikimedia.org/wikipedia/commons/7/78/Dropbox_Icon.svg"
)

# Local file name override (per provider). If present, it will be preferred.
# File is looked up next to this script. Example:
#   LOCAL_FILE_MAP[kasm]="workspaces-logo.svg"
declare -A LOCAL_FILE_MAP=(
  [kasm]="workspaces-logo.svg"
  # [s3]="s3.svg"
  # [nextcloud]="nextcloud.svg"
  # [onedrive]="onedrive.svg"
  # [gdrive]="gdrive.svg"
  # [dropbox]="dropbox.svg"
)

# Set to "0" to skip network fetch and rely only on local files.
: "${ALLOW_NETWORK_FETCH:=1}"

# ----------------------------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEST_DIR="/usr/share/icons/hicolor/scalable/emblems"
AUTOSTART_DIR="/etc/xdg/autostart"

mkdir -p "$DEST_DIR" "$AUTOSTART_DIR"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

download_file() {
  local url="$1" out="$2"
  if [[ "${ALLOW_NETWORK_FETCH}" != "1" ]]; then
    return 1
  fi
  if have_cmd curl; then
    curl -fsSL -o "$out" -L "$url" && return 0
  fi
  if have_cmd wget; then
    wget -q -O "$out" "$url" && return 0
  fi
  return 1
}

install_icon_meta() {
  local name="$1"
  local icon_path="${DEST_DIR}/${name}-emblem.icon"
  printf "[Icon Data]\nDisplayName=%s-emblem\n" "$name" > "$icon_path"
  chmod 644 "$icon_path" || true
}

fetch_or_copy() {
  local name="$1" url="$2"
  local out_svg="${DEST_DIR}/${name}-emblem.svg"

  # 1) Prefer local override if present
  local local_name="${LOCAL_FILE_MAP[$name]:-}"
  if [[ -n "$local_name" && -f "${SCRIPT_DIR}/${local_name}" ]]; then
    cp -f "${SCRIPT_DIR}/${local_name}" "$out_svg"
    echo "✓ ${name}: installed from local ${local_name}"
    install_icon_meta "$name"
    return 0
  fi

  # 2) Try download
  if download_file "$url" "$out_svg"; then
    echo "✓ ${name}: downloaded from ${url}"
    install_icon_meta "$name"
    return 0
  fi

  # 3) Fallback: if a same-name local file exists (e.g., s3.svg), use it
  if [[ -f "${SCRIPT_DIR}/${name}.svg" ]]; then
    cp -f "${SCRIPT_DIR}/${name}.svg" "$out_svg"
    echo "✓ ${name}: fallback to local ${name}.svg"
    install_icon_meta "$name"
    return 0
  fi

  echo "✗ ${name}: no local file and download failed" >&2
  return 1
}

# Process all providers
for name in "${!PROVIDERS[@]}"; do
  fetch_or_copy "$name" "${PROVIDERS[$name]}" || true
done

# Refresh icon cache (ignore failure if tool is missing)
if have_cmd gtk-update-icon-cache; then
  gtk-update-icon-cache -f /usr/share/icons/hicolor || true
fi

# Ensure dynamic re-apply on session init (optional helper hook)
cat >"${AUTOSTART_DIR}/emblems.desktop"<<'EOL'
[Desktop Entry]
Type=Application
Name=Folder Emblems
Exec=/dockerstartup/emblems.sh
EOL
chmod +x "${AUTOSTART_DIR}/emblems.desktop" || true
