extends FKEvent

func get_description() -> String:
	return "Poll: fires when a Tween stored on the node meta flowkit_active_tween finishes."

func get_id() -> String:
	return "on_tween_finished"

func get_name() -> String:
	return "On Tween Finished"

func get_supported_types() -> Array[String]:
	return ["Node"]

func is_signal_event() -> bool:
	return false

func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if node == null or not node.has_meta("flowkit_active_tween"):
		return false
	var tw = node.get_meta("flowkit_active_tween")
	if tw == null or not is_instance_valid(tw):
		node.remove_meta("flowkit_active_tween")
		return true
	if tw is Tween and not (tw as Tween).is_running():
		node.remove_meta("flowkit_active_tween")
		return true
	return false
