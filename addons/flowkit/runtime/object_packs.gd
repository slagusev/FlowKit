extends RefCounted
class_name FKObjectPacks
## Declarative Object Mode packs: enable → behaviors + instance vars + optional rules.


static func all_packs() -> Array:
	## Array of pack definition Dictionaries.
	return [
		{
			"id": "platformer_2d",
			"name": "Platformer 2D",
			"description": "Left/right + jump for CharacterBody2D.",
			"supported_types": ["CharacterBody2D"],
			"behavior_ids": ["platformer_movement"],
			"behavior_inputs": {
				"platformer_movement": {
					"speed": 200.0,
					"jump_force": 350.0,
					"gravity": 900.0,
					"move_left": "ui_left",
					"move_right": "ui_right",
					"jump": "ui_accept"
				}
			},
			"option_defs": [
				{"name": "speed", "type": "float", "default": 200.0, "maps_to": "platformer_movement.speed"},
				{"name": "jump_force", "type": "float", "default": 350.0, "maps_to": "platformer_movement.jump_force"},
				{"name": "gravity", "type": "float", "default": 900.0, "maps_to": "platformer_movement.gravity"}
			],
			"variables": {},
			"default_rules": []
		},
		{
			"id": "top_down_2d",
			"name": "Top-Down 2D",
			"description": "4/8-direction movement for CharacterBody2D.",
			"supported_types": ["CharacterBody2D"],
			"behavior_ids": ["top_down_movement"],
			"behavior_inputs": {
				"top_down_movement": {
					"speed": 200.0
				}
			},
			"option_defs": [
				{"name": "speed", "type": "float", "default": 200.0, "maps_to": "top_down_movement.speed"}
			],
			"variables": {},
			"default_rules": []
		},
		{
			"id": "health",
			"name": "Health",
			"description": "Instance HP (n_hp / n_max_hp). Optional destroy when HP ≤ 0.",
			"supported_types": ["Node"],
			"behavior_ids": [],
			"behavior_inputs": {},
			"option_defs": [
				{"name": "max_hp", "type": "float", "default": 100.0},
				{"name": "destroy_on_death", "type": "bool", "default": true}
			],
			"variables": {
				"max_hp": 100.0,
				"hp": 100.0
			},
			"default_rules": [
				{
					"id": "death_free",
					"enabled": true,
					"when": "hp_lte_0",
					"then": "queue_free",
					"params": {}
				}
			]
		},
		{
			"id": "collectible",
			"name": "Collectible",
			"description": "Area2D: on player overlap add sheet score and free self.",
			"supported_types": ["Area2D"],
			"behavior_ids": ["collectible_pickup"],
			"behavior_inputs": {
				"collectible_pickup": {
					"points": 1.0,
					"score_var": "score",
					"player_group": "player",
					"destroy_self": true
				}
			},
			"option_defs": [
				{"name": "points", "type": "float", "default": 1.0, "maps_to": "collectible_pickup.points"},
				{"name": "score_var", "type": "string", "default": "score", "maps_to": "collectible_pickup.score_var"},
				{"name": "player_group", "type": "string", "default": "player", "maps_to": "collectible_pickup.player_group"},
				{"name": "destroy_self", "type": "bool", "default": true, "maps_to": "collectible_pickup.destroy_self"}
			],
			"variables": {"points": 1.0},
			"default_rules": []
		},
		{
			"id": "float_bob",
			"name": "Float / Bob",
			"description": "Gentle vertical bob (Node2D).",
			"supported_types": ["Node2D"],
			"behavior_ids": ["bob_up_down"],
			"behavior_inputs": {
				"bob_up_down": {"amplitude": 8.0, "frequency": 2.0}
			},
			"option_defs": [
				{"name": "amplitude", "type": "float", "default": 8.0, "maps_to": "bob_up_down.amplitude"},
				{"name": "frequency", "type": "float", "default": 2.0, "maps_to": "bob_up_down.frequency"}
			],
			"variables": {},
			"default_rules": []
		},
		{
			"id": "enemy_patrol",
			"name": "Enemy Patrol",
			"description": "CharacterBody2D walks left/right, flips on wall.",
			"supported_types": ["CharacterBody2D"],
			"behavior_ids": ["enemy_patrol"],
			"behavior_inputs": {
				"enemy_patrol": {"speed": 80.0, "gravity": 900.0, "flip_on_wall": true, "patrol_time": 0.0}
			},
			"option_defs": [
				{"name": "speed", "type": "float", "default": 80.0, "maps_to": "enemy_patrol.speed"},
				{"name": "gravity", "type": "float", "default": 900.0, "maps_to": "enemy_patrol.gravity"},
				{"name": "flip_on_wall", "type": "bool", "default": true, "maps_to": "enemy_patrol.flip_on_wall"},
				{"name": "patrol_time", "type": "float", "default": 0.0, "maps_to": "enemy_patrol.patrol_time"}
			],
			"variables": {"is_enemy": true},
			"default_rules": []
		},
		{
			"id": "ui_button",
			"name": "UI Button Action",
			"description": "On press: change scene and/or call subsheet.",
			"supported_types": ["BaseButton", "Button"],
			"behavior_ids": ["ui_button_action"],
			"behavior_inputs": {
				"ui_button_action": {"scene_path": "", "subsheet": "", "message": ""}
			},
			"option_defs": [
				{"name": "scene_path", "type": "string", "default": "", "maps_to": "ui_button_action.scene_path"},
				{"name": "subsheet", "type": "string", "default": "", "maps_to": "ui_button_action.subsheet"},
				{"name": "message", "type": "string", "default": "", "maps_to": "ui_button_action.message"}
			],
			"variables": {},
			"default_rules": []
		},
		{
			"id": "twin_stick",
			"name": "Twin-Stick",
			"description": "Move with WASD/arrows, aim with mouse.",
			"supported_types": ["CharacterBody2D"],
			"behavior_ids": ["twin_stick_movement"],
			"behavior_inputs": {
				"twin_stick_movement": {
					"speed": 220.0,
					"aim_with_mouse": true,
					"move_up": "ui_up",
					"move_down": "ui_down",
					"move_left": "ui_left",
					"move_right": "ui_right"
				}
			},
			"option_defs": [
				{"name": "speed", "type": "float", "default": 220.0, "maps_to": "twin_stick_movement.speed"},
				{"name": "aim_with_mouse", "type": "bool", "default": true, "maps_to": "twin_stick_movement.aim_with_mouse"}
			],
			"variables": {},
			"default_rules": []
		},
		{
			"id": "camera_follow",
			"name": "Camera Follow",
			"description": "Camera2D follows first node in a group (default player).",
			"supported_types": ["Camera2D"],
			"behavior_ids": ["camera_follow_target"],
			"behavior_inputs": {
				"camera_follow_target": {"target_group": "player", "lerp_speed": 5.0}
			},
			"option_defs": [
				{"name": "target_group", "type": "string", "default": "player", "maps_to": "camera_follow_target.target_group"},
				{"name": "lerp_speed", "type": "float", "default": 5.0, "maps_to": "camera_follow_target.lerp_speed"}
			],
			"variables": {},
			"default_rules": []
		}
	]


