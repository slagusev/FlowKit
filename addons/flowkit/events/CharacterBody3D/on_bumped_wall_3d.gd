extends FKEvent
func get_description() -> String: return "Fires when CharacterBody3D touches a wall (edge)."
func get_id() -> String: return "on_bumped_wall_3d"
func get_name() -> String: return "On Bumped Wall (3D)"
func get_supported_types() -> Array[String]: return ["CharacterBody3D"]
func is_signal_event() -> bool: return false
func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node is CharacterBody3D: return false
	var body := node as CharacterBody3D
	var key := "fk_was_wall3_" + block_id
	var was: bool = bool(node.get_meta(key, false))
	var now: bool = body.is_on_wall()
	node.set_meta(key, now)
	return now and not was
