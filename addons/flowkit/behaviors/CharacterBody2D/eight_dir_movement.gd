extends FKBehavior

func get_description() -> String:
	return "8-direction top-down movement for CharacterBody2D with optional facing rotation."

func get_id() -> String:
	return "eight_dir_movement"

func get_name() -> String:
	return "8-Dir Movement"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "move_up", "type": "String", "default": "ui_up"},
		{"name": "move_down", "type": "String", "default": "ui_down"},
		{"name": "move_left", "type": "String", "default": "ui_left"},
		{"name": "move_right", "type": "String", "default": "ui_right"},
		{"name": "speed", "type": "float", "default": 200.0},
		{"name": "rotate_to_move", "type": "bool", "default": false},
	]

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k):
		node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is CharacterBody2D:
		return
	var body := node as CharacterBody2D
	var dir := Vector2(
		Input.get_action_strength(str(inputs.get("move_right", "ui_right"))) - Input.get_action_strength(str(inputs.get("move_left", "ui_left"))),
		Input.get_action_strength(str(inputs.get("move_down", "ui_down"))) - Input.get_action_strength(str(inputs.get("move_up", "ui_up")))
	)
	if dir.length() > 1.0:
		dir = dir.normalized()
	var speed: float = float(inputs.get("speed", 200.0))
	body.velocity = dir * speed
	body.move_and_slide()
	if bool(inputs.get("rotate_to_move", false)) and dir.length() > 0.01:
		body.rotation = dir.angle()
