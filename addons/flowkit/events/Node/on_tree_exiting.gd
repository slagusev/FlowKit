extends FKEvent

func get_description() -> String:
	return "Fires when the node is about to leave the scene tree."

func get_id() -> String:
	return "on_tree_exiting"

func get_name() -> String:
	return "On Tree Exiting"

func get_supported_types() -> Array[String]:
	return ["Node"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if node == null:
		return
	_callback = func(): trigger_callback.call()
	if not node.tree_exiting.is_connected(_callback):
		node.tree_exiting.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and _callback.is_valid():
		if node.tree_exiting.is_connected(_callback):
			node.tree_exiting.disconnect(_callback)
