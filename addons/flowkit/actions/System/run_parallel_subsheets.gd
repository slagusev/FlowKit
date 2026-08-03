extends FKAction

func get_description() -> String:
	return "Starts multiple subsheets in parallel (comma-separated names). Does not wait for them."

func get_id() -> String:
	return "run_parallel_subsheets"

func get_name() -> String:
	return "Run Parallel Subsheets"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_names]

static var _names: FKStringActionInput:
	get:
		return FKStringActionInput.new("Names", "Comma-separated subsheet names.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var raw: String = str(_names.get_val(inputs)).strip_edges()
	if raw.is_empty():
		return
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node and node.get_tree() else null
	if engine == null or not engine.has_method("run_subsheet"):
		return
	var scene = node.get_tree().current_scene if node.get_tree() else null
	for part in raw.split(","):
		var n := str(part).strip_edges()
		if n.is_empty():
			continue
		# Fire-and-forget async: call without await
		engine.run_subsheet(n, scene, {})
