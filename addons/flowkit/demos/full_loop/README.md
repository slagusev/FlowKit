# Full-loop demo (v3.3)

Shows the main FlowKit fork features in one place.

## Steps

1. Open `full_loop.tscn` in Godot.
2. Open the **FlowKit** bottom panel.
3. **File → Import Sheet JSON…**
4. Choose `full_loop_sheet.json` (this folder).
5. (Optional) Select **Player** → Inspector → **Behaviors (multi)** → add a movement behavior.
6. Run the scene (**F5**).
7. Press **Space** — score subsheet runs (breakpoint on the key event → use **F8/F9**).
8. **F4** — debug overlay (events, step, profiler).

## Concepts covered

| Concept | Where |
|---------|--------|
| Sheet var `s_score` | On Ready + subsheet |
| Subsheet params `p_amount` | `add_score` |
| Return `r_value` / StoreAs | Call Subsheet |
| Breakpoint | Space key event (🔴) |
| JSON import | File menu |

## GIF / website notes

Suggested short capture (8–15s):

1. Import JSON  
2. Toggle breakpoint  
3. Run → Space → F9 step → score updates → F4 overlay  

Save under `website/assets/examples/` when available.