static func get_pack(pack_id: String) -> Dictionary:
	for p in all_packs():
		if str(p.get("id", "")) == pack_id:
			return p
	return {}


static func packs_for_node(node: Node) -> Array:
	var out: Array = []
	if node == null:
		return out
	var cls := node.get_class()
	for p in all_packs():
		var types: Array = p.get("supported_types", [])
		var ok := false
		for t in types:
			if str(t) == "Node" or cls == str(t) or node.is_class(str(t)):
				ok = true
				break
		if ok:
			out.append(p)
	return out


static func apply_pack(node: Node, pack_id: String, options: Dictionary = {}) -> void:
	var pack := get_pack(pack_id)
	if pack.is_empty() or node == null:
		return
	var opts := _merge_option_defaults(pack, options)
	FKObjectConfig.set_pack(node, pack_id, true, opts)
	
	# Behaviors
	var behavior_inputs: Dictionary = pack.get("behavior_inputs", {})
	for bid in pack.get("behavior_ids", []):
		var inputs: Dictionary = {}
		if behavior_inputs.has(bid) and behavior_inputs[bid] is Dictionary:
			inputs = (behavior_inputs[bid] as Dictionary).duplicate(true)
		_apply_options_to_behavior_inputs(pack, opts, str(bid), inputs)
		FKBehaviorMeta.add_or_replace(node, str(bid), inputs)
	
	# Variables
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		vars = node.get_meta("flowkit_variables", {}).duplicate(true)
	var base_vars: Dictionary = pack.get("variables", {})
	for k in base_vars.keys():
		vars[k] = base_vars[k]
	if pack_id == "health":
		var max_hp := float(opts.get("max_hp", 100.0))
		vars["max_hp"] = max_hp
		vars["hp"] = max_hp
	if pack_id == "collectible":
		vars["points"] = float(opts.get("points", 1.0))
		if node is Area2D:
			(node as Area2D).monitoring = true
	if not vars.is_empty():
		node.set_meta("flowkit_variables", vars)
	
	# Default local rules (merge by id)
	var rules: Array = FKObjectConfig.get_local_rules(node)
	var defaults: Array = pack.get("default_rules", [])
	if pack_id == "health" and not bool(opts.get("destroy_on_death", true)):
		defaults = []
		# Remove death_free if present
		var filtered: Array = []
		for r in rules:
			if r is Dictionary and str(r.get("id", "")) != "death_free":
				filtered.append(r)
		rules = filtered
	for dr in defaults:
		if not (dr is Dictionary):
			continue
		var rid := str(dr.get("id", ""))
		var found := false
		for i in range(rules.size()):
			if rules[i] is Dictionary and str(rules[i].get("id", "")) == rid:
				rules[i] = (dr as Dictionary).duplicate(true)
				found = true
				break
		if not found:
			rules.append((dr as Dictionary).duplicate(true))
	FKObjectConfig.set_local_rules(node, rules)


