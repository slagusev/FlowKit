extends Control
## Main menu for Object Mode demos. Start button loads object_only scene.

func _ready() -> void:
	var btn := get_node_or_null("Center/VBox/StartButton") as Button
	if btn and not FKObjectConfig.is_pack_enabled(btn, "ui_button"):
		FKObjectRecipes.apply_recipe(btn, "start_to_object_only")
	# Re-scan so ui_button_action connects at runtime
	var engine = get_node_or_null("/root/FlowKit")
	if engine and engine.has_method("_scan_and_activate_behaviors"):
		engine._scan_and_activate_behaviors(self)
	if engine and engine.has_method("_scan_object_nodes"):
		engine._scan_object_nodes(self)
