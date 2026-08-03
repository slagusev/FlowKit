extends FKAction

func get_description() -> String:
	return "Sets a sheet-local variable (s_name in expressions)."

func get_id() -> String:
	return "set_sheet_variable"

func get_name() -> String:
	return "Set Sheet Variable"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_name_input, _val_input]

static var _name_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Name", "Sheet variable name (no s_ prefix).")

static var _val_input: FKActionInput:
	get:
		return FKActionInput.new("Value", "Variant", "Value to assign.", null)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var vname: String = str(_name_input.get_val(inputs)).strip_edges()
	if vname.is_empty():
		return
	var value: Variant = _val_input.get_val(inputs)
	var system: Node = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system and system.has_method("set_sheet_var"):
		system.set_sheet_var(vname, value)
