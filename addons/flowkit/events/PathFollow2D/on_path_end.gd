extends FKEvent

func get_description() -> String:
	return "Fires when PathFollow2D progress_ratio reaches 1.0 (edge)."

func get_id() -> String:
	return "on_path_end"

func get_name() -> String:
	return "On Path End"

func get_supported_types() -> Array[String]:
	return ["PathFollow2D"]

func is_signal_event() -> bool:
	return false

func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node is PathFollow2D:
		return false
	var pf := node as PathFollow2D
	var key := "fk_path_end_" + block_id
	var was: bool = bool(node.get_meta(key, false))
	var now: bool = pf.progress_ratio >= 0.999
	node.set_meta(key, now)
	return now and not was
