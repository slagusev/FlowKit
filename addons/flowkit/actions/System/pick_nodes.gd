extends FKAction

func get_description() -> String:
	return "Picks nodes by group/class into system.picked. Options: Random one, Invert filter, Max count."

func get_id() -> String:
	return "pick_nodes"

func get_name() -> String:
	return "Pick Nodes"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_group, _class, _filter, _random, _invert, _max]

static var _group: FKStringActionInput:
	get:
		return FKStringActionInput.new("Group", "Godot group name (optional).")

static var _class: FKStringActionInput:
	get:
		return FKStringActionInput.new("Class", "Node class name (optional).")

static var _filter: FKStringActionInput:
	get:
		return FKStringActionInput.new("Filter", "Optional Expression with n = candidate (e.g. n.visible).")

static var _random: FKBoolActionInput:
	get:
		return FKBoolActionInput.new("RandomOne", "If true, keep only one random match.", false)

static var _invert: FKBoolActionInput:
	get:
		return FKBoolActionInput.new("InvertFilter", "If true, keep nodes that FAIL the filter.", false)

static var _max: FKIntActionInput:
	get:
		return FKIntActionInput.new("MaxCount", "Max nodes to keep (0 = unlimited).", 0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var group_name: String = str(_group.get_val(inputs)).strip_edges()
	var class_name_str: String = str(_class.get_val(inputs)).strip_edges()
	var filter_expr: String = str(_filter.get_val(inputs)).strip_edges()
	var random_one: bool = bool(_random.get_val(inputs))
	var invert: bool = bool(_invert.get_val(inputs))
	var max_count: int = int(_max.get_val(inputs))
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node and node.get_tree() else null
	var root = node.get_tree().current_scene if node and node.get_tree() else null
	var matches: Array = []
	if engine and engine.has_method("find_nodes_for_each") and root:
		matches = engine.find_nodes_for_each(root, group_name, class_name_str)
	if not filter_expr.is_empty() and not matches.is_empty():
		var filtered: Array = []
		for n in matches:
			var expr := Expression.new()
			var err := expr.parse(filter_expr, PackedStringArray(["n"]))
			if err != OK:
				continue
			var ok = expr.execute([n])
			var pass_f := (not expr.has_execute_failed()) and bool(ok)
			if invert:
				pass_f = not pass_f
			if pass_f:
				filtered.append(n)
		matches = filtered
	if max_count > 0 and matches.size() > max_count:
		matches = matches.slice(0, max_count)
	if random_one and matches.size() > 1:
		matches = [matches[randi() % matches.size()]]
	if system:
		system.picked = matches
		system.picked_count = matches.size()
		if matches.size() > 0:
			system.current = matches[0]
			system.current_node = matches[0]
