extends FKBehavior

func get_description() -> String:
	return "Bobs a Node2D up and down with a sine wave."

func get_id() -> String:
	return "bob_up_down"

func get_name() -> String:
	return "Bob Up/Down"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "amplitude", "type": "float", "default": 8.0},
		{"name": "frequency", "type": "float", "default": 2.0},
	]

func get_supported_types() -> Array[String]:
	return ["Node2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	if node is Node2D:
		node.set_meta("flowkit_bob_origin_y", (node as Node2D).position.y)
		node.set_meta("flowkit_bob_t", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_" + get_id(), "flowkit_bob_origin_y", "flowkit_bob_t"]:
		if node.has_meta(k):
			node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Node2D:
		return
	var n2 := node as Node2D
	var t: float = float(node.get_meta("flowkit_bob_t", 0.0)) + delta
	node.set_meta("flowkit_bob_t", t)
	var origin: float = float(node.get_meta("flowkit_bob_origin_y", n2.position.y))
	var amp: float = float(inputs.get("amplitude", 8.0))
	var freq: float = float(inputs.get("frequency", 2.0))
	n2.position.y = origin + sin(t * freq * TAU) * amp
