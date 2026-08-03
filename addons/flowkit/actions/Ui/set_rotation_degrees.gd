extends FKAction
func get_description() -> String: return "Sets Control rotation in degrees."
func get_id() -> String: return "ui_set_rotation_degrees"
func get_name() -> String: return "Set Rotation Degrees (UI)"
func get_supported_types() -> Array[String]: return ["Control"]
func get_inputs() -> Array[FKActionInput]: return [_d]
static var _d: FKFloatActionInput:
	get: return FKFloatActionInput.new("Degrees", "")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Control: (node as Control).rotation_degrees = _d.get_val(inputs)
