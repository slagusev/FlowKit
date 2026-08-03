extends FKBehavior

func get_description() -> String:
	return "Rotates Node3D around Y at constant speed (radians/sec)."

func get_id() -> String:
	return "rotate_y_constantly_3d"

func get_name() -> String:
	return "Rotate Y Constantly (3D)"

func get_inputs() -> Array[Dictionary]:
	return [{"name": "radians_per_sec", "type": "float", "default": 1.0}]

func get_supported_types() -> Array[String]:
	return ["Node3D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if node is Node3D:
		(node as Node3D).rotate_y(float(inputs.get("radians_per_sec", 1.0)) * delta)
