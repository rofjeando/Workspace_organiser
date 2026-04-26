# Claude Instructions — Workspace_organiser

## Project Context

This project manages AeroSpace configuration for macOS window management. AeroSpace is an i3-inspired tiling window manager that replaces native macOS Spaces.

- **AeroSpace version:** 0.20.3-Beta
- **Config location:** `~/.aerospace.toml` (canonical source in `implementation/toml_configs/aerospace.toml`)
- **Docs:** https://nikitabobko.github.io/AeroSpace/guide

## Folder Conventions (from FolderGuideline.md in KM_organiser)

- Use `snake_case` for all folder names
- `guides/` for documentation and tutorials
- `implementation/` for actual executable/config files
- Be specific with subfolder names (e.g. `toml_configs`, not just `configs`)

## AeroSpace Key Facts

- Config format: TOML (`config-version = 2`)
- No SIP disabling required
- Workspaces are AeroSpace-managed (not macOS Spaces — disable Spaces in System Settings)
- Reload config: `aerospace reload-config` or via service mode (`alt-shift-;` → `esc`)
- App bundle IDs for `on-window-detected`: use `mdls -name kMDItemCFBundleIdentifier /Applications/App.app`

## Workflow Notes

- When editing `aerospace.toml`, always update both `implementation/toml_configs/aerospace.toml` AND `~/.aerospace.toml` (or keep them in sync via symlink)
- Test config validity: `aerospace config` prints the parsed config
