extends FKBehavior

func get_description() -> String:
	return "Rotates a Node2D at a constant angular speed (radians/sec)."

func get_id() -> String:
	return "rotate_constantly"

func get_name() -> String:
	return "Rotate Constantly"

func get_inputs() -> Array[Dictionary]:
	return [{"name": "radians_per_sec", "type": "float", "default": 1.0}]

func get_supported_types() -> Array[String]:
	return ["Node2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k):
		node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if node is Node2D:
		(node as Node2D).rotation += float(inputs.get("radians_per_sec", 1.0)) * delta
