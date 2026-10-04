#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy-flow-dictation"
BINDINGS="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua"
PLUGIN_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/shusui.flow-dictation"
MARK="-- BEGIN omarchy-flow-dictation managed binding"

for bin in python3 pw-record wtype notify-send; do
  command -v "$bin" >/dev/null || { echo "Missing required command: $bin" >&2; exit 1; }
done
[[ -f "$BINDINGS" ]] || { echo "Omarchy Hyprland bindings file not found: $BINDINGS" >&2; exit 1; }
if ! rg -qF -- "$MARK" "$BINDINGS" && rg -q 'SUPER\s*\+\s*(ALT\s*\+\s*)?XF86Fn' "$BINDINGS"; then
  echo "A dictation shortcut appears in $BINDINGS. Resolve that binding before installing." >&2
  exit 1
fi

mkdir -p "$CONFIG" "$PLUGIN_DEST"
if [[ "$ROOT" != "$PLUGIN_DEST" ]]; then
  rm -f "$PLUGIN_DEST/FlowDictationWidget.qml" "$PLUGIN_DEST/Panel.qml"
  install -m 0644 "$ROOT/manifest.json" "$ROOT/BarWidget.qml" "$PLUGIN_DEST/"
  install -m 0755 "$ROOT/flow_dictation.py" "$PLUGIN_DEST/flow_dictation.py"
fi
if [[ ! -e "$CONFIG/config.ini" ]]; then install -m 0600 "$ROOT/config.ini" "$CONFIG/config.ini"; fi
python3 - "$BINDINGS" "$PLUGIN_DEST" <<'PY'
from pathlib import Path
import sys
p, dest = Path(sys.argv[1]), sys.argv[2]
lines = p.read_text().splitlines(keepends=True)
start = "-- BEGIN omarchy-flow-dictation managed binding"
end = "-- END omarchy-flow-dictation managed binding"
starts = [i for i, line in enumerate(lines) if line.strip() == start]
ends = [i for i, line in enumerate(lines) if line.strip() == end]
if bool(starts) != bool(ends) or len(starts) > 1 or len(ends) > 1 or (starts and starts[0] >= ends[0]):
    raise SystemExit("Malformed managed binding block; bindings file left unchanged.")
block = [
    f"{start}\n",
    f'o.bind("SUPER + XF86Fn", "Flow dictation", "{dest}/flow_dictation.py")\n',
    f'o.bind("SUPER + ALT + XF86Fn", "Cancel dictation", "{dest}/flow_dictation.py cancel")\n',
    f'o.bind("SUPER + SHIFT + V", "Flow dictation (fallback)", "{dest}/flow_dictation.py")\n',
    f'o.bind("SUPER + ALT + SHIFT + V", "Cancel dictation (fallback)", "{dest}/flow_dictation.py cancel")\n',
    f"{end}\n",
]
updated = lines[:starts[0]] + block + lines[ends[0] + 1:] if starts else lines + ["\n"] + block
p.write_text("".join(updated))
PY
echo "Installed Flow Dictation files under $PLUGIN_DEST. Reloading Hyprland config…"
hyprctl reload
omarchy plugin validate "$PLUGIN_DEST"
omarchy-shell shell rescanPlugins
omarchy plugin enable shusui.flow-dictation --section right
echo "Flow Dictation is enabled in the Omarchy plugin list and bar. Press Super+Fn, Super+Shift+V, or click its microphone icon to start/stop."
