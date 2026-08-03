extends FKBehavior

func get_description() -> String:
	return "Bobs a Control's position.y for a floating UI effect."

func get_id() -> String:
	return "ui_float_bob"

func get_name() -> String:
	return "UI Float Bob"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "amplitude", "type": "float", "default": 6.0},
		{"name": "frequency", "type": "float", "default": 1.2},
	]

func get_supported_types() -> Array[String]:
	return ["Control"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	if node is Control:
		node.set_meta("fk_ui_bob_oy", (node as Control).position.y)
		node.set_meta("fk_ui_bob_t", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_"+get_id(), "fk_ui_bob_oy", "fk_ui_bob_t"]:
		if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Control: return
	var c := node as Control
	var t: float = float(node.get_meta("fk_ui_bob_t", 0.0)) + delta
	node.set_meta("fk_ui_bob_t", t)
	var oy: float = float(node.get_meta("fk_ui_bob_oy", c.position.y))
	c.position.y = oy + sin(t * float(inputs.get("frequency", 1.2)) * TAU) * float(inputs.get("amplitude", 6.0))
