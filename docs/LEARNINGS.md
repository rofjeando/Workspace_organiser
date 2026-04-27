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
- Canonical source: `implementation/toml_configs/aerospace.toml`
- Symlink so edits to the project file take effect immediately:

```sh
ln -sf ~/Library/CloudStorage/Dropbox/Automation/Workspace_organiser/implementation/toml_configs/aerospace.toml ~/.aerospace.toml
```

- Reload after edits: `alt-shift-;` → `esc`, or `aerospace reload-config` in terminal
- Validate: `aerospace config` prints the parsed config

---

## 4. Version Gotchas (0.20.3-Beta)

| Key | Status |
|---|---|
| `auto-reload-config` | **Not available** — added in a later version. Causes parse failure. |
| `preset = 'azerty'` | **Not available** — only `qwerty`, `dvorak`, `colemak`. See section 13. |
| `config-version = 2` | Required for `persistent-workspaces` and other modern features. |

---

## 5. Monitor Setup

```
1 | Elgato Prom.           — Zoom / teaching sessions
2 | Built-in Retina        — MacBook 14" native screen  (workspace D)
3 | LG HDR WQHD            — Primary workspace screen
```

Monitor names come from: `aerospace list-monitors`

Workspaces are pinned to monitors via `workspace-to-monitor-force-assignment`.
Without this, AeroSpace places workspaces on whichever monitor was last active —
causing apps to appear on the wrong screen after relaunch.

---

## 6. Workspace Strategy

Named letter workspaces — letters are meaningful and memorable.
On AZERTY keyboards, see section 13 for which physical keys to press.

| Key (QWERTY) | Workspace | Monitor | Apps |
|---|---|---|---|
| `alt-n` | **N** Notes | LG | Skim, DEVONthink, Antidote, Typora |
| `alt-q` ¹ | **A** Automation | LG | KM, WezTerm, opcode, Windsurf, Comet, ScriptDebugger |
| `alt-p` | **P** Presentation | LG | Keynote, Affinity Designer 2 |
| `alt-s` | **S** Session-zoom | Elgato | Zoom only |
| `alt-b` | **B** Booking | LG | Mail, BusyCal, BBEdit |
| `alt-r` | **R** Reading | LG | Safari |
| `alt-o` | **O** sOund | LG | Audio Hijack, Audirvana Studio |
| `alt-d` | **D** Desktop | MacBook | Overflow / MacBook-only work |

¹ `alt-q` on AZERTY = press key labeled `a`. See section 13.

**Nomadic apps** (no fixed workspace — go wherever focus is when launched):
Finder, Obsidian, Quiver, IINA. Move with `alt-shift-[letter]`.

**Finder** is set to float globally (`layout floating` in `on-window-detected`)
so it overlays without displacing tiled windows.

---

## 7. App → Workspace Assignment

Use `[[on-window-detected]]` rules in the TOML:

```toml
[[on-window-detected]]
    if.app-id = 'net.sourceforge.skim-app.skim'
    run = 'move-node-to-workspace N'
```

Rules fire when a window **first appears** — not on state changes to existing windows.
They run at AeroSpace startup (existing windows) and on new app launches.

Apps already open when rules are added will **not** be moved automatically.
Quit and relaunch each app, or move manually with `alt-shift-[letter]`.

To get a bundle ID:
```sh
mdls -name kMDItemCFBundleIdentifier /Applications/App.app
# For apps in subfolders:
mdls -name kMDItemCFBundleIdentifier "/Applications/Antidote/Antidote 11.app"
```

`implementation/shell_scripts/get_bundle_ids.sh` lists bundle IDs for all
currently running GUI apps — run from KM to identify any new app.

---

## 8. The Tiling Paradigm

**A single window on a workspace fills the entire screen.** This is not fullscreen —
it is correct tiling behaviour. It looks like fullscreen but AeroSpace controls it.
Add a second window to the same workspace and they split automatically.

To get windows side by side: they must be on the **same workspace**.
Use `alt-shift-[letter]` to move a window to the workspace where another already lives.

For a WQHD screen, 2–3 tiled windows is the sweet spot.

