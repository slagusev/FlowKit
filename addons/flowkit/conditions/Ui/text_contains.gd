extends FKCondition
func get_description() -> String: return "True when control text contains substring."
func get_id() -> String: return "ui_text_contains"
func get_name() -> String: return "Text Contains"
func get_inputs() -> Array[Dictionary]:
	return [{"name": "Substring", "type": "String", "description": "Text to find"}]
func get_supported_types() -> Array[String]: return ["Label", "RichTextLabel", "Button", "LineEdit", "TextEdit"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	var sub := str(inputs.get("Substring", ""))
	if sub.is_empty() or not ("text" in node): return false
	return str(node.text).find(sub) >= 0
