extends FKAction

func get_description() -> String:
	return "Picks nodes into system.picked. Filter expr, overlap Area2D, sort, random N, max count."

func get_id() -> String:
	return "pick_nodes"

func get_name() -> String:
	return "Pick Nodes"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return [_group, _class, _filter, _overlap, _sort, _random, _random_n, _invert, _max]

static var _group: FKStringActionInput:
	get:
		return FKStringActionInput.new("Group", "Godot group name (optional).")

static var _class: FKStringActionInput:
	get:
		return FKStringActionInput.new("Class", "Node class name (optional).")

static var _filter: FKStringActionInput:
	get:
		return FKStringActionInput.new("Filter", "Optional Expression with n = candidate (e.g. n.visible).")

static var _overlap: FKStringActionInput:
	get:
		return FKStringActionInput.new("OverlapPath", "Optional NodePath to Area2D/Area3D — keep nodes overlapping it.")

static var _sort: FKStringActionInput:
	get:
		return FKStringActionInput.new("SortBy", "Optional Expression with n = candidate; sort ascending by result.")

static var _random: FKBoolActionInput:
	get:
		return FKBoolActionInput.new("RandomOne", "If true, keep only one random match.", false)

static var _random_n: FKIntActionInput:
	get:
		return FKIntActionInput.new("RandomCount", "If >0, shuffle and keep up to N random (overrides RandomOne).", 0)

static var _invert: FKBoolActionInput:
	get:
		return FKBoolActionInput.new("InvertFilter", "If true, keep nodes that FAIL the filter.", false)

static var _max: FKIntActionInput:
	get:
		return FKIntActionInput.new("MaxCount", "Max nodes to keep after sort (0 = unlimited).", 0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var group_name: String = str(_group.get_val(inputs)).strip_edges()
	var class_name_str: String = str(_class.get_val(inputs)).strip_edges()
	var filter_expr: String = str(_filter.get_val(inputs)).strip_edges()
	var overlap_path: String = str(_overlap.get_val(inputs)).strip_edges()
	var sort_expr: String = str(_sort.get_val(inputs)).strip_edges()
	var random_one: bool = bool(_random.get_val(inputs))
	var random_n: int = int(_random_n.get_val(inputs))
	var invert: bool = bool(_invert.get_val(inputs))
	var max_count: int = int(_max.get_val(inputs))
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node and node.get_tree() else null
	var root = node.get_tree().current_scene if node and node.get_tree() else null
	var matches: Array = []
	if engine and engine.has_method("find_nodes_for_each") and root:
		matches = engine.find_nodes_for_each(root, group_name, class_name_str)

	# Overlap filter (Area2D / Area3D)
	if not overlap_path.is_empty() and root:
		var area_n = root.get_node_or_null(overlap_path)
		if area_n == null and node.get_tree():
			area_n = node.get_tree().root.get_node_or_null(overlap_path)
		if area_n is Area2D:
			var keep2: Array = []
			var a2 := area_n as Area2D
			var bodies: Array = a2.get_overlapping_bodies()
			var areas: Array = a2.get_overlapping_areas()
			for n in matches:
				if n in bodies or n in areas:
					keep2.append(n)
			matches = keep2
		elif area_n is Area3D:
			var keep3: Array = []
			var a3 := area_n as Area3D
			var bodies3: Array = a3.get_overlapping_bodies()
			var areas3: Array = a3.get_overlapping_areas()
			for n3 in matches:
				if n3 in bodies3 or n3 in areas3:
					keep3.append(n3)
			matches = keep3

	if not filter_expr.is_empty() and not matches.is_empty():
		var filtered: Array = []
		for n in matches:
			var pass_f := _eval_bool_on_n(filter_expr, n, root, system)
			if invert:
				pass_f = not pass_f
			if pass_f:
				filtered.append(n)
		matches = filtered

	# Sort by expression
	if not sort_expr.is_empty() and matches.size() > 1:
		var keyed: Array = []
		for n in matches:
			var key = _eval_variant_on_n(sort_expr, n, root, system)
			keyed.append({"n": n, "k": key})
		keyed.sort_custom(func(a, b):
			return str(a["k"]) < str(b["k"])
		)
		matches = []
		for e in keyed:
			matches.append(e["n"])

	if random_n > 0 and matches.size() > random_n:
		matches.shuffle()
		matches = matches.slice(0, random_n)
	elif random_one and matches.size() > 1:
		matches = [matches[randi() % matches.size()]]
	if max_count > 0 and matches.size() > max_count:
		matches = matches.slice(0, max_count)

	if system:
		system.picked = matches
		system.picked_count = matches.size()
		if matches.size() > 0:
			system.current = matches[0]
			system.current_node = matches[0]
		if system.has_method("debug_push"):
			system.debug_push("pick", "picked=%d group=%s class=%s" % [matches.size(), group_name, class_name_str])


static func _eval_bool_on_n(expr_str: String, n: Node, root: Node, system: Node) -> bool:
	var v = _eval_variant_on_n(expr_str, n, root, system)
	return bool(v)


static func _eval_variant_on_n(expr_str: String, n: Node, root: Node, system: Node) -> Variant:
	# Prefer FKExpressionEvaluator if available for n_ / s_
	if ClassDB.class_exists("FKExpressionEvaluator") or true:
		var r = FKExpressionEvaluator.evaluate(expr_str, n, root, n)
		if r != null:
			return r
	var expr := Expression.new()
	var err := expr.parse(expr_str, PackedStringArray(["n", "current"]))
	if err != OK:
		if system and system.has_method("debug_push"):
			system.debug_push("expr_error", "pick filter parse: " + expr_str)
		return false
	var ok = expr.execute([n, n])
	if expr.has_execute_failed():
		if system and system.has_method("debug_push"):
			system.debug_push("expr_error", "pick filter fail: " + expr_str)
		return false
	return ok
