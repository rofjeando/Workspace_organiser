# Workspace_organiser

Project for configuring and managing **AeroSpace** — an i3-inspired tiling window manager for macOS that fully replaces native Spaces with fast, animation-free virtual workspaces.

## Goal

- Replace macOS native Spaces with AeroSpace virtual workspaces
- Establish a reproducible, version-controlled window management configuration
- Automate workspace assignment per application
- Integrate with status bar tools (e.g. Sketchybar)

## Quick Start

1. AeroSpace is installed via Homebrew: `brew install --cask nikitabobko/tap/aerospace`
2. Config lives at `~/.aerospace.toml` (symlinked or copied from `implementation/toml_configs/aerospace.toml`)
3. Launch `/Applications/AeroSpace.app` — grant Accessibility permission when prompted
4. Reload config: `alt-shift-;` then `esc`

## Key Bindings (default)

| Action | Binding |
|---|---|
| Focus window | `alt-h/j/k/l` |
| Move window | `alt-shift-h/j/k/l` |
| Switch workspace | `alt-1..9`, `alt-a..z` |
| Move window to workspace | `alt-shift-1..9`, `alt-shift-a..z` |
| Toggle layout (tiles) | `alt-/` |
| Toggle layout (accordion) | `alt-,` |
| Resize window | `alt-minus` / `alt-=` |
| Back-and-forth workspace | `alt-tab` |
| Move workspace to next monitor | `alt-shift-tab` |
| Enter service mode | `alt-shift-;` |

## Folder Structure

```
Workspace_organiser/
├── guides/
│   ├── aerospace_concepts/    # Tiling, containers, tree model
│   ├── keybindings/           # Keybinding reference and customisation
│   ├── workspace_strategies/  # How to organise workspaces per workflow
│   └── integration/           # Sketchybar, Raycast, yabai migration
├── implementation/
│   ├── toml_configs/          # aerospace.toml and variants
│   ├── shell_scripts/         # Helper scripts for automation
│   └── python_scripts/        # Python automation
├── docs/                      # General project documentation
├── miscellaneous/             # Snippets and experiments
└── project-specific/          # Sub-projects
```
