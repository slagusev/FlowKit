extends FKAction
func get_description() -> String: return "Hides a Popup or Window."
func get_id() -> String: return "ui_hide_popup"
func get_name() -> String: return "Hide Popup"
func get_supported_types() -> Array[String]: return ["Popup", "Window"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Window: (node as Window).hide()
	elif node is Popup: (node as Popup).hide()
