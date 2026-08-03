extends FKEvent
func get_description() -> String: return "Fires when Camera2D becomes current (poll edge)."
func get_id() -> String: return "on_camera2d_became_current"
func get_name() -> String: return "On Became Current"
func get_supported_types() -> Array[String]: return ["Camera2D"]
func is_signal_event() -> bool: return false
func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node is Camera2D: return false
	var now: bool = (node as Camera2D).is_current()
	var key := "fk_cam_cur_" + block_id
	var was: bool = bool(node.get_meta(key, false))
	node.set_meta(key, now)
	return now and not was
