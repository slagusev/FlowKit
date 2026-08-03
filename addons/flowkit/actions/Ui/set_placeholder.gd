extends FKAction
func get_description() -> String: return "Sets LineEdit placeholder_text."
func get_id() -> String: return "ui_set_placeholder"
func get_name() -> String: return "Set Placeholder"
func get_supported_types() -> Array[String]: return ["LineEdit"]
func get_inputs() -> Array[FKActionInput]: return [_t]
static var _t: FKStringActionInput:
	get: return FKStringActionInput.new("Text", "Placeholder")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is LineEdit: (node as LineEdit).placeholder_text = _t.get_val(inputs)
