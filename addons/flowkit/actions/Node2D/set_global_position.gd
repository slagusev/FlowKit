extends FKAction
func get_description() -> String: return "Sets global position of a Node2D."
func get_id() -> String: return "node2d_set_global_position"
func get_name() -> String: return "Set Global Position"
func get_supported_types() -> Array[String]: return ["Node2D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Global X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Global Y")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node2D: (node as Node2D).global_position = Vector2(_x.get_val(inputs), _y.get_val(inputs))
