extends FKBehavior

func get_description() -> String:
	return "Offsets Camera2D slightly toward the mouse for a look-ahead effect."

func get_id() -> String:
	return "camera_mouse_look"

func get_name() -> String:
	return "Camera Mouse Look"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "strength", "type": "float", "default": 0.15},
		{"name": "max_offset", "type": "float", "default": 80.0},
	]

func get_supported_types() -> Array[String]:
	return ["Camera2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Camera2D: return
	var cam := node as Camera2D
	var vp := cam.get_viewport()
	if vp == null: return
	var center := vp.get_visible_rect().size * 0.5
	var mouse := vp.get_mouse_position()
	var off := (mouse - center) * float(inputs.get("strength", 0.15))
	var mx: float = float(inputs.get("max_offset", 80.0))
	off.x = clampf(off.x, -mx, mx)
	off.y = clampf(off.y, -mx, mx)
	cam.offset = cam.offset.lerp(off, clampf(8.0 * delta, 0.0, 1.0))
