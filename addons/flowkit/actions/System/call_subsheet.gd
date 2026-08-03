extends FKAction

func get_description() -> String:
	return "Runs a named subsheet (reusable action list) defined on the current event sheet."

func get_id() -> String:
	return "call_subsheet"

func get_name() -> String:
	return "Call Subsheet"

func get_supported_types() -> Array[String]:
	return ["System"]

func requires_multi_frames() -> bool:
	return true

func get_inputs() -> Array[FKActionInput]:
	return [_name_input]

static var _name_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Name", "Subsheet name exactly as defined on the sheet.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var sub_name: String = str(_name_input.get_val(inputs)).strip_edges()
	if sub_name.is_empty():
		exec_completed.emit()
		return
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node and node.get_tree() else null
	if engine and engine.has_method("run_subsheet"):
		await engine.run_subsheet(sub_name, node.get_tree().current_scene if node.get_tree() else null)
	else:
		push_warning("[FlowKit] Call Subsheet: engine unavailable.")
	exec_completed.emit()
