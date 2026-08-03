extends FKBehavior

func get_description() -> String:
	return "Oscillates Node2D on X axis with a sine wave."

func get_id() -> String:
	return "sine_move_x"

func get_name() -> String:
	return "Sine Move X"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "amplitude", "type": "float", "default": 40.0},
		{"name": "frequency", "type": "float", "default": 1.0},
	]

func get_supported_types() -> Array[String]:
	return ["Node2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	if node is Node2D:
		node.set_meta("fk_sine_ox", (node as Node2D).position.x)
		node.set_meta("fk_sine_t", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_"+get_id(), "fk_sine_ox", "fk_sine_t"]:
		if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Node2D: return
	var n2 := node as Node2D
	var t: float = float(node.get_meta("fk_sine_t", 0.0)) + delta
	node.set_meta("fk_sine_t", t)
	var ox: float = float(node.get_meta("fk_sine_ox", n2.position.x))
	n2.position.x = ox + sin(t * float(inputs.get("frequency", 1.0)) * TAU) * float(inputs.get("amplitude", 40.0))
