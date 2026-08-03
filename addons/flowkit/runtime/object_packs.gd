extends RefCounted
class_name FKObjectPacks
## Declarative Object Mode packs: enable → behaviors + instance vars + optional rules.
## v3.12: register_pack() for data-driven / extension packs.

## Extra packs registered at runtime (id → definition Dictionary).
static var _registered: Dictionary = {}


## Register or replace a pack definition. Required keys: id, name, supported_types.
static func register_pack(def: Dictionary) -> bool:
	var pid := str(def.get("id", "")).strip_edges()
	if pid.is_empty():
		push_warning("[FKObjectPacks] register_pack: missing id")
		return false
	var copy := def.duplicate(true)
	if not copy.has("supported_types"):
		copy["supported_types"] = ["Node"]
	if not copy.has("behavior_ids"):
		copy["behavior_ids"] = []
	if not copy.has("behavior_inputs"):
		copy["behavior_inputs"] = {}
	if not copy.has("option_defs"):
		copy["option_defs"] = []
	if not copy.has("variables"):
		copy["variables"] = {}
	if not copy.has("default_rules"):
		copy["default_rules"] = []
	_registered[pid] = copy
	return true


static func unregister_pack(pack_id: String) -> void:
	_registered.erase(pack_id.strip_edges())


static func clear_registered() -> void:
	_registered.clear()


static func all_packs() -> Array:
	## Built-ins first, then registered (registered override same id).
	var by_id: Dictionary = {}
	for p in _builtin_packs():
		var pid := str(p.get("id", ""))
		if not pid.is_empty():
			by_id[pid] = p
	for pid in _registered.keys():
		by_id[str(pid)] = _registered[pid]
	var out: Array = []
	for pid in by_id.keys():
		out.append(by_id[pid])
	return out


static func _builtin_packs() -> Array:
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
		},
		{
			"id": "rigid_thrust",
			"name": "Rigid Thrust (Ship)",
			"description": "Asteroids-style thrust + torque for RigidBody2D.",
			"supported_types": ["RigidBody2D"],
			"behavior_ids": ["rigid_thrust"],
			"behavior_inputs": {
				"rigid_thrust": {
					"thrust_action": "ui_up",
					"left_action": "ui_left",
					"right_action": "ui_right",
					"thrust_force": 400.0,
					"torque": 8000.0
				}
			},
			"option_defs": [
				{"name": "thrust_force", "type": "float", "default": 400.0, "maps_to": "rigid_thrust.thrust_force"},
				{"name": "torque", "type": "float", "default": 8000.0, "maps_to": "rigid_thrust.torque"}
			],
			"variables": {},
			"default_rules": []
		},
		{
			"id": "typewriter",
			"name": "Typewriter Text",
			"description": "Reveals Label/RichTextLabel text over time.",
			"supported_types": ["Label", "RichTextLabel"],
			"behavior_ids": ["ui_typewriter"],
			"behavior_inputs": {
				"ui_typewriter": {"chars_per_sec": 30.0}
			},
			"option_defs": [
				{"name": "chars_per_sec", "type": "float", "default": 30.0, "maps_to": "ui_typewriter.chars_per_sec"}
			],
			"variables": {},
			"default_rules": []
		},
		# --- v3.12 combat / spawn packs ---
		{
			"id": "hitbox_2d",
			"name": "Hitbox 2D",
			"description": "Area2D damages overlapping player (group) each frame while overlapping.",
			"supported_types": ["Area2D"],
			"behavior_ids": [],
			"behavior_inputs": {},
			"option_defs": [
				{"name": "damage", "type": "float", "default": 10.0},
				{"name": "player_group", "type": "string", "default": "player"}
			],
			"variables": {"damage": 10.0},
			"default_rules": [
				{
					"id": "hitbox_tick",
					"enabled": true,
					"when": "body_in_group_player",
					"then": "damage_overlapping_player",
					"params": {"Amount": 10.0, "Group": "player"},
					"once": false
				}
			]
		},
		{
			"id": "hurtbox_emit_died",
			"name": "Hurtbox / Die Event",
			"description": "Health + on death emit object event 'died' (sheet listens with On Object Event).",
			"supported_types": ["Node"],
			"behavior_ids": [],
			"behavior_inputs": {},
			"option_defs": [
				{"name": "max_hp", "type": "float", "default": 50.0},
				{"name": "death_event", "type": "string", "default": "died"}
			],
			"variables": {"max_hp": 50.0, "hp": 50.0},
			"default_rules": [
				{
					"id": "hurtbox_emit_died",
					"enabled": true,
					"when": "hp_lte_0",
					"then": "emit_object_event",
					"params": {"Event": "died"},
					"once": true
				},
				{
					"id": "hurtbox_free",
					"enabled": true,
					"when": "hp_lte_0",
					"then": "queue_free",
					"params": {},
					"once": true
				}
			]
		},
		{
			"id": "state_flags",
			"name": "State Flags",
			"description": "Instance vars: n_state (string) + simple flag bag for sheet expressions.",
			"supported_types": ["Node"],
			"behavior_ids": [],
			"behavior_inputs": {},
			"option_defs": [
				{"name": "initial_state", "type": "string", "default": "idle"}
			],
			"variables": {"state": "idle", "flag_a": false, "flag_b": false},
			"default_rules": []
		},
		{
			"id": "spawn_pool",
			"name": "Spawn Scene (pool)",
			"description": "On ready once: instance PackedScene path as child (or under parent path).",
			"supported_types": ["Node"],
			"behavior_ids": [],
			"behavior_inputs": {},
			"option_defs": [
				{"name": "scene_path", "type": "string", "default": ""},
				{"name": "count", "type": "int", "default": 1},
				{"name": "parent_path", "type": "string", "default": ""}
			],
			"variables": {"spawn_count": 1},
			"default_rules": [
				{
					"id": "spawn_once",
					"enabled": true,
					"when": "on_ready_once",
					"then": "spawn_scene",
					"params": {"ScenePath": "", "Count": 1, "ParentPath": ""},
					"once": true
				}
			]
		}
	]