### Layout commands

| Binding | Action |
|---|---|
| `alt-/` | Toggle tiles horizontal / vertical |
| `alt-,` | Toggle accordion (one visible, cycle through stack) |
| `alt-h/j/k/l` | Focus window left/down/up/right |
| `alt-shift-h/j/k/l` | Move window left/down/up/right |
| `alt-minus` / `alt-=` | Resize smart −50 / +50 px |
| `cmd-drag` window edge | Proportional resize — AeroSpace respects it |

### Creating a nested vertical container (3 cols, last col split)

1. Focus the window that should be bottom-right
2. `alt-shift-;` → enter service mode  (AZERTY: `alt-shift` + key labeled `m`)
3. `alt-shift-k` (join-with up) → merges with window above into vertical stack
4. `esc` → exit service mode

### Service mode bindings  (`alt-shift-;` to enter · `esc` to exit)

| Key | Action |
|---|---|
| `esc` | Reload config + return to main |
| `r` | Flatten workspace tree (reset layout) |
| `f` | Toggle float / tile for focused window |
| `backspace` | Close all windows except current |
| `alt-shift-h/j/k/l` | Join window with neighbour (nested container) |

---

## 9. macOS Native Fullscreen — Do Not Use

The green button puts a window into macOS native fullscreen, removing it from
AeroSpace's control into its own isolated macOS Space.

- `on-window-detected` **cannot** intercept this — it only fires on new windows.
- To escape: press `alt-f` (bound to `macos-native-fullscreen off`)
  or the macOS shortcut `ctrl-cmd-f`.

**Avoid the green button** when using AeroSpace.

---

## 10. Multi-Monitor Behaviour

### Menu bar indicator

`S | D | *B` — one entry per monitor, separated by `|`, in monitor order:
- Each letter = the workspace currently active on that monitor
- `*` = the monitor that currently has keyboard focus

Example: `S | D | *B` means Elgato shows S, MacBook shows D, LG shows B (focused).

### Monitor check in shell scripts

When a macro uses `layout floating` + precise `x,y,w,h` coordinates, those
coordinates are screen-specific. Always check which monitors are connected first:

```bash
if /opt/homebrew/bin/aerospace list-monitors | grep -q "LG HDR WQHD"; then
    # Three-screen coordinates
    WIN_X=0; WIN_W=1280; WIN_H=1440
else
    # MacBook-only coordinates
    WIN_X=0; WIN_W=756; WIN_H=415
fi
```

Macros that only do `move-node-to-workspace` (no coordinates) do **not** need
a monitor check — AeroSpace migrates workspaces to the available monitor automatically.

---

## 11. Floating Windows

Every AeroSpace window is either **tiled** (AeroSpace controls position/size)
or **floating** (released to macOS — behaves like a normal window).

**To float a window:**
- Keyboard: `alt-shift-;` → `f` (service mode toggle)
- Shell: `/opt/homebrew/bin/aerospace layout floating`
- Config rule: `run = 'layout floating'` in `[[on-window-detected]]`

**Why floating matters for KM macros:**
AeroSpace immediately undoes any KM `MoveAndResize` action on a tiled window.
Always float the window first, then resize:

```
1. Activate Application      [app]
2. Execute Shell Script      /opt/homebrew/bin/aerospace move-node-to-workspace P
3. Execute Shell Script      /opt/homebrew/bin/aerospace layout floating
4. Pause                     0.2s
5. Manipulate Window         MoveAndResize  x=… y=… w=… h=…
```

**Z-order (depth) of floating windows:**
The last app you activate sits on top. To layer windows (e.g. Affinity behind Keynote),
activate Affinity first, then Keynote — Keynote ends up in front.

---

## 12. Session Layout Pattern

Teaching session layout on workspace P (LG screen) + workspace S (Elgato):

```
Elgato:  Zoom (workspace S — student-facing)
LG back: Affinity Designer 2 — full screen (floating)
LG mid:  Keynote — left half (floating, on top of Affinity)
LG top:  IINA — small overlay (floating, position to taste)
```

