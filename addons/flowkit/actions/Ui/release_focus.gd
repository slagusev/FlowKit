extends FKAction
func get_description() -> String: return "Releases focus from this Control."
func get_id() -> String: return "ui_release_focus"
func get_name() -> String: return "Release Focus"
func get_supported_types() -> Array[String]: return ["Control"]
func get_inputs() -> Array[FKActionInput]: return []
func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is Control: (node as Control).release_focus()
