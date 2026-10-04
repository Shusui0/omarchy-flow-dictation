# Omarchy Flow Dictation

A small system-wide voice dictation helper for Omarchy/Hyprland, inspired by Wispr Flow. Press **Super+Fn** or **Super+Shift+V** to record; press the same shortcut again to stop, and the finished text is typed into the current cursor. Press **Super+Alt+Fn** or **Super+Alt+Shift+V** to cancel and discard the recording. It does not press Enter or submit anything.

This plugin is community code. It runs unsandboxed with your user permissions; inspect the source before installing. Marketplace listing and validation are not a security review.

## Screenshot

The combined assistant and microphone button appears in the Omarchy bar. Click it to start or stop dictation.

<img src="screenshots/flow-dictation-bar.png" alt="Flow Dictation button in the Omarchy bar" width="900">

## Install

Requirements: Omarchy Quattro, Python 3, `pw-record`, `wtype`, `notify-send`, `whisper-cli` with a Whisper model, and Ollama with the `qwen2.5:7b` model for local correction. Omarchy provides `hyprctl`, the plugin manager, and the Hyprland bindings file. The script checks the system commands it needs; it does not install packages or download models.

Install and enable the plugin from its public GitHub repository:

```bash
omarchy plugin add https://github.com/shusui0/omarchy-flow-dictation.git --enable
cd ~/.config/omarchy/plugins/shusui.flow-dictation
./install.sh
```

The Marketplace install places the bar widget and helper in the plugin directory. Running `install.sh` adds marked global keybindings to `~/.config/hypr/bindings.lua`, creates a default config under `~/.config/omarchy-flow-dictation/` if one does not exist, reloads Hyprland, validates the plugin, and enables it on the right side of the bar. It refuses to install if either default shortcut is already in use. Change the shortcuts in the managed `o.bind(...)` lines if needed.

Fn key note: Linux/Hyprland can bind this only if your keyboard exposes Fn as the `XF86Fn` key event. Some keyboards handle Fn internally and do not report it to the operating system. The fallback **Super+Shift+V** works without an Fn event.

To remove the global keybindings and plugin while keeping your dictation configuration:

```bash
./uninstall.sh
omarchy plugin remove shusui.flow-dictation
```

## Transcription

Local mode is the default. Install `whisper.cpp` and a model supported by its `whisper-cli`, then edit `~/.config/omarchy-flow-dictation/config.ini` and set `transcription.model` to the model file path. Set `transcription.language` to a Whisper language code (for example `en`) or leave it blank for automatic detection.

For an OpenAI-compatible transcription endpoint, change `provider` to `openai-compatible`, configure `base_url`, and export the configured key variable (default `FLOW_API_KEY`) in the graphical session environment before starting Omarchy. This mode sends the active recording to that endpoint.

AI cleanup is enabled by default and runs locally through Ollama using `qwen2.5:7b`. It fixes clear grammar, spelling, capitalization, and punctuation issues; removes obvious fillers and false starts; and applies spoken self-corrections such as “meet at 2… actually 3.” Ambiguous wording is left as transcribed. To disable cleanup, set `writing.polish = false`. To use a cloud chat endpoint instead, set `writing.polish_backend = openai-compatible` and configure the cloud API settings and key. If cleanup fails, the raw transcript is still typed.

## Privacy and behavior

- Microphone capture begins only after the shortcut is pressed. Press it again to stop and transcribe.
- The temporary WAV lives under `$XDG_RUNTIME_DIR/omarchy-flow-dictation` when available and is deleted after processing.
- Local transcription and the default Ollama cleanup keep audio and text on-device. Cloud transcription uploads active recordings; cloud cleanup sends the transcript. No background capture or transcript history is kept.
- Text is typed directly into the focused app using `wtype`; the clipboard is untouched. Line breaks and tabs are flattened to spaces so typing cannot submit a message or execute a terminal command.
- Insertion targets whichever field is focused when processing finishes. Wayland does not provide a universal reliable way to identify secure fields or restore the original focus. Do not dictate secrets. If an app blocks virtual keyboard input, this plugin cannot type there.
- Terminal text is typed with line breaks flattened to spaces; it is never executed. Review it before pressing Enter yourself.

## Troubleshooting

- No recording: check that PipeWire is running and the microphone is available to `pw-record`.
- “Whisper CLI not found” or model error: install `whisper.cpp`, then set the correct `command` and model path.
- No text appears: ensure `wtype` is installed and the current app accepts Wayland virtual keyboard input.
- Shortcut conflict: pick another key combination in the managed binding line, then run `hyprctl reload`.
- Runtime diagnostics stay private: errors are shown via desktop notifications; audio and transcripts are not logged.
- Global shortcut files are managed as a marked block in `~/.config/hypr/bindings.lua`; removal deletes only that block. The dictation config and downloaded models are kept.

## Current scope

This initial plugin supports start/stop dictation, local Whisper CLI or OpenAI-compatible transcription, local Ollama or optional cloud AI cleanup, and direct keyboard typing. It does not yet include a review window, personal dictionary/snippets, app-aware context, meeting recording, or live partial transcripts.
