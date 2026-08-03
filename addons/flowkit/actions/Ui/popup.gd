extends FKAction
func get_description() -> String: return "Shows a Popup / PopupPanel / Window centered."
func get_id() -> String: return "ui_popup"
func get_name() -> String: return "Popup Centered"
func get_supported_types() -> Array[String]: return ["Popup", "Window"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Window:
		(node as Window).popup_centered()
	elif node is Popup:
		(node as Popup).popup_centered()
