extends RefCounted
class_name FKObjectRecipes
## One-click recipes: apply multiple packs + sensible defaults to a node.


static func all_recipes() -> Array:
	return [
		{
			"id": "platformer_player",
			"name": "Make Platformer Player",
			"description": "Platformer move + Health. Adds to group 'player'.",
			"supported_types": ["CharacterBody2D"],
			"packs": [
				{"id": "platformer_2d", "options": {"speed": 200.0, "jump_force": 380.0}},
				{"id": "health", "options": {"max_hp": 100.0, "destroy_on_death": false}}
			],
			"groups": ["player"],
			"variables": {"is_player": true}
		},
		{
			"id": "topdown_player",
			"name": "Make Top-Down Player",
			"description": "Top-down move + Health. Group 'player'.",
			"supported_types": ["CharacterBody2D"],
			"packs": [
				{"id": "top_down_2d", "options": {"speed": 220.0}},
				{"id": "health", "options": {"max_hp": 100.0, "destroy_on_death": false}}
			],
			"groups": ["player"],
			"variables": {"is_player": true}
		},
		{
			"id": "coin",
			"name": "Make Coin / Collectible",
			"description": "Area2D collectible: +1 score, free self. Monitoring on.",
			"supported_types": ["Area2D"],
			"packs": [
				{"id": "collectible", "options": {"points": 1.0, "score_var": "score", "player_group": "player"}}
			],
			"groups": ["collectible"],
			"variables": {}
		},
		{
			"id": "damage_zone",
			"name": "Make Damage Zone",
			"description": "Area2D that damages player HP on overlap (simple rule).",
			"supported_types": ["Area2D"],
			"packs": [],
			"groups": ["hazard"],
			"variables": {"damage": 10.0},
			"rules": [
				{
					"id": "hazard_touch",
					"enabled": true,
					"when": "body_in_group_player",
					"then": "damage_overlapping_player",
					"params": {"Amount": 10.0}
				}
			]
		}
	]


static func recipes_for_node(node: Node) -> Array:
	var out: Array = []
	if node == null:
		return out
	for r in all_recipes():
		var types: Array = r.get("supported_types", [])
		var ok := false
		for t in types:
			if node.get_class() == str(t) or node.is_class(str(t)) or str(t) == "Node":
				ok = true
				break
		if ok:
			out.append(r)
	return out


static func apply_recipe(node: Node, recipe_id: String) -> void:
	var recipe := {}
	for r in all_recipes():
		if str(r.get("id", "")) == recipe_id:
			recipe = r
			break
	if recipe.is_empty() or node == null:
		return
	for p in recipe.get("packs", []):
		if p is Dictionary:
			FKObjectPacks.apply_pack(node, str(p.get("id", "")), p.get("options", {}) if p.get("options", {}) is Dictionary else {})
	for g in recipe.get("groups", []):
		if not node.is_in_group(str(g)):
			node.add_to_group(str(g), true)
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		vars = node.get_meta("flowkit_variables", {}).duplicate(true)
	var add_vars: Dictionary = recipe.get("variables", {})
	for k in add_vars.keys():
		vars[k] = add_vars[k]
	if not vars.is_empty():
		node.set_meta("flowkit_variables", vars)
	# Extra rules from recipe
	var rules: Array = FKObjectConfig.get_local_rules(node)
	for er in recipe.get("rules", []):
		if not (er is Dictionary):
			continue
		var rid := str(er.get("id", ""))
		var found := false
		for i in range(rules.size()):
			if rules[i] is Dictionary and str(rules[i].get("id", "")) == rid:
				rules[i] = (er as Dictionary).duplicate(true)
				found = true
				break
		if not found:
			rules.append((er as Dictionary).duplicate(true))
	FKObjectConfig.set_local_rules(node, rules)
	# Ensure object config exists for scan
	var cfg := FKObjectConfig.get_config(node)
	FKObjectConfig.set_config(node, cfg)
