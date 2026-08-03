extends FKAction
func get_description() -> String: return "Clears text on Label/LineEdit/TextEdit/Button."
func get_id() -> String: return "ui_clear_text"
func get_name() -> String: return "Clear Text"
func get_supported_types() -> Array[String]: return ["Label", "RichTextLabel", "LineEdit", "TextEdit", "Button"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if "text" in node: node.set("text", "")
	if node is RichTextLabel: (node as RichTextLabel).clear()
