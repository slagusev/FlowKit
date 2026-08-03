extends Node2D
## Object Mode demo — no event sheet required.
## Setup is done in the editor via Object Mode recipes on Player / Coin / Enemy.

@onready var score_label: Label = %ScoreLabel
@onready var help: RichTextLabel = %Help

func _ready() -> void:
	if help:
		help.text = """[b]Object-only demo[/b]
If nodes are not set up yet:
1. Select [code]Player[/code] → Object Mode → [b]Make Platformer Player[/b]
2. Select [code]Coin[/code] → [b]Make Coin / Collectible[/b]
3. Select [code]Enemy[/code] → [b]Make Patrol Enemy[/b]
4. Select [code]HPBar[/code] is bound from Player: bind [code]hp[/code] → [code]UI/HPBar[/code]
5. Run (F5). Arrows/jump · collect coin · enemy patrols.

Player must stay in group [code]player[/code].
"""
	_ensure_demo_setup()

func _ensure_demo_setup() -> void:
	var player := get_node_or_null("Player")
	var coin := get_node_or_null("Coin")
	var enemy := get_node_or_null("Enemy")
	if player and not FKObjectConfig.is_pack_enabled(player, "platformer_2d"):
		FKObjectRecipes.apply_recipe(player, "platformer_player")
		FKObjectConfig.add_bind(player, "hp", "UI/HPBar", "max_hp")
	if coin and not FKObjectConfig.is_pack_enabled(coin, "collectible"):
		FKObjectRecipes.apply_recipe(coin, "coin")
	if enemy and not FKObjectConfig.is_pack_enabled(enemy, "enemy_patrol"):
		FKObjectRecipes.apply_recipe(enemy, "patrol_enemy")
	# Re-activate behaviors for runtime (scene already loaded)
	var engine = get_node_or_null("/root/FlowKit")
	if engine:
		if engine.has_method("_scan_and_activate_behaviors"):
			engine._scan_and_activate_behaviors(self)
		if engine.has_method("_scan_object_nodes"):
			engine._scan_object_nodes(self)

func _process(_delta: float) -> void:
	if score_label == null:
		return
	var system = get_node_or_null("/root/FlowKitSystem")
	var s = 0
	if system and system.has_method("get_sheet_var"):
		s = system.get_sheet_var("score", 0)
	score_label.text = "Score: %s" % str(s)
