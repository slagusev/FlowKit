extends FKBehavior

func get_description() -> String:
	return "Smoothly follows first Node3D in a group (offset applied)."

func get_id() -> String:
	return "camera_follow_group_3d"

func get_name() -> String:
	return "Camera Follow Group (3D)"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "target_group", "type": "String", "default": "player"},
		{"name": "offset_x", "type": "float", "default": 0.0},
		{"name": "offset_y", "type": "float", "default": 4.0},
		{"name": "offset_z", "type": "float", "default": 6.0},
		{"name": "lerp_speed", "type": "float", "default": 5.0},
	]

func get_supported_types() -> Array[String]:
	return ["Camera3D"]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k): node.remove_meta(k)

func process(node: Node, delta: float, inputs: Dictionary) -> void:
	if not node is Camera3D or node.get_tree() == null: return
	var cam := node as Camera3D
	var nodes := node.get_tree().get_nodes_in_group(str(inputs.get("target_group", "player")))
	if nodes.is_empty(): return
	var t = nodes[0]
	if not t is Node3D: return
	var off := Vector3(float(inputs.get("offset_x",0)), float(inputs.get("offset_y",4)), float(inputs.get("offset_z",6)))
	var target_pos: Vector3 = (t as Node3D).global_position + off
	var ls: float = float(inputs.get("lerp_speed", 5.0))
	cam.global_position = cam.global_position.lerp(target_pos, clampf(ls * delta, 0.0, 1.0))
	cam.look_at((t as Node3D).global_position, Vector3.UP)
