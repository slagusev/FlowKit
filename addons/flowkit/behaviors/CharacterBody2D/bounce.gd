extends FKBehavior

func get_description() -> String:
	return "Bounces CharacterBody2D off walls using collision normals (needs continuous motion)."

func get_id() -> String:
	return "bounce_movement"

func get_name() -> String:
	return "Bounce"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "speed", "type": "float", "default": 200.0},
		{"name": "dir_x", "type": "float", "default": 1.0},
		{"name": "dir_y", "type": "float", "default": 1.0},
	]

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	if node is CharacterBody2D:
		var d := Vector2(float(inputs.get("dir_x", 1.0)), float(inputs.get("dir_y", 1.0)))
		if d.length() < 0.001:
			d = Vector2(1, 1)
		node.set_meta("flowkit_bounce_dir", d.normalized())

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_" + get_id(), "flowkit_bounce_dir"]:
		if node.has_meta(k):
			node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is CharacterBody2D:
		return
	var body := node as CharacterBody2D
	var dir: Vector2 = node.get_meta("flowkit_bounce_dir", Vector2(1, 1))
	var speed: float = float(inputs.get("speed", 200.0))
	body.velocity = dir * speed
	body.move_and_slide()
	for i in range(body.get_slide_collision_count()):
		var col := body.get_slide_collision(i)
		if col:
			dir = dir.bounce(col.get_normal()).normalized()
			node.set_meta("flowkit_bounce_dir", dir)
			break
