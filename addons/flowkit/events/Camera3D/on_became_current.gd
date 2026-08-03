extends FKEvent
func get_description() -> String: return "Fires when Camera3D becomes current."
func get_id() -> String: return "on_camera3d_became_current"
func get_name() -> String: return "On Became Current (3D)"
func get_supported_types() -> Array[String]: return ["Camera3D"]
func is_signal_event() -> bool: return false
func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node is Camera3D: return false
	var now: bool = (node as Camera3D).current
	var key := "fk_cam3_cur_" + block_id
	var was: bool = bool(node.get_meta(key, false))
	node.set_meta(key, now)
	return now and not was
