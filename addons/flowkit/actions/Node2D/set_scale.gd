extends FKAction
func get_description() -> String: return "Sets the scale of a Node2D."
func get_id() -> String: return "node2d_set_scale"
func get_name() -> String: return "Set Scale"
func get_supported_types() -> Array[String]: return ["Node2D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Scale X", 1.0)
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Scale Y", 1.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node2D: (node as Node2D).scale = Vector2(_x.get_val(inputs), _y.get_val(inputs))
