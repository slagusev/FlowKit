extends FKAction
func get_description() -> String: return "Sets Control scale."
func get_id() -> String: return "ui_set_scale"
func get_name() -> String: return "Set Scale (UI)"
func get_supported_types() -> Array[String]: return ["Control"]
func get_inputs() -> Array[FKActionInput]: return [_x, _y]
static var _x: FKFloatActionInput:
	get: return FKFloatActionInput.new("X", "", 1.0)
static var _y: FKFloatActionInput:
	get: return FKFloatActionInput.new("Y", "", 1.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Control: (node as Control).scale = Vector2(_x.get_val(inputs), _y.get_val(inputs))
