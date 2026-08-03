extends FKCondition
func get_description() -> String: return "True when this Camera2D is the current camera."
func get_id() -> String: return "camera2d_is_current"
func get_name() -> String: return "Is Current"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["Camera2D"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is Camera2D and (node as Camera2D).is_current()
