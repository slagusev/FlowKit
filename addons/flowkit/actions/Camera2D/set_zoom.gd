extends FKAction
func get_description() -> String: return "Sets Camera2D zoom."
func get_id() -> String: return "camera2d_set_zoom"
func get_name() -> String: return "Set Zoom"
func get_supported_types() -> Array[String]: return ["Camera2D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Zoom X", 1.0)
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Zoom Y", 1.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Camera2D: (node as Camera2D).zoom = Vector2(_x.get_val(inputs), _y.get_val(inputs))
