extends FKBehavior

func get_description() -> String:
	return "Simple left/right patrol for CharacterBody2D. Flips direction on wall or timer."

func get_id() -> String:
	return "enemy_patrol"

func get_name() -> String:
	return "Enemy Patrol"

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "speed", "type": "float", "default": 80.0},
		{"name": "gravity", "type": "float", "default": 900.0},
		{"name": "flip_on_wall", "type": "bool", "default": true},
		{"name": "patrol_time", "type": "float", "default": 0.0}
	]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	node.set_meta("fk_patrol_dir", 1.0)
	node.set_meta("fk_patrol_t", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_" + get_id(), "fk_patrol_dir", "fk_patrol_t"]:
		if node.has_meta(k):
			node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not (node is CharacterBody2D):
		return
	var body := node as CharacterBody2D
	var speed := float(inputs.get("speed", 80.0))
	var gravity := float(inputs.get("gravity", 900.0))
	var flip_wall := bool(inputs.get("flip_on_wall", true))
	var patrol_time := float(inputs.get("patrol_time", 0.0))
	var dir := float(node.get_meta("fk_patrol_dir", 1.0))
	if patrol_time > 0.0:
		var t := float(node.get_meta("fk_patrol_t", 0.0)) + delta
		if t >= patrol_time:
			t = 0.0
			dir = -dir
		node.set_meta("fk_patrol_t", t)
	body.velocity.x = dir * speed
	body.velocity.y += gravity * delta
	body.move_and_slide()
	if flip_wall and body.is_on_wall():
		dir = -dir
	node.set_meta("fk_patrol_dir", dir)
