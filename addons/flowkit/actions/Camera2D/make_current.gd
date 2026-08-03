extends FKAction
func get_description() -> String: return "Makes this Camera2D the active camera."
func get_id() -> String: return "camera2d_make_current"
func get_name() -> String: return "Make Current"
func get_supported_types() -> Array[String]: return ["Camera2D"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Camera2D: (node as Camera2D).make_current()
