extends FKCondition
func get_description() -> String: return "True when Control has focus."
func get_id() -> String: return "ui_has_focus"
func get_name() -> String: return "Has Focus"
func get_inputs() -> Array[Dictionary]: return []
func get_supported_types() -> Array[String]: return ["Control"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is Control and (node as Control).has_focus()
