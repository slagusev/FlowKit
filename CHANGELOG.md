# FlowKit Fork Changelog

All notable changes to **slagusev/FlowKit** (not upstream LexianDEV).

## 3.2.0 — Max impact + runtime power + pain providers

### 1 — Maximum impact
- **Breakpoints** on events (context menu 🔴) — force step mode before actions
- **Step highlight**: `debug_active_*` on system + event-row yellow modulate + overlay banner
- **Expression autocomplete** popup (`FKExpressionAutocomplete`)
- **Action picker categories** (headers by supported type)
- **Mute UI**: Enabled on action/condition context menus + [OFF] dimming
- **Sheet JSON** export/import (File menu → `res://flowkit/event_sheets/export_*.json`)

### 2 — Runtime
- Pick Nodes: **RandomOne**, **InvertFilter**, **MaxCount**
- **Define Family** / **Pick Family** (`system.families`)
- **Instance vars** inspector section (`flowkit_variables` / `n_name`)
- **Run Parallel Subsheets** (fire-and-forget)
- **Save / Load Sheet State** (`user://flowkit_save_<slot>.json`)
- **Profiler** top-3 last action µs in debug overlay

### 3 — Architecture / quality
- `FKSheetJsonIO`, paste controller stub, unit tests for JSON/breakpoint/autocomplete
- Action timing via `record_profile`

### 4 — Providers (pain points)
- Multiplayer: On Peer Connected
- TileMapLayer: Set Cell
- Set Shader Param (CanvasItem / GeometryInstance3D)
- Load Resource → system var
- InputMap Set Action Key

## 3.1.0 — Roadmap A→G (typed inputs, multi-select, step debug, pick/return, nav/anim)

### A — Expression typed inputs + behavior param UI
- Expression modal: bool checkbox, int/float SpinBox, Expression toggle (`FKTypedParamWidgets`)
- Behavior inspector: typed widgets for bool/int/float params

### B — Multi-select + bulk
- Ctrl/Cmd+click multi-select events and items (`FKSelectionManager`)
- Bulk delete / multi-event copy
- Ctrl+Shift+D disable · Ctrl+Shift+E enable
- `enabled` flag on actions and conditions (runtime skip)

### C — Debugger step / condition explain
- Condition fail messages with id, target, inputs (`last_cond_fail`)
- F8 step mode, F9 continue one action; overlay shows step state

### D — Architecture + CI
- `FKMainEditorBranchController`, selection manager, sheet filter helper (from 3.0)
- GitHub Actions: **Godot 4.6.1**, hard timeouts on import/tests

### E — Subsheet return + pick/families
- **Set Subsheet Return** → `system.subsheet_return` / `r_value`
- Call Subsheet **StoreAs** sheet var
- **Pick Nodes** (group/class/filter) → `system.picked`
- **For Each Picked** runs a subsheet per picked node

### F — Targeted providers
- NavigationAgent2D/3D: set target position, is navigation finished
- AnimationTree: set state, set blend, on animation finished

### G — Docs
- README v3.1, website section, `demos/templates/README.md`

## 3.0.0 — Architecture debt + multi-behavior + subsheet params

### Architecture debt
- **Registry-backed modals**: action / event / condition / node pickers load providers from `FKRegistry` instead of scanning disk
- **`FKProviderCompat`**: shared node-type compatibility checks
- **`FKMainEditorSheetFilter`**: filter matching extracted from `main_editor.gd`
- **`FKBehaviorMeta`**: multi-behavior node meta (`flowkit_behaviors`) with legacy `flowkit_behavior` mirror
- **Group normalize**: sets `_is_normalized`, recurses nested groups
- **`FKSheetVarDef`**: typed sheet-var resource + coerce helpers (`.tres` still stores dicts)

### High priority
- **Multi-behavior inspector** (list + Add/Remove + params)
- **Apply Behavior** / **Remove Behavior** runtime actions
- **Subsheet parameters** (panel + Call Subsheet `ArgsJson` → `p_name` / `system.subsheet_params`)
- **Await Signal** multi-frame action (optional timeout)
- **Debug overlay**: F4 hide, F6 pause, F7 clear; timestamps + params/current
- **Expression helpers**: more math/random snippets, subsheet param list

### Providers
- Actions: Emit Signal, Set Modulate, Look At Position 3D, Set Progress Value
- Condition: Compare Subsheet Param
- Event: On Text Focus Exited
- Behavior: Drift Velocity (Node2D)

### Website
- Landing updated for v3.0 feature set

## 2.9.0 — Large 2D / 3D / UI behaviors & events expansion

### Behaviors (~31 total)
- **2D:** twin-stick, dash, rigid thrust, sine X, pulse scale, wrap screen, auto flip sprite, camera mouse look
- **3D:** platformer, fly, rotate Y, bob Y, orbit Y, camera follow group, rigid thrust
- **UI:** fade pulse, float bob, auto-fill range, typewriter label

### Events (~103 total)
- **2D:** ceiling hit, start/stop moving, Area mouse/input, CPUParticles/Audio2D finished, camera current, TileMapLayer changed
- **3D:** left floor/wall, Area mouse/input, screen notifier, NavigationAgent3D, particles, rigid exit, camera current
- **UI:** press started, visibility, lineedit focus, range changed, item activated, popup hide, tree select, color changed

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
