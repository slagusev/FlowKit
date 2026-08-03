extends FKCondition

func get_description() -> String:
	return "Compares a Range (ProgressBar/Slider) value with a threshold."

func get_id() -> String:
	return "ui_compare_progress"

func get_name() -> String:
	return "Compare Progress"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "Comparison", "type": "String", "description": "==, !=, <, >, <=, >="},
		{"name": "Value", "type": "float", "description": "Value to compare against."},
	]

func get_supported_types() -> Array[String]:
	return ["Range"]

func check(node: Node, inputs: Dictionary, block_id: String = "") -> bool:
	if not node is Range:
		return false
	var cur: float = (node as Range).value
	var op: String = str(inputs.get("Comparison", ">="))
	var val: float = float(inputs.get("Value", 0.0))
	match op:
		"==": return is_equal_approx(cur, val)
		"!=": return not is_equal_approx(cur, val)
		"<": return cur < val
		">": return cur > val
		"<=": return cur <= val
		">=": return cur >= val
		_: return cur >= val