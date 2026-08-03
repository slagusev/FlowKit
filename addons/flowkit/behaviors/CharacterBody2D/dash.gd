extends FKBehavior

func get_description() -> String:
	return "Adds dash on action press while keeping existing velocity/movement from other sources each frame."

func get_id() -> String:
	return "dash_behavior"

func get_name() -> String:
	return "Dash"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "dash_action", "type": "String", "default": "ui_select"},
		{"name": "dash_speed", "type": "float", "default": 500.0},
		{"name": "dash_time", "type": "float", "default": 0.15},
		{"name": "cooldown", "type": "float", "default": 0.5},
	]

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	node.set_meta("fk_dash_timer", 0.0)
	node.set_meta("fk_dash_cd", 0.0)
	node.set_meta("fk_dash_dir", Vector2.RIGHT)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_"+get_id(), "fk_dash_timer", "fk_dash_cd", "fk_dash_dir"]:
		if node.has_meta(k): node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is CharacterBody2D: return
	var body := node as CharacterBody2D
	var timer: float = float(node.get_meta("fk_dash_timer", 0.0))
	var cd: float = float(node.get_meta("fk_dash_cd", 0.0))
	cd = maxf(cd - delta, 0.0)
	if timer > 0.0:
		timer -= delta
		var d: Vector2 = node.get_meta("fk_dash_dir", Vector2.RIGHT)
		body.velocity = d * float(inputs.get("dash_speed", 500.0))
		body.move_and_slide()
		node.set_meta("fk_dash_timer", timer)
		node.set_meta("fk_dash_cd", cd)
		return
	var action := str(inputs.get("dash_action", "ui_select"))
	if cd <= 0.0 and Input.is_action_just_pressed(action):
		var dir := body.velocity
		if dir.length() < 0.1:
			dir = Vector2.RIGHT.rotated(body.rotation)
		else:
			dir = dir.normalized()
		node.set_meta("fk_dash_dir", dir)
		node.set_meta("fk_dash_timer", float(inputs.get("dash_time", 0.15)))
		node.set_meta("fk_dash_cd", float(inputs.get("cooldown", 0.5)))
	else:
		node.set_meta("fk_dash_cd", cd)
