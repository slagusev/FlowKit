extends FKCondition
func get_description() -> String: return "True when control text is empty."
func get_id() -> String: return "ui_text_is_empty"
func get_name() -> String: return "Text Is Empty"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["Label", "RichTextLabel", "Button", "LineEdit", "TextEdit"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return ("text" in node) and str(node.text).is_empty()
