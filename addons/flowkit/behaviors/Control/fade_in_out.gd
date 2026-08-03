extends FKBehavior

func get_description() -> String:
	return "Pulses Control modulate alpha (UI breathe / attention effect)."

func get_id() -> String:
	return "ui_fade_pulse"

func get_name() -> String:
	return "UI Fade Pulse"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "min_alpha", "type": "float", "default": 0.4},
		{"name": "max_alpha", "type": "float", "default": 1.0},
		{"name": "frequency", "type": "float", "default": 1.0},
	]

func get_supported_types() -> Array[String]:
	return ["Control", "CanvasItem"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	node.set_meta("fk_ui_fade_t", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_"+get_id(), "fk_ui_fade_t"]:
		if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is CanvasItem: return
	var t: float = float(node.get_meta("fk_ui_fade_t", 0.0)) + delta
	node.set_meta("fk_ui_fade_t", t)
	var mn: float = float(inputs.get("min_alpha", 0.4))
	var mx: float = float(inputs.get("max_alpha", 1.0))
	var freq: float = float(inputs.get("frequency", 1.0))
	var a: float = lerpf(mn, mx, 0.5 + 0.5 * sin(t * freq * TAU))
	var c: Color = (node as CanvasItem).modulate
	c.a = a
	(node as CanvasItem).modulate = c
