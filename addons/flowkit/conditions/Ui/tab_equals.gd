extends FKCondition
func get_description() -> String: return "True when TabContainer current_tab equals index."
func get_id() -> String: return "ui_tab_equals"
func get_name() -> String: return "Current Tab Equals"
func get_inputs() -> Array[Dictionary]:
	return [{"name": "Index", "type": "int", "description": "Tab index"}]
func get_supported_types() -> Array[String]: return ["TabContainer"]
func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	return node is TabContainer and (node as TabContainer).current_tab == int(inputs.get("Index", 0))
