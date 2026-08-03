extends RefCounted
class_name FKObjectRules
## Evaluate Object Mode local rules on a node.


static func process_node(node: Node, engine: Node = null) -> void:
	if node == null or not is_instance_valid(node):
		return
	var rules: Array = FKObjectConfig.get_local_rules(node)
	if rules.is_empty():
		return
	var runtime: Dictionary = FKObjectConfig.get_runtime(node)
	var fired: Dictionary = runtime.get("fired", {})
	if not (fired is Dictionary):
		fired = {}
	
	for rule in rules:
		if not (rule is Dictionary):
			continue
		if not bool(rule.get("enabled", true)):
			continue
		var rid := str(rule.get("id", ""))
		if rid.is_empty():
			rid = str(rule.get("when", "")) + "_" + str(rule.get("then", ""))
		var when_id := str(rule.get("when", ""))
		var then_id := str(rule.get("then", ""))
		var params: Dictionary = rule.get("params", {}) if rule.get("params", {}) is Dictionary else {}
		
		var pred := _eval_when(node, when_id)
		if not pred:
			# Re-arm when predicate becomes false again
			fired[rid] = false
			continue
		if bool(fired.get(rid, false)):
			continue
		_run_then(node, then_id, params, engine)
		fired[rid] = true
	
	runtime["fired"] = fired
	FKObjectConfig.set_runtime(node, runtime)


static func _eval_when(node: Node, when_id: String) -> bool:
	match when_id:
		"hp_lte_0":
			var vars: Dictionary = {}
			if node.has_meta("flowkit_variables"):
				vars = node.get_meta("flowkit_variables", {})
			var hp = vars.get("hp", vars.get("n_hp", 1))
			return float(hp) <= 0.0
		"never", "":
			return false
		_:
			return false


static func _run_then(node: Node, then_id: String, params: Dictionary, engine: Node) -> void:
	match then_id:
		"queue_free":
			node.queue_free()
		"print":
			print("[FlowKit ObjectRule] ", params.get("Message", node.name))
		"call_subsheet":
			var sub: String = str(params.get("Name", params.get("name", ""))).strip_edges()
			if sub.is_empty() or engine == null:
				return
			if engine.has_method("run_subsheet"):
				engine.run_subsheet(sub, node.get_tree().current_scene if node.get_tree() else null, {})
		"set_sheet_var":
			var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
			if system and system.has_method("set_sheet_var"):
				system.set_sheet_var(str(params.get("Name", "")), params.get("Value", null))
		_:
			pass
