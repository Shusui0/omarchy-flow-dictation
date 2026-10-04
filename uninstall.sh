#!/usr/bin/env bash
set -euo pipefail
BINDINGS="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua"
python3 - "$BINDINGS" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
if not p.exists():
    raise SystemExit(0)
lines = p.read_text().splitlines(keepends=True)
start = "-- BEGIN omarchy-flow-dictation managed binding"
end = "-- END omarchy-flow-dictation managed binding"
starts = [i for i, line in enumerate(lines) if line.strip() == start]
ends = [i for i, line in enumerate(lines) if line.strip() == end]
if not starts and not ends:
    raise SystemExit(0)
if len(starts) != 1 or len(ends) != 1 or starts[0] >= ends[0]:
    raise SystemExit("Malformed managed binding block; bindings file left unchanged.")
p.write_text("".join(lines[:starts[0]] + lines[ends[0] + 1:]))
PY
hyprctl reload
echo "Removed the managed keybindings. Run 'omarchy plugin remove shusui.flow-dictation' to remove the plugin files. Dictation settings are kept."
