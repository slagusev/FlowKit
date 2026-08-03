extends FKAction

func get_description() -> String:
	return "Emit a named object event on FlowKitSystem (sheets listen with On Object Event)."

func get_id() -> String:
	return "emit_object_event"

func get_name() -> String:
	return "Emit Object Event"

func get_supported_types() -> Array[String]:
	return ["Node", "System"]

func get_inputs() -> Array:
	return [
		FKStringActionInput.new("Event", "Event name (e.g. died, collected, hit)"),
		FKStringActionInput.new("PayloadJson", "Optional JSON object for payload (default {})"),
	]

func execute(node: Node, inputs: Dictionary, _block_id: String = "") -> void:
	var en := str(inputs.get("Event", inputs.get("Name", ""))).strip_edges()
	if en.is_empty():
		return
	var payload: Dictionary = {}
	var raw := str(inputs.get("PayloadJson", "")).strip_edges()
	if not raw.is_empty():
		var parsed = JSON.parse_string(raw)
		if parsed is Dictionary:
			payload = parsed
	var system = null
	if node and is_instance_valid(node) and node.get_tree():
		system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem")
	if system == null and Engine.get_main_loop() is SceneTree:
		system = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("/root/FlowKitSystem")
	if system and system.has_method("emit_object_event"):
		var src: Node = node if node != system else null
		system.emit_object_event(en, src, payload)
