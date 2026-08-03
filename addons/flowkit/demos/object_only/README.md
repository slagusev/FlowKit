# Object-only demo (no event sheet)

Proves Object Mode: player, coin, enemy patrol, HP bar bind.

## Open

`res://addons/flowkit/demos/object_only/object_only.tscn`

## First run

The scene script auto-applies recipes if packs are missing:

- Player → Platformer + Health + bind `hp` → `UI/HPBar`
- Coin → Collectible
- Enemy → Patrol + Health

Or set them manually in the Inspector → **Object Mode**.

## Controls

- Move / jump: default `ui_*` actions (arrows + Enter/Space)
- Collect yellow coin → sheet var `score`
- Red enemy patrols on the floor

## Note

Player must be in group `player` (recipe adds it).  
Regenerate provider manifest before export (new behaviors: enemy_patrol, ui_button_action).
