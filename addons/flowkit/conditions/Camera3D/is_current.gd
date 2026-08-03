extends FKCondition
func get_description() -> String: return "True when this Camera3D is current."
func get_id() -> String: return "camera3d_is_current"
func get_name() -> String: return "Is Current (3D)"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["Camera3D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is Camera3D and (node as Camera3D).current
