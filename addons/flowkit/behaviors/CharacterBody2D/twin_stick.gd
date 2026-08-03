extends FKBehavior

func get_description() -> String:
	return "Twin-stick: move with one pair of actions, aim rotation with mouse or second stick actions."

func get_id() -> String:
	return "twin_stick_movement"

func get_name() -> String:
	return "Twin-Stick Movement"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "move_up", "type": "String", "default": "ui_up"},
		{"name": "move_down", "type": "String", "default": "ui_down"},
		{"name": "move_left", "type": "String", "default": "ui_left"},
		{"name": "move_right", "type": "String", "default": "ui_right"},
		{"name": "speed", "type": "float", "default": 220.0},
		{"name": "aim_with_mouse", "type": "bool", "default": true},
	]

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is CharacterBody2D: return
	var body := node as CharacterBody2D
	var dir := Vector2(
		Input.get_action_strength(str(inputs.get("move_right","ui_right"))) - Input.get_action_strength(str(inputs.get("move_left","ui_left"))),
		Input.get_action_strength(str(inputs.get("move_down","ui_down"))) - Input.get_action_strength(str(inputs.get("move_up","ui_up")))
	)
	if dir.length() > 1.0: dir = dir.normalized()
	body.velocity = dir * float(inputs.get("speed", 220.0))
	body.move_and_slide()
	if bool(inputs.get("aim_with_mouse", true)):
		body.rotation = (body.get_global_mouse_position() - body.global_position).angle()
