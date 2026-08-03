# FlowKit fork — migration notes

## From upstream LexianDEV → slagusev fork

1. Replace `addons/flowkit` with this fork (or enable this plugin only).
2. Open project once so Godot reimports scripts / class names.
3. **Generate Provider Manifest** (Edit menu) before exporting a game build.
4. Existing `.tres` event sheets continue to load (legacy single behavior meta still works).

## 2.x → 3.0

| Change | Action |
|--------|--------|
| Multi-behavior | Use inspector **Behaviors (multi)**; legacy `flowkit_behavior` still loads as one entry |
| Registry modals | No action — pickers use `FKRegistry` |
| Sheet vars typed helper | Still stored as dicts in `.tres` |

## 3.0 → 3.1

| Change | Action |
|--------|--------|
| Typed expression widgets | Optional Expression toggle on bool/int/float |
| Action/condition `enabled` | Default true; mute via UI or Ctrl+Shift+D |
| Subsheet return | `Set Subsheet Return` + Call Subsheet **StoreAs** / `r_value` |

## 3.1 → 3.2

| Change | Action |
|--------|--------|
| Event breakpoints | Context menu → Breakpoint 🔴 |
| Sheet JSON | File → Export/Import Sheet JSON |
| Pick upgrades | RandomOne / InvertFilter / MaxCount |
| Families | Define Family + Pick Family |

## 3.2 → 3.3

| Change | Action |
|--------|--------|
| Empty main scene | Dev project main is `tests/empty_main.tscn` (open demos manually) |
| JSON FileDialog | Export/Import prompts for path |
| Picker icons | Category emoji prefixes in action/event/condition lists |
| Full-loop demo | `addons/flowkit/demos/full_loop/` |
| CI smoke | `tools/ci_smoke.gd` must pass in GitHub Actions |

## Breaking risks

- **None intentional** for sheet `.tres` format.
- Headless CI may fail if `main_scene` points at a long-running demo — keep empty main for this repo.
- After adding providers: regenerate **provider manifest** for export tree-shaking.
