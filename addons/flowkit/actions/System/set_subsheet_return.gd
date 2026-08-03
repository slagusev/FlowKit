extends FKAction

func get_description() -> String:
	return "Sets the return value of the current subsheet (system.subsheet_return / r_value)."

func get_id() -> String:
	return "set_subsheet_return"

func get_name() -> String:
	return "Set Subsheet Return"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_val_input]

static var _val_input: FKActionInput:
	get:
		return FKActionInput.new("Value", "Variant", "Value returned to the caller.", null)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var value: Variant = _val_input.get_val(inputs)
	var system: Node = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system and "subsheet_return" in system:
		system.subsheet_return = value
