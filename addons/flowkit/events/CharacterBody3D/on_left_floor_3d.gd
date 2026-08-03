extends FKEvent
func get_description() -> String: return "Fires when CharacterBody3D leaves the floor."
func get_id() -> String: return "on_left_floor_3d"
func get_name() -> String: return "On Left Floor (3D)"
func get_supported_types() -> Array[String]: return ["CharacterBody3D"]
func is_signal_event() -> bool: return false
func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node is CharacterBody3D: return false
	var body := node as CharacterBody3D
	var key := "fk_was_floor3l_" + block_id
	var was: bool = bool(node.get_meta(key, true))
	var now: bool = body.is_on_floor()
	node.set_meta(key, now)
	return was and not now
