extends FKAction
func get_description() -> String: return "Sets min_value on a Range."
func get_id() -> String: return "ui_set_progress_min"
func get_name() -> String: return "Set Progress Min"
func get_supported_types() -> Array[String]: return ["Range"]
func get_inputs() -> Array[FKActionInput]: return [_m]
static var _m: FKFloatActionInput:
	get: return FKFloatActionInput.new("Min", "", 0.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Range: (node as Range).min_value = _m.get_val(inputs)
