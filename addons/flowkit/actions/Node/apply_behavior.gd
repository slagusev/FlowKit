extends FKAction

func get_description() -> String:
	return "Applies a FlowKit behavior to this node at runtime (multi-behavior safe)."

func get_id() -> String:
	return "apply_behavior"

func get_name() -> String:
	return "Apply Behavior"

func get_supported_types() -> Array[String]:
	return ["Node"]

func get_inputs() -> Array[FKActionInput]:
	return [_id_input, _inputs_json]

static var _id_input: FKStringActionInput:
	get:
		return FKStringActionInput.new("BehaviorId", "Behavior provider id (e.g. platformer_movement).")

static var _inputs_json: FKStringActionInput:
	get:
		return FKStringActionInput.new("InputsJson", "Optional JSON object of behavior inputs, e.g. {\"speed\":200}.")

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	var bid: String = str(_id_input.get_val(inputs)).strip_edges()
	if bid.is_empty() or node == null:
		return
	var raw: String = str(_inputs_json.get_val(inputs)).strip_edges()
	var behavior_inputs: Dictionary = {}
	if not raw.is_empty():
		var parsed = JSON.parse_string(raw)
		if parsed is Dictionary:
			behavior_inputs = parsed
	FKBehaviorMeta.add_or_replace(node, bid, behavior_inputs)
	var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node.get_tree() else null
	if engine and engine.registry:
		var scene_root = node.get_tree().current_scene if node.get_tree() else null
		engine.registry.apply_behavior(bid, node, behavior_inputs, scene_root)
		if engine.has_method("track_behavior_node"):
			engine.track_behavior_node(node)
