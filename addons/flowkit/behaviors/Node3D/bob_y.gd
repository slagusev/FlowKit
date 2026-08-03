extends FKBehavior

func get_description() -> String:
	return "Bobs Node3D on local/global Y with a sine wave."

func get_id() -> String:
	return "bob_y_3d"

func get_name() -> String:
	return "Bob Y (3D)"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "amplitude", "type": "float", "default": 0.25},
		{"name": "frequency", "type": "float", "default": 1.5},
	]

func get_supported_types() -> Array[String]:
	return ["Node3D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	if node is Node3D:
		node.set_meta("fk_bob3_oy", (node as Node3D).position.y)
		node.set_meta("fk_bob3_t", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_"+get_id(), "fk_bob3_oy", "fk_bob3_t"]:
		if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Node3D: return
	var n3 := node as Node3D
	var t: float = float(node.get_meta("fk_bob3_t", 0.0)) + delta
	node.set_meta("fk_bob3_t", t)
	var oy: float = float(node.get_meta("fk_bob3_oy", n3.position.y))
	n3.position.y = oy + sin(t * float(inputs.get("frequency", 1.5)) * TAU) * float(inputs.get("amplitude", 0.25))
