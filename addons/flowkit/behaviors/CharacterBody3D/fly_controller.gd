extends FKBehavior

func get_description() -> String:
	return "Free-fly controller for CharacterBody3D (no gravity)."

func get_id() -> String:
	return "fly_controller_3d"

func get_name() -> String:
	return "Fly Controller (3D)"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "move_forward", "type": "String", "default": "ui_up"},
		{"name": "move_back", "type": "String", "default": "ui_down"},
		{"name": "move_left", "type": "String", "default": "ui_left"},
		{"name": "move_right", "type": "String", "default": "ui_right"},
		{"name": "move_up", "type": "String", "default": "ui_page_up"},
		{"name": "move_down", "type": "String", "default": "ui_page_down"},
		{"name": "speed", "type": "float", "default": 8.0},
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
	var basis := body.global_transform.basis
	var dir := Vector3.ZERO
	dir -= basis.z * (Input.get_action_strength(str(inputs.get("move_forward","ui_up"))) - Input.get_action_strength(str(inputs.get("move_back","ui_down"))))
	dir += basis.x * (Input.get_action_strength(str(inputs.get("move_right","ui_right"))) - Input.get_action_strength(str(inputs.get("move_left","ui_left"))))
	dir += Vector3.UP * (Input.get_action_strength(str(inputs.get("move_up","ui_page_up"))) - Input.get_action_strength(str(inputs.get("move_down","ui_page_down"))))
	if dir.length() > 1.0: dir = dir.normalized()
	body.velocity = dir * float(inputs.get("speed", 8.0))
	body.move_and_slide()
