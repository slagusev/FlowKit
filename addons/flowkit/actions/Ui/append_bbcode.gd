extends FKAction
func get_description() -> String: return "Appends BBCode text to RichTextLabel."
func get_id() -> String: return "ui_append_bbcode"
func get_name() -> String: return "Append BBCode"
func get_supported_types() -> Array[String]: return ["RichTextLabel"]
func get_inputs() -> Array[FKActionInput]: return [_t]
static var _t: FKStringActionInput:
	get: return FKStringActionInput.new("Text", "BBCode to append")
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is RichTextLabel: (node as RichTextLabel).append_text(_t.get_val(inputs))
