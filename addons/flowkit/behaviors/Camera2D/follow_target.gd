extends FKBehavior

func get_description() -> String:
	return "Smoothly follows a Node2D by group name (first node in group) or sibling name path."

func get_id() -> String:
	return "camera_follow_target"

func get_name() -> String:
	return "Camera Follow Target"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "target_group", "type": "String", "default": "player"},
		{"name": "lerp_speed", "type": "float", "default": 5.0},
	]

func get_supported_types() -> Array[String]:
	return ["Camera2D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k):
		node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Camera2D or node.get_tree() == null:
		return
	var cam := node as Camera2D
	var group: String = str(inputs.get("target_group", "player"))
	var nodes := node.get_tree().get_nodes_in_group(group)
	if nodes.is_empty():
		return
	var target: Node = nodes[0]
	if target is Node2D:
		var ls: float = float(inputs.get("lerp_speed", 5.0))
		cam.global_position = cam.global_position.lerp((target as Node2D).global_position, clampf(ls * delta, 0.0, 1.0))
