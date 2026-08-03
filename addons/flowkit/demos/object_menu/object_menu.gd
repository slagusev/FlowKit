extends Control
## Main menu for Object Mode demos.

func _ready() -> void:
	var btn := get_node_or_null("Center/VBox/StartButton") as Button
	var space_btn := get_node_or_null("Center/VBox/SpaceButton") as Button
	if btn and not FKObjectConfig.is_pack_enabled(btn, "ui_button"):
		FKObjectRecipes.apply_recipe(btn, "start_to_object_only")
	if space_btn and not FKObjectConfig.is_pack_enabled(space_btn, "ui_button"):
		FKObjectRecipes.apply_recipe(space_btn, "start_to_space")
	FKObjectActivate.refresh_scene(self)
