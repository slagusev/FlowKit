# FlowKit Fork Changelog

All notable changes to **slagusev/FlowKit** (not upstream LexianDEV).

## 2.6.0 — Favorites everywhere, subsheet node pick, CI, provider matrix

### Added
- **Favorites** for events and conditions (★, Ctrl/right-click) — same UX as actions
- **Subsheet Add Action** starts with **node picker** (any scene node or System), then action
- `tools/generate_provider_matrix.gd` → `docs/PROVIDER_MATRIX.md`
- GitHub Actions workflow `.github/workflows/tests.yml` (GUT + matrix gen)

## 2.5.0 — Subsheet editor, favorites, sheet-var snippets

### Added
- **Subsheet action editor** in the right panel: Add / Edit / Remove / reorder actions
- **Favorites** for actions (★): Ctrl+click or right-click in action picker; shown above recent
- Expression snippets list live **sheet variables** (`s_name` + bare name)

### Improved
- Condition OR styling (`or ·` badge + color)
- Subsheet workflow integrated with expression modal

## 2.4.0 — High-priority runtime & editor

### Added
- Sheet-local variables + meta panel
- Subsheets + Call Subsheet + For Each
- Debug overlay (F4)
- Event flags: Enabled / Trigger Once / Once While True
- Provider O(1) index; dirty indicator; Ctrl+F filter

## 2.3.0 — Provider expansion

Large 2D / 3D / UI action, condition, and event sets.

## 2.2.0 — OR groups, filter, early 3D/UI

OR condition groups, sheet filter bar, Area2D/3D and base UI providers.

## 2.1.0 — Stability fork

Multi-frame wait isolation, deep-copy fixes, project-local sheets, expression globals.