static func remove_pack(node: Node, pack_id: String) -> void:
	var pack := get_pack(pack_id)
	if pack.is_empty() or node == null:
		return
	FKObjectConfig.set_pack(node, pack_id, false, FKObjectConfig.get_pack_options(node, pack_id))
	for bid in pack.get("behavior_ids", []):
		FKBehaviorMeta.remove_id(node, str(bid))
	# Strip default rules from this pack
	var strip_ids: Dictionary = {}
	for dr in pack.get("default_rules", []):
		if dr is Dictionary:
			strip_ids[str(dr.get("id", ""))] = true
	if pack_id == "health":
		strip_ids["death_free"] = true
	var rules: Array = []
	for r in FKObjectConfig.get_local_rules(node):
		if r is Dictionary and strip_ids.has(str(r.get("id", ""))):
			continue
		rules.append(r)
	FKObjectConfig.set_local_rules(node, rules)


static func _merge_option_defaults(pack: Dictionary, options: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for od in pack.get("option_defs", []):
		if od is Dictionary:
			var n := str(od.get("name", ""))
			if n.is_empty():
				continue
			out[n] = od.get("default", null)
	for k in options.keys():
		out[k] = options[k]
	return out


static func _apply_options_to_behavior_inputs(pack: Dictionary, opts: Dictionary, behavior_id: String, inputs: Dictionary) -> void:
	for od in pack.get("option_defs", []):
		if not (od is Dictionary):
			continue
		var maps: String = str(od.get("maps_to", ""))
		if maps.is_empty() or not maps.begins_with(behavior_id + "."):
			continue
		var field := maps.substr(behavior_id.length() + 1)
		var oname := str(od.get("name", ""))
		if opts.has(oname):
			inputs[field] = opts[oname]
