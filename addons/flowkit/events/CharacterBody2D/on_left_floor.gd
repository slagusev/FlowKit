extends FKEvent

func get_description() -> String:
	return "Fires once when CharacterBody2D leaves the floor."

func get_id() -> String:
	return "on_left_floor"

func get_name() -> String:
	return "On Left Floor"

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func is_signal_event() -> bool:
	return false

func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node is CharacterBody2D:
		return false
	var body := node as CharacterBody2D
	var key := "fk_was_on_floor_left_" + block_id
	var was: bool = bool(node.get_meta(key, true))
	var now: bool = body.is_on_floor()
	node.set_meta(key, now)
	return was and not now
