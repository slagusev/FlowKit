extends FKAction
func get_description() -> String: return "Sets max_value on a Range (ProgressBar/Slider)."
func get_id() -> String: return "ui_set_progress_max"
func get_name() -> String: return "Set Progress Max"
func get_supported_types() -> Array[String]: return ["Range"]
func get_inputs() -> Array[FKActionInput]: return [_m]
static var _m: FKFloatActionInput:
	get: return FKFloatActionInput.new("Max", "", 100.0)
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Range: (node as Range).max_value = _m.get_val(inputs)
