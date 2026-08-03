extends FKBehavior

func get_description() -> String:
	return "On button press: change scene and/or call subsheet / print."

func get_id() -> String:
	return "ui_button_action"

func get_name() -> String:
	return "UI Button Action"

func get_supported_types() -> Array[String]:
	return ["BaseButton", "Button"]

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "scene_path", "type": "String", "default": ""},
		{"name": "subsheet", "type": "String", "default": ""},
		{"name": "message", "type": "String", "default": ""}
	]

func apply(node: Node, inputs: Dictionary) -> void:
	node.set_meta("flowkit_behavior_" + get_id(), inputs)
	if not (node is BaseButton):
		return
	if node.get_meta("fk_btn_action_connected", false):
		return
	var btn := node as BaseButton
	var on_press := func():
		_do_action(node)
	if not btn.pressed.is_connected(on_press):
		btn.pressed.connect(on_press)
	node.set_meta("fk_btn_action_connected", true)

func remove(node: Node) -> void:
	var k := "flowkit_behavior_" + get_id()
	if node.has_meta(k):
		node.remove_meta(k)

func _do_action(node: Node) -> void:
	if not is_instance_valid(node):
		return
	var inputs: Dictionary = node.get_meta("flowkit_behavior_" + get_id(), {})
	var msg := str(inputs.get("message", "")).strip_edges()
	if not msg.is_empty():
		print("[FlowKit UI] ", msg)
	var sub := str(inputs.get("subsheet", "")).strip_edges()
	if not sub.is_empty():
		var engine = node.get_tree().root.get_node_or_null("/root/FlowKit") if node.get_tree() else null
		if engine and engine.has_method("run_subsheet"):
			engine.run_subsheet(sub, node.get_tree().current_scene if node.get_tree() else null, {})
	var scene_path := str(inputs.get("scene_path", "")).strip_edges()
	if not scene_path.is_empty() and ResourceLoader.exists(scene_path):
		node.get_tree().change_scene_to_file(scene_path)
