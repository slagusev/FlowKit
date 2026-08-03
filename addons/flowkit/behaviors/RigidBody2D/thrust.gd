extends FKBehavior

func get_description() -> String:
	return "Applies force to RigidBody2D based on input (asteroids-style thrust + torque)."

func get_id() -> String:
	return "rigid_thrust"

func get_name() -> String:
	return "Thrust (Rigid2D)"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "thrust_action", "type": "String", "default": "ui_up"},
		{"name": "left_action", "type": "String", "default": "ui_left"},
		{"name": "right_action", "type": "String", "default": "ui_right"},
		{"name": "thrust_force", "type": "float", "default": 400.0},
		{"name": "torque", "type": "float", "default": 8000.0},
	]

func get_supported_types() -> Array[String]:
	return ["RigidBody2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is RigidBody2D: return
	var body := node as RigidBody2D
	if Input.is_action_pressed(str(inputs.get("thrust_action", "ui_up"))):
		var f := Vector2.RIGHT.rotated(body.rotation) * float(inputs.get("thrust_force", 400.0))
		body.apply_central_force(f)
	var t := 0.0
	if Input.is_action_pressed(str(inputs.get("left_action", "ui_left"))): t -= 1.0
	if Input.is_action_pressed(str(inputs.get("right_action", "ui_right"))): t += 1.0
	if t != 0.0:
		body.apply_torque(t * float(inputs.get("torque", 8000.0)))
