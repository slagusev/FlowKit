extends FKAction
func get_description() -> String: return "Sets Control position (top-left)."
func get_id() -> String: return "ui_set_position"
func get_name() -> String: return "Set Position"
func get_supported_types() -> Array[String]: return ["Control"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "")
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Control: (node as Control).position = Vector2(_x.get_val(inputs), _y.get_val(inputs))
