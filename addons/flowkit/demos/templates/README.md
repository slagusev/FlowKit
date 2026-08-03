# FlowKit sheet templates

## Built-in (editor)

In the FlowKit panel: **File → New from Template…**

| Id | Name |
|----|------|
| `blank` | Empty sheet + score var |
| `on_ready_print` | On Ready → Print hello |
| `score_loop` | Space key increments score |
| `or_example` | OR condition group example |
| `subsheet_call` | On Ready → Call Subsheet |

Implemented in `editor/sheet_templates.gd` (`FKSheetTemplates`).

## Manual recipes

Starter fragments you can also build by hand.

**Full interactive demo:** see [`../full_loop/`](../full_loop/) — import JSON and run.

## platformer_basics

1. Create sheet variables: `score` (int), `lives` (int, default 3).
2. On player **CharacterBody2D**:
   - Inspector → Behaviors: `platformer_movement` (+ optional `dash`).
3. Event **On Ready** (System): Set Sheet Variable `score` = 0.
4. Subsheet `add_score` with param `amount` (default 1):
   - Set Sheet Variable `score` = `s_score + p_amount`
   - Set Subsheet Return = `s_score`
5. Call Subsheet `add_score` with ArgsJson `{"amount":10}`, StoreAs `score`.

## pick_and_damage

1. Action **Pick Nodes**: Group `enemies`, Class `CharacterBody2D`.
2. **For Each Picked** subsheet `hurt`:
   - In subsheet: apply damage using `current` node.

## await_signal_example

1. On Timer: **Start** timer.
2. **Await Signal** `timeout` (Timeout 5).
3. **Print** "timer done".

See also the built-in demo scenes under `addons/flowkit/demos/`.
