extends FKAction

func get_description() -> String:
	return "Runs a subsheet for each node in system.picked (from Pick Nodes). Sets current each iteration."

func get_id() -> String:
	return "for_each_picked"

func get_name() -> String:
	return "For Each Picked"

func get_supported_types() -> Array[String]:
	return ["System"]

func requires_multi_frames() -> bool:
	return true

func get_inputs() -> Array[FKActionInput]:
	return [_sub]

static var _sub: FKStringActionInput:
	get:
		return FKStringActionInput.new("Subsheet", "Subsheet name to run for each picked node.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var sub_name: String = str(_sub.get_val(inputs)).strip_edges()
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node and node.get_tree() else null
	if sub_name.is_empty() or system == null or engine == null:
		exec_completed.emit()
		return
	var list: Array = system.picked if "picked" in system else []
	var scene = node.get_tree().current_scene if node.get_tree() else null
	for n in list:
		if not is_instance_valid(n):
			continue
		if system.has_method("set_current_node"):
			system.set_current_node(n)
		else:
			system.current = n
			system.current_node = n
		await engine.run_subsheet(sub_name, scene, {})
	exec_completed.emit()