Setup order matters for z-depth: activate Affinity → Keynote → IINA.
The full setup script is `implementation/shell_scripts/session_setup.sh`.

To switch which app is frontmost during a session:
```bash
osascript -e 'tell application "Keynote" to activate'
osascript -e 'tell application "Affinity Designer 2" to activate'
```

**Phase 2 — move Zoom to LG left half:**
1. Focus the Zoom window
2. Press `alt-shift-p` — Zoom moves to workspace P on LG
3. It tiles with Keynote: [Zoom | Keynote] split automatically

---

## 13. AZERTY Keyboard

AeroSpace has no `azerty` preset — only `qwerty`, `dvorak`, `colemak`.
With `preset = 'qwerty'`, AeroSpace reads **physical key positions**.
On AZERTY, some keys are at different physical positions than on QWERTY:

| Physical position | QWERTY label | AZERTY label | AeroSpace config key |
|---|---|---|---|
| Q position | `q` | `a` | `q` |
| A position | `a` | `q` | `a` |
| W position | `w` | `z` | `w` |
| Z position | `z` | `w` | `z` |
| `;` position | `;` | `m` | `semicolon` |

**In practice for this config:**

| Action | Config key | Press on AZERTY |
|---|---|---|
| Workspace A (Automation) | `alt-q` | `alt` + key labeled `a` |
| Move window → workspace A | `alt-shift-q` | `alt-shift` + key labeled `a` |
| Enter service mode | `alt-shift-semicolon` | `alt-shift` + key labeled `m` |
| All other workspaces (N,B,P,R,O,S,D) | same letter | same key |

The AZERTY compensation is built into the binding names in the config —
do not set `preset = 'azerty'` (it does not exist and causes a parse error).

---

## 14. Keyboard Maestro Integration

### Full path required

KM's shell environment does not include `/opt/homebrew/bin` in PATH.
Always use the full path for every `aerospace` command in KM:

```bash
/opt/homebrew/bin/aerospace layout floating
/opt/homebrew/bin/aerospace move-node-to-workspace R
/opt/homebrew/bin/aerospace workspace N
/opt/homebrew/bin/aerospace reload-config
```

### KM variable → shell script (two modes)

**Inline text mode** (`UseText = true`): KM substitutes `%Variable%Name%` before
running — pass the variable directly as an argument:
```bash
/bin/bash "/path/to/script.sh" "%Variable%WorkspaceLetter%"
```

**File mode** (`UseText = false`, `Path` set to script): KM exports all KM variables
as shell environment variables. The script reads them by name:
```bash
WORKSPACE="${1:-$WorkspaceLetter}"   # $1 if called with arg, else KM env var
```
Use `tr -d '[:space:]'` to strip accidental spaces from the value.

### KM Prompt with List — `__` separator

In KM's "Prompt for Input with List", the `__` separator splits display from value:
```
R__Reading    (Safari)
```
KM displays the full line but returns only `R` to the variable.
**No space before `__`** — `S __…` returns `S ` (with trailing space) which
AeroSpace rejects as an unknown workspace name.

### Universal window-move pattern

```
1. Activate Application      [target app]
2. Pause                     0.2s          ← gives AeroSpace time to detect focus
3. Shell Script              aerospace move-node-to-workspace [X]
4. Shell Script              aerospace layout floating         ← only if positioning
5. Pause                     0.15s                            ← only if positioning
6. Manipulate Window         MoveAndResize x y w h            ← only if positioning
```

Steps 4–6 are only needed when you require exact pixel coordinates.
For tiling (auto-split), stop at step 3.

### Reusable scripts in this project

| Script | Purpose |
|---|---|
| `aerospace_move.sh [X]` | Move focused window to workspace X and switch there |
| `aerospace_move_interactive.sh` | Same, reads workspace from KM env var `$WorkspaceLetter` |
| `session_setup.sh` | Full teaching session layout (floating, layered, LG screen) |
| `float_half_screen.sh` | Float focused window and snap to left half of LG |
| `get_bundle_ids.sh` | List bundle IDs of all running GUI apps |

---

## 15. Bundle ID Reference

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
| IINA | `com.colliderli.iina` |
