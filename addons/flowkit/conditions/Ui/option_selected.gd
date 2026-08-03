extends FKCondition
func get_description() -> String: return "True when OptionButton selected index equals value."
func get_id() -> String: return "ui_option_selected"
func get_name() -> String: return "Option Index Equals"
func get_inputs() -> Array[Dictionary]:
	return [{"name": "Index", "type": "int", "description": "Expected selected index"}]
func get_supported_types() -> Array[String]: return ["OptionButton"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is OptionButton and (node as OptionButton).selected == int(inputs.get("Index", 0))
