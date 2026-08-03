extends FKEvent

func get_description() -> String:
	return "Fires when CharacterBody2D is on a wall this physics frame (edge)."

func get_id() -> String:
	return "on_bumped_wall"

func get_name() -> String:
	return "On Bumped Wall"

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D"]

func is_signal_event() -> bool:
	return false

func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node is CharacterBody2D:
		return false
	var body := node as CharacterBody2D
	var key := "fk_was_on_wall_" + block_id
	var was: bool = bool(node.get_meta(key, false))
	var now: bool = body.is_on_wall()
	node.set_meta(key, now)
	return now and not was
