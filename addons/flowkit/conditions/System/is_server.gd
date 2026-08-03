extends FKCondition

func get_description() -> String:
	return "True if multiplayer peer is server (or offline single-player)."

func get_id() -> String:
	return "is_server"

func get_name() -> String:
	return "Is Server / Authority Host"

func get_supported_types() -> Array[String]:
	return ["System", "Node"]

func get_inputs() -> Array:
	return []

func check(node: Node, _inputs: Dictionary, _block_id: String = "") -> bool:
	if node == null or node.get_tree() == null:
		return true
	var mp := node.get_tree().get_multiplayer()
	if mp == null or mp.multiplayer_peer == null:
		return true  # offline = treat as host
	return mp.is_server()
