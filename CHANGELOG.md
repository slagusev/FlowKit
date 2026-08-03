# FlowKit Fork Changelog

All notable changes to **slagusev/FlowKit** (not upstream LexianDEV).

## 2.8.0 — More behaviors & events

### Behaviors (+10)
- 8-Dir Movement, Follow Mouse, Bounce (CharacterBody2D)
- Rotate Constantly, Bob Up/Down, Look At Mouse (Node2D)
- Path Follow (PathFollow2D)
- Camera Follow Target, Screen Shake (Camera2D)
- Top-Down Movement 3D (CharacterBody3D)

### Events (+20)
- CharacterBody2D: On Landed / Left Floor / Bumped Wall
- CharacterBody3D: On Landed
- VisibleOnScreenNotifier2D entered/exited
- NavigationAgent2D target/nav finished
- Particles finished, Path end, Tween finished (meta)
- HTTPRequest / FileDialog / GUI click / tree / child entered
- Animation started, RigidBody2D body exited, Area shape entered

## 2.7.0 — Visual AND/OR groups, subsheet retarget, stricter CI, site update

### Added
- **Visual AND/OR condition groups** in the event sheet (OR groups boxed, AND between groups)
- Subsheet action **Retarget** (new node) and **Change** (new node + action type)
- Website updated for v2.7 feature set

### Improved
- CI downloads Godot 4.4.1, runs import + GUT without `continue-on-error` on tests

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
