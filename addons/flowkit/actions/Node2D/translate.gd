extends FKAction
func get_description() -> String: return "Moves a Node2D by a relative offset."
func get_id() -> String: return "node2d_translate"
func get_name() -> String: return "Translate"
func get_supported_types() -> Array[String]: return ["Node2D"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "Delta X")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "Delta Y")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Node2D: (node as Node2D).translate(Vector2(_x.get_val(inputs), _y.get_val(inputs)))
