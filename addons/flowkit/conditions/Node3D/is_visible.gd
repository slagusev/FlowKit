extends FKCondition
func get_description() -> String: return "True when Node3D is visible."
func get_id() -> String: return "node3d_is_visible"
func get_name() -> String: return "Is Visible (3D)"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["Node3D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is Node3D and (node as Node3D).visible
