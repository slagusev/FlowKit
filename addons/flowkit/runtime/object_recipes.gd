extends RefCounted
class_name FKObjectRecipes
## One-click recipes: apply multiple packs + sensible defaults to a node.
## v3.12: undo_last_recipe, remove_recipe, register_recipe.

const META_RECIPE_STACK := "flowkit_recipe_stack"

static var _registered: Dictionary = {}


static func register_recipe(def: Dictionary) -> bool:
	var rid := str(def.get("id", "")).strip_edges()
	if rid.is_empty():
		return false
	_registered[rid] = def.duplicate(true)
	return true


static func unregister_recipe(recipe_id: String) -> void:
	_registered.erase(recipe_id.strip_edges())


static func all_recipes() -> Array:
	var by_id: Dictionary = {}
	for r in _builtin_recipes():
		var rid := str(r.get("id", ""))
		if not rid.is_empty():
			by_id[rid] = r
	for rid in _registered.keys():
		by_id[str(rid)] = _registered[rid]
	var out: Array = []
	for k in by_id.keys():
		out.append(by_id[k])
	return out


static func _builtin_recipes() -> Array:
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
					"params": {"Amount": 10.0},
					"once": false
				}
			]
		},
		{
			"id": "patrol_enemy",
			"name": "Make Patrol Enemy",
			"description": "Patrol AI + Health. Group 'enemy'.",
			"supported_types": ["CharacterBody2D"],
			"packs": [
				{"id": "enemy_patrol", "options": {"speed": 90.0}},
				{"id": "health", "options": {"max_hp": 30.0, "destroy_on_death": true}}
			],
			"groups": ["enemy"],
			"variables": {"is_enemy": true}
		},
		{
			"id": "combat_enemy",
			"name": "Make Combat Enemy (emit died)",
			"description": "Patrol + Hurtbox emit 'died' for sheet hooks. Group enemy.",
			"supported_types": ["CharacterBody2D"],
			"packs": [
				{"id": "enemy_patrol", "options": {"speed": 80.0}},
				{"id": "hurtbox_emit_died", "options": {"max_hp": 40.0, "death_event": "died"}}
			],
			"groups": ["enemy"],
			"variables": {"is_enemy": true}
		},
		{
			"id": "hazard_hitbox",
			"name": "Make Hazard Hitbox",
			"description": "Area2D hitbox damages player continuously.",
			"supported_types": ["Area2D"],
			"packs": [
				{"id": "hitbox_2d", "options": {"damage": 15.0, "player_group": "player"}}
			],
			"groups": ["hazard"],
			"variables": {}
		},
		{
			"id": "start_button",
			"name": "Make Start Button",
			"description": "Button prints + optional scene path (set in pack options).",
			"supported_types": ["Button", "BaseButton"],
			"packs": [
				{"id": "ui_button", "options": {"message": "Start pressed", "scene_path": "", "subsheet": ""}}
			],
			"groups": ["ui"],
			"variables": {}
		},
		{
			"id": "twin_stick_player",
			"name": "Make Twin-Stick Player",
			"description": "Twin-stick move + aim + Health. Group player.",
			"supported_types": ["CharacterBody2D"],
			"packs": [
				{"id": "twin_stick", "options": {"speed": 240.0, "aim_with_mouse": true}},
				{"id": "health", "options": {"max_hp": 100.0, "destroy_on_death": false}}
			],
			"groups": ["player"],
			"variables": {"is_player": true}
		},
		{
			"id": "follow_camera",
			"name": "Make Follow Camera",
			"description": "Camera2D current + follow group player.",
			"supported_types": ["Camera2D"],
			"packs": [
				{"id": "camera_follow", "options": {"target_group": "player", "lerp_speed": 6.0}}
			],
			"groups": ["camera"],
			"variables": {},
			"make_current": true
		},
		{
			"id": "start_to_object_only",
			"name": "Start → Object-Only Demo",
			"description": "Button loads demos/object_only scene.",
			"supported_types": ["Button", "BaseButton"],
			"packs": [
				{
					"id": "ui_button",
					"options": {
						"message": "Loading game…",
						"scene_path": "res://addons/flowkit/demos/object_only/object_only.tscn",
						"subsheet": ""
					}
				}
			],
			"groups": ["ui"],
			"variables": {}
		},
		{
			"id": "spaceship",
			"name": "Make Spaceship (Rigid)",
			"description": "RigidBody2D thrust + Health. Group player.",
			"supported_types": ["RigidBody2D"],
			"packs": [
				{"id": "rigid_thrust", "options": {"thrust_force": 450.0, "torque": 9000.0}},
				{"id": "health", "options": {"max_hp": 100.0, "destroy_on_death": true}}
			],
			"groups": ["player"],
			"variables": {"is_player": true}
		},
		{
			"id": "dialogue_label",
			"name": "Make Typewriter Dialogue",
			"description": "Label typewriter from current text (stores full string in meta).",
			"supported_types": ["Label", "RichTextLabel"],
			"packs": [
				{"id": "typewriter", "options": {"chars_per_sec": 28.0}}
			],
			"groups": ["ui", "dialogue"],
			"variables": {}
		},
		{
			"id": "start_to_space",
			"name": "Start → Space Demo",
			"description": "Button loads demos/object_space scene.",
			"supported_types": ["Button", "BaseButton"],
			"packs": [
				{
					"id": "ui_button",
					"options": {
						"message": "Launch!",
						"scene_path": "res://addons/flowkit/demos/object_space/object_space.tscn",
						"subsheet": ""
					}
				}
			],
			"groups": ["ui"],
			"variables": {}
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


static func get_recipe(recipe_id: String) -> Dictionary:
	for r in all_recipes():
		if str(r.get("id", "")) == recipe_id:
			return r
	return {}


static func _snapshot_node(node: Node) -> Dictionary:
	var groups: Array = []
	for g in node.get_groups():
		groups.append(str(g))
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		var v = node.get_meta("flowkit_variables")
		if v is Dictionary:
			vars = (v as Dictionary).duplicate(true)
	return {
		"config": FKObjectConfig.get_config(node),
		"variables": vars,
		"behaviors": FKBehaviorMeta.get_behaviors(node),
		"groups": groups,
		"recipe_id": ""
	}


static func _restore_snapshot(node: Node, snap: Dictionary) -> void:
	if node == null or snap.is_empty():
		return
	var cfg = snap.get("config", {})
	if cfg is Dictionary:
		FKObjectConfig.set_config(node, cfg)
	var vars = snap.get("variables", {})
	if vars is Dictionary and not vars.is_empty():
		node.set_meta("flowkit_variables", vars)
	elif node.has_meta("flowkit_variables"):
		node.remove_meta("flowkit_variables")
	var behaviors = snap.get("behaviors", [])
	if behaviors is Array:
		FKBehaviorMeta.set_behaviors(node, behaviors)
	# Groups: remove recipe-added ones not in snapshot
	var keep: Dictionary = {}
	for g in snap.get("groups", []):
		keep[str(g)] = true
	for g2 in node.get_groups():
		var gs := str(g2)
		if gs.begins_with("_") or gs == "flowkit":
			continue
		# Only manage groups that look like recipe groups (no underscore engine groups)
		if not keep.has(gs) and gs in ["player", "enemy", "collectible", "hazard", "ui", "projectile"]:
			node.remove_from_group(gs)


static func apply_recipe(node: Node, recipe_id: String) -> void:
	var recipe := get_recipe(recipe_id)
	if recipe.is_empty() or node == null:
		return
	# Push undo snapshot
	var stack: Array = []
	if node.has_meta(META_RECIPE_STACK):
		var raw = node.get_meta(META_RECIPE_STACK)
		if raw is Array:
			stack = raw
	var snap := _snapshot_node(node)
	snap["recipe_id"] = recipe_id
	stack.append(snap)
	# Cap stack
	while stack.size() > 8:
		stack.pop_front()
	node.set_meta(META_RECIPE_STACK, stack)

	for p in recipe.get("packs", []):
		if p is Dictionary:
			FKObjectPacks.apply_pack(node, str(p.get("id", "")), p.get("options", {}) if p.get("options", {}) is Dictionary else {})
	for g in recipe.get("groups", []):
		if not node.is_in_group(str(g)):
			node.add_to_group(str(g), true)
	if bool(recipe.get("make_current", false)) and node is Camera2D:
		(node as Camera2D).make_current()
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
	var cfg := FKObjectConfig.get_config(node)
	FKObjectConfig.set_config(node, cfg)


## Undo the last apply_recipe on this node (snapshot restore).
static func undo_last_recipe(node: Node) -> String:
	if node == null or not node.has_meta(META_RECIPE_STACK):
		return ""
	var stack = node.get_meta(META_RECIPE_STACK)
	if not (stack is Array) or stack.is_empty():
		return ""
	var last: Dictionary = stack.pop_back()
	node.set_meta(META_RECIPE_STACK, stack)
	var rid := str(last.get("recipe_id", ""))
	_restore_snapshot(node, last)
	# Re-apply enabled packs from restored config so behaviors match meta
	var cfg := FKObjectConfig.get_config(node)
	var packs: Dictionary = cfg.get("packs", {})
	for pid in packs.keys():
		var entry = packs[pid]
		if entry is Dictionary and bool(entry.get("enabled", false)):
			FKObjectPacks.apply_pack(node, str(pid), entry.get("options", {}) if entry.get("options", {}) is Dictionary else {})
		else:
			FKObjectPacks.remove_pack(node, str(pid))
	return rid


## Remove a recipe's packs/groups/rules without full snapshot (best-effort).
static func remove_recipe(node: Node, recipe_id: String) -> void:
	var recipe := get_recipe(recipe_id)
	if recipe.is_empty() or node == null:
		return
	for p in recipe.get("packs", []):
		if p is Dictionary:
			FKObjectPacks.remove_pack(node, str(p.get("id", "")))
	for g in recipe.get("groups", []):
		if node.is_in_group(str(g)):
			node.remove_from_group(str(g))
	var strip: Dictionary = {}
	for er in recipe.get("rules", []):
		if er is Dictionary:
			strip[str(er.get("id", ""))] = true
	var rules: Array = []
	for r in FKObjectConfig.get_local_rules(node):
		if r is Dictionary and strip.has(str(r.get("id", ""))):
			continue
		rules.append(r)
	FKObjectConfig.set_local_rules(node, rules)
