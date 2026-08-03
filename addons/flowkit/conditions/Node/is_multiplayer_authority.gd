extends FKCondition

func get_description() -> String:
	return "True if this node is multiplayer authority (or offline)."

func get_id() -> String:
	return "is_multiplayer_authority"

func get_name() -> String:
	return "Is Multiplayer Authority"

func get_supported_types() -> Array[String]:
	return ["Node"]

func get_inputs() -> Array:
	return []

func check(node: Node, _inputs: Dictionary, _block_id: String = "") -> bool:
	if node == null:
		return false
	if node.get_tree() == null:
		return true
	var mp := node.get_tree().get_multiplayer()
	if mp == null or mp.multiplayer_peer == null:
		return true
	return node.is_multiplayer_authority()
