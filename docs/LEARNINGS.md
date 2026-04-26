# AeroSpace — Learnings & Setup Notes

Accumulated during the initial setup of AeroSpace 0.20.3-Beta on macOS Tahoe (26.x)
with a 3-monitor setup: LG HDR WQHD · MacBook Pro 14" Built-in · Elgato Prom.

---

## 1. What AeroSpace Is

AeroSpace is an i3-inspired tiling window manager for macOS. It:
- Creates its own virtual workspaces, bypassing macOS native Spaces entirely
- Requires no SIP disabling
- Is configured purely through a single TOML file (`~/.aerospace.toml`)
- Is installed via Homebrew: `brew install --cask nikitabobko/tap/aerospace`

The paradigm shift: **you stop resizing windows and start switching workspaces**.
Each workspace is a context (Notes, Automation, etc.) rather than just a position.

---

## 2. Installation

```sh
brew tap nikitabobko/tap
brew install --cask nikitabobko/tap/aerospace
```

After launch, grant **Accessibility** permission in System Settings when prompted.
The app adds a menu bar indicator showing the active workspace on each monitor.

**macOS Spaces**: keep exactly **one** native Space. AeroSpace runs on top of it.
Remove extra Spaces via Mission Control (hover → click `×`).

---

## 3. Config File

- Location: `~/.aerospace.toml`
- In this project, the canonical source is `implementation/toml_configs/aerospace.toml`
- `~/.aerospace.toml` is a symlink to the project file:

```sh
ln -sf ~/Library/CloudStorage/Dropbox/Automation/Workspace_organiser/implementation/toml_configs/aerospace.toml ~/.aerospace.toml
```

- Reload after edits: `alt-shift-;` → `esc`, or `aerospace reload-config` in terminal
- Validate: `aerospace config` prints the parsed config

---

## 4. Version Gotchas (0.20.3-Beta)

| Key | Status |
|---|---|
| `auto-reload-config` | **Not available** — added in a later version. Remove it or config fails to parse. |
| `config-version = 2` | Required for `persistent-workspaces` and other modern features |

---

## 5. Monitor Setup

```
1 | Elgato Prom.           — Zoom / teaching sessions
2 | Built-in Retina        — MacBook 14" native screen
3 | LG HDR WQHD            — Primary workspace screen
```

Workspaces are pinned to monitors via `workspace-to-monitor-force-assignment`.
Without this, AeroSpace places workspaces on whichever monitor was last active.

---

## 6. Workspace Strategy

Named letter workspaces instead of numbers — letters are meaningful and memorable.

| Key | Workspace | Apps |
|---|---|---|
| `alt-n` | **N** Notes/Writing | Skim, DEVONthink, Antidote, Typora |
| `alt-a` | **A** Automation | KM, WezTerm, opcode, Windsurf, Comet, ScriptDebugger |
| `alt-s` | **S** Sessions | Keynote, Affinity Designer 2, Zoom |
| `alt-b` | **B** Booking | Mail, BusyCal, BBEdit |
| `alt-r` | **R** Reading | Safari |
| `alt-o` | **O** sOund | Audio Hijack, Audirvana Studio, Loopback |

**Nomadic apps** (no fixed workspace — follow focus): Finder, Obsidian, Quiver, IINA.
Move them anywhere with `alt-shift-[letter]`.

**Finder** is set to float globally so it overlays without displacing tiled windows.

---

## 7. App → Workspace Assignment

Use `[[on-window-detected]]` rules in the TOML:

```toml
[[on-window-detected]]
    if.app-id = 'net.sourceforge.skim-app.skim'
    run = 'move-node-to-workspace N'
```

Rules fire when a window **first appears** — not when a window changes state.
They run both at AeroSpace startup (for already-open windows) and on new launches.

To get a bundle ID:
```sh
mdls -name kMDItemCFBundleIdentifier /Applications/App.app
```

For apps in subfolders (e.g. Antidote):
```sh
mdls -name kMDItemCFBundleIdentifier "/Applications/Antidote/Antidote 11.app"
```

The shell script `implementation/shell_scripts/get_bundle_ids.sh` lists bundle IDs
for all currently running GUI apps (designed for use in Keyboard Maestro).

