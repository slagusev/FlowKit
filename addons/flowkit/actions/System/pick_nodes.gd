extends FKAction

func get_description() -> String:
	return "Picks nodes by group and/or class into system.picked (Array). Optional filter expression uses 'n' for candidate."

func get_id() -> String:
	return "pick_nodes"

func get_name() -> String:
	return "Pick Nodes"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_group, _class, _filter]

static var _group: FKStringActionInput:
	get:
		return FKStringActionInput.new("Group", "Godot group name (optional).")

static var _class: FKStringActionInput:
	get:
		return FKStringActionInput.new("Class", "Node class name (optional), e.g. CharacterBody2D.")

static var _filter: FKStringActionInput:
	get:
		return FKStringActionInput.new("Filter", "Optional: expression with n = candidate node, e.g. n.health > 0 (leave empty for all).")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var group_name: String = str(_group.get_val(inputs)).strip_edges()
	var class_name_str: String = str(_class.get_val(inputs)).strip_edges()
	var filter_expr: String = str(_filter.get_val(inputs)).strip_edges()
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node and node.get_tree() else null
	var root = node.get_tree().current_scene if node and node.get_tree() else null
	var matches: Array = []
	if engine and engine.has_method("find_nodes_for_each") and root:
		matches = engine.find_nodes_for_each(root, group_name, class_name_str)
	if not filter_expr.is_empty() and not matches.is_empty():
		var filtered: Array = []
		for n in matches:
			# Lightweight: only allow property-ish filters via Expression
			var expr := Expression.new()
			var err := expr.parse(filter_expr, ["n"])
			if err != OK:
				continue
			var ok = expr.execute([n], null, false)
			if not expr.has_execute_failed() and ok:
				filtered.append(n)
		matches = filtered
	if system:
		system.picked = matches
		system.picked_count = matches.size()
		if matches.size() > 0:
			system.current = matches[0]
			system.current_node = matches[0]
