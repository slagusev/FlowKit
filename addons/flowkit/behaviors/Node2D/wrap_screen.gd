extends FKBehavior

func get_description() -> String:
	return "Wraps Node2D around the viewport (asteroids-style screen wrap)."

func get_id() -> String:
	return "wrap_screen"

func get_name() -> String:
	return "Wrap Screen"

func get_inputs() -> Array[Dictionary]:
	return [{"name": "margin", "type": "float", "default": 0.0}]

func get_supported_types() -> Array[String]:
	return ["Node2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Node2D or node.get_viewport() == null: return
	var n2 := node as Node2D
	var rect := node.get_viewport().get_visible_rect()
	var m: float = float(inputs.get("margin", 0.0))
	var p := n2.global_position
	if p.x < rect.position.x - m: p.x = rect.end.x + m
	elif p.x > rect.end.x + m: p.x = rect.position.x - m
	if p.y < rect.position.y - m: p.y = rect.end.y + m
	elif p.y > rect.end.y + m: p.y = rect.position.y - m
	n2.global_position = p
