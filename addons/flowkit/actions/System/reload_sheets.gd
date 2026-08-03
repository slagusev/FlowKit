extends FKAction

func get_description() -> String:
	return "Hot-reload event sheets for the current scene from disk (runtime)."

func get_id() -> String:
	return "reload_sheets"

func get_name() -> String:
	return "Reload Sheets (hot)"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array[FKActionInput]:
	return []

func execute(node: Node, _inputs: Dictionary, _block_id: String = "") -> void:
	var engine = null
	if node and node.get_tree():
		engine = node.get_tree().root.get_node_or_null("/root/FlowKit")
	if engine == null and Engine.get_main_loop() is SceneTree:
		engine = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("/root/FlowKit")
	if engine and engine.has_method("hot_reload_sheets"):
		engine.hot_reload_sheets()
	elif engine and engine.has_method("_load_sheets_for_scene"):
		var scene = node.get_tree().current_scene if node.get_tree() else null
		if scene:
			engine._teardown_all_signal_events() if engine.has_method("_teardown_all_signal_events") else null
			engine._load_sheets_for_scene(scene)
			if engine.has_method("_create_block_providers"):
				for entry in engine.active_sheets:
					engine._create_block_providers(entry)
			if engine.has_method("_setup_signal_events"):
				for entry2 in engine.active_sheets:
					engine._setup_signal_events(entry2)
	var system = node.get_tree().root.get_node_or_null("/root/FlowKitSystem") if node and node.get_tree() else null
	if system and system.has_method("debug_push"):
		system.debug_push("reload", "sheets hot-reloaded")
	print("[FlowKit] Sheets hot-reloaded")
