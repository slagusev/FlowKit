extends FKBehavior

func get_description() -> String:
	return "Applies decaying screen shake to Camera2D. Set system var camera_shake_strength to trigger."

func get_id() -> String:
	return "camera_screen_shake"

func get_name() -> String:
	return "Screen Shake"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "decay", "type": "float", "default": 5.0},
		{"name": "max_offset", "type": "float", "default": 12.0},
	]

func get_supported_types() -> Array[String]:
	return ["Camera2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	node.set_meta("flowkit_shake", 0.0)

func remove(node: Node) -> void:
	for k in ["flowkit_behavior_" + get_id(), "flowkit_shake"]:
		if node.has_meta(k):
			node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Camera2D or node.get_tree() == null:
		return
	var cam := node as Camera2D
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem")
	var shake: float = float(node.get_meta("flowkit_shake", 0.0))
	if system and system.has_method("get_var"):
		var ext = system.get_var("camera_shake_strength", 0.0)
		if float(ext) > shake:
			shake = float(ext)
			if system.has_method("set_var"):
				system.set_var("camera_shake_strength", 0.0)
	var decay: float = float(inputs.get("decay", 5.0))
	var max_off: float = float(inputs.get("max_offset", 12.0))
	shake = maxf(shake - decay * delta, 0.0)
	node.set_meta("flowkit_shake", shake)
	if shake > 0.0:
		cam.offset = Vector2(
			randf_range(-1, 1) * max_off * shake,
			randf_range(-1, 1) * max_off * shake
		)
	else:
		cam.offset = Vector2.ZERO
