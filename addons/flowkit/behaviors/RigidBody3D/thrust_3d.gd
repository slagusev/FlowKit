extends FKBehavior

func get_description() -> String:
	return "Applies forward thrust and yaw torque to RigidBody3D from input actions."

func get_id() -> String:
	return "rigid_thrust_3d"

func get_name() -> String:
	return "Thrust (Rigid3D)"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "thrust_action", "type": "String", "default": "ui_up"},
		{"name": "left_action", "type": "String", "default": "ui_left"},
		{"name": "right_action", "type": "String", "default": "ui_right"},
		{"name": "thrust_force", "type": "float", "default": 20.0},
		{"name": "torque", "type": "float", "default": 10.0},
	]

func get_supported_types() -> Array[String]:
	return ["RigidBody3D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func physics_process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is RigidBody3D: return
	var body := node as RigidBody3D
	if Input.is_action_pressed(str(inputs.get("thrust_action", "ui_up"))):
		var f: Vector3 = -body.global_transform.basis.z * float(inputs.get("thrust_force", 20.0))
		body.apply_central_force(f)
	var yaw := 0.0
	if Input.is_action_pressed(str(inputs.get("left_action", "ui_left"))): yaw += 1.0
	if Input.is_action_pressed(str(inputs.get("right_action", "ui_right"))): yaw -= 1.0
	if yaw != 0.0:
		body.apply_torque(Vector3.UP * yaw * float(inputs.get("torque", 10.0)))
