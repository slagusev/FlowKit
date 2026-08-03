extends FKAction

func get_description() -> String:
	return "Removes a FlowKit behavior from this node by id (or all if id empty)."

func get_id() -> String:
	return "remove_behavior"

func get_name() -> String:
	return "Remove Behavior"

func get_supported_types() -> Array[String]:
	return ["Node"]

func get_inputs() -> Array[FKActionInput]:
	return [_id_input]

static var _id_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("BehaviorId", "Behavior id to remove. Leave empty to remove all.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node == null:
		return
	var bid: String = str(_id_input.get_val(inputs)).strip_edges()
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node.get_tree() else null
	if bid.is_empty():
		var all_ids: Array = []
		for b in FKBehaviorMeta.get_behaviors(node):
			all_ids.append(str(b.get("id", "")))
		if engine and engine.registry:
			for id in all_ids:
				if not str(id).is_empty():
					engine.registry.remove_behavior(str(id), node)
		FKBehaviorMeta.clear_all(node)
		return
	if engine and engine.registry:
		engine.registry.remove_behavior(bid, node)
	FKBehaviorMeta.remove_id(node, bid)