---

## 8. The Tiling Paradigm

**Key insight:** a single window on a workspace fills the entire screen. This is not
fullscreen — it is correct tiling behaviour. Add a second window to the same workspace
and they split the screen automatically.

The workflow change: instead of resizing, **switch workspaces** (`alt-n`, `alt-a`, etc.)
or **tile multiple apps together** on one workspace.

For a WQHD screen, 2–3 tiled windows is the sweet spot.

### Layout commands

| Binding | Action |
|---|---|
| `alt-/` | Toggle tiles horizontal / vertical |
| `alt-,` | Toggle accordion (one visible, cycle through stack) |
| `alt-h/j/k/l` | Focus window in direction |
| `alt-shift-h/j/k/l` | Move window in direction |
| `alt-minus` / `alt-=` | Resize smart −50 / +50 px |
| `cmd-drag` window edge | Proportional resize (AeroSpace respects it) |

### Creating a nested vertical container (e.g. 3 cols, last col split)

1. Focus the window that should be bottom-right
2. `alt-shift-;` → enter service mode
3. `alt-shift-k` (join-with up) → merges with window above into vertical stack
4. `esc` → exit service mode

### Service mode bindings (`alt-shift-;` to enter, `esc` to exit)

| Key | Action |
|---|---|
| `esc` | Reload config + return to main |
| `r` | Flatten workspace tree (reset layout) |
| `f` | Toggle float / tile for focused window |
| `backspace` | Close all windows except current |
| `alt-shift-h/j/k/l` | Join window with neighbour (create nested container) |

---

## 9. macOS Native Fullscreen — Do Not Use

The green button puts a window into macOS native fullscreen, which **removes it from
AeroSpace's control** into its own isolated macOS Space.

- `on-window-detected` **cannot** intercept this — it only fires on new windows,
  not on state changes to existing ones.
- To escape: focus the window and press `alt-f` (bound to `macos-native-fullscreen off`)
  or the macOS shortcut `ctrl-cmd-f`.

**Avoid clicking the green button** when using AeroSpace.

---

## 10. Multi-Monitor Behaviour

Without `workspace-to-monitor-force-assignment`, workspaces land on whichever monitor
was last focused when the app launched — causing apps to appear on the wrong screen.

Always pin workspaces explicitly:

```toml
[workspace-to-monitor-force-assignment]
    N = 'LG HDR WQHD'
    S = 'Elgato Prom.'
```

Monitor names come from `aerospace list-monitors`.

---

## 11. Status Bar Apps on macOS Tahoe

macOS Tahoe (26.x) changed the menu bar significantly. Status bar extras (including
Sketchybar) may behave incorrectly. AeroSpace's own built-in menu bar indicator
(showing active workspace per monitor) is sufficient for daily use.
Hold off on third-party bar replacements until Tahoe compatibility stabilises.

---

## 12. Bundle ID Reference

| App | Bundle ID |
|---|---|
| Skim | `net.sourceforge.skim-app.skim` |
| DEVONthink | `com.devon-technologies.think` |
| Antidote 11 | `com.druide.Antidote` |
| Typora | `abnerworks.Typora` |
| Obsidian | `md.obsidian` |
| Keyboard Maestro | `com.stairways.keyboardmaestro.editor` |
| WezTerm | `com.github.wez.wezterm` |
| opcode | `opcode.asterisk.so` |
| Windsurf | `com.exafunction.windsurf` |
| Comet | `ai.perplexity.comet` |
| Script Debugger | `com.latenightsw.ScriptDebugger8` |
| Keynote | `com.apple.iWork.Keynote` |
| Affinity Designer 2 | `com.seriflabs.affinitydesigner2` |
| Zoom | `us.zoom.xos` |
| Mail | `com.apple.mail` |
| BusyCal | `com.busymac.busycal3` |
| BBEdit | `com.barebones.bbedit` |
| Safari | `com.apple.Safari` |
| Audio Hijack | `com.rogueamoeba.audiohijack` |
| Audirvana Studio | `com.audirvana.Audirvana-Studio` |
| Loopback | `com.rogueamoeba.loopback` *(not yet installed)* |
| Finder | `com.apple.finder` |
