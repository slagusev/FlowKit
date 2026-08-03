# FlowKit (enhanced fork)

[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5%2B-blue.svg)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**This repository is a fork of [LexianDEV/FlowKit](https://github.com/LexianDEV/FlowKit).**  
Improvements here are maintained independently and are **not** automatically contributed back to the upstream project.

Clickteam Fusion 2.5 / Construct–inspired **visual event sheets** for Godot 4.

- Upstream: https://github.com/LexianDEV/FlowKit  
- This fork: https://github.com/slagusev/FlowKit  
- Site assets: `website/`  
- Changelog: [CHANGELOG.md](CHANGELOG.md)  
- Providers: [docs/PROVIDER_MATRIX.md](docs/PROVIDER_MATRIX.md)  
- Templates: [addons/flowkit/demos/templates/](addons/flowkit/demos/templates/)

## What's new in v3.5 — Object Mode phase 2

| Feature | How |
|---------|-----|
| **Recipes** | One-click: Platformer Player, Top-Down Player, Coin, Damage Zone |
| **Collectible** | Area2D pack → +sheet score, free self |
| **Property binds** | `hp` → ProgressBar path (live) |
| **More rules** | var thresholds, damage zone overlap, hide/show |

### Object Mode quick start

1. Select **CharacterBody2D** → Inspector → **Object Mode**
2. Click **Make Platformer Player** (or enable packs manually)
3. Select **Area2D** → **Make Coin / Collectible** (player must be in group `player`)
4. Optional: bind `hp` → `UI/HPBar` for a ProgressBar

Design: [docs/design/OBJECT_MODE.md](docs/design/OBJECT_MODE.md)

Sheets remain for complex logic; packs and sheets share the same runtime.

## Earlier — v3.4 Object Mode MVP

| Pack | Effect |
|------|--------|
| **Platformer 2D** | CharacterBody2D movement + jump |
| **Top-Down 2D** | 4/8-dir movement |
| **Health** | `n_hp` / `n_max_hp`; optional destroy at 0 |

## Earlier — v3.3

| Area | Features |
|------|----------|
| **CI** | Empty main scene, `ci_smoke.gd`, hard timeouts on Godot 4.6 |
| **JSON** | **FileDialog** export/import (no fixed path) |
| **Pickers** | Category **icons** (emoji) + headers for actions/events/conditions |
| **Demo** | `demos/full_loop/` — import JSON → Space awards score → F8/F9 |
| **Docs** | [docs/MIGRATION.md](docs/MIGRATION.md) |

### Full-loop demo

1. Open `addons/flowkit/demos/full_loop/full_loop.tscn`
2. FlowKit → **File → Import Sheet JSON…** → `full_loop_sheet.json`
3. Run · **Space** · **F4** / **F8** / **F9**

## Earlier — v3.2

| Area | Features |
|------|----------|
| **Debugger** | Event **breakpoints** 🔴, step highlight, profiler tops |
| **Editor** | Expression **autocomplete**, action **categories**, mute UI, **JSON export/import** |
| **Runtime** | Pick random/invert/max, **families**, parallel subsheets, **save/load state** |
| **Inspector** | Instance vars (`n_name`) + multi-behaviors |
| **Providers** | Multiplayer peer, TileMapLayer cell, shader param, load resource, InputMap rebind |

## Earlier — v3.1 (A→G)

| Area | Features |
|------|----------|
| **A Expression / behaviors** | Typed bool/int/float widgets in expression modal + behavior inspector; Expression toggle |
| **B Multi-select** | Ctrl+click rows/items; bulk Delete/Copy; **Ctrl+Shift+D/E** disable/enable |
| **C Debugger** | F4 overlay; F6 pause; F7 clear; **F8 step mode**; **F9 continue**; condition-fail explain |
| **D Architecture / CI** | Selection + branch controllers; sheet filter helper; registry modals; CI on **Godot 4.6** |
| **E Subsheets / pick** | Subsheet params `p_`; return `r_value` + StoreAs; **Pick Nodes** + **For Each Picked** |
| **F Providers** | Nav2D/3D target + finished; AnimationTree state/blend/finished |
| **G Docs** | This README, website v3.1, templates, matrix |

## Quick start

1. Copy `addons/flowkit` into your project (enable plugin).
2. Open a scene → FlowKit bottom panel → add events.
3. Sheet Variables / Subsheets: right meta panel.
4. Multi-behavior: select a node → Inspector → **Behaviors (multi)**.
5. Debug builds: **F4** overlay; **F8** step through actions.

### Expressions cheatsheet

| Syntax | Meaning |
|--------|---------|
| `s_score` | Sheet variable |
| `p_damage` | Subsheet parameter |
| `r_value` | Last subsheet return |
| `n_hp` | Node FlowKit variable |
| `current` | For Each / Picked current node |
| `system.picked` | Array from Pick Nodes |

### Keyboard (sheet editor)

| Shortcut | Action |
|----------|--------|
| Ctrl+F | Filter sheet |
| Ctrl+C / V | Copy / paste |
| Delete | Delete selection |
| Ctrl+click | Multi-select |
| Ctrl+Shift+D / E | Disable / enable selection |
| F4 / F6 / F7 | Debug hide / pause / clear |
| F8 / F9 | Step mode / continue |

## Version history (summary)

- **3.1** — A–G roadmap (typed inputs, multi-select, step debug, pick/return, nav/animtree, docs)
- **3.0** — Architecture debt, multi-behavior meta, await signal, registry modals
- **2.9** — Large 2D/3D/UI behaviors & events
- **2.7** — Visual AND/OR, subsheet retarget, CI
- **2.4** — Sheet vars, subsheets, For Each, debug overlay, event flags

Full notes: [CHANGELOG.md](CHANGELOG.md).

## License

MIT — see [LICENSE](LICENSE). Upstream copyright LexianDEV; fork modifications by slagusev contributors.
