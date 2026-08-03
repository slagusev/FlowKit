extends FKCondition

func get_description() -> String:
	return "True when the distance between this node and a target node path is less than Distance."

func get_id() -> String:
	return "distance_less_than"

func get_name() -> String:
	return "Distance Less Than"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "Target Path", "type": "String", "description": "NodePath relative to the scene root (e.g. Player)."},
		{"name": "Distance", "type": "float", "description": "Maximum distance in pixels (2D) or units (3D)."},
	]

func get_supported_types() -> Array[String]:
	return ["Node2D", "Node3D"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	var target_path: String = str(inputs.get("Target Path", "")).strip_edges()
	var max_dist: float = float(inputs.get("Distance", 0.0))
	if target_path.is_empty() or not node:
		return false
	
	var scene := node.get_tree().current_scene if node.get_tree() else null
	var other: Node = null
	if scene:
		other = scene.get_node_or_null(target_path)
	if other == null and node.get_parent():
		other = node.get_parent().get_node_or_null(target_path)
	if other == null:
		return false
	
	if node is Node2D and other is Node2D:
		return node.global_position.distance_to(other.global_position) < max_dist
	if node is Node3D and other is Node3D:
		return node.global_position.distance_to(other.global_position) < max_dist
	return false
