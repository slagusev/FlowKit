extends FKBehavior

func get_description() -> String:
	return "Rotates Node2D to always face the mouse."

func get_id() -> String:
	return "look_at_mouse"

func get_name() -> String:
	return "Look At Mouse"

func get_inputs() -> Array[Dictionary]:
	return [{"name": "offset_degrees", "type": "float", "default": 0.0}]

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
		var n2 := node as Node2D
		var ang := (n2.get_global_mouse_position() - n2.global_position).angle()
		n2.rotation = ang + deg_to_rad(float(inputs.get("offset_degrees", 0.0)))
