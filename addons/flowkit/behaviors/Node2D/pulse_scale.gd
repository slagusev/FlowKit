extends FKBehavior

func get_description() -> String:
	return "Pulses Node2D scale with a sine wave."

func get_id() -> String:
	return "pulse_scale"

func get_name() -> String:
	return "Pulse Scale"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "base_scale", "type": "float", "default": 1.0},
		{"name": "amount", "type": "float", "default": 0.15},
		{"name": "frequency", "type": "float", "default": 2.0},
	]

func get_supported_types() -> Array[String]:
	return ["Node2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	node.set_meta("fk_pulse_t", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_"+get_id(), "fk_pulse_t"]:
		if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Node2D: return
	var t: float = float(node.get_meta("fk_pulse_t", 0.0)) + delta
	node.set_meta("fk_pulse_t", t)
	var base_s: float = float(inputs.get("base_scale", 1.0))
	var amt: float = float(inputs.get("amount", 0.15))
	var freq: float = float(inputs.get("frequency", 2.0))
	var s: float = base_s + sin(t * freq * TAU) * amt
	(node as Node2D).scale = Vector2(s, s)
