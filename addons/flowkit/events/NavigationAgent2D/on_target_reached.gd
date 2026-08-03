extends FKEvent

func get_description() -> String:
	return "Fires when NavigationAgent2D reaches its target."

func get_id() -> String:
	return "on_nav_target_reached"

func get_name() -> String:
	return "On Target Reached"

func get_supported_types() -> Array[String]:
	return ["NavigationAgent2D"]

func is_signal_event() -> bool:
	return true

var _callback: Callable

func setup(node: Node, trigger_callback: Callable, block_id: String = "") -> void:
	if not node is NavigationAgent2D:
		return
	_callback = func(): trigger_callback.call()
	if not node.target_reached.is_connected(_callback):
		node.target_reached.connect(_callback)

func teardown(node: Node, block_id: String = "") -> void:
	if is_instance_valid(node) and node is NavigationAgent2D and _callback.is_valid():
		if node.target_reached.is_connected(_callback):
			node.target_reached.disconnect(_callback)
