extends FKEvent
func get_description() -> String: return "Fires when CharacterBody2D velocity drops below threshold."
func get_id() -> String: return "on_stopped_moving"
func get_name() -> String: return "On Stopped Moving"
func get_supported_types() -> Array[String]: return ["CharacterBody2D"]
func get_inputs() -> Array: return [{"name": "threshold", "type": "float", "default": 5.0}]
func is_signal_event() -> bool: return false
func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node is CharacterBody2D: return false
	var thr: float = float(inputs.get("threshold", 5.0))
	var moving: bool = (node as CharacterBody2D).velocity.length() > thr
	var key := "fk_was_moving_stop_" + block_id
	var was: bool = bool(node.get_meta(key, true))
	node.set_meta(key, moving)
	return was and not moving
