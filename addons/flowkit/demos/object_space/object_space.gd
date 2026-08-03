extends Node2D
## Rigid-body ship demo (Object Mode only).

func _ready() -> void:
	var ship := get_node_or_null("Ship")
	var cam := get_node_or_null("Camera2D")
	var label := get_node_or_null("UI/Hint")
	if ship and not FKObjectConfig.is_pack_enabled(ship, "rigid_thrust"):
		FKObjectRecipes.apply_recipe(ship, "spaceship")
	if cam and not FKObjectConfig.is_pack_enabled(cam, "camera_follow"):
		# Follow group player (ship recipe adds ship to player)
		FKObjectRecipes.apply_recipe(cam, "follow_camera")
	if label is Label and not FKObjectConfig.is_pack_enabled(label, "typewriter"):
		(label as Label).text = "Thrust: Up · Turn: Left/Right · Object Mode ship"
		FKObjectRecipes.apply_recipe(label, "dialogue_label")
	FKObjectActivate.refresh_scene(self)
