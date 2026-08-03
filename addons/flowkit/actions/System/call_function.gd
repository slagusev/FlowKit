extends FKAction

func get_description() -> String:
	return "Calls a function previously registered with Define Function."

func get_id() -> String:
	return "call_function"

func get_name() -> String:
	return "Call Function"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_name_input, _arg0_input]

static var _name_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Name", "Name of the function to call.")

static var _arg0_input: FKActionInput:
	get:
		return FKActionInput.new("Arg0", "Variant", "Optional first argument (available as arg0 in the body).", null)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var function_name: String = str(_name_input.get_val(inputs)).strip_edges()
	var arg0: Variant = _arg0_input.get_val(inputs)

	if function_name.is_empty():
		push_warning("[FlowKit] Call Function: empty name — ignored.")
		return

	var system: Node = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system == null or not system.has_method("call_function"):
		push_error("[FlowKit] Call Function: FlowKitSystem unavailable.")
		return

	var args: Array = []
	if arg0 != null:
		args.append(arg0)
	system.call_function(function_name, args)