static func get_pack(pack_id: String) -> Dictionary:
	if _registered.has(pack_id):
		return (_registered[pack_id] as Dictionary).duplicate(true)
	for p in _builtin_packs():
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
	if pack_id == "health" or pack_id == "hurtbox_emit_died":
		var max_hp := float(opts.get("max_hp", 100.0))
		vars["max_hp"] = max_hp
		vars["hp"] = max_hp
	if pack_id == "state_flags":
		vars["state"] = str(opts.get("initial_state", "idle"))
	if pack_id == "spawn_pool":
		vars["spawn_count"] = int(opts.get("count", 1))
		vars["spawn_scene"] = str(opts.get("scene_path", ""))
	if pack_id == "hitbox_2d":
		vars["damage"] = float(opts.get("damage", 10.0))
		if node is Area2D:
			(node as Area2D).monitoring = true
			(node as Area2D).monitorable = true
	if pack_id == "collectible":
		vars["points"] = float(opts.get("points", 1.0))
		if node is Area2D:
			var area := node as Area2D
			area.monitoring = true
			area.monitorable = true
	if pack_id == "typewriter":
		# Capture full text before typewriter clears it
		if "text" in node:
			var full := str(node.get("text"))
			if not full.is_empty():
				node.set_meta("flowkit_typewriter_full", full)
	if not vars.is_empty():
		node.set_meta("flowkit_variables", vars)
	
	# Default local rules (merge by id)
	var rules: Array = FKObjectConfig.get_local_rules(node)
	var defaults: Array = pack.get("default_rules", []).duplicate(true)
	# Inject option values into rule params
	if pack_id == "hitbox_2d":
		for dr in defaults:
			if dr is Dictionary and str(dr.get("id", "")) == "hitbox_tick":
				dr["params"] = {
					"Amount": float(opts.get("damage", 10.0)),
					"Group": str(opts.get("player_group", "player"))
				}
	if pack_id == "hurtbox_emit_died":
		for dr2 in defaults:
			if dr2 is Dictionary and str(dr2.get("id", "")) == "hurtbox_emit_died":
				dr2["params"] = {"Event": str(opts.get("death_event", "died"))}
	if pack_id == "spawn_pool":
		for dr3 in defaults:
			if dr3 is Dictionary and str(dr3.get("id", "")) == "spawn_once":
				dr3["params"] = {
					"ScenePath": str(opts.get("scene_path", "")),
					"Count": int(opts.get("count", 1)),
					"ParentPath": str(opts.get("parent_path", ""))
				}
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
	if pack_id == "hurtbox_emit_died":
		strip_ids["hurtbox_emit_died"] = true
		strip_ids["hurtbox_free"] = true
	if pack_id == "hitbox_2d":
		strip_ids["hitbox_tick"] = true
	if pack_id == "spawn_pool":
		strip_ids["spawn_once"] = true
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
