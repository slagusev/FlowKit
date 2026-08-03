extends FKBehavior

func get_description() -> String:
	return "Simple 3D platformer: horizontal move + jump for CharacterBody3D."

func get_id() -> String:
	return "platformer_movement_3d"

func get_name() -> String:
	return "Platformer Movement (3D)"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "move_forward", "type": "String", "default": "ui_up"},
		{"name": "move_back", "type": "String", "default": "ui_down"},
		{"name": "move_left", "type": "String", "default": "ui_left"},
		{"name": "move_right", "type": "String", "default": "ui_right"},
		{"name": "jump", "type": "String", "default": "ui_accept"},
		{"name": "speed", "type": "float", "default": 5.0},
		{"name": "jump_force", "type": "float", "default": 6.0},
		{"name": "gravity", "type": "float", "default": 20.0},
	]

func get_supported_types() -> Array[String]:
	return ["CharacterBody3D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is CharacterBody3D: return
	var body := node as CharacterBody3D
	var dir := Vector3(
		Input.get_action_strength(str(inputs.get("move_right","ui_right"))) - Input.get_action_strength(str(inputs.get("move_left","ui_left"))),
		0.0,
		Input.get_action_strength(str(inputs.get("move_back","ui_down"))) - Input.get_action_strength(str(inputs.get("move_forward","ui_up")))
	)
	if dir.length() > 1.0: dir = dir.normalized()
	var speed: float = float(inputs.get("speed", 5.0))
	body.velocity.x = dir.x * speed
	body.velocity.z = dir.z * speed
	if not body.is_on_floor():
		body.velocity.y -= float(inputs.get("gravity", 20.0)) * delta
	elif Input.is_action_just_pressed(str(inputs.get("jump", "ui_accept"))):
		body.velocity.y = float(inputs.get("jump_force", 6.0))
	body.move_and_slide()
