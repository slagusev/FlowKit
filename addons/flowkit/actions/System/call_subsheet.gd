extends FKAction

func get_description() -> String:
	return "Runs a named subsheet (reusable action list). Optional JSON args become p_name inside the subsheet."

func get_id() -> String:
	return "call_subsheet"

func get_name() -> String:
	return "Call Subsheet"

func get_supported_types() -> Array[String]:
	return ["System"]

func requires_multi_frames() -> bool:
	return true

func get_inputs() -> Array[FKActionInput]:
	return [_name_input, _args_input]

static var _name_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Name", "Subsheet name exactly as defined on the sheet.")

static var _args_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("ArgsJson", "Optional JSON object of parameters, e.g. {\"damage\":10}.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var sub_name: String = str(_name_input.get_val(inputs)).strip_edges()
	if sub_name.is_empty():
		exec_completed.emit()
		return
	var args: Dictionary = {}
	var raw: String = str(_args_input.get_val(inputs)).strip_edges()
	if not raw.is_empty():
		var parsed = JSON.parse_string(raw)
		if parsed is Dictionary:
			args = parsed
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node and node.get_tree() else null
	if engine and engine.has_method("run_subsheet"):
		var scene = node.get_tree().current_scene if node.get_tree() else null
		await engine.run_subsheet(sub_name, scene, args)
	else:
		push_warning("[FlowKit] Call Subsheet: engine unavailable.")
	exec_completed.emit()
