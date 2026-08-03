extends FKAction
func get_description() -> String: return "Adds a delta to Range value."
func get_id() -> String: return "ui_add_progress"
func get_name() -> String: return "Add Progress"
func get_supported_types() -> Array[String]: return ["Range"]
func get_inputs() -> Array[FKActionInput]: return [_d]
static var _d: FKFloatActionInput:
	get: return FKFloatActionInput.new("Delta", "Amount to add")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Range: (node as Range).value += _d.get_val(inputs)
