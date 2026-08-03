extends FKAction

func get_description() -> String:
	return "For each matching node (by group and/or class), sets system.current and runs a subsheet."

func get_id() -> String:
	return "for_each"

func get_name() -> String:
	return "For Each"

func get_supported_types() -> Array[String]:
	return ["System"]

func requires_multi_frames() -> bool:
	return true

func get_inputs() -> Array[FKActionInput]:
	return [_group_input, _class_input, _subsheet_input]

static var _group_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Group", "Godot group name (optional if Class set).")

static var _class_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Class", "Node class e.g. CharacterBody2D (optional if Group set).")

static var _subsheet_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("Subsheet", "Subsheet to run for each match.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var group_name: String = str(_group_input.get_val(inputs)).strip_edges()
	var class_name_str: String = str(_class_input.get_val(inputs)).strip_edges()
	var sub_name: String = str(_subsheet_input.get_val(inputs)).strip_edges()
	
	if sub_name.is_empty() or (group_name.is_empty() and class_name_str.is_empty()):
		push_warning("[FlowKit] For Each: need Subsheet and Group or Class.")
		exec_completed.emit()
		return
	
	var tree := node.get_tree() if node else null
	if tree == null:
		exec_completed.emit()
		return
	
	var engine = tree.root.get_node_or_null("/root/FlowKit")
	var system = tree.root.get_node_or_null("/root/FlowKitSystem")
	var root: Node = tree.current_scene
	
	var matches: Array = []
	if engine and engine.has_method("find_nodes_for_each"):
		matches = engine.find_nodes_for_each(root, group_name, class_name_str)

	var max_n: int = 512
	if system and "for_each_max" in system:
		max_n = int(system.for_each_max)
	if max_n > 0 and matches.size() > max_n:
		if system and system.has_method("debug_push"):
			system.debug_push("for_each", "capped %d→%d" % [matches.size(), max_n])
		matches = matches.slice(0, max_n)

	var i := 0
	for n in matches:
		if not is_instance_valid(n):
			continue
		if system and system.has_method("set_current_node"):
			system.set_current_node(n)
		if system and "variables" in system:
			system.variables["for_each_index"] = i
		if engine and engine.has_method("run_subsheet"):
			await engine.run_subsheet(sub_name, root)
		i += 1

	if system and system.has_method("set_current_node"):
		system.set_current_node(null)

	exec_completed.emit()
