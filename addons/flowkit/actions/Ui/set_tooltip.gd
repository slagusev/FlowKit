extends FKAction
func get_description() -> String: return "Sets Control tooltip_text."
func get_id() -> String: return "ui_set_tooltip"
func get_name() -> String: return "Set Tooltip"
func get_supported_types() -> Array[String]: return ["Control"]
func get_inputs() -> Array[FKActionInput]: return [_t]
static var _t: FKStringActionInput:
	get: return FKStringActionInput.new("Text", "Tooltip text")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Control: (node as Control).tooltip_text = _t.get_val(inputs)
