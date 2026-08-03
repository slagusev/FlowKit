# FlowKit (enhanced fork)

[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5%2B-blue.svg)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**This repository is a fork of [LexianDEV/FlowKit](https://github.com/LexianDEV/FlowKit).**  
Improvements here are maintained independently and are **not** automatically contributed back to the upstream project.

Clickteam Fusion 2.5 / Construct–inspired **visual event sheets** for Godot 4.

- Upstream: https://github.com/LexianDEV/FlowKit  
- This fork: https://github.com/slagusev/FlowKit  
- Site assets (fork): `website/` in this repo  

## What's different in this fork (2.4)

### High-priority features
- **Sheet variables** — define on the right panel; use `s_name` or bare name in expressions; **Set Sheet Variable** / **Compare Sheet Variable**
- **Subsheets** — create named lists; **Call Subsheet** runs them
- **For Each** — group and/or class + subsheet; `current` in expressions
- **Debug overlay** (F4) — last events, condition fails, expression errors, live vars (debug builds)
- **Event flags** — Enabled / Trigger Once / Once While True (context menu)
- **Expression editor** — live paren/quote check, helpers, sheet-var snippets
- **Performance** — provider id index O(1)
- **UX** — dirty indicator, Ctrl+F filter, jump-to match, meta panel save-safe

---

## Earlier (2.3)

### Massive provider expansion (2D / 3D / UI)
- **2D:** Camera2D, Sprite2D, RigidBody2D, Light2D, particles, collision layers, PathFollow2D, RayCast2D, area/area signals, animation finished, tweens (scale/modulate), velocity vector
- **3D:** Node3D transform/tween, RigidBody3D, Light3D, particles, AudioStreamPlayer3D, collision layers, RayCast3D, area entered, ceiling check
- **UI:** position/size/scale/rotation, tooltips, mouse filter, focus, tabs, OptionButton, ItemList, popups, texture, text helpers, progress min/max/add, many UI events (submit, select, tab, button down/up)

---

## Earlier (2.2)

### OR condition groups
- Right-click a condition → **OR with previous**
- Within an OR group any condition may pass; groups are still AND'd
- Visual `OR` separator between linked conditions

### Sheet filter
- Filter bar in the FlowKit top bar — matches events, conditions, actions, comments

### 3D & UI providers
- CharacterBody3D / Node3D / Camera3D / Area3D events & actions
- UI: visibility, modulate, disable, focus, progress, color, text equals, toggles, mouse enter/exit

---

## Earlier (2.1)

### Stability
- Multi-frame actions use **per-invocation wait tokens** (no shared hang flag)
- Nested branch **deep-copy** on drag-drop / `duplicate_block`
- **On Ready** waits for `Node.ready` (or next frame if already ready)
- **Wait For Input** validates Input Map bindings and has a safety timeout
- Expression evaluator always injects **global system variables**

### UX
- Selector search matches **name + id + description**
- Auto-focus search; Enter confirms the first match
- Alphabetical provider lists

### Sheets
- Default save path: `res://flowkit/event_sheets/<SceneName>_<uid>.tres`
- Still loads legacy `res://addons/flowkit/saved/event_sheet/<uid>.tres`
- Optional override: Project Setting `flowkit/event_sheets/directory`

### New providers (examples)
| Type | Providers |
|------|-----------|
| Events | Area2D On Body Entered / Exited |
| Conditions | Is on Wall / Ceiling, Distance Less Than, Random Chance |
| Actions | Queue Free, Look At Position, Tween Position, Create Instance, Play Animation, Call Function |
| System | Define Function (registers expression body) |

### Other
- Removed shipped `.bak` files
- Fixed `FKEvent.get_class()` mislabel
- GUT tests for expression evaluator + enabled undo tracker tests
- Updated marketing site under `website/`

## Requirements

- Godot **4.5+** (developed against **4.6.2**)
- GDScript only (no GDExtension)

## Installation

1. Clone this fork or copy `addons/flowkit` into your project.
2. Enable **FlowKit** under **Project → Project Settings → Plugins**.
3. Open the FlowKit main screen and create a sheet for the current scene.

Demo scenes: `addons/flowkit/demos/`.

## Custom providers

Create a `.gd` file under:

- `addons/flowkit/actions/<Category>/`
- `addons/flowkit/conditions/<Category>/`
- `addons/flowkit/events/<Category>/`

Extend `FKAction`, `FKCondition`, or `FKEvent` and implement `get_id()`, `get_name()`, `get_supported_types()`, and the execute/check/poll (or signal setup) API.

## Testing

With GUT enabled:

```text
# From the project root, using Godot CLI
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

## License

MIT — see [LICENSE](LICENSE).  
Copyright of original work remains with LexianDEV; fork modifications by slagusev.

## Credits

- [LexianDEV](https://github.com/LexianDEV) — original FlowKit
- Clickteam Fusion, Construct, Scratch — design inspiration
- Godot Engine
