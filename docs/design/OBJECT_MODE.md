# FlowKit Object Mode — Design Document

**Status:** MVP implemented (fork **3.4.0**)  
**Version:** 1.0  
**Audience:** slagusev/FlowKit maintainers  

---

## 1. Problem

Event sheets are powerful but **high friction** for common game tasks:

- “Make this body a platformer”
- “Add HP and die at 0”
- “Coin awards score on touch”

Users want **checkbox / slider / pack** workflows (Construct / Fusion style), without abandoning sheets for quests, UI flow, and complex logic.

---

## 2. Goals

| Goal | Metric |
|------|--------|
| Prototype a playable character **without opening the sheet** | Platformer + health via Object Panel only |
| Keep **one runtime** | No second engine; packs write existing meta |
| Bridge to sheets | Local rules can Call Subsheet / set sheet vars |
| Non-breaking | Existing behaviors, sheets, demos still work |

### Non-goals (MVP)

- Full Construct instance system / families UI  
- Visual state machine graph  
- Replacing event sheets  
- Networked object replication  

---

## 3. Two modes, one node

```
┌─────────────────────────────────────────────┐
│  Selected Node                              │
│  ┌─────────────────┐  ┌──────────────────┐  │
│  │ Object Mode     │  │ Event Sheet      │  │
│  │ (per-node)      │  │ (per-scene)      │  │
│  │ packs, toggles  │  │ events/conds/acts│  │
│  │ properties,     │  │ subsheets, OR    │  │
│  │ local rules     │  │ debug, filter    │  │
│  └────────┬────────┘  └────────▲─────────┘  │
│           │  n_ / behaviors / subsheets     │
│           └──────────► shared runtime ──────┘
└─────────────────────────────────────────────┘
```

| Concern | Object Mode | Event Sheet |
|---------|-------------|-------------|
| Movement / AI loops | Behaviors + packs | Rarely |
| Combat / HP | Health pack + properties | Complex combos |
| Level scripting | Local rules (simple) | Primary |
| UI flows / menus | Quick actions | Primary |
| Debug / OR / For Each | — | Primary |

---

## 4. Data model

### 4.1 Meta keys (on `Node`)

| Key | Type | Purpose |
|-----|------|---------|
| `flowkit_behaviors` | Array[{id, inputs}] | Existing multi-behavior (canonical) |
| `flowkit_behavior` | Dictionary | Legacy single-slot mirror |
| `flowkit_variables` | Dictionary | Instance props `n_name` |
| **`flowkit_object`** | Dictionary | **New** Object Mode config |

### 4.2 `flowkit_object` schema

```gdscript
{
  "version": 1,
  "packs": {
    "platformer_2d": { "enabled": true, "options": { "dash": false } },
    "health": { "enabled": true, "options": { "max_hp": 100, "destroy_on_death": true } }
  },
  "local_rules": [
    {
      "id": "rule_1",
      "enabled": true,
      "when": "hp_lte_0",          # built-in predicate id
      "then": "call_subsheet",     # built-in action id
      "params": { "Name": "death" }
    }
  ],
  "quick_notes": ""                # optional designer text
}
```

Packs **do not duplicate** behavior storage: enabling a pack **adds/updates** entries in `flowkit_behaviors` and properties in `flowkit_variables`. Disabling removes pack-owned behaviors (by id list).

### 4.3 Ownership

Each pack declares:

- `behavior_ids: PackedStringArray` — behaviors it manages  
- `variable_defaults: Dictionary` — `n_` keys it owns  
- `supported_types: PackedStringArray` — node classes  
- `options` → mapped into behavior inputs / vars  

---

## 5. Packs (catalog)

### MVP packs

| Pack id | Node types | Applies |
|---------|------------|---------|
| `platformer_2d` | CharacterBody2D | behavior `platformer_movement` |
| `top_down_2d` | CharacterBody2D | behavior `top_down_movement` |
| `health` | Node | vars `hp`, `max_hp`; optional destroy; local rule hook |
| `collectible` | Area2D | vars `points`; on body entered → add sheet score (rule) |

### Phase 2 packs / recipes (v3.5)

