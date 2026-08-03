extends FKAction
func get_description() -> String: return "Scrolls ScrollContainer to top."
func get_id() -> String: return "ui_scroll_to_top"
func get_name() -> String: return "Scroll To Top"
func get_supported_types() -> Array[String]: return ["ScrollContainer"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is ScrollContainer:
		(node as ScrollContainer).scroll_vertical = 0
		(node as ScrollContainer).scroll_horizontal = 0
