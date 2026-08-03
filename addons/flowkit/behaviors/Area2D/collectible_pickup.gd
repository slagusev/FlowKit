extends FKBehavior

func get_description() -> String:
	return "On body/area enter: add points to sheet var and optionally free self."

func get_id() -> String:
	return "collectible_pickup"

func get_name() -> String:
	return "Collectible Pickup"

func get_supported_types() -> Array[String]:
	return ["Area2D"]

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "points", "type": "float", "default": 1.0},
		{"name": "score_var", "type": "String", "default": "score"},
		{"name": "player_group", "type": "String", "default": "player"},
		{"name": "destroy_self", "type": "bool", "default": true}
	]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	if not (node is Area2D):
		return
	var area := node as Area2D
	area.monitoring = true
	if node.get_meta("fk_collect_connected", false):
		return
	var on_body := func(body: Node):
		_try_pickup(node, body)
	var on_area := func(other: Area2D):
		_try_pickup(node, other)
	if not area.body_entered.is_connected(on_body):
		area.body_entered.connect(on_body)
	if not area.area_entered.is_connected(on_area):
		area.area_entered.connect(on_area)
	node.set_meta("fk_collect_connected", true)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k):
		node.remove_meta(k)
	# Signal disconnect is hard without stored Callable; leave connected no-op if meta gone

func _try_pickup(area_node: Node, other: Node) -> void:
	if not is_instance_valid(area_node) or area_node.is_queued_for_deletion():
		return
	var inputs: Dictionary = area_node.get_meta("flowkit_behavior_" + get_id(), {})
	if inputs.is_empty():
		return
	var group: String = str(inputs.get("player_group", "player")).strip_edges()
	if not group.is_empty():
		if other == null or not other.is_in_group(group):
			# Also accept if other has no group filter empty
			return
	var points := float(inputs.get("points", 1.0))
	var score_var: String = str(inputs.get("score_var", "score")).strip_edges()
	var system = area_node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if area_node.get_tree() else null
	if system and system.has_method("set_sheet_var") and not score_var.is_empty():
		var cur = 0.0
		if system.has_method("get_sheet_var"):
			cur = float(system.get_sheet_var(score_var, 0))
		system.set_sheet_var(score_var, cur + points)
	# Mirror to instance var points_collected
	var vars: Dictionary = {}
	if area_node.has_meta("flowkit_variables"):
		vars = area_node.get_meta("flowkit_variables", {}).duplicate(true)
	vars["collected"] = true
	area_node.set_meta("flowkit_variables", vars)
	if bool(inputs.get("destroy_self", true)):
		area_node.queue_free()