| id | Notes |
|----|--------|
| `collectible` | Area2D + `collectible_pickup` behavior |
| `float_bob` | Node2D bob |
| Recipes | platformer_player, topdown_player, coin, damage_zone |
| Binds | `flowkit_object.binds` → ProgressBar / Label |

### Future packs

Enemy patrol, twin-stick, camera follow, UI button→scene, rigid thrust, typewriter UI.

---

## 6. Editor UX

### 6.1 Placement

**Inspector → FlowKit** section, **above** multi-behavior list:

1. **Object Mode** header + short help  
2. **Packs** — checkbox list (filtered by node class)  
3. **Pack options** — typed widgets when pack selected/enabled  
4. **Properties** — instance vars (existing UI, tighter)  
5. **Local rules** — compact list (when / then / params)  
6. **Advanced** — collapsible multi-behavior editor (current UI)  

### 6.2 Pack checkbox semantics

- **Check** → `FKObjectPack.apply(node, options)`  
- **Uncheck** → `FKObjectPack.remove(node)` (only pack-owned behaviors/vars, optional keep vars)  
- Changing option sliders → re-apply pack / update behavior inputs  

### 6.3 Local rules (MVP predicates / actions)

**When (predicates):**

| id | Meaning |
|----|---------|
| `hp_lte_0` | `n_hp` ≤ 0 |
| `never` | disabled placeholder |

**Then (actions):**

| id | Meaning |
|----|---------|
| `queue_free` | `node.queue_free()` |
| `call_subsheet` | engine `run_subsheet(name)` |
| `set_sheet_var` | `system.set_sheet_var` |
| `print` | debug print |

MVP: evaluate local rules in engine `_process` for nodes that have `flowkit_object.local_rules` non-empty (scanned with behaviors).

---

## 7. Runtime

```
FlowKitEngine._ready
  scan behaviors (existing)
  scan flowkit_object → track object_nodes

_process / physics:
  process behaviors (existing)
  process local_rules on object_nodes (new, cheap)
```

Local rules fire **once** until re-armed (e.g. hp rises again) via runtime flags on node meta `flowkit_object_runtime`.

---

## 8. Bridge to Event Sheet

| From Object | To Sheet |
|-------------|----------|
| `n_hp` | readable as `n_hp` if expressions target that node |
| Pack enables behavior | visible in multi-behavior meta |
| Local rule `call_subsheet` | same subsheets as sheet panel |
| Quick “Open Event Sheet” | focuses FlowKit main screen (future) |

Sheets **never required** for packs-only gameplay.

---

## 9. MVP scope (implement next)

### In

- [x] Design doc (this file)  
- [x] `FKObjectConfig` read/write meta  
- [x] Pack registry: platformer_2d, top_down_2d, health  
- [x] Inspector **Object Mode** packs UI (checkboxes + options)  
- [x] Apply/remove → `FKBehaviorMeta`  
- [x] Health vars + optional `queue_free` local rule  
- [x] Engine local rule tick (hp_lte_0 → queue_free / call_subsheet)  
- [x] Docs blurb + CHANGELOG  

### Out of MVP

- collectible pack (phase 2)  
- Recipes one-click multi-node  
- Property ↔ Control binding  
- State machine  
- Drag-drop packs  

---

## 10. Testing

| Test | Expect |
|------|--------|
| Enable platformer on CharacterBody2D | `flowkit_behaviors` contains `platformer_movement` |
| Disable pack | behavior removed |
| Health max_hp 50 | `n_max_hp`/`n_hp` = 50 |
| hp_lte_0 + queue_free | node freed when hp set ≤ 0 at runtime |
| Sheet still loads | no regression on `.tres` sheets |

---

## 11. Rollout

1. Ship behind always-on inspector (no feature flag)  
2. Demo: CharacterBody2D + packs only (no sheet) optional later  
3. Version: **3.4.0** “Object Mode MVP”  

---

## 12. Open questions (later)

- Should packs version-migrate options?  
- Can sheet actions toggle packs at runtime? (likely yes via meta)  
- Multiplayer authority for object config?  

---

## 13. Decision log

| Date | Decision |
|------|----------|
| 2026-08-03 | Dual mode; packs own behavior ids; local rules minimal |
| 2026-08-03 | MVP = platformer + top_down + health + inspector packs UI |
