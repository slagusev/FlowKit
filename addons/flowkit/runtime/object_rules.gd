extends RefCounted
class_name FKObjectRules
## Evaluate Object Mode local rules + property binds on a node.


static func process_node(node: Node, engine: Node = null) -> void:
	if node == null or not is_instance_valid(node):
		return
	_apply_property_binds(node)
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
		
		var pred := _eval_when(node, when_id, params)
		var once := bool(rule.get("once", true))
		if not pred:
			if once:
				fired[rid] = false
			continue
		if once and bool(fired.get(rid, false)):
			continue
		_run_then(node, then_id, params, engine)
		if once:
			fired[rid] = true
	
	runtime["fired"] = fired
	FKObjectConfig.set_runtime(node, runtime)


static func _get_vars(node: Node) -> Dictionary:
	if node.has_meta("flowkit_variables"):
		var v = node.get_meta("flowkit_variables", {})
		if v is Dictionary:
			return v
	return {}


static func _eval_when(node: Node, when_id: String, params: Dictionary = {}) -> bool:
	var vars := _get_vars(node)
	match when_id:
		"hp_lte_0":
			var hp = vars.get("hp", vars.get("n_hp", 1))
			return float(hp) <= 0.0
		"var_lte":
			var vn := str(params.get("Var", params.get("Name", "hp")))
			var thr := float(params.get("Value", 0))
			return float(vars.get(vn, 0)) <= thr
		"var_gte":
			var vn2 := str(params.get("Var", params.get("Name", "hp")))
			var thr2 := float(params.get("Value", 0))
			return float(vars.get(vn2, 0)) >= thr2
		"var_eq":
			var vn3 := str(params.get("Var", "flag"))
			return str(vars.get(vn3, "")) == str(params.get("Value", ""))
		"on_ready_once":
			# True only first frame rules run after scene load
			var rt := FKObjectConfig.get_runtime(node)
			return not bool(rt.get("ready_done", false))
		"always":
			return true
		"body_in_group_player":
			return _area_overlaps_group(node, str(params.get("Group", "player")))
		"never", "":
			return false
		_:
			return false


static func _area_overlaps_group(node: Node, group: String) -> bool:
	if not (node is Area2D):
		return false
	var area := node as Area2D
	for b in area.get_overlapping_bodies():
		if b is Node and (b as Node).is_in_group(group):
			return true
	for a in area.get_overlapping_areas():
		if a is Node and (a as Node).is_in_group(group):
			return true
	return false


static func _run_then(node: Node, then_id: String, params: Dictionary, engine: Node) -> void:
	match then_id:
		"queue_free":
			node.queue_free()
		"hide":
			if node is CanvasItem:
				(node as CanvasItem).visible = false
			elif "visible" in node:
				node.set("visible", false)
		"show":
			if node is CanvasItem:
				(node as CanvasItem).visible = true
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
		"add_sheet_var":
			var system2 = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node.get_tree() else null
			if system2 and system2.has_method("set_sheet_var"):
				var nm := str(params.get("Name", "score"))
				var add := float(params.get("Value", params.get("Amount", 1)))
				var cur := 0.0
				if system2.has_method("get_sheet_var"):
					cur = float(system2.get_sheet_var(nm, 0))
				system2.set_sheet_var(nm, cur + add)
		"set_var":
			var vars: Dictionary = _get_vars(node).duplicate(true)
			vars[str(params.get("Name", "flag"))] = params.get("Value", true)
			node.set_meta("flowkit_variables", vars)
		"damage_self":
			var vars2: Dictionary = _get_vars(node).duplicate(true)
			var hp := float(vars2.get("hp", 0))
			hp -= float(params.get("Amount", params.get("Value", 10)))
			vars2["hp"] = hp
			node.set_meta("flowkit_variables", vars2)
		"damage_overlapping_player":
			if not (node is Area2D):
				return
			var amt := float(params.get("Amount", 10))
			var group := str(params.get("Group", "player"))
			for b in (node as Area2D).get_overlapping_bodies():
				if b is Node and (b as Node).is_in_group(group):
					var bv: Dictionary = {}
					if b.has_meta("flowkit_variables"):
						bv = b.get_meta("flowkit_variables", {}).duplicate(true)
					bv["hp"] = float(bv.get("hp", 100)) - amt
					b.set_meta("flowkit_variables", bv)
		_:
			pass
	# Mark on_ready_once consumed
	if then_id != "":
		var rt := FKObjectConfig.get_runtime(node)
		rt["ready_done"] = true
		FKObjectConfig.set_runtime(node, rt)


## Bind instance vars to Range (ProgressBar etc.) via flowkit_object.binds
static func _apply_property_binds(node: Node) -> void:
	var cfg := FKObjectConfig.get_config(node)
	var binds = cfg.get("binds", [])
	if not (binds is Array) or binds.is_empty():
		return
	var vars := _get_vars(node)
	var root := node.get_tree().current_scene if node.get_tree() else null
	for b in binds:
		if not (b is Dictionary):
			continue
		if not bool(b.get("enabled", true)):
			continue
		var vname := str(b.get("var", "hp"))
		var path := str(b.get("path", ""))
		if path.is_empty():
			continue
		var target: Node = null
		if root:
			target = root.get_node_or_null(path)
		if target == null and node.get_parent():
			target = node.get_parent().get_node_or_null(path)
		if target == null:
			target = node.get_node_or_null(path)
		if target == null:
			continue
		var val := float(vars.get(vname, 0))
		if target is Range:
			var r := target as Range
			var max_vname := str(b.get("max_var", "max_hp"))
			if vars.has(max_vname):
				r.max_value = float(vars.get(max_vname, r.max_value))
			r.value = val
		elif target is Label:
			(target as Label).text = str(int(val)) if b.get("as_int", true) else str(val)
