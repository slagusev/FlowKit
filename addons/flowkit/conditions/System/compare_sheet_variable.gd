extends FKCondition

func get_description() -> String:
	return "Compares a sheet-local variable against a value."

func get_id() -> String:
	return "compare_sheet_variable"

func get_name() -> String:
	return "Compare Sheet Variable"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "Name", "type": "String", "description": "Sheet variable name."},
		{"name": "Comparison", "type": "String", "description": "==, !=, <, >, <=, >="},
		{"name": "Value", "type": "Variant", "description": "Value to compare."},
	]

func get_supported_types() -> Array[String]:
	return ["System"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	var vname: String = str(inputs.get("Name", "")).strip_edges()
	var op: String = str(inputs.get("Comparison", "=="))
	var compare_value: Variant = inputs.get("Value", null)
	var system: Node = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system == null or not system.has_method("get_sheet_var"):
		return false
	var var_value: Variant = system.get_sheet_var(vname, null)
	match op:
		"==": return var_value == compare_value
		"!=": return var_value != compare_value
		"<": return var_value < compare_value
		">": return var_value > compare_value
		"<=": return var_value <= compare_value
		">=": return var_value >= compare_value
		_: return var_value == compare_value
